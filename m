From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH ipvs-next v3 0/2] sched: Add cond_resched_rcu_lock()
 helper
Date: Tue, 28 May 2013 10:51:36 +0200
Message-ID: <20130528085136.GB30172@gmail.com>
References: <1369201832-17163-1-git-send-email-horms@verge.net.au>
 <20130522075438.GO26912@twins.programming.kicks-ass.net>
 <20130522.013108.58504645261021804.davem@davemloft.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-type:content-disposition:in-reply-to:user-agent;
        bh=fUVqTY3vlvHBe9Blc+N41PnUn8PU6KaJc4IlNs94NpY=;
        b=fDKow1HxA80DAdtkOGMD6lAGkEta3QExDffo2vgH71/Vh5CpKs2XZ0SarBf76d6YRy
         YP9ks2p2fiLKYdOfApOfZ6R2jGZ6SoL95zcxo7F7+J1RIke4jJcOOkqsO9YI7oe2UtUM
         izr/U+QtiZN6UiBEGQnnTPk6Qnj57tHvZLJWfOso4DDWQDnQOVv3It1V8oJCvEsyL7Jj
         1TXEvD+WkddugMz2tho2hZXTAUVnHTAEVKVsiUUb8ukuQu7xrnoSKPQVQ8HJLZ4uYxsS
         9cxdSY5B3tLruDNYm5TX0p8UGvdH4u9ATOpvHs/9u6P3S02xN3f6+XvC5DZSau8/W2bJ
         bm+w==
Content-Disposition: inline
In-Reply-To: <20130522.013108.58504645261021804.davem@davemloft.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: peterz@infradead.org, horms@verge.net.au, eric.dumazet@gmail.com, ja@ssi.bg, mingo@redhat.com, paulmck@linux.vnet.ibm.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, pablo@netfilter.org, dipankar@in.ibm.com


* David Miller <davem@davemloft.net> wrote:

> From: Peter Zijlstra <peterz@infradead.org>
> Date: Wed, 22 May 2013 09:54:38 +0200
> 
> > On Wed, May 22, 2013 at 02:50:30PM +0900, Simon Horman wrote:
> >> Add a helper that for use in loops which read data protected by RCU and
> >> may have a large number of iterations.  Such an example is dumping the list
> >> of connections known to IPVS: ip_vs_conn_array() and ip_vs_conn_seq_next().
> >> 
> >> This series also updates IPVS to use the helper.
> >> 
> >> Simon Horman (2):
> >>   sched: add cond_resched_rcu() helper
> >>   ipvs: use cond_resched_rcu() helper when walking connections
> >> 
> >>  include/linux/sched.h           |  9 +++++++++
> >>  net/netfilter/ipvs/ip_vs_conn.c | 23 ++++++++---------------
> >>  2 files changed, 17 insertions(+), 15 deletions(-)
> > 
> > Acked-by: Peter Zijlstra <peterz@infradead.org>
> > 
> > How do you want to go about merging this? Do you want to route it
> > through the net tree or through -tip?
> 
> I think we can have Pablo merge it into his netfilter tree.

Yeah, that's what we agreed upon earlier during the review of these 
patches.

Thanks,

	Ingo

