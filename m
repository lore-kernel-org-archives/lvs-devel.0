From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/3] ipvs: Fix faulty IPv6 extension header handling in
 IPVS
Date: Sun, 26 Aug 2012 23:13:45 +0200 (MEST)
Message-ID: <Pine.GSO.4.63.1208262311110.16771@stinky-local.trash.net>
References: <20120820130732.1509.13080.stgit@dragon> <20120820130840.1509.75794.stgit@dragon>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120820130840.1509.75794.stgit@dragon>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: netdev@vger.kernel.org, Hans Schillstrom <hans@schillstrom.com>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org

On Mon, 20 Aug 2012, Jesper Dangaard Brouer wrote:

> Based on patch from: Hans Schillstrom
>
> IPv6 headers must be processed in order of appearance,
> neither can it be assumed that Upper layer headers is first.
> If anything else than L4 is the first header IPVS will throw it.
>
> IPVS will write SNAT & DNAT modifications at a fixed pos which
> will corrupt the message. Proper header position must be found
> before writing modifying packet.
>
> This patch contains a lot of API changes.  This is done, to avoid
> the costly scan of finding the IPv6 headers, via ipv6_find_hdr().
> Finding the IPv6 headers is done as early as possible, and passed
> on as a pointer "struct ip_vs_iphdr *" to the affected functions.

How about we change netfilter to set up the skb's transport header
at an early time so we can avoid all (most of) these header scans
in netfilter?
