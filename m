From: Simon Horman <horms@verge.net.au>
Subject: LVS changes in 2.6.39
Date: Thu, 2 Jun 2011 08:33:53 +0900
Message-ID: <20110601233351.GA16256@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-users@linuxvirtualserver.org, lvs-devel@vger.kernel.org, Joseph Mack NA3T <jmack@wm7d.net>

Hi,

in an effort to keep more people up to date on recent developments
to LVS I post a report of changes for each kernel release. This
report looks at the changes to LVS in the 2.6.39 kernel.

In all 2.6.39 was a rather busy release for LVS with a total of 92 patches.
Some highlights are:

Features
* Network namespace support
* New synchronisation protocol
* Optimised statistics reading

Bug Fixes
* Allow transmit of GRO aggregated skbs
* Allow fragmented packets to be handled by SIP persistence engine
* Correct zeroing of statistics

Clean-Ups
* Reduce code suse when compiled without CONFIG_SYSCTL

There are no new LVS features queued up for inclusion in Linux 3.0,
it looks like it will be a bug-fix release from an LVS point of view.

This report was generated with the help of the following git log:

# git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
# cd linux-2.6
# git log --no-merges v2.6.38..v2.6.39 -- \
	net/netfilter/ipvs/ include/net/ip_vs.h include/linux/ip_vs.h

Which is rather long, an abridged version is:

# git log --oneline --no-merges v2.6.38..v2.6.39 -- \
	net/netfilter/ipvs/ include/net/ip_vs.h include/linux/ip_vs.h


0f08190 IPVS: fix netns if reading ip_vs_* procfs entries
7a4f076 IPVS: init and cleanup restructuring
1ae132b IPVS: Change of socket usage to enable name space exit.
a09d197 IPVS: fix NULL ptr dereference in ip_vs_ctl.c ip_vs_genl_dump_daemons()
25985ed Fix common misspellings
736561a IPVS: Use global mutex in ip_vs_app.c
f40f94f ipvs: fix a typo in __ip_vs_control_init()
f2247fb IPVS: Conditionally include sysctl members of struct netns_ipvs
14e4054 IPVS: Add __ip_vs_control_{init,cleanup}_sysctl()
fb1de43 IPVS: Conditionally define and use ip_vs_lblc{r}_table
a7a86b8 IPVS: Minimise ip_vs_leave when CONFIG_SYSCTL is undefined
a4e2f5a IPVS: Conditional ip_vs_conntrack_enabled()
3a1bbf1 IPVS: ip_vs_todrop() becomes a noop when CONFIG_SYSCTL is undefined
b27d777 IPVS: Conditinally use sysctl_lblc{r}_expiration
8e1b0b1 IPVS: Add expire_quiescent_template()
71a8ab6 IPVS: Add sysctl_expire_nodest_conn()
7532e8d IPVS: Add sysctl_sync_ver()
59e0350 IPVS: Add {sysctl_sync_threshold,period}()
0cfa558 IPVS: Add sysctl_nat_icmp_send()
84b3cee IPVS: Add sysctl_snat_reroute()
ba4fd7e IPVS: Add ip_vs_route_me_harder()
6ef757f ipvs: rename estimator functions
ea9f22c ipvs: optimize rates reading
87d68a1 ipvs: remove unused seqcount stats
55a3d4e ipvs: properly zero stats and rates
2a0751a ipvs: reorganize tot_stats
2553d06 ipvs: move struct netns_ipvs
06b6939 IPVS: Fix variable assignment in ip_vs_notrack
6060c74 netfilter:ipvs: use kmemdup
4a569c0 ipvs: remove _bh from percpu stats reading
097fc76 ipvs: avoid lookup for fwmark 0
4c9483b ipv6: Convert to use flowi6 where applicable.
9d6ec93 ipv4: Use flowi4 in public route lookup interfaces.
1d28f42 net: Put flowi_* prefix on AF independent members of struct flowi
78fbfd8 ipv4: Create and use route lookup helpers.
b23dd4f ipv4: Make output route lookup return rtable directly.
452edd5 xfrm: Return dst directly from xfrm_lookup()
b552f7e ipvs: unify the formula to estimate the overhead of processing connections
17a8f8e ipvs: use enum to instead of magic numbers
731109e ipvs: use hlist instead of list
41ac51e ipvs: make "no destination available" message more informative
6cb90db ipvs: remove extra lookups for ICMP packets
16a7fd3 ipvs: fix timer in get_curr_sync_buff
7c9989a IPVS: precedence bug in ip_vs_sync_switch_mode()
8525d6f IPVS: Use correct lock in SCTP module
ed3d1e7 IPVS: Remove ip_vs_sync_cleanup from section __exit
0443929 IPVS: Allow compilation with CONFIG_SYSCTL disabled
a136764 IPVS: Remove unused variables
258e958 IPVS: remove duplicate initialisation or rs_table
a870c8c IPVS: use z modifier for sizeof() argument
9f4e1cc netfilter: ipvs: fix compiler warnings
0792470 IPVS netns BUG, register sysctl for root ns
4b3fd57 IPVS: Change sock_create_kernel() to __sock_create()
091bb34 netfilter: ipvs: fix compiler warnings
c6d2d44 IPVS: netns, final patch enabling network name space.
4a98480 IPVS: netns, misc init_net removal in core.
763f8d0 IPVS: netns, svc counters moved in ip_vs_ctl,c
f2431e6 IPVS: netns, trash handling
f6340ee IPVS: netns, defense work timer.
a0840e2 IPVS: netns, ip_vs_ctl local vars moved to ipvs struct.
6e67e58 IPVS: netns, connection hash got net as param.
b17fc99 IPVS: netns, ip_vs_stats and its procfs
f131315 IPVS: netns awareness to ip_vs_sync
29c2026 IPVS: netns awareness to ip_vs_est
ab8a5e8 IPVS: netns awareness to ip_vs_app
9bbac6a IPVS: netns, common protocol changes and use of appcnt.
9330419 IPVS: netns, use ip_vs_proto_data as param.
88fe2d3 IPVS: netns preparation for proto_ah_esp
9d93487 IPVS: netns preparation for proto_sctp
78b16bd IPVS: netns preparation for proto_udp
4a85b96 IPVS: netns preparation for proto_tcp
252c641 IPVS: netns, prepare protocol
b6e885d IPVS: netns awarness to lblc sheduler
d0a1eef IPVS: netns awarness to lblcr sheduler
fc72325 IPVS: netns to services part 1
61b1ab4 IPVS: netns, add basic init per netns.
b880c1f IPVS: Backup, adding version 0 sending capabilities
986a075 IPVS: Backup, Change sending to Version 1 format
fe5e7a1 IPVS: Backup, Adding Version 1 receive capability
2981bc9 IPVS: Backup, Adding structs for new sync format
a5959d5 IPVS: Handle Scheduling errors.
3716522 IPVS: skb defrag in L7 helpers
ce144f2 IPVS: Split ports[2] into src_port and dst_port
0e051e6 IPVS: Backup, Prepare for transferring firewall marks (fwmark) to the backup daemon.
8f1b03a ipvs: allow transmit of GRO aggregated skbs
a333e2e ipvs: remove shadow rt variable
4ecd294 ipvs: add static and read_mostly attributes
8aadf93 IPVS: buffer argument to ip_vs_process_message() should not be const
7ae246a IPVS: Remove useless { } block from ip_vs_process_message()
d494262 IPVS: Make the cp argument to ip_vs_sync_conn() static
ea2c73a IPVS: Only match pe_data created by the same pe
e9e5eee IPVS: Add persistence engine to connection entry
