From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 0/3] ipvs: IPv6 fragment handling for IPVS
Date: Tue, 21 Aug 2012 14:24:15 +0900
Message-ID: <20120821052415.GD14933@verge.net.au>
References: <20120820130732.1509.13080.stgit@dragon>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120820130732.1509.13080.stgit@dragon>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>, Hans Schillstrom <hans@schillstrom.com>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>

On Mon, Aug 20, 2012 at 03:08:30PM +0200, Jesper Dangaard Brouer wrote:
> The following patchset implement IPv6 fragment handling for IPVS.
> 
> This work is based upon patches from Hans Schillstrom.  I have taken
> over the patchset, in close agreement with Hans, because he don't have
> (gotten allocated) time to complete his work.
> 
> I have cleaned up the patchset, changed the API a bit, fixed a refcnt
> bug, and rebased on top of Julians recent changes. (All with Hans'es
> knowledge)
> 
>  Patch01: is just unrelated trivial fixes.
> 
>  Patch02: Fix faulty IPv6 extension header handling in IPVS
> 
>  Patch03: Complete IPv6 fragment handling for IPVS
> 
> This patchset is based upon:
>  Homes ipvs-next tree:
>   git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git
> 
>  On top of commit 3654e61137db891f5312e6dd813b961484b5fdf3:
>   ipvs: add pmtu_disc option to disable IP DF for TUN packets

I have no objection to these changes, but I would be more comfortable
applying them after a review from Hans, Julian or Pablo.

> 
> ---
> 
> Jesper Dangaard Brouer (3):
>       ipvs: Complete IPv6 fragment handling for IPVS
>       ipvs: Fix faulty IPv6 extension header handling in IPVS
>       ipvs: Trivial changes, use compressed IPv6 address in output
> 
> 
>  include/net/ip_vs.h                     |  191 +++++++++++----
>  net/netfilter/ipvs/Kconfig              |    7 -
>  net/netfilter/ipvs/ip_vs_conn.c         |   15 -
>  net/netfilter/ipvs/ip_vs_core.c         |  384 +++++++++++++++++--------------
>  net/netfilter/ipvs/ip_vs_dh.c           |    2 
>  net/netfilter/ipvs/ip_vs_lblc.c         |    2 
>  net/netfilter/ipvs/ip_vs_lblcr.c        |    2 
>  net/netfilter/ipvs/ip_vs_pe_sip.c       |   27 ++
>  net/netfilter/ipvs/ip_vs_proto.c        |    6 
>  net/netfilter/ipvs/ip_vs_proto_ah_esp.c |    9 -
>  net/netfilter/ipvs/ip_vs_proto_sctp.c   |   42 +--
>  net/netfilter/ipvs/ip_vs_proto_tcp.c    |   40 +--
>  net/netfilter/ipvs/ip_vs_proto_udp.c    |   41 +--
>  net/netfilter/ipvs/ip_vs_sched.c        |    2 
>  net/netfilter/ipvs/ip_vs_sh.c           |    2 
>  net/netfilter/ipvs/ip_vs_xmit.c         |   75 +++---
>  net/netfilter/xt_ipvs.c                 |    4 
>  17 files changed, 489 insertions(+), 362 deletions(-)
> 
> 
> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Sr. Network Kernel Developer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer
> 
