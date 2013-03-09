From: Simon Horman <horms@verge.net.au>
Subject: Re: IPVS changes in 3.3 - 3.8
Date: Sat, 9 Mar 2013 08:53:28 +0100
Message-ID: <20130309075322.GA30329@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-users@linuxvirtualserver.org, lvs-devel@vger.kernel.org, Joseph Mack NA3T <jmack@wm7d.net>

Hi,

in an effort to keep more people up to date on recent developments to IPVS
I post a report of changes for each kernel release. Sometimes I forget and
combine several release into one report. This report comes at the
end of an extended period of my forgetfulness and
looks at the changes to IPVS in the 3.3, 3.4, 3.5, 3.6, 3.7 and 3.8.

3.3:
* Feature
  + Allow the use of real-server weights with the SH scheduler

3.4:
* Bug Fixes
  + Fix various crash bugs related to the initialisation order
    of IPVS components and their dependencies

3.5:
* Bug Fixes
  + Fix oops on rmmod
  + Fix oops in NAT
  + Fix leak in IPv6

* Features:
  + Multi-threaded connection synchronisation
  + New connection synchronisation sysctl parameters:
    sync_refresh_period, sync_retries. 
  + Improve synchronisation slave handling of unbound connections

3.6
* Bug Fixes
  + Fix information leak in getsockopt IP_VS_SO_GET_TIMEOUT

3.7
* Feature
  + Add pmtu_disc sysctl parameter to allow PMTU of IP-TUN packets

* Bug Fixes
  + Fix ARP resolution and thus DR
    - Resolves regression introduced in 3.4
  + Fix IPv6 MTU checking of GSO packets

3.8
* Features
  + SIP fragment handling
  + Complete IPv6 fragment handling

* Bug Fixes
  + Fix IPv6 extension header handling
  + Fix memory leak on error in connection synchronisation daemon
  + fix checksumming on SNAT and DNAT handlers of SCTP
    - Present since SCTP was added to IPVS

Queued up for 3.9
* No bug fixes or features


This report was generated with the help of the following git logs.
Longer versions of the logs may be obtained by omitting --oneline
from the git commands.


git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
cd linux
# git log --oneline --no-merges v3.8..v3.9-rc1 -- \
	net/netfilter/ipvs/ include/net/ip_vs.h include/linux/ip_vs.h

b67bfe0 hlist: drop the node parameter from iterators
ece31ff net: proc: change proc_net_remove to remove_proc_entry
d4beaa6 net: proc: change proc_net_fops_create to proc_create
25cc4ae net: remove redundant check for timer pending state before del_timer


git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
cd linux
# git log --oneline --no-merges v3.7..v3.8 -- \
	net/netfilter/ipvs/ include/net/ip_vs.h include/linux/ip_vs.h

4b47bc9 ipvs: sctp: fix checksumming on snat and dnat handlers
b425df4 ipvs: freeing uninitialized pointer on error
e5ef39e netfilter: Remove the spurious \ in __ip_vs_lblc_init
df008c9 net: Allow userns root to control llc, netfilter, netlink, packet, and xfrm
464dc80 net: Don't export sysctls to unprivileged users
05b4b06 ipvs: remove silly double assignment
54d83ef ipvs: fix build errors related to config option combinations
92eec78 ipvs: SIP fragment handling
d4383f0 ipvs: API change to avoid rescan of IPv6 exthdr
2f74713 ipvs: Complete IPv6 fragment handling for IPVS
63dca2c ipvs: Fix faulty IPv6 extension header handling in IPVS
a638e51 ipvs: Use config macro IS_ENABLED()
2fab891 ipvs: IPv6 extend ICMPv6 handling for future types
120b9c1 ipvs: Trivial changes, use compressed IPv6 address in output


git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
cd linux
# git log --oneline --no-merges v3.6..v3.7 -- \
	net/netfilter/ipvs/ include/net/ip_vs.h include/linux/ip_vs.h

607ca46 UAPI: (Scripted) Disintegrate include/linux
b61a602 ipvs: initialize returned data in do_ip_vs_get_ctl
ad4d3ef ipvs: fix ARP resolving for direct routing mode
15e4730 netlink: Rename pid to portid to avoid confusion
0edd948 ipvs: use list_del_init instead of list_del/INIT_LIST_HEAD
051966c netfilter: nf_nat: add protoff argument to packet mangling functions
4cdd340 netfilter: nf_conntrack_ipv6: improve fragmentation handling
590e3f7 ipvs: IPv6 MTU checking cleanup and bugfix
3654e61 ipvs: add pmtu_disc option to disable IP DF for TUN packets
f2edb9f ipvs: implement passive PMTUD for IPIP packets
2b2d280 ipvs: fixed sparse warning
be97fdb ipvs: generalize app registration in netns
aaea4ed ipvs: ip_vs_ftp depends on nf_conntrack_ftp helper


git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
cd linux
# git log --oneline --no-merges v3.5..v3.6 -- \
	net/netfilter/ipvs/ include/net/ip_vs.h include/linux/ip_vs.h

0a54e93 ipvs: fix error return code
2d8a041 ipvs: fix info leak in getsockopt(IP_VS_SO_GET_TIMEOUT)
6700c27 net: Pass optional SKB and SK arguments to dst_ops->{update_pmtu,redirect}()
4c809d6 netfilter: ipvs: switch hook PFs to nfproto
5d0ba55 net: use consume_skb() in place of kfree_skb()


git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
cd linux
# git log --oneline --no-merges v3.4..v3.5 -- \
	net/netfilter/ipvs/ include/net/ip_vs.h include/linux/ip_vs.h

283283c ipvs: fix oops in ip_vs_dst_event on rmmod
9e33ce4 ipvs: fix oops on NAT reply in br_nf context
c24584c netfilter: ipvs: fix dst leak in __ip_vs_addr_is_local_v6
068d522 ipvs: ip_vs_proto: local functions should not be exposed globally
d5cce20 ipvs: ip_vs_ftp: local functions should not be exposed globally
6b324db ipvs: optimize the use of flags in ip_vs_bind_dest
f73181c ipvs: add support for sync threads
749c42b ipvs: reduce sync rate with time thresholds
1c003b1 ipvs: wakeup master thread
cdcc5e9 ipvs: always update some of the flags bits in backup
882a844 ipvs: fix ip_vs_try_bind_dest to rebind app and transmitter
06611f8 ipvs: remove check for IP_VS_CONN_F_SYNC from ip_vs_bind_dest
82cfc06 ipvs: ignore IP_VS_CONN_F_NOOUTPUT in backup server
9615e61e ipvs: use GFP_KERNEL allocation where possible
d6318f0 ipvs: SH scheduler does not need GFP_ATOMIC allocation
45d4e71 ipvs: LBLCR scheduler does not need GFP_ATOMIC allocation on init
4f2a94d ipvs: WRR scheduler does not need GFP_ATOMIC allocation
4beddbe ipvs: DH scheduler does not need GFP_ATOMIC allocation
748d845 ipvs: LBLC scheduler does not need GFP_ATOMIC allocation on init
41cff6d ipvs: timeout tables do not need GFP_ATOMIC allocation
4a17fd5 sock: Introduce named constants for sk_reuse
a5347fe net: Delete all remaining instances of ctl_path
ec8f23c net: Convert all sysctl registrations to register_net_sysctl
95c9617 net: cleanup unsigned to unsigned int
969e8e2 ipvs: Stop using NLA_PUT*().


git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
cd linux
# git log --oneline --no-merges v3.3..v3.4 -- \
	net/netfilter/ipvs/ include/net/ip_vs.h include/linux/ip_vs.h

8537de8 ipvs: kernel oops - do_ip_vs_get_ctl
582b8e3 ipvs: take care of return value from protocol init_netns
4b984cd ipvs: null check of net->ipvs in lblc(r) shedulers
39f618b ipvs: reset ipvs pointer in netns
8d08d71 ipvs: add check in ftp for initialized core
8f9b9a2 ipvs: fix crash in ip_vs_control_net_cleanup on unload
7118c07 ipvs: Verify that IP_VS protocol has been registered
9ffc93f Remove all #inclusions of asm/system.h
187f188 BUG: headers with BUG/BUG_ON etc. need linux/bug.h


git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
cd linux
# git log --oneline --no-merges v3.2..v3.3 -- \
	net/netfilter/ipvs/ include/net/ip_vs.h include/linux/ip_vs.h

e0aac52 ipvs: fix matching of fwmark templates during scheduling
d191854 ipv6: Kill rt6i_dev and rt6i_expires defines.
3db1cd5 net: fix assignment of 0/1 to bool variables.
c0cd115 net:netfilter: use IS_ENABLED
76ad94f IPVS: Modify the SH scheduler to use weights
4e3fd7a net: remove ipv6_addr_copy()
3f9416c drop "select GCD" from three Kconfig files
