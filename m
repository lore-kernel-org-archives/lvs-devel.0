From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= 
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2/2] IPVS: Add genetlink interface implementation
Date: Thu, 10 Jul 2008 00:17:48 +0900 (JST)
Message-ID: <20080710.001748.72390839.yoshfuji@linux-ipv6.org>
References: <1215616317-11386-1-git-send-email-juliusv@google.com>
	<1215616317-11386-3-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1215616317-11386-3-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: juliusv@google.com
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, vbusam@google.com, horms@verge.net.au, kaber@trash.net, davem@davemloft.net, yoshfuji@linux-ipv6.org

In article <1215616317-11386-3-git-send-email-juliusv@google.com> (at Wed,  9 Jul 2008 17:11:57 +0200), Julius Volz <juliusv@google.com> says:

:
> +static struct genl_ops ip_vs_genl_ops[] __read_mostly = {
> +	/* SET commands */
> +	{
> +		.cmd	= IPVS_CMD_ADD_SERVICE,
> +		.flags	= GENL_ADMIN_PERM,
> +		.policy	= ip_vs_entries_policy,
> +		.doit	= ip_vs_genl_set_cmd

please add ",".

--yoshfuji
