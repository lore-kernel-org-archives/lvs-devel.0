From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: Ldirectord Feature Request
Date: Sat, 2 May 2009 05:33:43 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0905020531001.18799@wm7d.net>
References: <33afbbe70905011318j35d226a6h31e0dfaeb1b77b45@mail.gmail.com>
 <20090502021644.GA15603@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20090502021644.GA15603@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Caleb Anthony <caleb.anthony@gmail.com>, lvs-devel@vger.kernel.org


On Sat, 2 May 2009, Simon Horman wrote:

> I'll double check, but I think the weight specifies a proportion
> of conections rather than an absolute number. Could you let
> me know which documentation you are looking at?

it's the number of connections

see section 4.10.2 of

http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.ipvsadm.html#SH-scheduler

no-one used the -SH scheduler for years because no-one 
understood how to use it. I expect that weighting by the 
number of connections was probably the easiest to code up, 
but it's not particularly useful

Joe

-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
