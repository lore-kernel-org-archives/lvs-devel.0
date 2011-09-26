From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH 1/4] IPVS: Add documentation for new sysctl entries
Date: Mon, 26 Sep 2011 10:16:41 -0700
Message-ID: <4E80B379.2040701@xenotime.net>
References: <1317000233-11169-1-git-send-email-horms@verge.net.au> <1317000233-11169-2-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=xenotime.net; s=default;
	h=Content-Transfer-Encoding:Content-Type:In-Reply-To:References:Subject:CC:To:MIME-Version:From:Date:Message-ID; bh=PnYkrLN69BnHazlRU706lDPljpD+xDRsO4WON9NlpcE=;
	b=TQwnT4mdLRgof6R4/n2kU0KJFIMWoQ34+neDnpXPVDT51mXxfPTC+2eTj9n6cfOOlBTtTtqAsmSrBs42JawWP6xhie0BwuvrSyCb2hAj3LZPCi5WtZtAr4ta9T6BtDDq;
In-Reply-To: <1317000233-11169-2-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

On 09/25/2011 06:23 PM, Simon Horman wrote:
> Add missing documentation for conntrack, snat_reroute and sync_version.
> 
> Also fix up a typo, IPVS_DEBUG should be IP_VS_DEBUG.
> 
> Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> conntrack
> ---
>  Documentation/networking/ipvs-sysctl.txt |   53 +++++++++++++++++++++++++++++-
>  1 files changed, 52 insertions(+), 1 deletions(-)
> 
> diff --git a/Documentation/networking/ipvs-sysctl.txt b/Documentation/networking/ipvs-sysctl.txt
> index 4ccdbca..5214339 100644
> --- a/Documentation/networking/ipvs-sysctl.txt
> +++ b/Documentation/networking/ipvs-sysctl.txt
> @@ -15,6 +15,23 @@ amemthresh - INTEGER
>          enabled and the variable is automatically set to 2, otherwise
>          the strategy is disabled and the variable is  set  to 1.
>  
> +conntrack - BOOLEAN
> +	0 - disabled (default)
> +	not 0 - enabled
> +
> +	If set, maintain connection tracking entries for
> +	connections handled by IPVS.
> +
> +	This should be enabled if connections handled by IPVS are to be
> +	also handled by stateful firewall rules. That is, iptables rules
> +	that make use of connection tracking.  It is a performance
> +	optimisation to disable this setting otherwise.
> +
> +	Connections handled by the IPVS FTP application module
> +	will have connection tracking entries regardless of this setting.
> +
> +	Only available when IPVS is compiled with the CONFIG_IP_VS_NFCT

seems to be missing something.  Maybe

	Only available when IPVS is compiled with CONFIG_IP_VS_NFCT enabled.
or
	Only available when IPVS is compiled with the CONFIG_IP_VS_NFCT
	symbol enabled.

> +
>  cache_bypass - BOOLEAN
>          0 - disabled (default)
>          not 0 - enabled
> @@ -39,7 +56,7 @@ debug_level - INTEGER
>  	11         - IPVS packet handling (ip_vs_in/ip_vs_out)
>  	12 or more - packet traversal
>  
> -	Only available when IPVS is compiled with the CONFIG_IPVS_DEBUG
> +	Only available when IPVS is compiled with the CONFIG_IP_VS_DEBUG

	                                     with CONFIG_IP_VS_DEBUG enabled.

>  
>  	Higher debugging levels include the messages for lower debugging
>  	levels, so setting debug level 2, includes level 0, 1 and 2


-- 
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
