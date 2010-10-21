From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 1/9] ipvs network name space aware
Date: Thu, 21 Oct 2010 10:58:24 +0200
Message-ID: <1287651504.6871.44.camel@edumazet-laptop>
References: <201010081316.46690.hans.schillstrom@ericsson.com>
	 <201010181523.49568.hans.schillstrom@ericsson.com>
	 <20101019184436.GG2362@linux.vnet.ibm.com>
	 <201010201025.20950.hans.schillstrom@ericsson.com>
	 <20101020160205.GB2386@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:received:received:subject:from:to:cc
         :in-reply-to:references:content-type:date:message-id:mime-version
         :x-mailer:content-transfer-encoding;
        bh=kHD71KTqdGCBkN1r97IC+oXPbNO1jSQex0e3zja3p2U=;
        b=FUz+mqqVQXGXGbHMxZqZx7MTGSOHc0cB1cb2wUX734npnn01F2c/HdIGfgGmps9aVU
         /sTLRx+YnoVgy1ITqYqSgcPVEzSlIiwqEpt8scdtzqjqlzwypQAnCm454nhJmSZZazTO
         BqQGN28C3eJ5isxhgXEcspMKuUWLwVyGwnmOA=
In-Reply-To: <20101020160205.GB2386@linux.vnet.ibm.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: paulmck@linux.vnet.ibm.com
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, Daniel Lezcano <daniel.lezcano@free.fr>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "horms@verge.net.au" <horms@verge.net.au>, "ja@ssi.bg" <ja@ssi.bg>, "wensong@linux-vs.org" <wensong@linux-vs.org>


> You said that there were a lot of "stepi" commands to get through
> rcu_read_lock() on x86_64.  This is quite surprising, especially if you
> built with CONFIG_RCU_TREE.  Even if you built with CONFIG_PREEMPT_RCU_TREE,
> you should only see something like the following from rcu_read_lock():
> 
> 000000b7 <__rcu_read_lock>:
>       b7:	55                   	push   %ebp
>       b8:	64 a1 00 00 00 00    	mov    %fs:0x0,%eax
>       be:	ff 80 80 01 00 00    	incl   0x180(%eax)
>       c4:	89 e5                	mov    %esp,%ebp
>       c6:	5d                   	pop    %ebp
>       c7:	c3                   	ret    
> 
> Unless you have some sort of debugging options turned on.  Or unless
> six instructions counts for "quite many" stepi commands.  ;-)
> 

Paul, this should be inlined, dont you think ?

Also, I dont understand why we use ACCESS_ONCE() in rcu_read_lock()

ACCESS_ONCE(current->rcu_read_lock_nesting)++;

Apparently, some compilers are a bit noisy here.

mov    0x1b0(%rdx),%eax
inc    %eax
mov    %eax,0x1b0(%rdx)

instead of :

incl   0x1b0(%rax)

So if the ACCESS_ONCE() is needed, we might add a comment, because it's
not obvious ;)



