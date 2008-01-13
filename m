From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: [PATCH] Runtime interception method switch
Date: Sun, 13 Jan 2008 09:59:26 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0801130758580.32303@wm7d.net>
References: <07C2E63F-FDF8-45D5-A20C-0B294C119A5E@endian.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <07C2E63F-FDF8-45D5-A20C-0B294C119A5E@endian.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: LVS Devel <lvs-devel@vger.kernel.org>

On Sun, 13 Jan 2008, Raphael Vallazza wrote:

> 3. PREROUTING Intercept incoming connections before DNAT 
> and input filtering has been applied, this enables 
> transparent proxying on realnodes and localnode.

Raphael,

 	What's the best way of implementing F5-SNAT? All 
packets must arrive at the realservers with src_addr=DIP. 
Where should ipvs be hooked and where should the iptables 
rules be to NAT the packets?

client: CIP->VIP:80

ipvs on LVS-NAT director: CIP->RIP:80

iptables rules on director (in POSTROUTING?) DIP->RIP:80

realserver: RIP:80->DIP

iptables rules on director RIP:80->CIP

ipvs on LVS-NAT director: VIP:80->CIP

client: gets packet VIP:80->CIP

Thanks 
Joe
-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
