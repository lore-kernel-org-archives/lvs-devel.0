From: Simon Horman <horms@verge.net.au>
Subject: IPVS changes in 3.0, 3.1 and 3.2
Date: Tue, 17 Jan 2012 12:08:58 +1100
Message-ID: <20120117010856.GK19503@verge.net.au>
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
combine several release into one report. This is one such time and this
report looks at the changes to IPVS in the 3.0, 3.1 and 3.2 kernels.

In all 3.0, 3.1 and 3.2 have been fairly quiet releases for IPVS.
Some highlights are:

3.0:
* Bug Fixes
  + Correct crash that manifests when the ip_vs is unloaded from the kernel
    if it was not loaded before nf_conntrack_netlink.
  + Restore support for iptables SNAT which was broken since 2.6.37.

3.1:
* Feature
  + Support more variations of the FTP PASV response format
* Bug Fixes
  + Correct deadlock in netns support
  + Free resources on module removal

3.2:
* Features
  + Expose the ports parameter of the ip_vs_ftp module in sysfs to
    allow it to be changed at run-time.
  + Also check for 0-port services on backup linux-directors when looking
    up the server of a synchronised connection

Scheduled for inclusion 3.3:
* Feature
  + Allow the use of real-server weights with the SH scheduler

This report was generated with the help of the following git logs.
Longer versions of the logs may be obtained by omitting --oneline
from the git commands.

# git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
# cd linux-2.6
# git log --oneline --no-merges v2.6.39..v3.0 -- \
	net/netfilter/ipvs/ include/net/ip_vs.h include/linux/ip_vs.h

8f4e0a1 IPVS netns exit causes crash in conntrack
afb523c ipvs: restore support for iptables SNAT
c74c0bf IPVS: bug in ip_vs_ftp, same list heaad used in all netns.
c92f5ca ipvs: Remove all remaining references to rt->rt_{src,dst}
44e3125 ipvs: Eliminate rt->rt_dst usage in __ip_vs_get_out_rt().
e58b344 ipvs: Use IP_VS_RT_MODE_* instead of magic constants.
2a9e950 net: Remove __KERNEL__ cpp checks from include/net
e3f6a65 IPVS: combine consecutive #ifdef CONFIG_PROC_FS blocks

# git log --oneline --no-merges v3.0..v3.1 -- \
	net/netfilter/ipvs/ include/net/ip_vs.h include/linux/ip_vs.h

ae1d48b IPVS netns shutdown/startup dead-lock
3458e21 netfilter: Use proper rwlock init function
6006349 atomic: use <linux/atomic.h>
7676e34 IPVS: Free resources on module removal
56f8a75 ip: introduce ip_is_fragment helper inline function
6c8f794 IPVS: remove unused init and cleanup functions.
552ad65 IPVS: labels at pos 0
503cf15 IPVS: rename of netns init and cleanup functions.
ed78bec IPVS remove unused var from migration to netns
c3aa1bd ipvs: support more FTP PASV responses

# git log --oneline --no-merges v3.1..v3.2 -- \
	net/netfilter/ipvs/ include/net/ip_vs.h include/linux/ip_vs.h

52793db ipvs: try also real server with port 0 in backup server
e23ebf0 ipvs: Fix compilation error in ip_vs.h for ip_vs_confirm_conntrack funct
ad542ced ipvs: Remove unused variable "cs" from ip_vs_leave function.
0a9ee81 netfilter: Remove unnecessary OOM logging messages
b6338b5 ipvs: Removed unused variables
4a516f1 ipvs: Remove unused return value of protocol state transitions
3c2de2a ipvs: Remove unused parameter from ip_vs_confirm_conntrack()
52669df ipvs: Expose ip_vs_ftp module parameters via sysfs.
69e7dae ip_vs.h: fix implicit use of module_get/module_put from module.h

# git log --oneline -1 origin/master
53999bf error: implicit declaration of function 'module_flags_taint
# git log --oneline --no-merges v3.2..origin/master -- \
	net/netfilter/ipvs/ include/net/ip_vs.h include/linux/ip_vs.h

d191854 ipv6: Kill rt6i_dev and rt6i_expires defines.
3db1cd5 net: fix assignment of 0/1 to bool variables.
c0cd115 net:netfilter: use IS_ENABLED
76ad94f IPVS: Modify the SH scheduler to use weights
4e3fd7a net: remove ipv6_addr_copy()
3f9416c drop "select GCD" from three Kconfig files

