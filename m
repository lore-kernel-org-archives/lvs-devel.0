From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 2/3] ipvs: Fix faulty IPv6 extension  header handling in
 IPVS
Date: Fri, 31 Aug 2012 12:22:26 +0200
Message-ID: <1346408546.3069.537.camel@localhost>
References: <nhkcv8u.3c7ad6d61f90aef8e9467df88476311d@obelix.schillstrom.com>
	 <1346240770.3069.477.camel@localhost>
	 <Pine.GSO.4.63.1208291429160.26100@stinky-local.trash.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.GSO.4.63.1208291429160.26100@stinky-local.trash.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Patrick McHardy <kaber@trash.net>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Hans Schillstrom <hans@schillstrom.com>, Hans Schillstrom <hans.schillstrom@ericsson.com>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, netfilter-devel@vger.kernel.org

On Wed, 2012-08-29 at 14:34 +0200, Patrick McHardy wrote:
> On Wed, 29 Aug 2012, Jesper Dangaard Brouer wrote:
> > On Wed, 2012-08-29 at 11:47 +0200, Hans Schillstrom wrote:
> >>>
> >>> On Mon, 2012-08-27 at 14:02 +0200, Patrick McHardy wrote:
> >>>> On Mon, 27 Aug 2012, Hans Schillstrom wrote:
> >>>>
> >>>>>>>> How about we change netfilter to set up the skb's transport header
> >>>>>>>> at an early time so we can avoid all (most of) these header scans
> >>>>>>>> in netfilter?

[...cut...]

> >>>> I guess inet6_skb_parm will be at least slightly more popular than
> >>>> adding it to the skb itself. The netfilter pointers are all used for
> >>>> optional things, so we can't really add it to any of those.
> >>>

[...cut...]

> >> Should we give it a try to put it in inet6_skb_parm
> >> and minimize what we put there ?
> >> I think it could be worth it.
> >
> > Okay, but then I do need some help and guidance, especially from
> > Patrick, think.
> >
> > First of all, where in the netfilter code, should we update the new
> > fields in inet6_skb_parm?
> 
> Good question. I think we'd need at least three spots since every one
> of these subsystems can be used indepedently from each other:
> 
> - conntrack/IPVS: PRE_ROUTING/LOCAL_OUT at lowest priority
> - ip6tables: first time packet hits ip6t_do_table()?

I've been looking at the code for ip6t_do_table() and it already calls
ipv6_find_hdr().  ip6t_do_table() calls ip6_packet_match()

And ip6_packet_match() already calls
  ipv6_find_hdr(skb, protoff, -1, &_frag_off, NULL);
but only if((ip6info->flags & IP6T_F_PROTO))

ip6t_do_table() uses the data found by
ipv6_find_hdr()/ip6_packet_match() and updates 'struct xt_action_param
acpar' (which is passed on to all netfilter modules/functions as 'par')

 protohdr = ipv6_find_hdr(skb, protoff, -1, &_frag_off, NULL)
 *fragoff = _frag_off;

 par->thoff   = protoff  /* thoff = Transport Header Offset */
 par->fragoff = fragoff  /* frag indicator and fragment offset */

The returned protocol (protohdr) is only used inside
ip6_packet_match(), thus the info on the protocol is lost.

(Side note) Saving the protocol could be useful for, the following
modules, as they call ipv6_find_hdr() once again to extract this:

 net/netfilter/xt_TPROXY.c: function tproxy_tg6_v1()
 net/netfilter/xt_socket.c: function socket_mt6_v1()

Thus, the netfilter framework already have this information available.
It just uses the 'struct xt_action_param par' to carry this
information, to its modules.

Mine and Hans's patch are basically introducing the same thing for IPVS,
only that this information is carried via 'struct ip_vs_iphdr'.

I don't know, if its worth to store this information in
inet6_skb_parm/IP6CB ?

I guess, to would make sense to store 'thoff' transport header offset,
especially for IPv6, given the extension headers.

But how many (code) users are there?
Is it only Netfilter and IPVS that want to look at the port numbers?

There also seems to a lot of users of "ipv6_skip_exthdr", which could
benefit?  But I simply don't know the IPv6 code well enough...


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer


