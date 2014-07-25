From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH ipvs 1/2] ipvs: Do tcp/udp checksumming prior to tunnel
 xmit
Date: Fri, 25 Jul 2014 11:53:24 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1407251105430.1554@ja.home.ssi.bg>
References: <1406097465-8180-1-git-send-email-agartrell@fb.com> <alpine.LFD.2.11.1407231054180.5114@ja.home.ssi.bg> <B3481EE3D901EA4983A2D2CFBA42F3AA700E2782@PRN-MBX01-3.TheFacebook.com> <alpine.LFD.2.11.1407240116400.2125@ja.home.ssi.bg>
 <alpine.LFD.2.11.1407240915400.1538@ja.home.ssi.bg> <20140724152921.44d4e3bd@agartrell-SH67H> <alpine.LFD.2.11.1407250651190.1554@ja.home.ssi.bg> <CFF7396F.4159B%agartrell@fb.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811672-1397102281-1406278405=:1554"
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <CFF7396F.4159B%agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Alex Gartrell <agartrell@fb.com>
Cc: "horms@verge.net.au" <horms@verge.net.au>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, kernel-team <Kernel-team@fb.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-1397102281-1406278405=:1554
Content-Type: TEXT/PLAIN; charset="utf-8"
Content-Transfer-Encoding: 8bit


	Hello,

On Fri, 25 Jul 2014, Alex Gartrell wrote:

> The driver in question is mlx4_en version 2.2-1
> 
> In this case, we have MLX4_TUNNEL_OFFLOAD_MODE turned off, so
> hw_enc_features is set to 0.

	ok

> >	Also, can you clarify again which test has
> >the problem with broken csums? All 3 tests? Or it
> >depends on enabled HW csums?
> 
> We run into problems with packets captured from NF_INET_LOCAL_OUT when
> we have hardware checksumming enabled.  Disabling hardware checksumming
> fixes the problem by removing the bits from the features and makes it
> act roughly the same as just setting the encapsulation bit

	ok, so it matches my understanding. I was
afraid you have problems with HW csum disabled.

> >From my reading, the pseudo code for it is basically as follows
> 
> Features = device_features # which has a bunch of stuff, including full
> checksumming
> 
> If skb->encapsulated:
>     Features = device_encapsulated_features # which is zero
> 
> If needs_gso(skb, features) # requires that gso params are set and that
> the features have it
>     # gso segment stuff
> Else
>     If skb->ip_summed == CHECKSUM_PARTIAL: # This is us
>          If skb->encapsulation:
>              skb_set_inner_transport_header(skb,
> skb_checksum_start_offset(skb))
>          Else
>              set_transport_header(skb, skb_checksum_start_offset(skb))
>          If !(features & NETIF_F_ALL_CSUM): # Basically equal to
> skb->encapsulation for us
>              If skb_checksum_help(skb) # will do the software checksumming
> we need
>                     # do error stuff

	I understand all this, that is the reason for
my patch.

> Taking a second look, I think that the problem with my approach is
> that it won¹t take advantage of gso offload for ipip encapsulation.
> Strictly speaking, I don¹t think we need it (the volume of ipvs
> Traffic originating from the host itself is almost always going to
> be negligible).  That said, taking advantage is clearly the right
> way to do it.
> 
> With that in mind, my only problem with your patch is that ipv4 is
> inconsistent with ipv6.  Can we do something like this?  (Apologies,
> I¹m stuck with outlook at home and it is ruining the formatting)  The
> specific change is that we use the same iptunnel_handle_offloads
> Invocation in ipv4 and ipv6.  It¹s disconcerting to me that it¹s unclear
> if we can do IP6IP6 with gso offload ‹ any thoughts there?

	That is my doubt too. iptunnel_handle_offloads is
called only for IPv4 tunnels, even in net/ipv6/. OTOH,
ip6_tnl_xmit2() does everything directly, that is why
I choosed the same thing for IPv6. I don't see value to use
instead of SKB_GSO_IPIP. Looking at ipv4_offload_init()
for IPv4 there is offload support for TCP, UDP and IPIP.
ipv6_offload_init() shows support for TCP, UDP,
via ipv6_exthdrs_offload_init for IPPROTO_ROUTING and
IPPROTO_DSTOPTS), sit_offload (IPPROTO_IPV6). So, it
may be possible to use iptunnel_handle_offloads for IPv6.

	We may need help from experts in this area. So,
I'll post the patch as RFC on netdev after little
research for GRO/GSO.

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-1397102281-1406278405=:1554--
