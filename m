From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 2/3] ipvs: Fix faulty IPv6 extension header handling in
 IPVS
Date: Tue, 04 Sep 2012 23:25:18 +0200
Message-ID: <1346793918.3069.663.camel@localhost>
References: <20120820130732.1509.13080.stgit@dragon>
	 <20120820130840.1509.75794.stgit@dragon>
	 <Pine.GSO.4.63.1208262311110.16771@stinky-local.trash.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.GSO.4.63.1208262311110.16771@stinky-local.trash.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Patrick McHardy <kaber@trash.net>
Cc: netdev@vger.kernel.org, Hans Schillstrom <hans@schillstrom.com>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org

On Mon, 20 Aug 2012, Jesper Dangaard Brouer wrote:

[cut]

> This patch contains a lot of API changes.  This is done, to avoid
> the costly scan of finding the IPv6 headers, via ipv6_find_hdr().

(small correction ipv6_find_hdr() is not that costly for the general
case of no exthdrs)

> Finding the IPv6 headers is done as early as possible, and passed
> on as a pointer "struct ip_vs_iphdr *" to the affected functions.

This passing the "struct ip_vs_iphdr" actually makes sense.  It reminds
me of the way netfilter/iptables passes the xt_actions_param to each
rule.  Which contains the same information as ip_vs_iphdr.  (note ipvs
register at hooks at a lower level and don't get passed the
xt_actions_param).

Thus, perhaps we should keep these API changes.  Even if we decide to
optimize ipv6_find_hdr().  (as proposed by my RFC patch)

Perhaps we should consider adding a "family" to ip_vs_iphdr, as is done
in xt_actions_param.  This could help us, with collapsing IPv4 and IPv6
code, but i can see that other structs in IPVS carry this info already,
so not sure its relevant.


