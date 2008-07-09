From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] IPVS: Add genetlink interface implementation
Date: Wed, 09 Jul 2008 18:43:40 +0200
Message-ID: <4874EABC.4000301@trash.net>
References: <1215616317-11386-1-git-send-email-juliusv@google.com> <1215616317-11386-3-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1215616317-11386-3-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, vbusam@google.com, horms@verge.net.au, davem@davemloft.net

Julius Volz wrote:
> Add the implementation of the new Generic Netlink interface to IPVS and keep
> the old set/getsockopt interface for userspace backwards compatibility.
> 
> Signed-off-by: Julius Volz <juliusv@google.com>

Just a few quick comments, will try to do a full review later:

> + * Policy used for commands that operate on service, destination
> + * or daemon entries
> + */
> +static struct nla_policy ip_vs_entries_policy[IPVS_ENTRY_ATTR_MAX + 1]
> +__read_mostly = {

These can all be const (and have the __read_mostly annotation removed).

> +static int ip_vs_genl_fill_stats(struct sk_buff *skb, int container_type,
> +				 struct ip_vs_stats *stats)
> +{
> +	struct nlattr *nl_stats = nla_nest_start(skb, container_type);
> +	if (!nl_stats)
> +		goto nla_put_failure;

Unbalanced locking.

> +
> +	spin_lock_bh(&stats->lock);
> +
> +	NLA_PUT_U32(skb, IPVS_STATS_ATTR_CONNS, stats->conns);
> +	NLA_PUT_U32(skb, IPVS_STATS_ATTR_INPKTS, stats->inpkts);
> +	NLA_PUT_U32(skb, IPVS_STATS_ATTR_OUTPKTS, stats->outpkts);
> +	NLA_PUT_U64(skb, IPVS_STATS_ATTR_INBYTES, stats->inbytes);
> +	NLA_PUT_U64(skb, IPVS_STATS_ATTR_OUTBYTES, stats->outbytes);
> +	NLA_PUT_U32(skb, IPVS_STATS_ATTR_CPS, stats->cps);
> +	NLA_PUT_U32(skb, IPVS_STATS_ATTR_INPPS, stats->inpps);
> +	NLA_PUT_U32(skb, IPVS_STATS_ATTR_OUTPPS, stats->outpps);
> +	NLA_PUT_U32(skb, IPVS_STATS_ATTR_INBPS, stats->inbps);
> +	NLA_PUT_U32(skb, IPVS_STATS_ATTR_OUTBPS, stats->outbps);
> +
> +	spin_unlock_bh(&stats->lock);
> +
> +	nla_nest_end(skb, nl_stats);
> +
> +	return 0;
> +
> +nla_put_failure:
> +	spin_unlock_bh(&stats->lock);
> +
> +	nla_nest_cancel(skb, nl_stats);
> +	return -EMSGSIZE;
> +}
> +
> +static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
> +{
> +	struct ip_vs_service *svc;
> +	struct ip_vs_service_user usvc;
> +	struct ip_vs_dest_user udest;
> +	int ret = 0, cmd, flags;
> +	int need_full_svc = 0, need_full_dest = 0;
> +
> +	cmd = info->genlhdr->cmd;
> +	flags = info->nlhdr->nlmsg_flags;
> +
> +	/* increase the module use count */
> +	ip_vs_use_count_inc();

This looks fishy - the reference probably must be taken by
genetlink before calling the command handler.

> +int ip_vs_genl_register(void)
> +{
> +	int ret, i;
> +
> +	ret = genl_register_family(&ip_vs_genl_family);
> +	if (ret)
> +		return ret;
> +
> +	for (i = 0; i < ARRAY_SIZE(ip_vs_genl_ops); i++) {
> +		ret = genl_register_ops(&ip_vs_genl_family, &ip_vs_genl_ops[i]);
> +		if (ret)
> +			goto err_out;
> +	}
> +	return 0;
> +
> +err_out:
> +	genl_unregister_family(&ip_vs_genl_family);
> +	return ret;
> +}
> +
> +void ip_vs_genl_unregister(void)
> +{
> +	genl_unregister_family(&ip_vs_genl_family);

Doesn't it also has to unregister the ops?
