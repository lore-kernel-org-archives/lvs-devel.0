From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: Adding SNAT support to LVS/NAT
Date: Sat, 13 Sep 2008 11:17:33 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0809131100320.20936@wm7d.net>
References: <f4845fc0809130412n41967d79l1240558492c84cb7@mail.gmail.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <f4845fc0809130412n41967d79l1240558492c84cb7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, j.stubbs@linkthink.co.jp

On Sat, 13 Sep 2008, Julius Volz wrote:

> Hi,
>
> I'm wondering about how hard it would be to add SNAT 
> support to IPVS (that is, the director rewriting packets 
> from the client to backends to appear to be from the VIP 
> and some randomly allocated port).

when we've discussed it before, the packets will appear to 
come from the DIP, a private IP (or whatever IP the servers 
were using for their default route before they were put into 
an LVS).

> This would allow us to have remote real servers with 
> LVS/NAT.

more importantly, people who are bound by serious IT rules 
setup by managers, can duplicate their (real) servers only 
with a change in RIP on each server and can keep the default 
route.

> I realize that Jason Stubb's PRE/POSTROUTING patches would 
> also make this possible, but they seemed risky and we 
> haven't heard of them in a long time.

Jason just sent me his current patch this week. You could 
ask him for it directly. Apparently it's little/no different 
to the patch he posted at

http://archive.linuxvirtualserver.org/html/lvs-devel/2008-04/msg00041.html

(hope I'm paraphrasing Horms correctly here...)
Horms would be happy to have this in the main release if it 
could be invoked as an option.

> Also, having this option directly integrated into the rest 
> of the IPVS NAT code might make it easier to use: just add 
> another flag on the ipvsadm command line when you want 
> SNAT for an LVS/NAT backend.

sounds great to me.

From talking to Horms, LVS-NAT (and possibly LVS-DR) sends 
the packets to the realservers via

ip_vs_post_routing()

which bypasses the OUTPUT chain. It would seem to me that if 
you instead injected the packets into the OUTPUT chain, then 
normal iptables rules could handle the SNAT to the 
realservers. It might be slower that rewriting the packets 
yourself, but for a first attempt, I think people will be so 
happy to have the functionality that they won't quibble 
about speed.

Joe

-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
