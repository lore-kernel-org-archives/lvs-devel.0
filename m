From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCHv2 2/2] IPVS: Add genetlink interface implementation
Date: Fri, 25 Jul 2008 01:58:33 +0200
Message-ID: <20080724235833.GD20815@postel.suug.ch>
References: <1216645375-20410-1-git-send-email-juliusv@google.com> <1216645375-20410-3-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1216645375-20410-3-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, horms@verge.net.au, kaber@trash.net, davem@davemloft.net, vbusam@google.com

* Julius Volz <juliusv@google.com> 2008-07-21 15:02
> +static int ip_vs_genl_parse_dest(struct ip_vs_dest_user *udest,
> +				 struct nlattr *nla, int full_entry)
> +{
> +	struct nlattr *attrs[IPVS_SVC_ATTR_MAX + 1];
> +	struct nlattr *nla_addr, *nla_port;
> +
> +	/* Parse mandatory identifying destination fields first */
> +	if (nla == NULL ||
> +	    nla_parse_nested(attrs, IPVS_DEST_ATTR_MAX, nla, ip_vs_dest_policy))

Small typo here, attrs[] is defined with a length of IPVS_SVC_ATTR_MAX+1
while IPVS_DEST_ATTR_MAX is passed to to nla_parse_nested.

