From: Simon Horman <horms@verge.net.au>
Subject: Re: Ldirectord Feature Request
Date: Sat, 2 May 2009 12:16:44 +1000
Message-ID: <20090502021644.GA15603@verge.net.au>
References: <33afbbe70905011318j35d226a6h31e0dfaeb1b77b45@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <33afbbe70905011318j35d226a6h31e0dfaeb1b77b45@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Caleb Anthony <caleb.anthony@gmail.com>
Cc: lvs-devel@vger.kernel.org

Hi,

On Fri, May 01, 2009 at 02:18:06PM -0600, Caleb Anthony wrote:
> Hello,
> 
> In my organization we use ldirectord to monitor and maintain the ipvs
> table. It works great, except that we run a bit of a strange setup
> that involves nested ipvs (ipvs forwarding to another ipvs), and a
> combination of direct routing and IP tunneling. I'm actually in the
> process of writing up a small of a testimonial about our
> configuration, which I don't think is very common, or maybe ever been
> used at all. But, in our endeavors we've come across two limitations
> with ldirectord in our environment.
> 
> First, we use the source hash scheduling algorithm to maintain
> affinity with real servers. And according to the documentation that I
> have seen, the weight setting really means "number of connections" to
> the source hash scheduler. This is a problem for us with the fallback
> setting, because ldirectord doesn't allow you to set the weight of a
> fallback server. Instead, it just defaults to 1. So, in the event of
> an emergency, ipvs is only going to allow 1 connection at a time to
> our fallback server. Being able to specify the weight of a fallback
> server would be a great addition for us.

I'll double check, but I think the weight specifies a proportion
of conections rather than an absolute number. Could you let
me know which documentation you are looking at?

> Our second suggestion would be to have the ability to specify multiple
> fallback servers, just like you can with real servers. It's hard for
> me to explain why we can't live with just one fallback server without
> a huge explanation about our setup, but basically we have more than
> one fallback server that serves real content, and if a failure
> occurred, we have to hope that that one server we have configured is
> not only running, but able to handle the sudden load. Also, I'm not
> entirely sure if fallback servers are health monitored. I ask because,
> if we could specify multiple fallback servers, we would like them to
> be monitored just like a real server and added or removed from the
> ipvs table as necessary.

Fallback servers are not monitored at this time. Implementing Fallback as a
second pool of monitored servers would be possible to add to ldirectord,
though it would be a non-trivial change.  In other words, it would be a
reasonable amount of work.  But I can't see any disadvantages to your idea
as it should be possible to maintain the existing model too.

-- 
Simon Horman
  VA Linux Systems Japan K.K. Satellite Lab in Sydney, Australia
  H: www.vergenet.net/~horms/            W: www.valinux.co.jp/en

