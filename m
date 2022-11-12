From: Jiri Wiesner <jwiesner@suse.de>
Subject: Re: [RFC PATCHv6 1/7] ipvs: add rcu protection to stats
Date: Sat, 12 Nov 2022 08:51:51 +0100
Message-ID: <20221112075151.GF3484@incl>
References: <20221031145647.156930-1-ja@ssi.bg>
 <20221031145647.156930-2-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1668239511; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=+hHx63Mh4fJHTWNVdrYBjQx/8WmXU8zhRsEjRgjmryU=;
        b=UjDcjVV2f2oNY4L/3uCTZwnNvINCTX6tyTsxawBAbeIZfnqC53Hr2Clhz7mBt5RmYxTRqW
        ktg+fH5EQTZ65vXve2Zqu5MoWbhpS7DX7gz31zbyflpTxK36RJbSsKxQ0qC+c2RGFfU8l1
        YnvJjuHbK1V8/fPwlwJBfoj2QNJJN6U=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1668239511;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=+hHx63Mh4fJHTWNVdrYBjQx/8WmXU8zhRsEjRgjmryU=;
        b=n5lfvxdTI1d6A7I/ySr1FtmQcDrwLZgr6H84hSHDUWfb2Qumkd38Wg0x3bbhnMArMbnFsl
        eN5BKRm0F6RT9UAg==
Content-Disposition: inline
In-Reply-To: <20221031145647.156930-2-ja@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, dust.li@linux.alibaba.com

On Mon, Oct 31, 2022 at 04:56:41PM +0200, Julian Anastasov wrote:
> In preparation to using RCU locking for the list
> with estimators, make sure the struct ip_vs_stats
> are released after RCU grace period by using RCU
> callbacks. This affects ipvs->tot_stats where we
> can not use RCU callbacks for ipvs, so we use
> allocated struct ip_vs_stats_rcu. For services
> and dests we force RCU callbacks for all cases.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---

Reviewed-by: Jiri Wiesner <jwiesner@suse.de>

-- 
Jiri Wiesner
SUSE Labs
