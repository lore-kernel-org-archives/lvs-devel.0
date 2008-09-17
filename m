From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: Adding SNAT support to LVS/NAT
Date: Wed, 17 Sep 2008 15:53:15 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0809171552030.9336@wm7d.net>
References: <f4845fc0809130412n41967d79l1240558492c84cb7@mail.gmail.com> 
 <Pine.LNX.4.64.0809131100320.20936@wm7d.net> 
 <f4845fc0809131731g7f953b21t57aa226ebdc9641e@mail.gmail.com> 
 <Pine.LNX.4.64.0809131835001.12375@wm7d.net> 
 <f4845fc0809140339p1d3be327j98ddcb02c4efc786@mail.gmail.com> 
 <f4845fc0809140747u63f6ad63m43877bbbf09c4778@mail.gmail.com> 
 <20080915014337.GA10026@verge.net.au> <f4845fc0809161345r2f24cfa4sf33bd9173f50041b@mail.gmail.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <f4845fc0809161345r2f24cfa4sf33bd9173f50041b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, j.stubbs@linkthink.co.jp, =?ISO-8859-1?Q?Siim_P=F5der?= <siim@p6drad-teel.net>, Vince Busam <vbusam@google.com>

On Tue, 16 Sep 2008, Julius Volz wrote:

> Amazingly, the first SYN and the SYN/ACK of a TCP connection to the
> VIP:vport do not traverse the NAT chain in POSTROUTING at all

:-(

> (verified by LOG target),

you didn't see the packets in the logs?

Joe

-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
