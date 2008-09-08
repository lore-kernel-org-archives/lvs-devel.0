From: "Julius Volz" <juliusv@google.com>
Subject: Re: [rfc 0/3] IPVS: checksum updates
Date: Mon, 8 Sep 2008 14:14:12 +0200
Message-ID: <f4845fc0809080514i6118cc4bt6510da3d93483156@mail.gmail.com>
References: <20080908020420.313463898@vergenet.net>
	 <f4845fc0809080303s53094205kc045e6003014cd24@mail.gmail.com>
	 <20080908104120.GB5795@verge.net.au>
	 <20080908114258.GA29477@google.com>
	 <20080908115734.GA24228@verge.net.au>
	 <20080908120413.GB24228@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220876055; bh=jCsd4H6t2W+sLAnKNXnlyQIrXU0=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=TG5KH4tniUxeR30OZWOFNTIiRIzceLqe
	GaWMsf8NRawbchXPh5LAyqp64/M3oUcld/JdemfA/rgtYq2MpQ5DVg==
In-Reply-To: <20080908120413.GB24228@verge.net.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, =?ISO-8859-1?Q?Siim_P=F5der?= <siim@p6drad-teel.net>, Julian Anastasov <ja@ssi.bg>, Malcolm Turnbull <malcolm@loadbalancer.org>, Vince Busam <vbusam@google.com>, Herbert Xu <herbert@gondor.apana.org.au>

On Mon, Sep 8, 2008 at 2:04 PM, Simon Horman <horms@verge.net.au> wrote:
> On Mon, Sep 08, 2008 at 09:57:35PM +1000, Simon Horman wrote:
>> On Mon, Sep 08, 2008 at 01:42:59PM +0200, Julius Volz wrote:
>> > On Mon, Sep 08, 2008 at 08:41:22PM +1000, Simon Horman wrote:
>> > > On Mon, Sep 08, 2008 at 12:03:04PM +0200, Julius Volz wrote:
>> > > > On Mon, Sep 8, 2008 at 4:04 AM, Simon Horman wrote:
>> > > > > Hi,
>> > > > >
>> > > > > The impetus for this series of patches is Julian Anastasov noting
>> > > > > that "load balance IPv4 connections from a local process" checks
>> > > > > for 0 TCP checksums. Herbert Xu confirmed that this is not legal,
>> > > > > even on loopback traffic, but that rather partial checksums are
>> > > > > possible.
>> > > > >
>> > > > > The first patch in this series is a proposed solution to handle
>> > > > > partial checksums for both TCP and UDP.
>> > > > >
>> > > > > The other two patches clean things up a bit.
>> > > > >
>> > > > > I have not tested this code beyond compilation yet.
>> > > >
>> > > > After some first tests, remote connections are still working, but not
>> > > > local ones from the director. The TCP handshake works and the
>> > > > connection is established, but all following packets arriving at the
>> > > > real server have an incorrect TCP checksum.
>> > > >
>> > > > Btw., this happens both with and without this last series of patches,
>> > > > so I can't get the local client feature working at all. Looking at it
>> > > > further...
>> > >
>> > > Ok, is this for both IPv4 & IPv6? Does it still occur with just the first
>> > > patch in this series applied?
>> >
>> > It's for both, although I only tested IPv4 at first. Here is a complete
>> > test matrix of what works when:
>> >
>> > CR = connection refused
>> > T = connection timeout
>> > C = connection established, but not working afterwards
>> > OK = working
>> >
>> >                     remote client | local client
>> > COMMIT                      v4      v6    | v4      v6
>> > ======================================|=================
>> > CSUM 3/3            OK      T     | C       T
>> > CSUM 2/3            OK      T     | C       T
>> > CSUM 1/3            OK      T     | OK      T
>> > W/O CSUM            OK      T     | C       T
>> > ...                               |
>> > f2428ed5            OK      T     | CR      CR
>> > 4856c84c            OK      CR    | CR      CR
>> > f94fd041 (my last one)      OK      OK    | CR      CR
>> >
>> > So the last time that IPv6 was working _at all_ was at my last commit of
>> > the big v6 series...
>>
>> Ok, I'm really sorry about that :-(
>>
>> Do you want me to revert f2428ed5 & 4856c84c until this has been tracked down?
>>
>
> Hi,
>
> Does 4856c84c + the following change (which you pointed out over the
> weekend) work for remote IPv6 ?
>
> diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
> index 26e3d99..c413444 100644
> --- a/net/ipv4/ipvs/ip_vs_core.c
> +++ b/net/ipv4/ipvs/ip_vs_core.c
> @@ -1282,7 +1282,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb,
>         *      Don't handle local packets on IPv6 for now
>         */
>        if (unlikely(skb->pkt_type != PACKET_HOST ||
> -                    (af == AF_INET6 || (skb->dev->flags & IFF_LOOPBACK ||
> +                    (af == AF_INET6 && (skb->dev->flags & IFF_LOOPBACK ||
>                                         skb->sk)))) {
>                IP_VS_DBG_BUF(12, "packet type=%d proto=%d daddr=%s ignored\n",
>                              skb->pkt_type,
>

No, that just changes the behavior from "connection refused" to timeout...

I'm actually looking at that case now (4856c84c1358b, but with the fix
above). It seems that the NAT isn't working (DR works, by the way!).
At least the first packet arriving at the real server still has the
client's IP as the source (in the v6 case)...

Let's wait with reverting the local client patches until tomorrow...
maybe I can find the problem until then.

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
