From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [GIT-PULL nf-next 00/15] IPVS Updates for v4.4
Date: Fri, 18 Sep 2015 09:20:42 -0500
Message-ID: <87io77stad.fsf@x220.int.ebiederm.org>
References: <1442468451-24012-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1442468451-24012-1-git-send-email-horms@verge.net.au> (Simon
	Horman's message of "Thu, 17 Sep 2015 14:40:36 +0900")
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

Simon Horman <horms@verge.net.au> writes:

> Hi Pablo,
>
> please consider these IPVS Updates for v4.4.

Just a quick heads up.

In my work to pass struct net down into the netfilter functions so they
don't have to guess, I wound up performing some significant surgery on
ipvs.  In particular so the code stayed clean I wound up turning the
relationship between struct net, and the structures netns_ipvs,
ip_vs_conn_param, ip_vs_conn, ip_vs_service inside out.  That is in
every structure holds a struct net reference and in every function that
takes a struct net reference I use a struct netns_ipvs reference
instead.

In most cases netns_ipvs is what the code actually wants so this just
reduces the unncessary rigamarole the code has to go through, and just
plain feels cleaner.  For example all of the sysctl wrappers wind up
taking struct netns_ipvs reference because it has become the natural
thing for them to do.

There are also quite a few functions where I have added a netns_ipvs
parameter so they would not have to guess, so in the addition of
parameters the code change is about the same as my previous patch.

I do not think there are any conflicts that will be difficult to resolve
between this patchset and my pending changes, as my pending changes
barely perform any changes of substance.  My changes do result in
conflicts.

For example in my pending changes and in this patchset they both change
the function prototype of ip_vs_protocol.conn_in_get.  My pending
changes add struct netns_ipvs as the first parameter and these patches
remove the final inverse parameter.

Eric

> The updates include the following from Alex Gartrell:
> * Scheduling of ICMP
> * Sysctl to ignore tunneled packets; and hence some packet-looping scenarios
>
> The following changes since commit 851345c5bbb4644911f7c351c042559a71f57d19:
>
>   netfilter: reduce sparse warnings (2015-08-28 21:04:12 +0200)
>
> are available in the git repository at:
>
>   https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs-for-v4.4
>
> for you to fetch changes up to 4e478098ac0ac1b6ef9a70fcdc2ec8b93f1b59a1:
>
>   ipvs: add sysctl to ignore tunneled packets (2015-09-17 11:50:02 +0900)
>
> ----------------------------------------------------------------
> Alex Gartrell (15):
>       ipvs: replace ip_vs_fill_ip4hdr with ip_vs_fill_iph_skb_off
>       ipvs: Add hdr_flags to iphdr
>       ipvs: Handle inverse and icmp headers in ip_vs_leave
>       ipvs: pull out ip_vs_try_to_schedule function
>       ipvs: drop inverse argument to conn_{in,out}_get
>       ipvs: Make ip_vs_schedule aware of inverse iph'es
>       ipvs: add schedule_icmp sysctl
>       ipvs: Use outer header in ip_vs_bypass_xmit_v6
>       ipvs: sh: support scheduling icmp/inverse packets consistently
>       ipvs: attempt to schedule icmp packets
>       ipvs: ensure that ICMP cannot be sent in reply to ICMP
>       ipvs: support scheduling inverse and icmp TCP packets
>       ipvs: support scheduling inverse and icmp UDP packets
>       ipvs: support scheduling inverse and icmp SCTP packets
>       ipvs: add sysctl to ignore tunneled packets
>
>  Documentation/networking/ipvs-sysctl.txt |  10 ++
>  include/net/ip_vs.h                      | 120 ++++++++++---
>  net/netfilter/ipvs/ip_vs_conn.c          |  12 +-
>  net/netfilter/ipvs/ip_vs_core.c          | 299 +++++++++++++++++++------------
>  net/netfilter/ipvs/ip_vs_ctl.c           |  15 +-
>  net/netfilter/ipvs/ip_vs_pe_sip.c        |   2 +-
>  net/netfilter/ipvs/ip_vs_proto_ah_esp.c  |  17 +-
>  net/netfilter/ipvs/ip_vs_proto_sctp.c    |  34 ++--
>  net/netfilter/ipvs/ip_vs_proto_tcp.c     |  38 +++-
>  net/netfilter/ipvs/ip_vs_proto_udp.c     |  25 ++-
>  net/netfilter/ipvs/ip_vs_sh.c            |  45 +++--
>  net/netfilter/ipvs/ip_vs_xmit.c          |  24 +--
>  net/netfilter/xt_ipvs.c                  |   4 +-
>  13 files changed, 427 insertions(+), 218 deletions(-)
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
