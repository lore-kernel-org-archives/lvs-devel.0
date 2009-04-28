From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [bug] FWMARKs and persistence in IPVS: The Use of Unions
Date: Tue, 28 Apr 2009 14:27:34 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0904281421530.7300@fbirervta.pbzchgretzou.qr>
References: <20090428081509.GA746@verge.net.au> <alpine.LSU.2.00.0904281103250.27149@fbirervta.pbzchgretzou.qr> <20090428092351.GC8165@verge.net.au> <20090428105941.GA20907@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20090428105941.GA20907@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: netfilter-devel <netfilter-devel@vger.kernel.org>, lvs-devel@vger.kernel.org, =?UTF-8?Q?Fabien_Duch=C3=AAne?= <fabien.duchene@student.uclouvain.be>, Joseph Mack NA3T <jmack@wm7d.net>, Julius Volz <julius.volz@gmail.com>


On Tuesday 2009-04-28 12:59, Simon Horman wrote:
>>>
>>>union nf_inet_addr fwmark = {
>>>	.all = { 0, 0, 0, htonl(svc->fwmark) }
>>>};
>[said something about cp->af...]

It does not make sense to use AF_INE with some address as unreal
as {0,0,0,fwmark}, just BTW.

>> > If you use ->all, then using NFPROTO_UNSPEC as af
>> > seems to me like a good match.
>
>I am guessing that AF_UNSPEC is more appropriate than NFPROTO_UNSPEC.
>Please correct me if I am wrong.

Whatever. You could even use AF_INET6 to mean "take the ipv4 part
of nf_inet_addr", and AF_INET to "take the ipv6 part". The mapping
is on you, so to speak.
Since you are dealing with an *nf*_inet_addr, using *NF*PROTO_ seemed
the closest thing.

>The following patch expresses these ideas as they crrently stand.
>Fabien, is it possible for you to test this?
>
>Index: net-next-2.6/net/netfilter/ipvs/ip_vs_conn.c
>===================================================================
>--- net-next-2.6.orig/net/netfilter/ipvs/ip_vs_conn.c	2009-04-28 20:37:48.000000000 +1000
>+++ net-next-2.6/net/netfilter/ipvs/ip_vs_conn.c	2009-04-28 20:37:51.000000000 +1000
>@@ -260,7 +260,10 @@ struct ip_vs_conn *ip_vs_ct_in_get
> 	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
> 		if (cp->af == af &&
> 		    ip_vs_addr_equal(af, s_addr, &cp->caddr) &&
>-		    ip_vs_addr_equal(af, d_addr, &cp->vaddr) &&
>+		    /* protocol should only be IPPROTO_IP if
>+		     * d_addr is a fwmark */
>+		    ip_vs_addr_equal(protocol == IPPROTO_IP ? AF_UNSPEC : af,
>+		                     d_addr, &cp->vaddr) &&

What about IPPROTO_IPV6?
