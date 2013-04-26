From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] ipvs: Use cond_resched_rcu_lock() helper when
 dumping connections
Date: Fri, 26 Apr 2013 08:59:07 -0700
Message-ID: <1366991947.8964.233.camel@edumazet-glaptop>
References: <1366940708-10180-1-git-send-email-horms@verge.net.au>
	 <1366940708-10180-3-git-send-email-horms@verge.net.au>
	 <20130426080313.GC8669@dyad.programming.kicks-ass.net>
	 <20130426154547.GC3860@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=x-received:message-id:subject:from:to:cc:date:in-reply-to
         :references:content-type:x-mailer:content-transfer-encoding
         :mime-version;
        bh=FHP6GS7Ev93uVY58MXo+TfBd/0sHFpl47OeqEbCzGFI=;
        b=BCAY3Wxdj0iN3Z18Sw2FwSQHwlH7dwuao/u+TqyrLIqKv56Qm2lbryIfKIB5ZfF6Ni
         CzaR2OxEYWenVZLR3u5KgSfTtgUiYU7cFAeb4ftUdijA5FoBOIvYidO5GmYnMK06ZOFP
         sBGidj4MYbdBcZ+PRztvfLVvqVnMgnQx6rO3xdmUJQvc4HzSRfLdUxHoGs86sOoQSfqm
         tuh+BVNLk9GgUwT1+EcSwiwoytCxQQG/n7gbjXKALQokWiBwtW06iGMEUCK5+fnTQqfY
         ePWc5MGtGxB1935mQQ7F+vCcAeIkL9V+ty2fDlD9IrzhZs01L6oBrGp+B57+CjI7r12V
         mH0g==
In-Reply-To: <20130426154547.GC3860@linux.vnet.ibm.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: paulmck@linux.vnet.ibm.com
Cc: Peter Zijlstra <peterz@infradead.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Ingo Molnar <mingo@redhat.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>, dhaval.giani@gmail.com

On Fri, 2013-04-26 at 08:45 -0700, Paul E. McKenney wrote:

> I have done some crude coccinelle patterns in the past, but they are
> subject to false positives (from when you transfer the pointer from
> RCU protection to reference-count protection) and also false negatives
> (when you atomically increment some statistic unrelated to protection).
> 
> I could imagine maintaining a per-thread count of the number of outermost
> RCU read-side critical sections at runtime, and then associating that
> counter with a given pointer at rcu_dereference() time, but this would
> require either compiler magic or an API for using a pointer returned
> by rcu_dereference().  This API could in theory be enforced by sparse.
> 
> Dhaval Giani might have some ideas as well, adding him to CC.


We had this fix the otherday, because tcp prequeue code hit this check :

static inline struct dst_entry *skb_dst(const struct sk_buff *skb)
{
        /* If refdst was not refcounted, check we still are in a 
         * rcu_read_lock section
         */
        WARN_ON((skb->_skb_refdst & SKB_DST_NOREF) &&
                !rcu_read_lock_held() &&
                !rcu_read_lock_bh_held());
        return (struct dst_entry *)(skb->_skb_refdst & SKB_DST_PTRMASK);
}

( http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=093162553c33e9479283e107b4431378271c735d )

Problem is the rcu protected pointer was escaping the rcu lock and was
then used in another thread.


What would be cool (but expensive maybe) , would be to get a cookie from
rcu_read_lock(), and check the cookie at rcu_dereference(). These
cookies would have system wide scope to catch any kind of errors.

Because a per thread counter would not catch following problem :

rcu_read_lock();

ptr = rcu_dereference(x);
if (!ptr)
	return NULL;
...


rcu_read_unlock();

...
rcu_read_lock();
/* no reload of x, ptr might be now stale/freed */
if (ptr->field) { ... }



