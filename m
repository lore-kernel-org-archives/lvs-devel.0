From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] net: netfilters: Remove extra parenthesis
Date: Mon, 27 Mar 2017 14:02:09 +0200
Message-ID: <20170327120209.GA13666@salvia>
References: <20170325135313.GA10861@arushi-HP-Pavilion-Notebook>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170325135313.GA10861@arushi-HP-Pavilion-Notebook>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arushi Singhal <arushisinghal19971997@gmail.com>
Cc: wensong@linux-vs.org, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, outreachy-kernel@googlegroups.com

Hi Arushi,

On Sat, Mar 25, 2017 at 07:23:13PM +0530, Arushi Singhal wrote:
> diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
> index 6806b5e73567..aa344c5868c5 100644
> --- a/net/netfilter/nf_conntrack_netlink.c
> +++ b/net/netfilter/nf_conntrack_netlink.c
> @@ -467,7 +467,7 @@ ctnetlink_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
>  	struct nlattr *nest_parms;
>  	unsigned int flags = portid ? NLM_F_MULTI : 0, event;
>  
> -	event = (NFNL_SUBSYS_CTNETLINK << 8 | IPCTNL_MSG_CT_NEW);
> +	event = NFNL_SUBSYS_CTNETLINK << 8 | IPCTNL_MSG_CT_NEW;

Could you send us a unfront patch to add something like:

static inline u16 nfnl_msg_type(u8 subsys, u8 msg_type)
{
        return subsys << 8 | msg_type;
}

I would suggest you place this in include/linux/netfilter/nfnetlink.h

Then, use it here.

>  	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
>  	if (nlh == NULL)
>  		goto nlmsg_failure;
> @@ -1983,7 +1983,7 @@ ctnetlink_ct_stat_cpu_fill_info(struct sk_buff *skb, u32 portid, u32 seq,
>  	struct nfgenmsg *nfmsg;
>  	unsigned int flags = portid ? NLM_F_MULTI : 0, event;
>  
> -	event = (NFNL_SUBSYS_CTNETLINK << 8 | IPCTNL_MSG_CT_GET_STATS_CPU);
> +	event = NFNL_SUBSYS_CTNETLINK << 8 | IPCTNL_MSG_CT_GET_STATS_CPU;

... And here too.

>  	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
>  	if (nlh == NULL)
>  		goto nlmsg_failure;
> @@ -2066,7 +2066,7 @@ ctnetlink_stat_ct_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
>  	unsigned int flags = portid ? NLM_F_MULTI : 0, event;
>  	unsigned int nr_conntracks = atomic_read(&net->ct.count);
>  
> -	event = (NFNL_SUBSYS_CTNETLINK << 8 | IPCTNL_MSG_CT_GET_STATS);
> +	event = NFNL_SUBSYS_CTNETLINK << 8 | IPCTNL_MSG_CT_GET_STATS;

And so on. Look for more spots where we can replace this opencoded
thing.

I guess there are more spots in all of the net/netfilter/ netlink
subsystems.

Once that patch gets in, you can follow up with this parens cleanup.

Thanks!

P.S: Cc'ing netfilter-devel@vger.kernel.org (and
lvs-devel@vger.kernel.org if you touch 'ipvs' bits) should be fine. No
need to Cc all those many lists, better to narrow down you target.
