From: Jason Stubbs <j.stubbs@linkthink.co.jp>
Subject: Re: moving ipvs() to POST/PREROUTING
Date: Sat, 12 Apr 2008 21:59:45 +0900
Message-ID: <200804122159.45792.j.stubbs@linkthink.co.jp>
References: <200804111400.12331.j.stubbs@linkthink.co.jp> <Pine.LNX.4.58.0804121021110.2942@u.domain.uli>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.58.0804121021110.2942@u.domain.uli>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: LVS Devel <lvs-devel@vger.kernel.org>

On Saturday 12 April 2008 18:07:59 JST, Julian Anastasov wrote:
> 	Hello,
>
> On Fri, 11 Apr 2008, Jason Stubbs wrote:
> > Greetings,
> >
> > Ok, things are mostly working now. The patch is a little messy as in
> > there's old comments remaining and function names are left as is, but
> > hopefully reviewable. If it's not, I'll split it up and add appropriate
> > comments...
>
> 	Your changes will break existing setups. I'll recommend
> you to start by reading http://www.ssi.bg/~ja/LVS.txt. I just updated
> it with some 2.6 info as it was too old document. There you can
> see some requirements and motivation why IPVS uses specific hooks and
> priority.

My initial expectation was that this sort of patch wouldn't be integrated 
because it does break existing setups, but that these or similar changes 
would need to occur regardless. Thanks for link. I'd already learnt about 
half of what's written from reading the netfilter sources, but it answers a 
lot of the more difficult questions.

> 	I think, for such changes there are many things to be considered
> and carefully tested:
>
> - all forwarding methods can be tested on LAN, even LVS-TUN
> - forwarding of related ICMP traffic (ICMP errors) in both directions,
> for all methods
> - ICMP generation to both sides (client and real server): when there is no
> real server, when skb is longer than PMTU.
> - scheduling by nfmark
> - firewall: at least basic packet fields matching
> - ip_vs_ftp testing (LVS-NAT) when netfilter ftp module is in
> effect: test if double NAT happens resulting in broken packets (TCP
> sequence numbers or payload) when payload is changed if IP:PORT
> strings in FTP commands have different length (VIP and RIP).

I've tested LVS-NAT and LVS-DR on a LAN, but haven't tested any of the others 
yet. I'm confident that they all still work or can be made to work with very 
little tweaking though. Another thing listed in your link above that I 
probably need to test and address is fragmented packet handling.

> 	Note that there are many new changes in Netfilter and
> Networking after IPVS was included in early 2.6. Even I already don't know
> what happens in latest kernels for POST_ROUTING, with fragmentation, etc.
> May be some things work by luck because IPVS tries to work closely with
> Netfilter without breaking things. That is why a careful testing is needed
> for any new changes if such changes are planned for inclusion in kernel.

Whether included or not, I need to test the changes before putting it in 
production. ;)

> > With local node, 127.0.0.1 doesn't work but an IP address on a local
> > interface does. When the address is 127.0.0.1, the SYN makes it all the
> > way through INPUT, but the SYN/ACK doesn't come into OUTPUT. Something to
> > investigate further... Also, null_xmit doesn't work as ipvs_in is being
> > done in POSTROUTING, so I've simple aliased LOCAL to MASQ for the time
> > being.
>
> 	LOCAL replaced with MASQ? Such changes can not be accepted for
> inclusion, they break existing setups just because something does not
> work in your new way to handle things.

Local node via a local interface address works fine - only 127.0.0.1 doesn't. 
I have a plan on how to fix this though, so existing setups won't be broken 
for this point.

> You should always remember that there must be a reason some code to exist. 
> If you really want to modify IPVS I'll recommend you to create some short 
> document that explains:  

<snip>

I'll put those things together. And thanks for the other info on how to test 
things.

> 	IPVS traffic should not be NAT-ed by Netfilter. This double-NAT
> leads to broken packets as I already mentioned above.
>
> 	What I do not understand is what is the end goal for your
> changes? Speed or IPVS traffic to fully benefit from Netfilter features?
> Or some setup does not work?

I can understand that trying to use DNAT with LVS is not a good idea, but SNAT 
is needed to allow access to VIPs from real servers when using LVS-NAT. That 
and making firewall rules a little easier to write are my goals. 
Unfortunately speed will actually decrease a little unless connection 
tracking is disabled.

--
Jason Stubbs
