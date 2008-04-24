From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: IPVS IPv6: code and data structure reuse
Date: Thu, 24 Apr 2008 09:14:31 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0804240908370.5724@wm7d.net>
References: <f4845fc0804240432x7afcf927u70aace0b5f097dc0@mail.gmail.com> 
 <Pine.LNX.4.64.0804240516440.12876@wm7d.net>
 <f4845fc0804240838s342149f2v3113ae44ff773f87@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <f4845fc0804240838s342149f2v3113ae44ff773f87@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: lvs-devel@vger.kernel.org

On Thu, 24 Apr 2008, Julius Volz wrote:

> About running out of time: The good thing is that I can still continue
> on this regardless of my current employer, since the project is
> interesting by itself ;)

well you may have time in the future, but don't count on it. 
Things happen, your car needs repair, you go on vacation, 
someone calls you up with a neat idea and you'll find you 
have 3 months of ipvs_ipv6 code sitting on the shelf which 
isn't going anywhere. Plan on writing code to your current 
horizon and if that winds up being what time you have, then 
you won't have done all that work for nothing. If you can 
keep going, then there's no harm done.

THere's been two previous efforts to move the ipvs() hook 
from LOCAL_IN which have produced no code in the outside 
world, for what I presume is running out of time. The guy 
who did the original IPV6 port for LVS a long time ago, just 
disappeared. Presumably he didn't have time to update it.

Joe

-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
