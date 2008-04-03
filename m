From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: Adapting LVS in order to allow Call-Id based persistence
Date: Thu, 3 Apr 2008 08:20:28 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0804030814180.9867@wm7d.net>
References: <c2f80c020804020703u6ebd4ed6oc430668daae94b30@mail.gmail.com> 
 <Pine.LNX.4.64.0804020713370.25100@wm7d.net>  <20080403052243.GA1683@verge.net.au>
  <c2f80c020804030056k1ba58dc6ocb7a2e1acfe4c013@mail.gmail.com> 
 <Pine.LNX.4.64.0804030616320.14722@wm7d.net>
 <c2f80c020804030717g21c1dc5bhabdcf99349cb7d90@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <c2f80c020804030717g21c1dc5bhabdcf99349cb7d90@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: pierrick grasland <pierrick.grasland@nexcom.fr>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org

On Thu, 3 Apr 2008, pierrick grasland wrote:

> 1) IMHO, we don't have to allow persistence for more than a call .
>
> I'm hoping to detect a call Id, set a timer for this call Id,
> corresponding to persistence. But a phone call as a very variable
> time, from short call (less than 30s) to long call (more than 15
> minutes, and my stats are only based on my bills ^^).

does the call id get refreshed during the call, ie is it 
sent with every packet, ie can you update the timer? If not 
and it's only sent on the invite and bye, then you don't 
know if the call has gone away without a bye and you'll need 
a long timeout.

> Then, we don't have SIP messages exchanged during the length of the
> communication, which use RTP. But, we must transfer the BYE in order
> to close the call.

what if you loose the BYE packet?

> I think we have several options here :
> - hash (seems practical, but I don't know how it's react in case of
> addition / deletion of server)
> - timers
> - parsing sip headers in order to detect call terminaison, which seems
> totally impractical with a DR setup (we don't see all messages
> exchange from the 2 clients)

LVS-DR is doable as the IP layer has fixed timeouts. If the 
information you need to terminate a call isn't available in 
LVS-DR, then maybe SIP will be limited to LVS-NAT. 
Alternately you could start with LVS-NAT and leave LVS-DR 
to be figured out later.

Joe
-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
