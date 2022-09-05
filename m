From: Jiri Wiesner <jwiesner@suse.de>
Subject: Re: [RFC PATCH 1/4] ipvs: add rcu protection to stats
Date: Mon, 5 Sep 2022 12:43:37 +0200
Message-ID: <20220905104337.GC18621@incl>
References: <20220827174154.220651-1-ja@ssi.bg>
 <20220827174154.220651-2-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1662374617; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=8dALBtuhRkZMjNvySioaM5hFMcYX/TMNiMJYQMT81is=;
        b=Sb9wUDSXrSkhcAiIr5kb9EOsGOXPJfPSs5xs7nJQ7xQGf5jLKzq9vgHsYG8vTKnkSui76p
        Y2aHrt2sxTfTy0B9aWkXKa8RSeInI1EOdAT3wPYKnzudAwBY2Qvx+9/j+PWpLPXJjTmFHL
        Tx5F5Z1LX5U0wPZ/gJsBR1VmA8UJ/wM=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1662374617;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=8dALBtuhRkZMjNvySioaM5hFMcYX/TMNiMJYQMT81is=;
        b=+Uj0yXXpVd4mfaikRDnIt5BSgHJAY4ZK8ru/fw9O/SVQSzaHma4iLJvemUPEbOfTwbot/o
        NCxnJ0jqZG2ECJBg==
Content-Disposition: inline
In-Reply-To: <20220827174154.220651-2-ja@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, yunhjiang@ebay.com, dust.li@linux.alibaba.com, tangyang@zhihu.com

On Sat, Aug 27, 2022 at 08:41:51PM +0300, Julian Anastasov wrote:
> In preparation to using RCU locking for the list
> with estimators, make sure the struct ip_vs_stats
> are released after RCU grace period by using RCU
> callbacks. This affects ipvs->tot_stats where we
> can not use RCU callbacks for ipvs, so we use
> allocated struct ip_vs_stats_rcu. For services
> and dests we force RCU callbacks for all cases.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Reviewed-by: Jiri Wiesner <jwiesner@suse.de>
-- 
Jiri Wiesner
SUSE Labs
