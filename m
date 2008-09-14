From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: Adding SNAT support to LVS/NAT
Date: Sun, 14 Sep 2008 08:14:18 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0809140809500.5635@wm7d.net>
References: <f4845fc0809130412n41967d79l1240558492c84cb7@mail.gmail.com> 
 <Pine.LNX.4.64.0809131100320.20936@wm7d.net> 
 <f4845fc0809131731g7f953b21t57aa226ebdc9641e@mail.gmail.com> 
 <Pine.LNX.4.64.0809131835001.12375@wm7d.net> 
 <f4845fc0809140339p1d3be327j98ddcb02c4efc786@mail.gmail.com>
 <f4845fc0809140747u63f6ad63m43877bbbf09c4778@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <f4845fc0809140747u63f6ad63m43877bbbf09c4778@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, j.stubbs@linkthink.co.jp

On Sun, 14 Sep 2008, Julius Volz wrote:

> Actually, what if we modify or remove that function to 
> allow further processing in POSTROUTING? Could SNAT work 
> with IPVS then?

sounds OK by me. You should get an opinion from people who 
know the code better than I do.

> The comment above it says that the function specifically 
> wants to avoid further NAT by netfilter. But is this 
> always a problem?

I assume the function is there

o to speed up LVS (useful but not required for LVS-NAT)

o to push the layer 2 packet for LVS-DR out on the wire. 
This packet has the MAC address of the RIP, but 
dst_addr=VIP, so can't be sent through routing.

Joe

-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
