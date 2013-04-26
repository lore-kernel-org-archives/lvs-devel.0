From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] ipvs: Use cond_resched_rcu_lock() helper when
 dumping connections
Date: Fri, 26 Apr 2013 11:26:55 -0700
Message-ID: <1367000815.8964.243.camel@edumazet-glaptop>
References: <1366940708-10180-1-git-send-email-horms@verge.net.au>
	 <1366940708-10180-3-git-send-email-horms@verge.net.au>
	 <20130426080313.GC8669@dyad.programming.kicks-ass.net>
	 <20130426154547.GC3860@linux.vnet.ibm.com>
	 <20130426171948.GA31467@dyad.programming.kicks-ass.net>
	 <20130426174815.GI3860@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=x-received:message-id:subject:from:to:cc:date:in-reply-to
         :references:content-type:x-mailer:content-transfer-encoding
         :mime-version;
        bh=Giyb1mA/w8f4VMCPUjhRP4disF91OjK9vKBXeqEAwWA=;
        b=Fb9IW3IB4fdEubN8dE1l9W3O/NPwd55690nkRRHIHm/81rEQXdtshwaz+RdZ1X+o1D
         f8Lgtt+4IUdmC6fqoDh2BGs714aZGkgyJ7/HnBUcH53RnAuXtv2i8swF8TO2xVENJX0N
         7DKMIfzJ86/huJ0rLUuH1d+GWYxsli6/k8unvTaqPuJlh4axdLGtltO4zhVjO5Xl6sOi
         Ih4+ztUbl3HT0bHBiBK6vBQ3SLrtVCJJm+/DzLceTxg/uDzQOf3Lwr6PDr19vxMFQxxY
         PobxaGvAvTfC6x8Hxfwsu4NyMQpROT0o4bd1pscs4tlIgHY0Qku1haliILCXh6HZix9o
         ZWXQ==
In-Reply-To: <20130426174815.GI3860@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: paulmck@linux.vnet.ibm.com
Cc: Peter Zijlstra <peterz@infradead.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Ingo Molnar <mingo@redhat.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>, dhaval.giani@gmail.com

On Fri, 2013-04-26 at 10:48 -0700, Paul E. McKenney wrote:

> Don't get me wrong, I am not opposing cond_resched_rcu_lock() because it
> will be difficult to validate.  For one thing, until there are a lot of
> them, manual inspection is quite possible.  So feel free to apply my
> Acked-by to the patch.

One question : If some thread(s) is(are) calling rcu_barrier() and
waiting we exit from rcu_read_lock() section, is need_resched() enough
for allowing to break the section ?

If not, maybe we should not test need_resched() at all.

rcu_read_unlock();
cond_resched();
rcu_read_lock();



