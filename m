From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: Adding SNAT support to LVS/NAT
Date: Sat, 13 Sep 2008 18:37:59 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0809131835001.12375@wm7d.net>
References: <f4845fc0809130412n41967d79l1240558492c84cb7@mail.gmail.com> 
 <Pine.LNX.4.64.0809131100320.20936@wm7d.net>
 <f4845fc0809131731g7f953b21t57aa226ebdc9641e@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <f4845fc0809131731g7f953b21t57aa226ebdc9641e@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, j.stubbs@linkthink.co.jp

On Sun, 14 Sep 2008, Julius Volz wrote:

> So maybe it would already work? ;)

No. Some highly motivated people tried doing SNAT on OUTPUT 
in an attempt to do F5-SNAT and it didn't work. This lead to 
the write up in

http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.non-modified_realservers.html#F5_snat

which brings us to where we are now.

Joe

-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
