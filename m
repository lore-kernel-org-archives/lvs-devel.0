From: Jiri Wiesner <jwiesner@suse.de>
Subject: Re: [RFC PATCH 4/4] ipvs: run_estimation should control the kthread
 tasks
Date: Mon, 5 Sep 2022 16:57:54 +0200
Message-ID: <20220905145754.GF18621@incl>
References: <20220827174154.220651-1-ja@ssi.bg>
 <20220827174154.220651-5-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1662389875; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=AiSbwvV48dhV9xNM3d1vGzTwYVvEfvPNfSqKQjZUUG0=;
        b=uPFkOv5iKepev4YfNyZjQYOkGj5tl89fSc5A/OYDP5Vzv5PxizmkcmJmNQZ1gp7Mo+C8FL
        JoA4gJlvi/TI0Yqc/cEr13LkniownEdg9h2FsvYMzdIvCOOmfl9aVMsLwkmVJiadIXiI4L
        qn9lM3ukXBd3p6B/QuN46zWzW+p/Ubo=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1662389875;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=AiSbwvV48dhV9xNM3d1vGzTwYVvEfvPNfSqKQjZUUG0=;
        b=0tglCboWkIErGdmmjzyNvf0bVSnBXvC2Etah/D9E2jCYOjD05JJc2J4ug2cHd3eW9sCRX7
        V3X6TzMpVkT5fDBg==
Content-Disposition: inline
In-Reply-To: <20220827174154.220651-5-ja@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, yunhjiang@ebay.com, dust.li@linux.alibaba.com, tangyang@zhihu.com

On Sat, Aug 27, 2022 at 08:41:54PM +0300, Julian Anastasov wrote:
> Change the run_estimation flag to start/stop the kthread tasks.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Reviewed-by: Jiri Wiesner <jwiesner@suse.de>

-- 
Jiri Wiesner
SUSE Labs
