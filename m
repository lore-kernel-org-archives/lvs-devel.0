From: "wanghai (M)" <wanghai38@huawei.com>
Subject: Re: [PATCH net] ipvs: fix possible memory leak in
 ip_vs_control_net_init
Date: Fri, 20 Nov 2020 16:29:52 +0800
Message-ID: <0574c34c-60a8-8d8d-38b1-962898e55801@huawei.com>
References: <20201119104102.67427-1-wanghai38@huawei.com>
 <f111e78-b9c1-453-c6e5-a063e62cd83b@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f111e78-b9c1-453-c6e5-a063e62cd83b@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"; format="flowed"
To: Julian Anastasov <ja@ssi.bg>
Cc: horms@verge.net.au, pablo@netfilter.org, kadlec@netfilter.org, fw@strlen.de, davem@davemloft.net, kuba@kernel.org, christian@brauner.io, hans.schillstrom@ericsson.com, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org


=D4=DA 2020/11/20 2:22, Julian Anastasov =D0=B4=B5=C0:
> 	Hello,
>
> On Thu, 19 Nov 2020, Wang Hai wrote:
>
>> kmemleak report a memory leak as follows:
>>
>> BUG: memory leak
>> unreferenced object 0xffff8880759ea000 (size 256):
>> comm "syz-executor.3", pid 6484, jiffies 4297476946 (age 48.546s)
>> hex dump (first 32 bytes):
>> 00 00 00 00 01 00 00 00 08 a0 9e 75 80 88 ff ff ...........u....
[...]
>> Reported-by: Hulk Robot <hulkci@huawei.com>
>> Signed-off-by: Wang Hai <wanghai38@huawei.com>
>> ---
>>   net/netfilter/ipvs/ip_vs_ctl.c | 3 +++
>>   1 file changed, 3 insertions(+)
>>
>> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_c=
tl.c
>> index e279ded4e306..d99bb89e7c25 100644
>> --- a/net/netfilter/ipvs/ip_vs_ctl.c
>> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
>> @@ -4180,6 +4180,9 @@ int __net_init ip_vs_control_net_init(struct netns=
_ipvs *ipvs)
>>   	return 0;
> 	May be we should add some #ifdef CONFIG_PROC_FS because
> proc_create_net* return NULL when PROC is not used. For example:
>
> #ifdef CONFIG_PROC_FS
> 	if (!proc_create_net...
> 		goto err_vs;
> 	if (!proc_create_net...
> 		goto err_stats;
> 	...
> #endif
> 	...
>
>>   err:
> #ifdef CONFIG_PROC_FS
>> +	remove_proc_entry("ip_vs_stats_percpu", ipvs->net->proc_net);
> err_percpu:
>> +	remove_proc_entry("ip_vs_stats", ipvs->net->proc_net);
> err_stats:
>> +	remove_proc_entry("ip_vs", ipvs->net->proc_net);
> err_vs:
> #endif
>
>>   	free_percpu(ipvs->tot_stats.cpustats);
>>   	return -ENOMEM;
>>   }
>> --=20
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
>
> .

Thanks for your advice, I just sent v2

=A1=B0[PATCH net v2] ipvs: fix possible memory leak in ip_vs_control_net_in=
it=A1=B1

>
