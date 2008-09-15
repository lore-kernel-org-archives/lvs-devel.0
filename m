From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: Adding SNAT support to LVS/NAT
Date: Mon, 15 Sep 2008 08:24:38 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0809150815580.32594@wm7d.net>
References: <f4845fc0809130412n41967d79l1240558492c84cb7@mail.gmail.com>
 <Pine.LNX.4.64.0809131100320.20936@wm7d.net>
 <f4845fc0809131731g7f953b21t57aa226ebdc9641e@mail.gmail.com>
 <Pine.LNX.4.64.0809131835001.12375@wm7d.net>
 <f4845fc0809140339p1d3be327j98ddcb02c4efc786@mail.gmail.com>
 <f4845fc0809140747u63f6ad63m43877bbbf09c4778@mail.gmail.com>
 <20080915014337.GA10026@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20080915014337.GA10026@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Julius Volz <juliusv@google.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, j.stubbs@linkthink.co.jp, Siim =?iso-8859-1?Q?P=F5der?= <siim@p6drad-teel.net>

On Mon, 15 Sep 2008, Simon Horman wrote:

> Well, it would be a problem if it gets DNATed a second time.

Are you just being really safe? Are you trying to prevent 
someone from adding DNAT rules to OUTPUT?

Would it be better (as much as possible) for LVS to appear 
to be just another netfilter module, in which case if 
someone wants to DNAT in OUTPUT, this should be allowed 
(whether it's sensible or not). Currently LVS-NAT doesn't 
allow SNAT on OUTPUT, which no-one thought about when 
LVS-NAT was first written and it turns out to be useful.

Joe

-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
