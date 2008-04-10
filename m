From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: moving ipvs() to POST/PREROUTING- was: Real servers
 as LVS clients
Date: Thu, 10 Apr 2008 08:37:56 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0804100824350.30366@wm7d.net>
References: <200804091658.43490.j.stubbs@linkthink.co.jp>
 <200804101720.33657.j.stubbs@linkthink.co.jp> <Pine.LNX.4.64.0804100658460.22622@wm7d.net>
 <200804102357.17456.j.stubbs@linkthink.co.jp>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <200804102357.17456.j.stubbs@linkthink.co.jp>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Jason Stubbs <j.stubbs@linkthink.co.jp>
Cc: Horms <horms@vergenet.net>, Raphael Vallazza <raphael@endian.com>, Janusz Krzysztofik <jkrzyszt@tis.icnet.pl>, LVS Devel <lvs-devel@vger.kernel.org>

On Thu, 10 Apr 2008, Jason Stubbs wrote:

> Yep, I subscribed before posting the LC patches.

OK found your first posting. I had a quick look last time, 
but missed you.

>> There's an effort to move ipvs() out of LOCAL_IN. Horms is
>> coordinating the patches, but he's just moved from Japan to
>> Sydney and will be even busier than he's been previously.
>
> I'll be doing the same in January. ;)

I take it that you know Horms then :-)

> I'd like to look at what patches are currently available. 
> Is there somewhere I can find them?

I've been leaving it to Horms to keep track of the patches, 
but he's been too busy to incorporate them.

Horms,

 	Do you have the patches for moving ipvs() from 
LOCAL_IN (possibly including your code from a few years 
back). All the recent code, that I know about, came from 
Janusz and Raphael.

Janusz, Raphael,

 	Jason wants to have a go at moving ipvs() from 
LOCAL_IN. Can you send him your current set of patches? I 
can bounce him the patches that you've sent to lvs-devel if 
that's not convenient. I don't know if I have the complete 
or current patches.

> I can probably spend up to a week full-time on getting 
> things working in at least the -NAT case - if they aren't 
> already. At the very least, I'm happy to provide a(nother) 
> test bed for changes into the future.

thanks. That would be great. Let me know if you don't get 
code in the next couple of days.

> (Working from home at 23:57)

You're 11 hours back from me.

Joe

-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
