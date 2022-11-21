From: Jiri Wiesner <jwiesner@suse.de>
Subject: Re: [RFC PATCHv6 5/7] ipvs: add est_cpulist and est_nice sysctl vars
Date: Mon, 21 Nov 2022 17:29:27 +0100
Message-ID: <20221121162927.GO3484@incl>
References: <20221031145647.156930-1-ja@ssi.bg>
 <20221031145647.156930-6-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1669048168; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=G0Y+TOUnn9zUCHI4aa1d3mbhLBqxbWh9x7difBcSH0I=;
        b=bXk3SOCABJ/fVP3wEcyNy3QB+ojVQ8hjjbqB0FcZVy0vltgknc7pnifm0iiHxT2yC/V23W
        jMvb4aXkSaK7WWjcJqIPN/GhslmOWDoBcDUP6k2DVgbToBUt5fykfepfHZ5JbSJ30MtnWM
        Nk8+4mBx2xPCP9b7Lv2G7i7A+c7V+24=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1669048168;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=G0Y+TOUnn9zUCHI4aa1d3mbhLBqxbWh9x7difBcSH0I=;
        b=f1lHXjthjaSP99QAXp46+NJNYd/EkI8XOtHzU725ZEtk9SGZDjXjV2+2O9W5GgidYV2Kre
        ZyeP2PG9vAnFN/BA==
Content-Disposition: inline
In-Reply-To: <20221031145647.156930-6-ja@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, dust.li@linux.alibaba.com

On Mon, Oct 31, 2022 at 04:56:45PM +0200, Julian Anastasov wrote:
> Allow the kthreads for stats to be configured for
> specific cpulist (isolation) and niceness (scheduling
> priority).
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---

Reviewed-by: Jiri Wiesner <jwiesner@suse.de>

-- 
Jiri Wiesner
SUSE Labs
