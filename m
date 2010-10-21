From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 1/9] ipvs network name space aware
Date: Thu, 21 Oct 2010 08:16:13 -0700
Message-ID: <20101021151613.GB2363@linux.vnet.ibm.com>
References: <201010081316.46690.hans.schillstrom@ericsson.com>
 <201010181523.49568.hans.schillstrom@ericsson.com>
 <20101019184436.GG2362@linux.vnet.ibm.com>
 <201010201025.20950.hans.schillstrom@ericsson.com>
 <20101020160205.GB2386@linux.vnet.ibm.com>
 <1287651504.6871.44.camel@edumazet-laptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1287651504.6871.44.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, Daniel Lezcano <daniel.lezcano@free.fr>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "horms@verge.net.au" <horms@verge.net.au>, "ja@ssi.bg" <ja@ssi.bg>, "wensong@linux-vs.org" <wensong@linux-vs.org>

On Thu, Oct 21, 2010 at 10:58:24AM +0200, Eric Dumazet wrote:
> 
> > You said that there were a lot of "stepi" commands to get through
> > rcu_read_lock() on x86_64.  This is quite surprising, especially if you
> > built with CONFIG_RCU_TREE.  Even if you built with CONFIG_PREEMPT_RCU_TREE,
> > you should only see something like the following from rcu_read_lock():
> > 
> > 000000b7 <__rcu_read_lock>:
> >       b7:	55                   	push   %ebp
> >       b8:	64 a1 00 00 00 00    	mov    %fs:0x0,%eax
> >       be:	ff 80 80 01 00 00    	incl   0x180(%eax)
> >       c4:	89 e5                	mov    %esp,%ebp
> >       c6:	5d                   	pop    %ebp
> >       c7:	c3                   	ret    
> > 
> > Unless you have some sort of debugging options turned on.  Or unless
> > six instructions counts for "quite many" stepi commands.  ;-)
> 
> Paul, this should be inlined, dont you think ?

Indeed it should!!!  It is out-of-line due to header-file issues.
Lai Jiangshan proposed a change to kbuild to allow it to be inlined as
part of his ring-RCU patch, and I have asked him to submit a version
of that for Tree and Tiny preemptible RCU.  This is the usual trick of
having the build system compile the data structure and emit offsets,
which are then used in the main kernel build.  (Yes, I did something
similar in DYNIX/ptx, but never managed to work up the courage to attempt
the equivalent in Linux's kbuild, so props to Lai!)

> Also, I dont understand why we use ACCESS_ONCE() in rcu_read_lock()
> 
> ACCESS_ONCE(current->rcu_read_lock_nesting)++;
> 
> Apparently, some compilers are a bit noisy here.
> 
> mov    0x1b0(%rdx),%eax
> inc    %eax
> mov    %eax,0x1b0(%rdx)
> 
> instead of :
> 
> incl   0x1b0(%rax)
> 
> So if the ACCESS_ONCE() is needed, we might add a comment, because it's
> not obvious ;)

Here is what it looks like in my -rcu tree:

void __rcu_read_lock(void)
{
	current->rcu_read_lock_nesting++;
	barrier();  /* needed if we ever invoke rcu_read_lock in rcutree.c */
}

So yes, I finally did convince myself that the ACCESS_ONCE was not
needed.  ;-)

This is not yet in mainline, but Ingo sent the series containing this
commit (80dcf60e) to Linus earlier today, so there is hope!

							Thanx, Paul
