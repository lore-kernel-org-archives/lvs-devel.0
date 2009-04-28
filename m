From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [bug] FWMARKs and persistence in IPVS: The Use of Unions
Date: Tue, 28 Apr 2009 17:28:06 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0904281724040.17524@fbirervta.pbzchgretzou.qr>
References: <20090428081509.GA746@verge.net.au> <alpine.LSU.2.00.0904281103250.27149@fbirervta.pbzchgretzou.qr> <20090428092351.GC8165@verge.net.au> <20090428105941.GA20907@verge.net.au> <alpine.LSU.2.00.0904281421530.7300@fbirervta.pbzchgretzou.qr>
 <20090428150045.GA8377@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20090428150045.GA8377@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: netfilter-devel <netfilter-devel@vger.kernel.org>, lvs-devel@vger.kernel.org, =?UTF-8?Q?Fabien_Duch=C3=AAne?= <fabien.duchene@student.uclouvain.be>, Joseph Mack NA3T <jmack@wm7d.net>, Julius Volz <julius.volz@gmail.com>


On Tuesday 2009-04-28 17:00, Simon Horman wrote:
>> >Index: net-next-2.6/net/netfilter/ipvs/ip_vs_conn.c
>> >===================================================================
>> >--- net-next-2.6.orig/net/netfilter/ipvs/ip_vs_conn.c	2009-04-28 20:37:48.000000000 +1000
>> >+++ net-next-2.6/net/netfilter/ipvs/ip_vs_conn.c	2009-04-28 20:37:51.000000000 +1000
>> >@@ -260,7 +260,10 @@ struct ip_vs_conn *ip_vs_ct_in_get
>> > 	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
>> > 		if (cp->af == af &&
>> > 		    ip_vs_addr_equal(af, s_addr, &cp->caddr) &&
>> >-		    ip_vs_addr_equal(af, d_addr, &cp->vaddr) &&
>> >+		    /* protocol should only be IPPROTO_IP if
>> >+		     * d_addr is a fwmark */
>> >+		    ip_vs_addr_equal(protocol == IPPROTO_IP ? AF_UNSPEC : af,
>> >+		                     d_addr, &cp->vaddr) &&
>> 
>> What about IPPROTO_IPV6?
>
>I believe that the value IPPROTO_IP is only used in the case of fwmark.
>Here is a explanation of why.
>
>1) If a fwmark in use, then it is set to IPPROTO_IP when dealing
>   with templates for persistance.
>2) If the entry is created by the FTP helper, IPPROTO_TCP is used.
>3) If the entry is created by syncrhonisation of the table of another
>   machine, then the protocol used in the foreign entry is used -
>   which would have been set by one of these 4 cases.
>4) Otherwise the value of iph.protocol is used.

That sounds a bit like whenever you get an IPIP packet,
IPVS will erroneously think it is operating on an fwmark-based address.
