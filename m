From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next 00/84] Second Round of IPVS Updates for v4.4
Date: Thu, 24 Sep 2015 09:51:45 +0900
Message-ID: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, "Eric W. Biederman" <ebiederm@xmission.com>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider these bug fixes and extensive clean-ups of IPVS
from Eric Biederman for v4.4.

His excellent description of the changes, which is part of an even larger
set of clean-up work, is as follows:

  I am gradually working my way through the netfilter stack passing struct
  down into the netfilter hooks and from the netfilter hooks and from there
  down into the functions that actually care.  This removes the need for
  netfilter functions to guess how to figure out how to compute which
  network namespace they are in and instead provides a simple and reliable
  method to do so.

  The cleanups stand on their own but this is part of a larger effort to
  have routes with an output device that is not in the current network
  namespace.

  The IPVS code has been a bit more of a challenge than most.  Just passing
  struct net through to where it is needed did not feel clean to me.  The
  practical issue is that the ipvs code in most places actually wants
  struct netns_ipvs and not struct net.

  So as part of this process I have turned the relationship between struct
  net and the structs netns_ipvs, ip_vs_conn_param, ip_vs_conn, and
  ip_vs_service inside out.  I have modified the ipvs functions to take a
  struct netns_ipvs not a struct net.  The net is code with fewer
  conversions from one type of structure to another.  I did wind up adding
  a struct netns_ipvs parameter to quite a few functions that did not have
  it before so I could pass the structure down from the netfilter hooks to
  where it is actually needed to avoid guessing.

  I have broken up the work in a bunch of small patches so there is at
  least a chance and reviewing that each step I took is correct.  The
  series compiles at each step so bisecting it should not be a problem if
  something weird comes up.

  The first two changes in this series are actually bug fixes.  The first
  is a compile fix for a bug in sctp that came in, in the last round of
  ipvs changes merged into nf-next.  The second fixes an older bug where in
  pathological circumstances the wrong network namespace could be used when
  a proc file is written to.

  The rest of the patchset is a bunch of boring changes getting pushing
  struct netns_ipvs (and by extension ipvs->net) where it needs to be.
  Either by replacing struct net pointers or adding new struct netns_ipvs
  pointers.  With a handful of other minor cleanups (like removing
  skb_net).

I have decided include the bug fixes in this pull request. Patch one
relates to a bug that was added to nf-next recently and is thus not
applicable to nf . Patch two could arguably be promoted to a fix for v4.3
and stable though it does not appear to be severe enough to warrant that
course of action; let me know if you would like me to reconsider.


The following changes since commit 227b9e8708b14a8a26ef67bbbe19b13626df4a35:

  usbnet: remove invalid check (2015-09-22 16:14:32 -0700)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs2-for-v4.4

for you to fetch changes up to 57781c1ceead5a3c1cd3ae11834226ef1de21cb5:

  ipvs: Pass ipvs into ip_vs_gather_frags (2015-09-24 09:34:43 +0900)

----------------------------------------------------------------
Eric W. Biederman (84):
      ipvs: Hoist computation of ipvs earlier in sctp_conn_schedule
      ipvs: Don't use current in proc_do_defense_mode
      ipvs: Use state->net in the ipvs forward functions
      ipvs: Store ipvs not net in struct ip_vs_conn
      ipvs: Store ipvs not net in struct ip_vs_conn_param
      ipvs: Pass ipvs not net to ip_vs_fill_conn
      ipvs: Store ipvs not net in struct ip_vs_service
      ipvs: Pass ipvs not net to ip_vs_svc_fwm_hashkey
      ipvs: Pass ipvs not net to __ip_vs_svc_fwm_find
      ipvs: Pass ipvs not net to ip_vs_svc_hashkey
      ipvs: Pass ipvs not net to __ip_vs_service_find
      ipvs: Pass ipvs not net to ip_vs_service_find
      ipvs: Pass ipvs not net to ip_vs_has_real_service
      ipvs: Pass ipvs not net to ip_vs_find_dest
      ipvs: Pass ipvs not net to ip_vs_trash_cleanup
      ipvs: Pass ipvs not net to __ip_vs_del_dest
      ipvs: Pass ipvs not net to ip_vs_dest_trash_expire
      ipvs: Cache ipvs in ip_vs_genl_set_cmd
      ipvs: Pass ipvs not net to ip_vs_add_service
      ipvs: Pass ipvs not net to ip_vs_flush
      ipvs: Pass ipvs not net to ip_vs_service_net_cleanup
      ipvs: Pass ipvs not net to ip_vs_zero_all
      ipvs: Cache ipvs in ip_vs_in_icmp and ip_vs_in_icmp_v6
      ipvs: Pass ipvs not net to ip_vs_proto_data_get
      ipvs: Pass ipvs not net to ip_vs_set_timeout
      ipvs: Pass ipvs not net to __ip_vs_get_service_entries
      ipvs: Pass ipvs not net to __ip_vs_get_dest_entries
      ipvs: Pass ipvs not net to __ip_vs_get_timeouts
      ipvs: Pass ipvs not net to ip_vs_genl_parse_service
      ipvs: Pass ipvs not net to ip_vs_genl_find_service
      ipvs: Pass ipvs not net to ip_vs_genl_new_daemon
      ipvs: Pass ipvs not net to ip_vs_genl_del_daemon
      ipvs: Pass ipvs not net to start_sync_thread
      ipvs: Pass ipvs not net to stop_sync_thread
      ipvs: Pass ipvs not net to make_send_sock
      ipvs: Pass ipvs not net to make_receive_sock
      ipvs: Store ipvs not net in struct ip_vs_sync_thread_data
      ipvs: Pass ipvs not net to ip_vs_process_message
      ipvs: Pass ipvs not net to ip_vs_sync_conn_v0
      ipvs: Pass ipvs not net to ip_vs_sync_conn
      ipvs: Pass ipvs not net to ip_vs_proc_conn
      ipvs: Pass ipvs not net to ip_vs_proc_sync_conn
      ipvs: Pass ipvs not net to ip_vs_sync_net_init
      ipvs: Pass ipvs not net to ip_vs_sync_net_cleanup
      ipvs: Pass ipvs not net to ip_vs_genl_set_config
      ipvs: Pass ipvs not net to ip_vs_start_estimator aned ip_vs_stop_estimator
      ipvs: Pass ipvs not net to ip_vs_random_drop_entry
      ipvs: Pass ipvs not net to ip_vs_control_net_(init|cleanup)_sysctl
      ipvs: Pass ipvs not net into ip_vs_control_net_(init|cleanup)
      ipvs: Pass ipvs not net to estimation_timer
      ipvs: Pass ipvs not net to ip_vs_estimator_net_init and ip_vs_estimator_cleanup
      ipvs: Pass ipvs not net into register_app and unregister_app
      ipvs: Pass ipvs not net into ip_vs_app_inc_new
      ipvs: Pass ipvs not net to register_ip_vs_app_inc
      ipvs: Pass ipvs not net to register_ip_vs_app and unregister_ip_vs_app
      ipvs: Pass ipvs not net into ip_vs_app_inc_release
      ipvs: Pass ipvs not net into ip_vs_app_net_init and ip_vs_app_net_cleanup
      ipvs: Pass ipvs not net into [un]register_ip_vs_proto_netns
      ipvs: Pass ipvs not net into init_netns and exit_netns
      ipvs: Pass ipvs into ip_vs_conn_fill_param_proto
      ipvs: Pass ipvs into .conn_in_get and ip_vs_conn_in_get_proto
      ipvs: Pass ipvs into conn_out_get
      ipvs: Pass ipvs not net to ip_vs_conn_hashkey
      ipvs: Pass ipvs not net into ip_vs_conn_net_flush
      ipvs: Pass ipvs not net into ip_vs_conn_net_init and ip_vs_conn_net_cleanup
      ipvs: Pass ipvs into .conn_schedule and ip_vs_try_to_schedule
      ipvs: Better derivation of ipvs in ip_vs_tunnel_xmit
      ipvs: Pass ipvs into __ip_vs_get_out_rt
      ipvs: Pass ipvs into __ip_vs_get_out_rt_v6
      ipvs: Pass ipvs into ensure_mtu_is adequate
      ipvs: Better derivation of ipvs in ip_vs_in_stats and ip_vs_out_stats
      ipvs: Wrap sysctl_cache_bypass and remove ifdefs in ip_vs_leave
      ipvs: Simplify ipvs and net access in ip_vs_leave
      ipvs: Pass ipvs not net into sysctl_nat_icmp_send
      ipvs: Pass ipvs into ip_vs_out
      ipvs: Pass ipvs into ip_vs_in
      ipvs: Pass ipvs into ip_vs_in_icmp and ip_vs_in_icmp_v6
      ipvs: Pass ipvs into ip_vs_out_icmp and ip_vs_out_icmp_v6
      ipvs: Pass ipvs through ip_vs_route_me_harder into sysctl_snat_reroute
      ipvs: Remove net argument from ip_vs_tcp_conn_listen
      ipvs: Pass ipvs not net to ip_vs_protocol_net_(init|cleanup)
      ipvs: Remove skb_net
      ipvs: Remove skb_sknet
      ipvs: Pass ipvs into ip_vs_gather_frags

 include/net/ip_vs.h                     | 179 +++++++--------------
 net/netfilter/ipvs/ip_vs_app.c          |  36 ++---
 net/netfilter/ipvs/ip_vs_conn.c         |  76 ++++-----
 net/netfilter/ipvs/ip_vs_core.c         | 228 ++++++++++++--------------
 net/netfilter/ipvs/ip_vs_ctl.c          | 276 ++++++++++++++++----------------
 net/netfilter/ipvs/ip_vs_est.c          |  20 +--
 net/netfilter/ipvs/ip_vs_ftp.c          |  27 ++--
 net/netfilter/ipvs/ip_vs_lblc.c         |   3 +-
 net/netfilter/ipvs/ip_vs_lblcr.c        |   3 +-
 net/netfilter/ipvs/ip_vs_nfct.c         |   5 +-
 net/netfilter/ipvs/ip_vs_proto.c        |  33 ++--
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |  19 ++-
 net/netfilter/ipvs/ip_vs_proto_sctp.c   |  28 ++--
 net/netfilter/ipvs/ip_vs_proto_tcp.c    |  33 ++--
 net/netfilter/ipvs/ip_vs_proto_udp.c    |  28 ++--
 net/netfilter/ipvs/ip_vs_sync.c         |  87 +++++-----
 net/netfilter/ipvs/ip_vs_xmit.c         |  55 ++++---
 net/netfilter/xt_ipvs.c                 |   3 +-
 18 files changed, 501 insertions(+), 638 deletions(-)
