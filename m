From: Jiri Wiesner <jwiesner@suse.de>
Subject: Re: [RFC PATCHv6 3/7] ipvs: use u64_stats_t for the per-cpu counters
Date: Sat, 19 Nov 2022 08:46:39 +0100
Message-ID: <20221119074639.GM3484@incl>
References: <20221031145647.156930-1-ja@ssi.bg>
 <20221031145647.156930-4-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1668844000; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=gGK7OYeTPTB9if68cZg9buicT+kxyUPwJSk9CVJ+mrk=;
        b=Gc4z6KhohCV5YLZk7l+kDyMWOZCg8AeQnZBOqohpiHVAfRj0Tv4Q4g3mG6/8y78Vr+HcE8
        qf+pXIMbRpy16GLrJpMqG+49xhHoTlzr72uBML0KX0hXsdyM2gPbetrcKafWb6SDiwXALx
        OSiz6i4GbPZ4L/cANE6s6UyG5ke4Tv0=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1668844000;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=gGK7OYeTPTB9if68cZg9buicT+kxyUPwJSk9CVJ+mrk=;
        b=47oxONQ9HFll/J2+Utnf44BeV4w+Gq8sy2plWuVLJ3GtqRK/egcFag2Ovirexg5Xr2FBh7
        uaMyrLMvO8CXrZDA==
Content-Disposition: inline
In-Reply-To: <20221031145647.156930-4-ja@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, dust.li@linux.alibaba.com

On Mon, Oct 31, 2022 at 04:56:43PM +0200, Julian Anastasov wrote:
> Use the provided u64_stats_t type to avoid
> load/store tearing.
> 
> Fixes: 316580b69d0a ("u64_stats: provide u64_stats_t type")
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---

Tested-by: Jiri Wiesner <jwiesner@suse.de>
Reviewed-by: Jiri Wiesner <jwiesner@suse.de>

-- 
Jiri Wiesner
SUSE Labs
