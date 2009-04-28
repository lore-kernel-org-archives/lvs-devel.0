From: Simon Horman <horms@verge.net.au>
Subject: Re: [bug] FWMARKs and persistence in IPVS: The Use of Unions
Date: Wed, 29 Apr 2009 01:00:49 +1000
Message-ID: <20090428150045.GA8377@verge.net.au>
References: <20090428081509.GA746@verge.net.au> <alpine.LSU.2.00.0904281103250.27149@fbirervta.pbzchgretzou.qr> <20090428092351.GC8165@verge.net.au> <20090428105941.GA20907@verge.net.au> <alpine.LSU.2.00.0904281421530.7300@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.0904281421530.7300@fbirervta.pbzchgretzou.qr>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jan Engelhardt <jengelh@medozas.de>
Cc: netfilter-devel <netfilter-devel@vger.kernel.org>, lvs-devel@vger.kernel.org, Fabien =?iso-8859-1?Q?Duch=EAne?= <fabien.duchene@student.uclouvain.be>, Joseph Mack NA3T <jmack@wm7d.net>, Julius Volz <julius.volz@gmail.com>

On Tue, Apr 28, 2009 at 02:27:34PM +0200, Jan Engelhardt wrote:
> 
> On Tuesday 2009-04-28 12:59, Simon Horman wrote:
> >>>
> >>>union nf_inet_addr fwmark = {
> >>>	.all = { 0, 0, 0, htonl(svc->fwmark) }
> >>>};
> >[said something about cp->af...]
> 
> It does not make sense to use AF_INE with some address as unreal
> as {0,0,0,fwmark}, just BTW.

Agreed.

> >> > If you use ->all, then using NFPROTO_UNSPEC as af
> >> > seems to me like a good match.
> >
> >I am guessing that AF_UNSPEC is more appropriate than NFPROTO_UNSPEC.
> >Please correct me if I am wrong.
> 
> Whatever. You could even use AF_INET6 to mean "take the ipv4 part
> of nf_inet_addr", and AF_INET to "take the ipv6 part". The mapping
> is on you, so to speak.

Ok, though I would hope that we can come up with something a little
more intuative than that.

> Since you are dealing with an *nf*_inet_addr, using *NF*PROTO_ seemed
> the closest thing.

Ok, as it happens the code that looked like it should be modified was
using AF_ values, even though it deals with nf_inet_addr. As you mention
this, it looks like it should be possible to change all the relevant
ip_vs code over to use NFPROTO_ instead, but lets leave looking into
that for later.

> >The following patch expresses these ideas as they crrently stand.
> >Fabien, is it possible for you to test this?
> >
> >Index: net-next-2.6/net/netfilter/ipvs/ip_vs_conn.c
> >===================================================================
> >--- net-next-2.6.orig/net/netfilter/ipvs/ip_vs_conn.c	2009-04-28 20:37:48.000000000 +1000
> >+++ net-next-2.6/net/netfilter/ipvs/ip_vs_conn.c	2009-04-28 20:37:51.000000000 +1000
> >@@ -260,7 +260,10 @@ struct ip_vs_conn *ip_vs_ct_in_get
> > 	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
> > 		if (cp->af == af &&
> > 		    ip_vs_addr_equal(af, s_addr, &cp->caddr) &&
> >-		    ip_vs_addr_equal(af, d_addr, &cp->vaddr) &&
> >+		    /* protocol should only be IPPROTO_IP if
> >+		     * d_addr is a fwmark */
> >+		    ip_vs_addr_equal(protocol == IPPROTO_IP ? AF_UNSPEC : af,
> >+		                     d_addr, &cp->vaddr) &&
> 
> What about IPPROTO_IPV6?

I believe that the value IPPROTO_IP is only used in the case of fwmark.
Here is a explanation of why.

The value of protocol in ip_vs_ct_in_get() and ip_vs_conn_new()
can come from serveral sources:

1) If a fwmark in use, then it is set to IPPROTO_IP when dealing
   with templates for persistance.
2) If the entry is created by the FTP helper, IPPROTO_TCP is used.
3) If the entry is created by syncrhonisation of the table of another
   machine, then the protocol used in the foreign entry is used -
   which would have been set by one of these 4 cases.
4) Otherwise the value of iph.protocol is used. iph is set set as
   ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);

The key is that functions that provide cases 1), 2) and 4) are all called
from ip_vs_in() which filters packets so that, amongst other things, the
protocol is accepted by ip_vs_proto_get(). At this time, that means it must
be one of:

    IPPROTO_TCP (as per ip_vs_protocol_tcp)
    IPPROTO_UDP (as per ip_vs_protocol_udp)
    IPPROTO_AH  (as per ip_vs_protocol_ah)
    IPPROTO_ESP (as per ip_vs_protocol_esp)

I had thought about adding an explicit is_fwmark field to ip_vs_ct_in_get()
and ip_vs_conn_new(), but it would also need to be added to the syncronisation
protocol, changes to which seem best avoided for compatibility reasons.

