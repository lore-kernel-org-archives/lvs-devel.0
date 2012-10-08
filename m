From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [GIT PULL nf-next] IPVS for 3.7 #2
Date: Mon, 08 Oct 2012 20:44:25 +0200
Message-ID: <1349721865.22194.53.camel@localhost>
References: <1348800904-23902-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1348800904-23902-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Hans Schillstrom <hans@schillstrom.com>

Hey Pablo,

These changes were intended for 3.7, but just checked you git tree...
and it looks like you didn't pull in Simon's changes, and thus they have
not hit DaveM's tree for the merge window :-(

--Jesper


On Fri, 2012-09-28 at 11:54 +0900, Simon Horman wrote:
> Hi Pablo,
> 
> please consider the following enhancements to IPVS for inclusion in 3.7.
> 
> ----------------------------------------------------------------
> The following changes since commit 82c93fcc2e1737fede2752520f1bf8f4de6304d8:
> 
>   x86: bpf_jit_comp: add XOR instruction for BPF JIT (2012-09-24 16:54:35 -0400)
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git master
> 
> for you to fetch changes up to 92eec78d25aee6bbc9bd295f51c022ddfa80cdd9:
> 
>   ipvs: SIP fragment handling (2012-09-28 11:37:16 +0900)
> 
> ----------------------------------------------------------------
> Jesper Dangaard Brouer (7):
>       ipvs: Trivial changes, use compressed IPv6 address in output
>       ipvs: IPv6 extend ICMPv6 handling for future types
>       ipvs: Use config macro IS_ENABLED()
>       ipvs: Fix faulty IPv6 extension header handling in IPVS
>       ipvs: Complete IPv6 fragment handling for IPVS
>       ipvs: API change to avoid rescan of IPv6 exthdr
>       ipvs: SIP fragment handling
> 
>  include/net/ip_vs.h                     |  194 +++++++++++----
>  net/netfilter/ipvs/Kconfig              |    7 +-
>  net/netfilter/ipvs/ip_vs_conn.c         |   15 +-
>  net/netfilter/ipvs/ip_vs_core.c         |  404 +++++++++++++++++--------------
>  net/netfilter/ipvs/ip_vs_dh.c           |    2 +-
>  net/netfilter/ipvs/ip_vs_lblc.c         |    2 +-
>  net/netfilter/ipvs/ip_vs_lblcr.c        |    2 +-
>  net/netfilter/ipvs/ip_vs_pe_sip.c       |   18 +-
>  net/netfilter/ipvs/ip_vs_proto.c        |    6 +-
>  net/netfilter/ipvs/ip_vs_proto_ah_esp.c |    9 +-
>  net/netfilter/ipvs/ip_vs_proto_sctp.c   |   42 ++--
>  net/netfilter/ipvs/ip_vs_proto_tcp.c    |   40 ++-
>  net/netfilter/ipvs/ip_vs_proto_udp.c    |   41 ++--
>  net/netfilter/ipvs/ip_vs_sched.c        |    2 +-
>  net/netfilter/ipvs/ip_vs_sh.c           |    2 +-
>  net/netfilter/ipvs/ip_vs_xmit.c         |   73 +++---
>  net/netfilter/xt_ipvs.c                 |    4 +-
>  17 files changed, 501 insertions(+), 362 deletions(-)


