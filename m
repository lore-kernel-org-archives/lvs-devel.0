From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 00/16] net: Pass net through the output path v2
Date: Wed, 07 Oct 2015 16:46:49 -0500
Message-ID: <87bnca4aie.fsf_-_@x220.int.ebiederm.org>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
	<87pp1fpy1b.fsf@x220.int.ebiederm.org>
	<87fv2bo7br.fsf_-_@x220.int.ebiederm.org>
	<87si62gteh.fsf_-_@x220.int.ebiederm.org>
	<877fn7eh2f.fsf_-_@x220.int.ebiederm.org>
	<878u7fesrg.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <878u7fesrg.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Tue, 06 Oct 2015 13:50:11 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org


This is the next installment of my work to pass struct net through the
output path so the code does not need to guess how to figure out which
network namespace it is in, and ultimately routes can have output
devices in another network namespace.

The first patch in this series is a fix for a bug that came in when sk
was passed through the functions in the output path, and as such is
probably a candidate for net.  At the same time my later patches depend
on it so sending the fix separately would be confusing.

The second patch in this series is another fix that for an issue that
came in when sk was passed through the output path.  I don't think it
needs a backport as I don't think anyone uses the path where the code
was incorrect.

The rest of the patchset focuses on the path from xxx_local_out to
dst_output and in the end succeeds in passing sock_net(sk) from the
socket a packet locally originates on to the dst->output function.

Given the size reduction in the code I think this counts as a cleanup as
much as feature work.

There remain a number of helper functions (like ip option processing) to
take care of before the network stack can support destination devices in
other network namespaces but with this set of changes the backbone of
the work is done.

The changes are also available against net-next at:
git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/net-next.git master

Eric

Eric W. Biederman (16):
      ipv4: Fix ip_local_out_sk by passing the sk into __ip_local_out_sk
      ipv4: Fix ip_queue_xmit to pass sk into ip_local_out_sk
      xfrm: Only compute net once in xfrm_policy_queue_process
      net: Pass net into dst_output and remove dst_output_okfn
      dst: Pass a sk into .local_out
      ipv4: Merge __ip_local_out and __ip_local_out_sk
      ipv4: Merge ip_local_out and ip_local_out_sk
      ipv6: Merge __ip6_local_out and __ip6_local_out_sk
      ipv6: Merge ip6_local_out and ip6_local_out_sk
      ipv4: Cache net in iptunnel_xmit
      ipv4: Cache net in ip_build_and_send_pkt and ip_queue_xmit
      ppp: Cache net in pptp_xmit
      ipvlan: Cache net in ipvlan_process_v4_outbound and ipvlan_process_v6_outbound
      ipv4,ipv6: Pass net into __ip_local_out and __ip6_local_out
      ipv4,ipv6: Pass net into ip_local_out and ip6_local_out
      dst: Pass net into dst->output

 drivers/net/ipvlan/ipvlan_core.c    | 10 +++++----
 drivers/net/ppp/pptp.c              |  7 ++++---
 drivers/net/vrf.c                   |  9 ++++----
 include/net/dst.h                   | 14 +++++--------
 include/net/dst_ops.h               |  3 ++-
 include/net/ip.h                    | 12 ++++-------
 include/net/ip6_tunnel.h            |  2 +-
 include/net/ipv6.h                  |  7 +++----
 include/net/lwtunnel.h              |  8 +++----
 include/net/xfrm.h                  |  6 +++---
 net/core/dst.c                      | 14 ++++++-------
 net/core/lwtunnel.c                 |  4 ++--
 net/decnet/dn_nsp_out.c             |  4 ++--
 net/decnet/dn_route.c               |  6 +++---
 net/ipv4/igmp.c                     |  4 ++--
 net/ipv4/ip_forward.c               |  2 +-
 net/ipv4/ip_output.c                | 42 ++++++++++++++++---------------------
 net/ipv4/ip_tunnel_core.c           |  6 +++---
 net/ipv4/ip_vti.c                   |  2 +-
 net/ipv4/ipmr.c                     |  2 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c   |  2 +-
 net/ipv4/netfilter/nf_dup_ipv4.c    |  2 +-
 net/ipv4/netfilter/nf_reject_ipv4.c |  2 +-
 net/ipv4/raw.c                      |  2 +-
 net/ipv4/route.c                    |  4 ++--
 net/ipv4/xfrm4_output.c             |  6 ++----
 net/ipv6/ila.c                      |  4 ++--
 net/ipv6/ip6_output.c               |  9 ++++----
 net/ipv6/ip6_vti.c                  |  2 +-
 net/ipv6/ip6mr.c                    |  2 +-
 net/ipv6/mcast.c                    |  4 ++--
 net/ipv6/ndisc.c                    |  2 +-
 net/ipv6/netfilter/ip6t_SYNPROXY.c  |  2 +-
 net/ipv6/netfilter/nf_dup_ipv6.c    |  2 +-
 net/ipv6/netfilter/nf_reject_ipv6.c |  2 +-
 net/ipv6/output_core.c              | 22 +++++--------------
 net/ipv6/raw.c                      |  2 +-
 net/ipv6/route.c                    | 14 ++++++-------
 net/ipv6/xfrm6_output.c             |  6 ++----
 net/mpls/mpls_iptunnel.c            |  2 +-
 net/netfilter/ipvs/ip_vs_xmit.c     |  8 +++----
 net/xfrm/xfrm_output.c              |  4 ++--
 net/xfrm/xfrm_policy.c              | 11 +++++-----
 43 files changed, 125 insertions(+), 155 deletions(-)
