From: Simon Horman <horms@verge.net.au>
Subject: Re: Adapting LVS in order to allow Call-Id based persistence
Date: Fri, 4 Apr 2008 17:09:47 +0900
Message-ID: <20080404080944.GB30670@verge.net.au>
References: <c2f80c020804020703u6ebd4ed6oc430668daae94b30@mail.gmail.com> <Pine.LNX.4.64.0804020713370.25100@wm7d.net> <20080403052243.GA1683@verge.net.au> <c2f80c020804030056k1ba58dc6ocb7a2e1acfe4c013@mail.gmail.com> <Pine.LNX.4.64.0804030616320.14722@wm7d.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804030616320.14722@wm7d.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Joseph Mack NA3T <jmack@wm7d.net>
Cc: pierrick grasland <pierrick.grasland@gmail.com>, lvs-devel@vger.kernel.org

On Thu, Apr 03, 2008 at 06:25:20AM -0700, Joseph Mack NA3T wrote:
> On Thu, 3 Apr 2008, pierrick grasland wrote:
>
>> But how do you work with persistence ? (actually, with -p options).
>>
>> Each call during the interval go to the same server, and then, do you reset
>> the timer for each new call) or no ?
>
> I'd defer to Horms on this if he thinks otherwise but... I wouldn't do it 
> that way. There's all sorts of problems with using a timer in the lvs 
> (-p) persistence to detect a returning client and I'm trying to convince 
> people to move to the -SH scheduler instead.
>
> The -SH scheduler addresses the same problem, but by scheduling on the 
> CIP. As long as the client doesn't change IPs within their session, then 
> you're OK (this is valid except for people using pathologically 
> configured proxy setups).
>
> I don't know if you can us the CIP to uniquely identify a client in SIP. 
> If not, you'll have to do it on call-id.

I think that in the case that I was looking at this would not have
worked well as all the traffic came from the same IP address or a
handful of IP addresses - think in terms of handling requests
from a proxy server.

However, -SH might be a good approach for many cases.

-- 
Horms

