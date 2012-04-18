From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re[3]: [PATCH 2/2] IPVS: make failure of netns init more 
	stable
Date: Thu, 19 Apr 2012 00:33:11 +0200 (CEST)
Message-ID: <3r6npeu.845e0d8f300f1e0189de32ae08f06900@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: "horms@verge.net.au" <horms@verge.net.au>, Hans Schillstrom <hans.schillstrom@ericsson.com>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>

Hello,
>
>On Wed, 18 Apr 2012, Hans Schillstrom wrote:
>
>> >trigger load error. When I generate ENOMEM on IPVS core init
>> >for such case I get ENOENT from register_ip_vs_app when
>> >patch 1 and 2 for apps are applied, i.e. net->ipvs is NULL.
>> >You can check it with NF_CONNTRACK=y, IP_VS=y and
>> >IP_VS_FTP=m. You only need to trigger ENOMEM in __ip_vs_init.
>> 
>> 
>> I did test this with 4 netns loaded and modprobe ip_vs_ftp
>> In the 4:th netns  (ipvs->gen >= 4) fire a -ENOMEM 
>> The result was as expected, ip_vs_ftp was not loaded.
>> 
>> All patches below was loaded. (included the ipvs NULL check)
>> 
>> Just for "fun" I also added a printk in the ipvs NULL check
>> but I can't trigger it. 
>
>	I trigger it in this way (ip_vs in kernel, ip_vs_ftp
>as module):
>
>        if (1 || ip_vs_app_net_init(net) < 0)
>                goto app_fail;
>
>	This causes ip_vs core to fail. I use NET_NS=n.

Thanks, It's a really odd case when you don't have enough memory to start the kernel
I think it's cured now, it doesn't trigger any dumps now.

Tested with and without CONFIG_NET_NS

>
>> Simon:
>>  do you have any possibility to test it or give me a hint how to do ?
>> (Just to make sure that the patches below will be sufficient)
>> 
>> >
>> >> With proper fault handling i.e. all ways returning fault codes to the netns init,
>> >> there is no need for checking for  "if (!net->ipvs)" or any other action.
>> >
>> >	Probably but one check on load does not hurt much.
>> 
>> I think I have tested all of above now and my conclusion is that we need the following patches
>> which also was applied when the tests was run.
>> (with a small reservation that I might have missed some..)
>> 
>> [PATCH v3 1/2] netfilter: ipvs: Verify that IP_VS protocol has been registered, Sasha Levin
>> [PATCH v3 2/2] netfilter: ipvs: use GFP_KERNEL allocation where possible, Sasha Levin
>> 
>> [PATCH 0/6] Convert some GFP_ATOMIC allocations, Julian Anastasov
>> [PATCH 1/6] ipvs: timeout tables do not need GFP_ATOMIC allocation, Julian Anastasov
>> [PATCH 2/6] ipvs: SH scheduler does not need GFP_ATOMIC allocation, Julian Anastasov
>> [PATCH 5/6] ipvs: LBLCR scheduler does not need GFP_ATOMIC allocation on init, Julian Anastasov
>> [PATCH 6/6] ipvs: WRR scheduler does not need GFP_ATOMIC allocation, Julian Anastasov
>> [PATCH 3/6] ipvs: DH scheduler does not need GFP_ATOMIC allocation, Julian Anastasov
>> [PATCH 4/6] ipvs: LBLC scheduler does not need GFP_ATOMIC allocation on init, Julian Anastasov
>> 
>> [PATCH] ipvs: fix crash in ip_vs_control_net_cleanup on unload, Julian Anastasov
>> 
>> [PATCH 1/2] ipvs: reset ipvs pointer in netns, Julian Anastasov
>> [PATCH 1/2] IPVS: take care of return value from protocol init_netns, Hans Schillstrom
>> 
>> To be safe,  add this to  [PATCH 1/2] ipvs: reset ipvs pointer in netns or make a new patch
>
>	The ip_vs_ftp part is fixed by:
>"[PATCH 2/2] ipvs: fix app registration in netns". So, this check
>for ip_vs_ftp is not needed anymore:

Well, I don't think "[PATCH 2/2] ipvs: fix app registration in netns" is needed if the null check is there.
I have only used the NULL check (without ERR_PTR()  :-)  not the entire patch in my tests.

If you think it's needed it is OK for me.

>
>> diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
>> index 538d74e..c757359 100644
>> --- a/net/netfilter/ipvs/ip_vs_ftp.c
>> +++ b/net/netfilter/ipvs/ip_vs_ftp.c
>> @@ -439,6 +439,9 @@ static int __net_init __ip_vs_ftp_init(struct net *net)
>>         struct ip_vs_app *app;
>>         struct netns_ipvs *ipvs = net_ipvs(net);
>>  
>> +       if (!ipvs)
>> +               return ERR_PTR(-ENOENT);
>> +
>>         app = kmemdup(&ip_vs_ftp, sizeof(struct ip_vs_app), GFP_KERNEL);
>>         if (!app)
>>                 return -ENOMEM;
>> 
>> diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
>> index 74c7278..1d74996 100644
>> --- a/net/netfilter/ipvs/ip_vs_lblc.c
>> +++ b/net/netfilter/ipvs/ip_vs_lblc.c
>> @@ -549,6 +549,9 @@ static int __net_init __ip_vs_lblc_init(struct net *net)
>>  {
>>         struct netns_ipvs *ipvs = net_ipvs(net);
>>  
>> +       if (!ipvs)
>> +               return ERR_PTR(-ENOENT);
>
>	You can post additional patches for lblc and lblcr but
>use 'return -ENOENT;', ERR_PTR is not appropriate here, it
>is for pointers.

Oops, cut & paste

>
>> +
>>         if (!net_eq(net, &init_net)) {
>>                 ipvs->lblc_ctl_table = kmemdup(vs_vars_table,
>>                                                 sizeof(vs_vars_table),
>> diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
>> index 8620c68..c328ee0 100644
>> --- a/net/netfilter/ipvs/ip_vs_lblcr.c
>> +++ b/net/netfilter/ipvs/ip_vs_lblcr.c
>> @@ -743,6 +743,9 @@ static int __net_init __ip_vs_lblcr_init(struct net *net)
>>  {
>>         struct netns_ipvs *ipvs = net_ipvs(net);
>>  
>> +       if (!ipvs)
>> +               return ERR_PTR(-ENOENT);
>> +
>>         if (!net_eq(net, &init_net)) {
>>                 ipvs->lblcr_ctl_table = kmemdup(vs_vars_table,
>>                                                 sizeof(vs_vars_table),
>
>Regards
>
>--
>Julian Anastasov <ja@ssi.bg>


--
Regards 
Hans Schillstrom <hans@schillstrom.com>



