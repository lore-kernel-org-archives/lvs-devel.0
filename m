From: Daniel Drown <dan-lvs@drown.org>
Subject: multiple local nodes (patch)
Date: Mon, 8 Dec 2008 21:40:12 +0000
Message-ID: <20081208214012.GP30076@vps.drown.org>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org

I have a need for multiple local nodes in LVS.  I started from the patch from
2005:
http://archive.linuxvirtualserver.org/html/lvs-users/2005-06/msg00113.html

I found three problems with it:
1. packet checksums were not calculated correctly
2. having stats enabled would deadlock the kernel in the stats update function
	(ip_vs_in_stats/ip_vs_out_stats)
3. the kernel would deadlock in the packet recieve function (ip_vs_in)

For #1, I believe this was because the existing code assumes the TCP/UDP
checksums are correct (which is not true for locally generated packets with
hardware checksum).  I just used the same code that the tcp and udp functions
use.

For #2 and #3, the problem was that the majority of the code runs as a bottom
handler.  Locally generated packets are run as a normal kernel context.  If a
network interrupt happens while the kernel is holding a IPVS lock for sending
a local packet, it can schedule the bottom handler.  The bottom handler can
then try to acquire the same lock, and this is a deadlock.  To prevent this
from happening, I've disabled bottom handlers (local_bh_disable) in the local
packet output function I created (ip_vs_out_nobh).

I've tested this and it works on a RH5/CentOS5 2.6.18.92.1.17.el5 kernel:
http://dan.drown.org/software/ipvs-2.6.18-92.1.17.el5-multiple-local-nodes.patch

I've ported it to a stock 2.6.27.7 kernel, but I haven't had time to test it
out yet:
http://dan.drown.org/software/ipvs-2.6.27.7-multiple-local-nodes.patch

I welcome any comments or criticism on the code.
