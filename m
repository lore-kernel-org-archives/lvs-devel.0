From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC net-next] ipv6: Use destination address determined by IPVS
Date: Tue, 15 Oct 2013 19:40:59 -0700
Message-ID: <1381891259.2045.100.camel@edumazet-glaptop.roam.corp.google.com>
References: <1381881751-6719-1-git-send-email-horms@verge.net.au>
	 <1381882426.2045.85.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131016002807.GM22321@verge.net.au>
	 <1381883949.2045.97.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131016021304.GA17801@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :content-type:content-transfer-encoding:mime-version;
        bh=CuYfYM1x/Vt8YsdJz2QstUZ6ufI4mhTzELTLKNDjrb0=;
        b=XD5//2MOvRPjMPt9aGPbDdx3e/lLn84cro/tlhgZo/FGo+yNOVcevs5V6gGOyZsElW
         FtHUvWewrMuDEow6LA8dYTV+gH3V/34HngL70KqUUjaw4ow3bvjDG1h/QLiSAy9bXYXv
         Yikk74a8CVnG6UpWKQZCXe5asXkyfNS7QuZQDsWPNV06uaV47G7BcZBERfT/1dWdsZds
         PNuqvJATdJuVjVZixWF4V9XSdlAXHqYHYJXBqxz7wkHLVLtkQJiJEX+CBoL9QNeMNetF
         yL3H2hlz1UfA1THLIN5voIncgUOzWI2xiUH9ANpnmQBNGyzRHMTz0p4SE+dWEOWnM7KK
         9oMg==
In-Reply-To: <20131016021304.GA17801@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: YOSHIFUJI Hideaki / =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?= <yoshfuji@linux-ipv6.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Mark Brooks <mark@loadbalancer.org>

On Wed, 2013-10-16 at 11:13 +0900, Simon Horman wrote:

> That does seem very promising but while implementing it
> I hit a problem.
> 
> struct tcp_skb_cb includes a field of type struct inet6_skb_parm.  And
> expanding struct inet6_skb_parm by 16 bytes means that struct tcp_skb_cb is
> now larger than 48 bytes and no longer fits in skb->cb.
> 
> Is it appropriate to grow skb->cb as the comment above struct tcp_skb_cb
> suggests?

Ah well...

No, its not appropriate to grow sk_buff by 16 bytes, sorry.

You could not change struct inet6_skb_parm, but define IP6CB as
a compound 

struct ip6cb {
   struct inet6_skb_parm foo;
   struct in6_addr       bar;
};



