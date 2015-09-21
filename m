From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH next 00/84] ipvs: Stop guessing the network namespace (take 2)
Date: Mon, 21 Sep 2015 13:01:59 -0500
Message-ID: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
	<87pp1fpy1b.fsf@x220.int.ebiederm.org>
	<87fv2bo7br.fsf_-_@x220.int.ebiederm.org>
	<87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87h9mplifu.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Sun, 20 Sep 2015 01:21:25 -0500")
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>


I am gradually working my way through the netfilter stack passing struct
down into the netfilter hooks and from the netfilter hooks and from
there down into the functions that actually care.  This removes the need
for netfilter functions to guess how to figure out how to compute which
network namespace they are in and instead provides a simple and reliable
method to do so.

The cleanups stand on their own but this is part of a larger effort to
have routes with an output device that is not in the current network
namespace.

The IPVS code has been a bit more of a challenge than most.  Just
passing struct net through to where it is needed did not feel clean to
me.  The practical issue is that the ipvs code in most places actually
wants struct netns_ipvs and not struct net.

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
series compiles at each step so bisecting it should not be a problem
if something weird comes up.

The first two changes in this series are actually bug fixes.  The first
is a compile fix for a bug in sctp that came in, in the last round of
ipvs changes merged into nf-next.  The second fixes an older bug where
in pathological circumstances the wrong network namespace could be used
when a proc file is written to.

The rest of the patchset is a bunch of boring changes getting pushing
struct netns_ipvs (and by extension ipvs->net) where it needs to be.
Either by replacing struct net pointers or adding new struct netns_ipvs
pointers.  With a handful of other minor cleanups (like removing
skb_net).

I have incorporated Julian Anastasov's feedback, which critically
involves fixing a wrong piece of code.

The changes are also available against nf-next at:
git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/net-next.git master

My entire pending set of changes for those who want to look ahead is at:
git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/net-next.git for-testing

Eric

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

Net differences since the first version of this patchset.

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 3d461f417c1d..d1d168c7fc68 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -360,7 +360,7 @@ struct ip_vs_conn *ip_vs_ct_in_get(const struct ip_vs_conn_param *p)
 
        hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[hash], c_list) {
                if (unlikely(p->pe_data && p->pe->ct_match)) {
-                       if (cp->ipvs == p->ipvs)
+                       if (cp->ipvs != p->ipvs)
                                continue;
                        if (p->pe == cp->pe && p->pe->ct_match(p, cp)) {
                                if (__ip_vs_conn_get(cp))
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index f7386d5b231c..e7c1b052c2a3 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1157,7 +1157,7 @@ static void ip_vs_dest_trash_expire(unsigned long data)
  *     Add a service into the service hash table
  */
 static int
- ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
+ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
                  struct ip_vs_service **svc_p)
 {
        int ret = 0, i;
@@ -3858,7 +3858,7 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
        } else
                tbl = vs_vars;
        /* Initialize sysctl defaults */
-       for (idx = 0; idx < sizeof(vs_vars)/sizeof(vs_vars[0]); idx++) {
+       for (idx = 0; idx < ARRAY_SIZE(vs_vars); idx++) {
                if (tbl[idx].proc_handler == proc_do_defense_mode)
                        tbl[idx].extra2 = ipvs;
        }
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 0733f36732b4..d30c327bb578 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -468,8 +468,10 @@ err_unreg:
 static void __ip_vs_ftp_exit(struct net *net)
 {
        struct netns_ipvs *ipvs = net_ipvs(net);
+
        if (!ipvs)
                return;
+
        unregister_ip_vs_app(ipvs, &ip_vs_ftp);
 }
 

