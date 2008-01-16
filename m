From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] Runtime interception method switch
Date: Wed, 16 Jan 2008 16:50:47 +0900
Message-ID: <20080116075044.GA19249@verge.net.au>
References: <07C2E63F-FDF8-45D5-A20C-0B294C119A5E@endian.com> <Pine.LNX.4.64.0801130758580.32303@wm7d.net> <47C3AD3C-1A21-43AC-B109-EE32E8B4B66A@endian.com> <Pine.LNX.4.64.0801140137470.32097@wm7d.net> <20080115082551.GB8826@verge.net.au> <Pine.LNX.4.64.0801150501120.22826@wm7d.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801150501120.22826@wm7d.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joseph Mack NA3T <jmack@wm7d.net>
Cc: LVS Devel <lvs-devel@vger.kernel.org>, Janusz Krzysztofik <jkrzyszt@tis.icnet.pl>

On Tue, Jan 15, 2008 at 05:13:14AM -0800, Joseph Mack NA3T wrote:
> On Tue, 15 Jan 2008, Simon Horman wrote:
>
>>> can this be put into the standard ipvs?
>
> ("this" == F5-SNAT
>
> http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.non-modified_realservers.html#F5_snat
>
> )
>
>> In principle yes, though I am a bit wary about what
>> side-effects it might have.
>>
>>>> or to implement SNAT in the IPVS/NAT method.
>>>
>>> can you do either of these?
>
> I know I'm not the one doing the coding but since
>
> o we're having a bit of a redesign
>
> o people reasonably expect iptables rules to be able to NAT packets 
> coming out of the director going to the realservers and it would be nice 
> to restore that functionality for ipvs
>
> o F5-SNAT is useful
>
> this would be a good time to look at adding F5-SNAT.
>
> What side effects might there be? Are they worse than not being able to 
> NAT packets emerging from a director?

I'm not sure, and thats what concerns me.

For starters could we clarify that the patch in question is the
following one by Janusz Krzysztofik?

Also can I clarify that the aim is to be able to SNAT LVS-DR
connections (and if possible LVS-NAT and LVS-TUN)?
Or is the aim to add a new method, LVS-FULL-NAT?

--- linux-source-2.6.17-2-e49_9.200610211740/net/ipv4/ipvs/ip_vs_core.c.orig	2006-06-18 03:49:35.000000000 +0200
+++ linux-source-2.6.17-2-e49_9.200610211740/net/ipv4/ipvs/ip_vs_core.c	2006-10-21 21:38:20.000000000 +0200
@@ -672,6 +672,9 @@ static int ip_vs_out_icmp(struct sk_buff
 	if (!cp)
 		return NF_ACCEPT;
 
+	if (IP_VS_FWD_METHOD(cp) == IP_VS_CONN_F_DROUTE)
+		return NF_ACCEPT;
+
 	verdict = NF_DROP;
 
 	if (IP_VS_FWD_METHOD(cp) != 0) {
@@ -801,6 +804,9 @@ ip_vs_out(unsigned int hooknum, struct s
 		return NF_ACCEPT;
 	}
 
+	if (IP_VS_FWD_METHOD(cp) == IP_VS_CONN_F_DROUTE)
+		return NF_ACCEPT;
+
 	IP_VS_DBG_PKT(11, pp, skb, 0, "Outgoing packet");
 
 	if (!ip_vs_make_skb_writable(pskb, ihl))
--- linux-source-2.6.17-2-e49_9.200610211740/net/ipv4/ipvs/ip_vs_xmit.c.orig	2006-06-18 03:49:35.000000000 +0200
+++ linux-source-2.6.17-2-e49_9.200610211740/net/ipv4/ipvs/ip_vs_xmit.c	2006-10-21 21:22:56.000000000 +0200
@@ -127,7 +127,6 @@ ip_vs_dst_reset(struct ip_vs_dest *dest)
 
 #define IP_VS_XMIT(skb, rt)				\
 do {							\
-	(skb)->ipvs_property = 1;			\
 	(skb)->ip_summed = CHECKSUM_NONE;		\
 	NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, (skb), NULL,	\
 		(rt)->u.dst.dev, dst_output);		\
@@ -278,6 +277,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, stru
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
+	skb->ipvs_property = 1;
 	IP_VS_XMIT(skb, rt);
 
 	LeaveFunction(10);
@@ -411,6 +411,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, s
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
+	skb->ipvs_property = 1;
 	IP_VS_XMIT(skb, rt);
 
 	LeaveFunction(10);
@@ -542,6 +543,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, str
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
+	skb->ipvs_property = 1;
 	IP_VS_XMIT(skb, rt);
 
 	rc = NF_STOLEN;
