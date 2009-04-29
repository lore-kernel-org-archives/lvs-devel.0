From: Simon Horman <horms@verge.net.au>
Subject: Re: [bug] FWMARKs and persistence in IPVS: The Use of Unions
Date: Wed, 29 Apr 2009 10:06:31 +1000
Message-ID: <20090429000631.GA9712@verge.net.au>
References: <20090428081509.GA746@verge.net.au> <alpine.LSU.2.00.0904281103250.27149@fbirervta.pbzchgretzou.qr> <20090428092351.GC8165@verge.net.au> <20090428105941.GA20907@verge.net.au> <alpine.LSU.2.00.0904281421530.7300@fbirervta.pbzchgretzou.qr> <20090428150045.GA8377@verge.net.au> <alpine.LSU.2.00.0904281724040.17524@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.0904281724040.17524@fbirervta.pbzchgretzou.qr>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jan Engelhardt <jengelh@medozas.de>
Cc: netfilter-devel <netfilter-devel@vger.kernel.org>, lvs-devel@vger.kernel.org, Fabien =?iso-8859-1?Q?Duch=EAne?= <fabien.duchene@student.uclouvain.be>, Joseph Mack NA3T <jmack@wm7d.net>, Julius Volz <julius.volz@gmail.com>

On Tue, Apr 28, 2009 at 05:28:06PM +0200, Jan Engelhardt wrote:
> 
> On Tuesday 2009-04-28 17:00, Simon Horman wrote:
> >> >Index: net-next-2.6/net/netfilter/ipvs/ip_vs_conn.c
> >> >===================================================================
> >> >--- net-next-2.6.orig/net/netfilter/ipvs/ip_vs_conn.c	2009-04-28 20:37:48.000000000 +1000
> >> >+++ net-next-2.6/net/netfilter/ipvs/ip_vs_conn.c	2009-04-28 20:37:51.000000000 +1000
> >> >@@ -260,7 +260,10 @@ struct ip_vs_conn *ip_vs_ct_in_get
> >> > 	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
> >> > 		if (cp->af == af &&
> >> > 		    ip_vs_addr_equal(af, s_addr, &cp->caddr) &&
> >> >-		    ip_vs_addr_equal(af, d_addr, &cp->vaddr) &&
> >> >+		    /* protocol should only be IPPROTO_IP if
> >> >+		     * d_addr is a fwmark */
> >> >+		    ip_vs_addr_equal(protocol == IPPROTO_IP ? AF_UNSPEC : af,
> >> >+		                     d_addr, &cp->vaddr) &&
> >> 
> >> What about IPPROTO_IPV6?
> >
> >I believe that the value IPPROTO_IP is only used in the case of fwmark.
> >Here is a explanation of why.
> >
> >1) If a fwmark in use, then it is set to IPPROTO_IP when dealing
> >   with templates for persistance.
> >2) If the entry is created by the FTP helper, IPPROTO_TCP is used.
> >3) If the entry is created by syncrhonisation of the table of another
> >   machine, then the protocol used in the foreign entry is used -
> >   which would have been set by one of these 4 cases.
> >4) Otherwise the value of iph.protocol is used.
> 
> That sounds a bit like whenever you get an IPIP packet,
> IPVS will erroneously think it is operating on an fwmark-based address.

Unless I am missing something, if the protcol of the skb is IPPROTO_IPIP
then ip_vs_in() will return NF_ACCEPT and it won't go through
any code paths that use the logic above.

iph.protocol needs to be matched by ip_vs_proto_get(),
which means it needs to be one of:

    IPPROTO_TCP
    IPPROTO_UDP
    IPPROTO_AH
    IPPROTO_ESP

IPPROTO_ICMP is also handled, basically by extracting the embeded
header and then checking its iph.protocol with ip_vs_proto_get()

In other words IPVS only knows how to load balance TCP, UDP, AH and ESP,
and handle related ICMP traffic.

-- 
Simon Horman
  VA Linux Systems Japan K.K. Satellite Lab in Sydney, Australia
  H: www.vergenet.net/~horms/            W: www.valinux.co.jp/en

