From: "Julius Volz" <juliusv@google.com>
Subject: Re: Adding SNAT support to LVS/NAT
Date: Sun, 14 Sep 2008 02:31:15 +0200
Message-ID: <f4845fc0809131731g7f953b21t57aa226ebdc9641e@mail.gmail.com>
References: <f4845fc0809130412n41967d79l1240558492c84cb7@mail.gmail.com>
	 <Pine.LNX.4.64.0809131100320.20936@wm7d.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1221352277; bh=SITwK3eKw4MtoBaYSgq1NPcP9zc=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=baCc4LDrTqfI8AKLPYpKQMxlXKErVeG1
	EJGfuRPvGiUygTUlwNCcTDSOjMESXucSpeh8A6w4qeRPfwl1Qldeew==
In-Reply-To: <Pine.LNX.4.64.0809131100320.20936@wm7d.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Joseph Mack NA3T <jmack@wm7d.net>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, j.stubbs@linkthink.co.jp

On Sat, Sep 13, 2008 at 8:17 PM, Joseph Mack NA3T <jmack@wm7d.net> wrote:
> On Sat, 13 Sep 2008, Julius Volz wrote:
>
>> Hi,
>>
>> I'm wondering about how hard it would be to add SNAT support to IPVS (that
>> is, the director rewriting packets from the client to backends to appear to
>> be from the VIP and some randomly allocated port).
>
> when we've discussed it before, the packets will appear to come from the
> DIP, a private IP (or whatever IP the servers were using for their default
> route before they were put into an LVS).

Good point, that would be better in some circumstances. We're already
looking up the route to the real server anyways and I think the route
entry also contains the source IP that a packet to that host would
have.

>> This would allow us to have remote real servers with LVS/NAT.
>
> more importantly, people who are bound by serious IT rules setup by
> managers, can duplicate their (real) servers only with a change in RIP on
> each server and can keep the default route.

Right!

>> I realize that Jason Stubb's PRE/POSTROUTING patches would also make this
>> possible, but they seemed risky and we haven't heard of them in a long time.
>
> Jason just sent me his current patch this week. You could ask him for it
> directly. Apparently it's little/no different to the patch he posted at
>
> http://archive.linuxvirtualserver.org/html/lvs-devel/2008-04/msg00041.html
>
> (hope I'm paraphrasing Horms correctly here...)
> Horms would be happy to have this in the main release if it could be invoked
> as an option.

Ok, just from the replies in that thread, it sounds like you have to
rethink many assumptions and cases which might be dangerous with that
patch. Or have these worries been resolved? Then it would be a nice
thing to have, of course.

>> Also, having this option directly integrated into the rest of the IPVS NAT
>> code might make it easier to use: just add another flag on the ipvsadm
>> command line when you want SNAT for an LVS/NAT backend.
>
> sounds great to me.
>
> From talking to Horms, LVS-NAT (and possibly LVS-DR) sends the packets to
> the realservers via
>
> ip_vs_post_routing()

Hm, that happens in ip_vs_in(), which then calls the connection's
transmit function. ip_vs_postrouting() just stops further netfilter
hook processing for packets handled by IPVS.

> which bypasses the OUTPUT chain. It would seem to me that if you instead
> injected the packets into the OUTPUT chain, then normal iptables rules could
> handle the SNAT to the realservers. It might be slower that rewriting the
> packets yourself, but for a first attempt, I think people will be so happy
> to have the functionality that they won't quibble about speed.

Looks like the packet is already injected into the OUTPUT chain in
IP_VS_XMIT(). To transmit the packet to the real server, it does:

NF_HOOK(PF_INET, NF_INET_LOCAL_OUT, (skb), NULL,
                (rt)->u.dst.dev, dst_output);

So maybe it would already work? ;)

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
