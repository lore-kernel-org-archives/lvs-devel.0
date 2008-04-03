From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: Adapting LVS in order to allow Call-Id based persistence
Date: Thu, 3 Apr 2008 06:25:20 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0804030616320.14722@wm7d.net>
References: <c2f80c020804020703u6ebd4ed6oc430668daae94b30@mail.gmail.com> 
 <Pine.LNX.4.64.0804020713370.25100@wm7d.net>  <20080403052243.GA1683@verge.net.au>
 <c2f80c020804030056k1ba58dc6ocb7a2e1acfe4c013@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <c2f80c020804030056k1ba58dc6ocb7a2e1acfe4c013@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: pierrick grasland <pierrick.grasland@gmail.com>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org

On Thu, 3 Apr 2008, pierrick grasland wrote:

> But how do you work with persistence ? (actually, with -p options).
>
> Each call during the interval go to the same server, and then, do you reset
> the timer for each new call) or no ?

I'd defer to Horms on this if he thinks otherwise but... I 
wouldn't do it that way. There's all sorts of problems with 
using a timer in the lvs (-p) persistence to detect a 
returning client and I'm trying to convince people to move 
to the -SH scheduler instead.

The -SH scheduler addresses the same problem, but by 
scheduling on the CIP. As long as the client doesn't change 
IPs within their session, then you're OK (this is valid 
except for people using pathologically configured proxy 
setups).

I don't know if you can us the CIP to uniquely identify a 
client in SIP. If not, you'll have to do it on call-id.

Joe
-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
