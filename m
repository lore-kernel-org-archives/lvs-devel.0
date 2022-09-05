From: Jiri Wiesner <jwiesner@suse.de>
Subject: Re: [RFC PATCH 3/4] ipvs: add est_cpulist and est_nice sysctl vars
Date: Mon, 5 Sep 2022 16:53:33 +0200
Message-ID: <20220905145333.GE18621@incl>
References: <20220827174154.220651-1-ja@ssi.bg>
 <20220827174154.220651-4-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1662389614; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=x1UnObJe2ULj6sSrzT5ZONR8Ni84LlugN35MPTGcstU=;
        b=ne73cDajtuXv9Vf3EmqzsfeOm8M2fI+rAdG5nfr/9svgKZe2u2IKMVE8oJ2anU7VgdlnQE
        RLF5ukJFLSW3VNOGbcfIXs356MmuE9EWtfbfVoIVKFTAivfcq43cfzUWLSZl+NaERAahGt
        Hnr0I7dJEssF0kU8KCMhgtoDqvamIns=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1662389614;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=x1UnObJe2ULj6sSrzT5ZONR8Ni84LlugN35MPTGcstU=;
        b=4OJKTalJCvP+muxjrPN3oROq3uYUseMV36gFMPYqY/SqdYUEoDCBVtk6RrWu/pSDAOIZeb
        aClzdHHkr+NXY2Bw==
Content-Disposition: inline
In-Reply-To: <20220827174154.220651-4-ja@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, yunhjiang@ebay.com, dust.li@linux.alibaba.com, tangyang@zhihu.com

On Sat, Aug 27, 2022 at 08:41:53PM +0300, Julian Anastasov wrote:
> Allow the kthreads for stats to be configured for
> specific cpulist (isolation) and niceness (scheduling
> priority).
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

I think moving the estimation kthreads to idle CPU core will become necessary for people who want their estimates to be as accurate as possible. Otherwise, scheduling latencies on busy systems may make the estimates inaccurate by delaying the kthreads after they have been woken up.

Reviewed-by: Jiri Wiesner <jwiesner@suse.de>

> diff --git a/Documentation/networking/ipvs-sysctl.rst b/Documentation/networking/ipvs-sysctl.rst
> index 387fda80f05f..90c7c325421a 100644
> --- a/Documentation/networking/ipvs-sysctl.rst
> +++ b/Documentation/networking/ipvs-sysctl.rst
> @@ -129,6 +129,26 @@ drop_packet - INTEGER
>  	threshold. When the mode 3 is set, the always mode drop rate
>  	is controlled by the /proc/sys/net/ipv4/vs/am_droprate.
>  
> +est_cpulist - CPULIST
> +	Allowed	CPUs for estimation kthreads
> +
> +	Syntax: standard cpulist format
> +	empty list - stop kthread tasks and estimation
> +	default - the system's housekeeping CPUs for kthreads
> +
> +	Example:
> +	"all": all possible CPUs
> +	"0-N": all possible CPUs, N denotes last CPU number
> +	"0,1-N:1/2": first and all CPUs with odd number
> +	"": empty list
> +
> +est_nice - INTEGER
> +	default 0
> +	Valid range: -20 (more favorable) - 19 (less favorable)

How about using dots instead of a hyphen in the range? I guess it will be easier to read.

> +
> +	Niceness value to use for the estimation kthreads (scheduling
> +	priority)
> +
>  expire_nodest_conn - BOOLEAN
>  	- 0 - disabled (default)
>  	- not 0 - enabled

-- 
Jiri Wiesner
SUSE Labs
