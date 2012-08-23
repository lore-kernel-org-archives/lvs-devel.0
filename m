From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 2/3] ipvs: Fix faulty IPv6 extension header handling in
 IPVS
Date: Thu, 23 Aug 2012 19:06:33 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1208231830300.28424@ja.ssi.bg>
References: <20120820130732.1509.13080.stgit@dragon>  <20120820130840.1509.75794.stgit@dragon>  <alpine.LFD.2.00.1208211558410.2149@ja.ssi.bg> <1345726251.3069.369.camel@localhost>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1345726251.3069.369.camel@localhost>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>, Hans Schillstrom <hans@schillstrom.com>, lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org


	Hello,

On Thu, 23 Aug 2012, Jesper Dangaard Brouer wrote:

> > > +#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> > > +#include <linux/netfilter_ipv6/ip6_tables.h>
> > > +#endif
> > 
> > 	There is already #if IS_ENABLED(CONFIG_IPV6) that
> > can replace #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> 
> Okay.
> 
> > 	It seems we need IS_ENABLED for many places:
> > CONFIG_NF_CONNTRACK, CONFIG_NF_DEFRAG_IPV6
> 
> Wondering if we should keep these cleanup changes to a separate patch.

	The way you prefer. We can fix it after this
patchset.

> > >  	/* Now find the contained IP header */
> > > -	offset += sizeof(_icmph);
> > > -	cih = skb_header_pointer(skb, offset, sizeof(_ciph), &_ciph);
> > > -	if (cih == NULL)
> > > -		return NF_ACCEPT; /* The packet looks wrong, ignore */
> > > +	ciph.len = iph->len + sizeof(_icmph);
> > > +	ciph.flags = 0;
> > > +	ciph.fragoffs = 0;
> > > +	ciph.protocol = ipv6_find_hdr(skb, &ciph.len, -1, &ciph.fragoffs,
> > > +				      &ciph.flags);
> 
> (notice that &ciph.len can get updated by ipv6_find_hdr())
> 
> > > +	ciph.saddr = iph->saddr;	/* con_in_get() handles reverse order */
> > > +	ciph.daddr = iph->daddr;
> > 
> > 	The ciph initialization looks dangerous if one day
> > we add new field into the header.
> > 
> > 	Can we use ciph = (struct ip_vs_iphdr) { .XXX = val, ... },
> > in such case we have to call ipv6_find_hdr out of (after)
> > this initialization? Of course, we will write twice to
> > small fields such as protocol, len, fragoffs, flags
> 
> I'm not sure I follow/understand.

	For example:

	ciph = (struct ip_vs_iphdr) {
		.len = iph->len + sizeof(_icmph),
		.saddr = iph->saddr,
		.daddr = iph->daddr,
	};
	ciph.protocol = ipv6_find_hdr(skb, &ciph.len, -1, &ciph.fragoffs,
				      &ciph.flags);

	but I'm not sure if the saddr/daddr part compiles.

> > 	Also ipv6_find_hdr looks a bit noisy for missing header,
> > can it be a problem for the inner IPv6 header in ICMP messages?
> 
> I can see, that I don't handle the error cases of missing headers, from
> a call to ipv6_find_hdr() ... I guess I need to check if the return
> value "protocol" is negative.  But I'm not sure if it matters in this
> case (Hans?)

	ok. But I was referring to this message:

printk(KERN_ERR "IPv6 header not found\n");

> > 	In patch 3 ip_vs_in_icmp_v6 initializes ciph in the
> > same way. It will be difficult to audit the code later
> > considering the large number of places where iph is used.
> 
> I'm not sure what you want me to do?

	May be it is only in ip_vs_in_icmp_v6, my above
example is for ip_vs_in_icmp_v6, let me know if it
compiles.

> > 	Still in the same func, above code is correct but
> > patch 3 changes it back to wrong state (offs_ciph = ciph.len).
> 
> Don't think its a "bug" in patch3, it might be a "bug" in this patch.
> Because &ciph.len gets updated earlier by ipv6_find_hdr()... but I'm
> starting to get confused.
> Perhaps we should move these changes to ip_vs_in_icmp_v6() into the same
> patch?

	ip_vs_icmp_xmit_v6 expects to see length that
will be made writeable, not exactly offset of header.
May be you can rename the ip_vs_icmp_xmit_v6 argument
from offset to wrtlen, it covers the ports because we
are going to mangle them. Patch 3 should not change
anymore there.

> > 	In this context, may be soon we will modify ip_vs_ftp to
> > support IPv6. It is possible to work with present FTP helper
> > in netfilter. Does it mean that we will see only reassembled
> > packets when conntrack is running? No original fragments.
> 
> Yes, it seems that we will *only* see the reassembled packet (no
> original fragments) after Patricks patches.  BUT *only* when loading the
> module nf_conntrack_ipv6.

	Yes, ok

> > Are we prepared to work in both ways (originals+reasm and
> > just reasm) ?
> 
> As mentioned in another thread, no. But only because the reassembled
> packet will be dropped due to the MTU check. After this is fixed, the
> ipvs code seems to work. (Notice, this is both without and with my/these
> patches)

	Very good

> > - For patch 3 in Kconfig do we need 'select NF_DEFRAG_IPV6' ?
> 
> Yes, but it is still possible not to load the module nf_defrag_ipv6.

	nf_defrag_ipv6 becomes mandatory for IPVS-IPv6.
Conntrack should be optional.

> When not loading, nf_defrag_ipv6, these patches have no effect, and no
> fragments are passed through.

	What happens with fragments if nf_defrag_ipv6 is
not loaded? IPVS will see original fragments without
reasm ptr? I assume IPVS can see them but can not do
much except to mangle addresses and ports.

> > 	Basicly, I'm concerned what will happen when we
> > start to mangle the protocol payloads (FTP). For now
> > we are safe by touching only addresses and ports. May be
> > we have to synchronize these changes with the work from
> > Patrick.
> 
> Yes, I think we should take Patrick's work into account.
> 
> My biggest concern is, that depending on which modules (nf_defrag_ipv6
> only, or also nf_conntrack_ipv6) are loaded, different code paths are
> used (to support IPv6 fragments for IPVS).

	May be just like for IPv4, I think, nf_defrag_ipv6
should be loaded (added as dep) but nf_conntrack_ipv6 should
be required only for FTP as we use some code from there.

> This will be hard to understand, from a user perspective.  And also
> difficult for us, when users report bugs...
> 
> Is loading nf_conntrack_ipv6 considered a big performance problem/issue
> for IPVS?
> (Can we tell people, to enable conntrack for frag support?)

	We should avoid it if possible. There can be small
routers that do not want conntrack. It would be better if
IPVS uses some symbol that will cause nf_defrag_ipv6 to
load, now we can add it as dep but what if user does not
load it? nf_defrag_ipv6_hooks.c is very small, I'm not
sure if we have to duplicate it just to cause defrag at
prerouting or even input to work for us in the case without
conntrack. Without this support we can not mangle FTP
payload.

Regards

--
Julian Anastasov <ja@ssi.bg>
