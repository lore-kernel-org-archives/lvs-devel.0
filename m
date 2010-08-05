From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch][bug][ldirectord] a fallback server specified in a
 virtual server section without a port
Date: Thu, 5 Aug 2010 15:35:32 +0900
Message-ID: <20100805063529.GA4630@verge.net.au>
References: <20100728.195127.48524095.sohgo@sohgo.dyndns.org>
 <20100805.135125.115917396.sohgo@sohgo.dyndns.org>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100805.135125.115917396.sohgo@sohgo.dyndns.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sohgo Takeuchi <sohgo@sohgo.dyndns.org>
Cc: lvs-devel@vger.kernel.org

On Thu, Aug 05, 2010 at 01:51:25PM +0900, Sohgo Takeuchi wrote:
> 
> 
> From: Sohgo Takeuchi <sohgo@sohgo.dyndns.org>
> |
> > I found a bug in ldirectord and attach a patch to fix this
> > problem to this E-mail.
> > 
> > The bug is that if a port is omitted in a "fallback" in a
> > virtual section, the entry is never seen in the virtual server
> > table even if all real servers are down.
> > 
> >     virtual=10.10.100.1:daytime
> > 	real=10.10.100.2:daytime gate
> > 	fallback=127.0.0.1
> > 
> > A debug message says like this.
> > 
> >     DEBUG2: Running system(/sbin/ipvsadm -a -t 10.10.100.1:13 -r 127.0.0.1: -g -w 1)
> >     Running system(/sbin/ipvsadm -a -t 10.10.100.1:13 -r 127.0.0.1: -g -w 1)
> >     illegal real server address[:port] specified
> >     DEBUG2: system(/sbin/ipvsadm -a -t 10.10.100.1:13 -r 127.0.0.1: -g -w 1) failed:
> >     system(/sbin/ipvsadm -a -t 10.10.100.1:13 -r 127.0.0.1: -g -w 1) failed:
> > 
> > 
> > The problem in the source code is that when a port of "fallback"
> > is omitted, the port is derived from a port specified in a
> > "virtual" service (from a behavior of the parse_fallback
> > function), but the port is used before it is defined.
> > 
> > I tested ldirectord on Ubuntu 10.04 with perl 5.10.1.
> > 
> > with best regards,
> 
> Does anyone have an interest in this bug?

Sorry, I missed your previous post.
I have pushed your patch into the agents tree.

