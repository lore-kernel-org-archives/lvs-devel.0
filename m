From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/2] IPVS: Add genetlink interface implementation
Date: Thu, 10 Jul 2008 13:36:49 +0200
Message-ID: <20080710113649.GS20815@postel.suug.ch>
References: <1215616317-11386-1-git-send-email-juliusv@google.com> <1215616317-11386-3-git-send-email-juliusv@google.com> <4874EABC.4000301@trash.net> <20080710112017.GA26952@google.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080710112017.GA26952@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, vbusam@google.com, horms@verge.net.au, davem@davemloft.net

* Julius Volz <juliusv@google.com> 2008-07-10 13:20
> +/* IPVS genetlink family */
> +static struct genl_family ip_vs_genl_family = {
> +	.id		= GENL_ID_GENERATE,
> +	.hdrsize	= 0,
> +	.name		= IPVS_GENL_NAME,
> +	.version	= IPVS_GENL_VERSION,
> +	.maxattr	= IPVS_CMD_MAX

It's not a bug but looks like a typo, maxattr should
specify the number of first level attributes.

> +static int ip_vs_genl_dump_service(struct sk_buff *skb, struct ip_vs_service *svc,
> +				   struct netlink_callback *cb)
> +{
> +	void *hdr;
> +
> +	hdr = genlmsg_put(skb, NETLINK_CB(cb->skb).pid, cb->nlh->nlmsg_seq,
> +			  &ip_vs_genl_family, NLM_F_MULTI,
> +			  IPVS_CMD_GET_SERVICES);

Typically, netlink code follows the following semantics WRT to
commands/message types:
-> GET_SERVICE (NLM_F_DUMP)
<- NEW_SERVICE
<- NEW_SERVICE
<- NEW_SERVICE

If you are ever going to send notifications, you can use the very same
NEW_SERVICE and userspace can use the same parsing functions.

> +static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
> +{
> +	struct sk_buff *msg;
> +	void *reply;
> +	int ret, cmd;
> +
> +	mutex_lock(&__ip_vs_mutex);
> +
> +	cmd = info->genlhdr->cmd;
> +
> +	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);

This should be nlmsg_new(NLMSG_DEFAULT_SIZE, ...) , NLMSG_GOODSIZE is for use
with skb_alloc().
