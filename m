From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 2/6] move ipvs to PRE/POSTROUTING
Date: Fri, 18 Apr 2008 10:46:32 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0804181019110.2843@u.domain.uli>
References: <200804151540.04006.j.stubbs@linkthink.co.jp>
 <200804161035.12575.j.stubbs@linkthink.co.jp> <Pine.LNX.4.58.0804161051400.2944@u.domain.uli>
 <200804171225.54424.j.stubbs@linkthink.co.jp>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <200804171225.54424.j.stubbs@linkthink.co.jp>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LVS Devel <lvs-devel@vger.kernel.org>


	Hello,

On Thu, 17 Apr 2008, Jason Stubbs wrote:

> > - do not play with packets accounted for sockets (skb->sk != NULL).
> > There was check you removed. Please, reconsider.
> 
> With this check restored, the director can't access the virtual server. I 
> haven't found any solid documentation, but skb->sk seems to be the local 
> socket that the packet is tied to? Is there some badness that can happen by 
> allowing these packets to be LVS'd?

	Hm, I didn't know that with your patch director can be client.
The problem was that IPVS didn't touched packets owned by sockets
before, I remember that there are rules when such skbs should be
modified, related to sharing and cloning, may be skbs should be
copied if modified. But I assume now skb_make_writable() handles
it properly.

> > - ability to throttle IPVS traffic with netfilter modules. How
> > we can benefit from such modules, can they protect us, can we avoid
> > IPVS scheduling on overload (such modules should work before IPVS conn
> > scheduling, which should be true if you schedule in POST_ROUTING).
> > Was true for LOCAL_IN scheduling.
> 
> Are you referring to ipt_RECENT here? That module tested ok.

	Yes, for example, -m limit for SYN packets _BEFORE_
IPVS scheduling to protect IPVS from SYN floods. But this should
be checked only for changes that move IPVS scheduling at PRE_ROUTING.

Regards

--
Julian Anastasov <ja@ssi.bg>
