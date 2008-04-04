From: Simon Horman <horms@verge.net.au>
Subject: Re: Adapting LVS in order to allow Call-Id based persistence
Date: Fri, 4 Apr 2008 17:17:43 +0900
Message-ID: <20080404081742.GC30670@verge.net.au>
References: <c2f80c020804020703u6ebd4ed6oc430668daae94b30@mail.gmail.com> <Pine.LNX.4.64.0804020713370.25100@wm7d.net> <20080403052243.GA1683@verge.net.au> <c2f80c020804030056k1ba58dc6ocb7a2e1acfe4c013@mail.gmail.com> <Pine.LNX.4.64.0804030616320.14722@wm7d.net> <c2f80c020804030717g21c1dc5bhabdcf99349cb7d90@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <c2f80c020804030717g21c1dc5bhabdcf99349cb7d90@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: pierrick grasland <pierrick.grasland@nexcom.fr>
Cc: Joseph Mack NA3T <jmack@wm7d.net>, lvs-devel@vger.kernel.org

On Thu, Apr 03, 2008 at 04:17:33PM +0200, pierrick grasland wrote:
> 1) IMHO, we don't have to allow persistence for more than a call .
> 
> I'm hoping to detect a call Id, set a timer for this call Id,
> corresponding to persistence. But a phone call as a very variable
> time, from short call (less than 30s) to long call (more than 15
> minutes, and my stats are only based on my bills ^^).
> 
> We can't allow a connexion logged as active for days, but if I'm in
> the following case (basic call flow in SIP) :
> 
> Bob  = INVITE => proxy1 = INVITE =>LVS = INVITE => realserver (proxy2)
> = INVITE ===> Alice
> Bob <= 200 OK = proxy1 <= 200 ok = LVS <= 200 ok = realserver
> (proxy2)<= 200 ok === Alice
> Bob  = ACK => proxy1 = ACK =>LVS = ACK => realserver (proxy2) = ACK
> =========> Alice
> 
> Bob <==========================RTP===============================> Alice
> 
> Bob <= BYE  = proxy1 <= BYE = LVS <= BYE = realserver <= BYE
> =============== Alice
> Bob  = 200 OK => proxy1 = 200 OK =>LVS = 200 OK => realserver (proxy2)
> = 200 OK => Alice
> 
> 
> Then, we don't have SIP messages exchanged during the length of the
> communication, which use RTP. But, we must transfer the BYE in order
> to close the call.
> 
> I think we have several options here :
> - hash (seems practical, but I don't know how it's react in case of
> addition / deletion of server)
> - timers
> - parsing sip headers in order to detect call terminaison, which seems
> totally impractical with a DR setup (we don't see all messages
> exchange from the 2 clients)

Yes, this all sounds very familiar.

The parsing approach sounds like a good idea, are you sure
that the packet-flow makes it impractical when DR is used?
It seems such a shame not to be able to use such a good idea.

The timeout idea is the most obvious approach, and probably the
best. But really long timeouts might well be needed. I mean,
its not uncommon for a phone call to go for several hours.

As for the hash, yes, I share your concern there.

> So, just for an example, I wish to know how do you implement
> persistence for HTTP.
> 
> 2) I'm actually browsing sources from kernel 2.6.24 (just for a better
> idea on the architecture). I found IPVS in
> linux-2.6.24.4/net/ipv4/ipvs.
> Does all sources are located in this folder ? Nothing with netfilter ?

There is also a header file, include/net/ip_vs.h

IPVS does use some of the netfilter code, but you probably
only need to study what is in net/ipv4/ipvs and include/net/ip_vs.h
to understand what is going on.

> PS : I have time to make something valuable (ie 4 months). I'm in
> internship, and this is my subject.
> -- 
> Grasland Pierrick
> NEXCOM Systems
> LANNION
> FRANCE

-- 
Horms

