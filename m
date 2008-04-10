From: Jason Stubbs <j.stubbs@linkthink.co.jp>
Subject: Re: moving ipvs() to POST/PREROUTING- was: Real servers as LVS clients
Date: Thu, 10 Apr 2008 23:57:17 +0900
Message-ID: <200804102357.17456.j.stubbs@linkthink.co.jp>
References: <200804091658.43490.j.stubbs@linkthink.co.jp> <200804101720.33657.j.stubbs@linkthink.co.jp> <Pine.LNX.4.64.0804100658460.22622@wm7d.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0804100658460.22622@wm7d.net>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org

On Thursday 10 April 2008 23:09:45 JST, Joseph Mack NA3T wrote:
> On Thu, 10 Apr 2008, Jason Stubbs wrote:
>
> Hi Jason,
>
>  	I'm moving this thread to the lvs-devel list.
>
> (http://lists.graemef.net/mailman/listinfo/lvs-devel, in
> case you aren't subscribed)

Yep, I subscribed before posting the LC patches.

> >> Moving ip_vs_in to the end of POSTROUTING and moving
> >> ip_vs_out to the start of PREROUTING as in the attached
> >> patch seems to work and lets me do what I want. LVS-NAT
> >> and SNAT are working both independently and in
> >> conjunction to allow connections to VIPs from anywhere.
>
> There's an effort to move ipvs() out of LOCAL_IN. Horms is
> coordinating the patches, but he's just moved from Japan to
> Sydney and will be even busier than he's been previously.

I'll be doing the same in January. ;)

I'd like to look at what patches are currently available. Is there somewhere I 
can find them? I can probably spend up to a week full-time on getting things 
working in at least the -NAT case - if they aren't already. At the very 
least, I'm happy to provide a(nother) test bed for changes into the future.

--
Jason Stubbs
(Working from home at 23:57)
