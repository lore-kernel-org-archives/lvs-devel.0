From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 1/2] sched: Add cond_resched_rcu_lock() helper
Date: Fri, 26 Apr 2013 08:13:59 +0200
Message-ID: <20130426061359.GA25912@gmail.com>
References: <1366940708-10180-1-git-send-email-horms@verge.net.au>
 <1366940708-10180-2-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=x-received:sender:date:from:to:cc:subject:message-id:references
         :mime-version:content-type:content-disposition:in-reply-to
         :user-agent;
        bh=MoETyhEeVVMpsI/DPpS/29i/r4RmSdMKtvtpA7lb47M=;
        b=aLg+TZLQ+6hiJhhvCpff57OlEnwHlJC0D5GFybyDS5vFjDFqgYDS8kCwG8Kkym1qQ1
         z2iy1zlYnptxEeWNoj963BVIixvSkD6lHUfdpbmD7iCaGNnSti5xJOB4s798Q5iwLVcc
         wl8wwTdSYTTSretB/0gQ1g67o5lgPKkpKWAwy2E8Xht30Lps29fB1zruoOO9RRE0ZhbT
         ZDfcdserJIxMfQJAwd5Q91ZV2uqzPYCqs70jLjExuIwJZxK32Apc0ERgSzsvNdqdxSg5
         oXOtaHYhaxjrCjtMrMgM8tnAUAmljOyopI8oxnQ5D6G6Nkd+rgLNsTqUq9KyhUFCRohy
         WKvA==
Content-Disposition: inline
In-Reply-To: <1366940708-10180-2-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Julian Anastasov <ja@ssi.bg>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>


* Simon Horman <horms@verge.net.au> wrote:

> This is intended for use in loops which read data protected by RCU and may
> have a large number of iterations.  Such an example is dumping the list of
> connections known to IPVS: ip_vs_conn_array() and ip_vs_conn_seq_next().
> 
> As suggested by Eric Dumazet.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Simon Horman <horms@verge.net.au>
> ---
>  include/linux/sched.h | 9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index e692a02..7eec4c7 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -2787,3 +2787,12 @@ static inline unsigned long rlimit_max(unsigned int limit)
>  }
>  
>  #endif
> +
> +static void inline cond_resched_rcu_lock(void)
> +{
> +	if (need_resched()) {
> +		rcu_read_unlock();
> +		cond_resched();
> +		rcu_read_lock();
> +	}
> +}

Acked-by: Ingo Molnar <mingo@kernel.org>

	Ingo
