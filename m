From: "Julius Volz" <juliusv@google.com>
Subject: Re: Adding SNAT support to LVS/NAT
Date: Tue, 16 Sep 2008 22:45:14 +0200
Message-ID: <f4845fc0809161345r2f24cfa4sf33bd9173f50041b@mail.gmail.com>
References: <f4845fc0809130412n41967d79l1240558492c84cb7@mail.gmail.com>
	 <Pine.LNX.4.64.0809131100320.20936@wm7d.net>
	 <f4845fc0809131731g7f953b21t57aa226ebdc9641e@mail.gmail.com>
	 <Pine.LNX.4.64.0809131835001.12375@wm7d.net>
	 <f4845fc0809140339p1d3be327j98ddcb02c4efc786@mail.gmail.com>
	 <f4845fc0809140747u63f6ad63m43877bbbf09c4778@mail.gmail.com>
	 <20080915014337.GA10026@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1221597917; bh=WKVMi6we/1laZdJxrL6nbgXYypc=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=m2OfYOqlTo6eqoIX/NWhAh2dWXKEfA7p
	GnD7jWjZjgOOfwh9vu+H/kZIHH4sMXRzsMOKwdqanAtEWt/+9xuVIg==
In-Reply-To: <20080915014337.GA10026@verge.net.au>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="windows-1252"
To: Simon Horman <horms@verge.net.au>
Cc: Joseph Mack NA3T <jmack@wm7d.net>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, j.stubbs@linkthink.co.jp, =?ISO-8859-1?Q?Siim_P=F5der?= <siim@p6drad-teel.net>, Vince Busam <vbusam@google.com>

On Mon, Sep 15, 2008 at 3:43 AM, Simon Horman <horms@verge.net.au> wrot=
e:
> On Sun, Sep 14, 2008 at 04:47:51PM +0200, Julius Volz wrote:
>> On Sun, Sep 14, 2008 at 12:39 PM, Julius Volz <juliusv@google.com> w=
rote:
>> > On Sun, Sep 14, 2008 at 3:37 AM, Joseph Mack NA3T <jmack@wm7d.net>=
 wrote:
>> >> On Sun, 14 Sep 2008, Julius Volz wrote:
>> >>
>> >>> So maybe it would already work? ;)
>> >>
>> >> No. Some highly motivated people tried doing SNAT on OUTPUT in an=
 attempt to
>> >> do F5-SNAT and it didn't work. This lead to the write up in
>> >>
>> >> http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.non-modifi=
ed_realservers.html#F5_snat
>> >>
>> >> which brings us to where we are now.
>> >
>> > Thanks for the info! Right, I even said myself in the previous rep=
ly
>> > that ip_vs_postrouting() stops further processing in the POSTROUTI=
NG
>> > chain, so it never reaches netfilter NAT code.
>>
>> Actually, what if we modify or remove that function to allow further
>> processing in POSTROUTING? Could SNAT work with IPVS then?
>>
>> The comment above it says that the function specifically wants to
>> avoid further NAT by netfilter. But is this always a problem?
>
> Well, it would be a problem if it gets DNATed a second time.
> But perhaps we can take a slightly different approach such that
> we protect against DNAT while allowing SNAT.

So I did some experiments and removed the ip_vs_post_routing()
function that stops further POSTROUTING processing. I added an SNAT
rule to POSTROUTING like this:

$ iptables =96t nat =96A POSTROUTING =96o eth1 =96j SNAT =96-to $DIP

Amazingly, the first SYN and the SYN/ACK of a TCP connection to the
VIP:vport do not traverse the NAT chain in POSTROUTING at all
(verified by LOG target), so their source is not rewritten (like in
normal LVS/NAT). However, the client's ACK response to the SYN/ACK
finally appears in this table and only this third packet is SNATed
correctly (the real server then answers with an RST, since it doesn't
know a connection from that source). The packet trace on the director
looks something like this:

Packet 1:
CIP =3D> VIP SYN (eth0, before IPVS)
CIP =3D> RIP SYN (eth1, after IPVS)

Packet 2:
RIP =3D> CIP SYN/ACK (eth1, before IPVS)
VIP =3D> CIP SYN/ACK (eth0, after IPVS)

Packet 3:
CIP =3D> VIP ACK (eth0, before IPVS)
DIP =3D> RIP ACK (eth1, after IPVS) - this is the first successfully
SNATed packet!

Packet 4:
RIP =3D> DIP RST - real server doesn't know this connection from the DI=
P

Any ideas why the first packets never appear in the POSTROUTING chain?
I do not understand this, since IPVS injects all handled packets into
the OUTPUT chain, whereafter they should traverse POSTROUTING...

Without any IPVS, SNAT works without any problems and as expected,
only the first (SYN) packet of a connection appears on the POSTROUTING
chain.

> Perhaps it might just be easier to allow iptables to explictly match
> packets that have been mangled by LVS-NAT. Perhaps by poviding
> a match rule for skb->ipvs_property? Or by using Siim P=F5der's match
> against connections in the LVS connection table.
>
> http://lists.graemef.net/pipermail/lvs-users/2008-July/021081.html

Thanks, interesting! Though for processing an already IPVS-ed packet
in POSTROUTING, it should be enough to match on skb->ipvs_property, I
think.

Julius

--=20
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
