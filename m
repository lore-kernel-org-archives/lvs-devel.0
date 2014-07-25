From: Alex Gartrell <agartrell@fb.com>
Subject: Re: [PATCH ipvs 1/2] ipvs: Do tcp/udp checksumming prior to tunnel
 xmit
Date: Fri, 25 Jul 2014 07:40:50 +0000
Message-ID: <CFF7396F.4159B%agartrell@fb.com>
References: <1406097465-8180-1-git-send-email-agartrell@fb.com>
 <alpine.LFD.2.11.1407231054180.5114@ja.home.ssi.bg>
 <B3481EE3D901EA4983A2D2CFBA42F3AA700E2782@PRN-MBX01-3.TheFacebook.com>
 <alpine.LFD.2.11.1407240116400.2125@ja.home.ssi.bg>
 <alpine.LFD.2.11.1407240915400.1538@ja.home.ssi.bg>
 <20140724152921.44d4e3bd@agartrell-SH67H>
 <alpine.LFD.2.11.1407250651190.1554@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : references : in-reply-to : content-type : content-id :
 content-transfer-encoding : mime-version; s=facebook;
 bh=Nn816GK4tVfXo5phlXsZZjocyQkP7MeT6dvQ7PKG9LU=;
 b=ehDGr7izhxEjvCbeyhiw9gxqA/Nt5Zdmz7F3ludZ2SrfPznJ+bp3P0Mo95OXLp+KwHC2
 oV4bOtrpOJ4Lng16R9wIgt+d0S2unR2LlriW65ZIDZxUJ6RrWhn8ovqLiNVahQr/k4AA
 rgbANUAEAuJAZNoPutM4qxMZUleQ2aknf34= 
In-Reply-To: <alpine.LFD.2.11.1407250651190.1554@ja.home.ssi.bg>
Content-Language: en-US
Content-ID: <C41D71D918DDF04EA21D3FC6ECB68658@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="windows-1252"
To: Julian Anastasov <ja@ssi.bg>
Cc: "horms@verge.net.au" <horms@verge.net.au>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, kernel-team <Kernel-team@fb.com>

Hey

On 7/24/14, 9:30 PM, "Julian Anastasov" <ja@ssi.bg> wrote:

>
>	Hello,
>
>On Thu, 24 Jul 2014, Alex Gartrell wrote:
>
>> So I've found a patch that addresses the problem in what I suspect i=
s
>>the
>> right way.
>>=20
>> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c
>>b/net/netfilter/ipvs/ip_vs_xmit.c
>> index 6f70bdd..ea7ef5e 100644
>> --- a/net/netfilter/ipvs/ip_vs_xmit.c
>> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
>> @@ -486,6 +486,7 @@ static inline int ip_vs_tunnel_xmit_prepare(stru=
ct
>>sk_buff *skb,
>>         if (ret =3D=3D NF_ACCEPT) {
>>                 nf_reset(skb);
>>                 skb_forward_csum(skb);
>> +               skb->encapsulation =3D 1;
>>         }
>>         return ret;
>>  }
>>=20
>> Empirically, this solves my problem :) I believe it solves the probl=
em
>>more
>> generally as well.
>>=20
>> Digging deeper into the v6 case (FB <3's v6)
>>=20
>> ip_vs_tunnel_xmit_v6
>> -> ip6_local_out
>> -> __ip6_local_out
>> -> dst_output
>> -> dst_output_sk
>> -> skb_dst(skb)->output (=3D ip6_output)
>> -> ip6_finish_output
>> -> ip6->finish_output2
>> -> neigh_direct_output
>> -> dev_queue_xmit
>> -> __dev_queue_xmit
>> -> dev_hard_start
>>=20
>> And then we run into this:
>>=20
>>         /* If encapsulation offload request, verify we are testing
>>          * hardware encapsulation features instead of standard
>>          * features for the netdev
>>          */
>>         if (skb->encapsulation)
>>                 features &=3D dev->hw_enc_features;
>>=20
>> This essentially strips out NETIF_F_ALL_CSUM, so we end up invoking
>> skb_checksum_help below.
>
>	For the case with missing NETIF_F_ALL_CSUM bits
>skb_checksum_help() does not care for skb->encapsulation,
>it works only by checking skb->csum_* fields. The
>skb_set_inner_transport_header() and skb_set_transport_header()
>calls simply update the header pointers for the drivers
>that have NETIF_F_ALL_CSUM bits set.
>
>	What is your driver? I have to check why do you
>have problem when NETIF_F_ALL_CSUM is not set. Is it
>missing the NETIF_F_IP_CSUM (v4) and NETIF_F_IPV6_CSUM (v6) bits?

The driver in question is mlx4_en version 2.2-1

In this case, we have MLX4_TUNNEL_OFFLOAD_MODE turned off, so
hw_enc_features is set to 0.


>	Also, can you clarify again which test has
>the problem with broken csums? All 3 tests? Or it
>depends on enabled HW csums?

We run into problems with packets captured from NF_INET_LOCAL_OUT when
we have hardware checksumming enabled.  Disabling hardware checksumming
fixes the problem by removing the bits from the features and makes it
act roughly the same as just setting the encapsulation bit

=46rom my reading, the pseudo code for it is basically as follows

=46eatures =3D device_features # which has a bunch of stuff, including =
full
checksumming

If skb->encapsulated:
    Features =3D device_encapsulated_features # which is zero

If needs_gso(skb, features) # requires that gso params are set and that
the features have it
    # gso segment stuff
Else
    If skb->ip_summed =3D=3D CHECKSUM_PARTIAL: # This is us
         If skb->encapsulation:
             skb_set_inner_transport_header(skb,
skb_checksum_start_offset(skb))
         Else
             set_transport_header(skb, skb_checksum_start_offset(skb))
         If !(features & NETIF_F_ALL_CSUM): # Basically equal to
skb->encapsulation for us
             If skb_checksum_help(skb) # will do the software checksumm=
ing
we need
                    # do error stuff


>
>>         /* If packet is not checksummed and device does not
>>          * support checksumming for this protocol, complete
>>          * checksumming here.
>>          */
>>         if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) {
>>                 if (skb->encapsulation)
>>                         skb_set_inner_transport_header(skb,
>>                                 skb_checksum_start_offset(skb));
>>                 else
>>                         skb_set_transport_header(skb,
>>                                 skb_checksum_start_offset(skb));
>>                 if (!(features & NETIF_F_ALL_CSUM) &&
>>                      skb_checksum_help(skb))
>>                         goto out_kfree_skb;
>>         }
>>=20
>> Does this seem like a reasonable approach to you, Julian?
>
>	Exactly, I was referring to this place. For IPv4
>we do the same as your change in ip_vs_tunnel_xmit_prepare,
>only that it is via iptunnel_handle_offloads() which in
>addition to setting skb->encapsulation adds SKB_GSO_IPIP bit
>for GSO purposes but skb_checksum_help() is called again
>in dev_hard_start_xmit().
>
>	Don't forget that the devices with NETIF_F_ALL_CSUM set
>need skb_reset_inner_headers() call, they use the
>skb->inner_* fields. What I have done in the patch is
>just to copy the handling from ip*_tunnel*.c. When
>NETIF_F_ALL_CSUM is not set we call skb_checksum_help() and
>then the device driver detects CHECKSUM_NONE, not
>CHECKSUM_PARTIAL.


Taking a second look, I think that the problem with my approach is
that it won=B9t take advantage of gso offload for ipip encapsulation.
Strictly speaking, I don=B9t think we need it (the volume of ipvs
Traffic originating from the host itself is almost always going to
be negligible).  That said, taking advantage is clearly the right
way to do it.

With that in mind, my only problem with your patch is that ipv4 is
inconsistent with ipv6.  Can we do something like this?  (Apologies,
I=B9m stuck with outlook at home and it is ruining the formatting)  The
specific change is that we use the same iptunnel_handle_offloads
Invocation in ipv4 and ipv6.  It=B9s disconcerting to me that it=B9s un=
clear
if we can do IP6IP6 with gso offload =8B any thoughts there?

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c
b/net/netfilter/ipvs/ip_vs_xmit.c
index 6f70bdd..b62a23e 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -37,6 +37,7 @@
 #include <net/icmp.h>                   /* for icmp_send */
 #include <net/route.h>                  /* for ip_route_output */
 #include <net/ipv6.h>
+#include <net/ip_tunnels.h>
 #include <net/ip6_route.h>
 #include <net/addrconf.h>
 #include <linux/icmpv6.h>
@@ -862,6 +863,10 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct
ip_vs_conn *cp,
 		old_iph =3D ip_hdr(skb);
 	}
=20
+	skb =3D iptunnel_handle_offloads(skb, false, SKB_GSO_IPIP);
+	if (IS_ERR(skb))
+		goto tx_error;
+
 	skb->transport_header =3D skb->network_header;
=20
 	/* fix old IP header checksum */
@@ -900,7 +905,8 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct
ip_vs_conn *cp,
 	return NF_STOLEN;
=20
   tx_error:
-	kfree_skb(skb);
+	if (!IS_ERR(skb))
+		kfree_skb(skb);
 	rcu_read_unlock();
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -953,6 +959,10 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct
ip_vs_conn *cp,
 		old_iph =3D ipv6_hdr(skb);
 	}
=20
+	skb =3D iptunnel_handle_offloads(skb, false, 0);
+	if (IS_ERR(skb))
+		goto tx_error;
+
 	skb->transport_header =3D skb->network_header;
=20
 	skb_push(skb, sizeof(struct ipv6hdr));
@@ -988,7 +998,8 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct
ip_vs_conn *cp,
 	return NF_STOLEN;
=20
 tx_error:
-	kfree_skb(skb);
+	if (!IS_ERR(skb))
+		kfree_skb(skb);
 	rcu_read_unlock();
 	LeaveFunction(10);
 	return NF_STOLEN;




