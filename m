From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch] IPVS: ip_vs_dbg_callid() is only needed for debugging
Date: Wed, 13 Oct 2010 21:23:22 +0200
Message-ID: <4CB6072A.4000801@trash.net>
References: <20101007012325.GA32392@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20101007012325.GA32392@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

Am 07.10.2010 03:23, schrieb Simon Horman:
> ip_vs_dbg_callid() and IP_VS_DEBUG_CALLID() are only needed
> it CONFIG_IP_VS_DEBUG is defined.
> 
> This resolves the following build warning when CONFIG_IP_VS_DEBUG is
> not defined.
> 
> net/netfilter/ipvs/ip_vs_pe_sip.c:11: warning: 'ip_vs_dbg_callid' defined but not used

Applied, thanks Simon.
