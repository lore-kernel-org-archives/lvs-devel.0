From: Jiri Wiesner <jwiesner@suse.de>
Subject: Re: [RFC PATCHv6 6/7] ipvs: run_estimation should control the
 kthread tasks
Date: Mon, 21 Nov 2022 17:32:00 +0100
Message-ID: <20221121163200.GP3484@incl>
References: <20221031145647.156930-1-ja@ssi.bg>
 <20221031145647.156930-7-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1669048321; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=VpsUVEtyx3mJ/Rw7gmuuRG64splN++CmwE8zJyfiPVM=;
        b=i1ZxbXsId6yZmZScQwxzvJgaCcZ8w4YpM5E14D0sPFqI39TnNCK3CITSDaV8BAikzOj0r4
        Q9udbqv/elWfJfosIrYUBRUytrhE2ozw16mW0ZkYfPNwbMubAVQ9aEtDduE2CKnFA3DwAH
        q+3iO8wsFKOeLRQU4tqnMNdAB4GL4Io=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1669048321;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=VpsUVEtyx3mJ/Rw7gmuuRG64splN++CmwE8zJyfiPVM=;
        b=81BpuGLoGB7BItQWwWJZqFHT8eMhu1u8zKD1odkpj33YHhQPuSHqH39WK74UoRO7wK72BK
        s77k5bCVh1zkpzBg==
Content-Disposition: inline
In-Reply-To: <20221031145647.156930-7-ja@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, dust.li@linux.alibaba.com

On Mon, Oct 31, 2022 at 04:56:46PM +0200, Julian Anastasov wrote:
> Change the run_estimation flag to start/stop the kthread tasks.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---

Reviewed-by: Jiri Wiesner <jwiesner@suse.de>

-- 
Jiri Wiesner
SUSE Labs
