From: Jason Stubbs <jasonbstubbs@gmail.com>
Subject: Re: moving ipvs() to POST/PREROUTING
Date: Sat, 12 Apr 2008 09:06:09 +0900
Message-ID: <200804120906.09863.jasonbstubbs@gmail.com>
References: <200804111400.12331.j.stubbs@linkthink.co.jp> <200804120015.41545.jasonbstubbs@gmail.com> <Pine.LNX.4.64.0804110908240.13199@wm7d.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0804110908240.13199@wm7d.net>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Joseph Mack NA3T <jmack@wm7d.net>
Cc: LVS Devel <lvs-devel@vger.kernel.org>

On Saturday 12 April 2008 01:14:08 JST, Joseph Mack NA3T wrote:
> On Sat, 12 Apr 2008, Jason Stubbs wrote:
> >> I would hope people don't do this. RIPs should be private,
> >> for security reasons and to preserve the fiction that the
> >> LVS setup is one machine.
> >
> > This is precisely why I chose the hooks that I did. My intention was for
> > the netfilter chains to only ever see the VIP, but packets with the RIP
> > are going through too after IP_VS_XMIT is called.
>
> hmm. still don't know what you're referring to then. Is this
> LVS-NAT, LVS-DR...?
>
> netfilter sees the source and dest on the packets. How can
> netfilter only see the VIP?

Current LVS-NAT goes something like:
PREROUTING  client => VIP
LOCAL_IN    client => VIP
    LVS in hook
LOCAL_OUT   client => RIP
POSTROUTING client => RIP

With my patch it goes like:
PREROUTING  client => VIP
FORWARD     client => VIP
POSTROUTING client => VIP
    LVS hook
POSTROUTING client => RIP

LVS-DR is pretty much the same flow except that the packet's MAC destination 
is changed instead. What I mean with netfilter only seeing the VIP is that 
I'd like the second POSTROUTING run that happens with my patch to not happen. 
Doing so makes rule writing on the director a little easier as the rules 
don't need to know about the RIPs at all.

The configuration I'm planning to use is a LVS-NAT director/firewall that 
allows external traffic to VIPs, SNATs traffic from RIPs to external 
(including to VIPs) and drops everything else.

With LVS-DR, I am pretty sure that all the issues mentioned in the page you 
linked to still apply as my patch only changes the flow through the director. 
The rules mentioned in the following link would be needed whether the 
SERVER_GW is separate device to the director or not.

http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.non-lvs_clients_on_realservers.html#3-tier_routes

-- 
Jason Stubbs
