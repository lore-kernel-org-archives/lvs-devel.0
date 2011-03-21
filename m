From: Simon Horman <horms@verge.net.au>
Subject: LVS changes in 2.6.38
Date: Mon, 21 Mar 2011 16:22:01 +0900
Message-ID: <20110321072159.GC6690@verge.net.au>
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
report looks at the changes to LVS in the 2.6.38 kernel.

In all 2.6.38 was a rather quiet release for LVS compared to the
previous few releases.

Features
* There were no new features added

Bug Fixes
* Julian fixed a locking bug which manifests if destinations are updated
  (frequently). This problem was introduced in 2.6.37 and a -stable
  fix is included in 2.6.37.4.

Clean-Ups
* There were a small number of clean-ups as per the git log below

There has been an very large amount of work on LVS for 2.6.39, I suspect a
record number of patches. The new features include a new synchronisation
protocol and support for network namespaces.  Special thanks to Hans and
Julian for their work in this area. There have also been a large number of
clean-ups, thanks to everyone who contributed.  If you are interested in
any of these changes I suggest looking at 2.6.39-rc1 once it is released
for a taste of things to come.


This report was generated with the help of the following git log:

# git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
# cd linux-2.6
# git log --no-merges v2.6.37..v2.6.38 \
	net/netfilter/ipvs/ include/net/ip_vs.h include/linux/ip_vs.h

commit ff75f40f44ae9b79d520bf32a05d35af74a805c0
Author: Julian Anastasov <ja@ssi.bg>
Date:   Tue Feb 22 10:40:25 2011 +0200

    ipvs: fix dst_lock locking on dest update
    
    	Fix dst_lock usage in __ip_vs_update_dest. We need
    _bh locking because destination is updated in user context.
    Can cause lockups on frequent destination updates.
    Problem reported by Simon Kirby. Bug was introduced
    in 2.6.37 from the "ipvs: changes for local real server"
    change.
    
    Signed-off-by: Julian Anastasov <ja@ssi.bg>
    Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit afe2c511fb2d75f1515081ff1be15bd79cfe722d
Author: Tejun Heo <tj@kernel.org>
Date:   Tue Dec 14 16:21:17 2010 +0100

    workqueue: convert cancel_rearming_delayed_work[queue]() users to cancel_delayed_work_sync()
    
    cancel_rearming_delayed_work[queue]() has been superceded by
    cancel_delayed_work_sync() quite some time ago.  Convert all the
    in-kernel users.  The conversions are completely equivalent and
    trivial.
    
    Signed-off-by: Tejun Heo <tj@kernel.org>
    Acked-by: "David S. Miller" <davem@davemloft.net>
    Acked-by: Greg Kroah-Hartman <gregkh@suse.de>
    Acked-by: Evgeniy Polyakov <zbr@ioremap.net>
    Cc: Jeff Garzik <jgarzik@pobox.com>
    Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
    Cc: Mauro Carvalho Chehab <mchehab@infradead.org>
    Cc: netdev@vger.kernel.org
    Cc: Anton Vorontsov <cbou@mail.ru>
    Cc: David Woodhouse <dwmw2@infradead.org>
    Cc: "J. Bruce Fields" <bfields@fieldses.org>
    Cc: Neil Brown <neilb@suse.de>
    Cc: Alex Elder <aelder@sgi.com>
    Cc: xfs-masters@oss.sgi.com
    Cc: Christoph Lameter <cl@linux-foundation.org>
    Cc: Pekka Enberg <penberg@cs.helsinki.fi>
    Cc: Andrew Morton <akpm@linux-foundation.org>
    Cc: netfilter-devel@vger.kernel.org
    Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: linux-nfs@vger.kernel.org

commit 5811662b15db018c740c57d037523683fd3e6123
Author: Changli Gao <xiaosuo@gmail.com>
Date:   Fri Nov 12 18:43:55 2010 +0000

    net: use the macros defined for the members of flowi
    
    Use the macros defined for the members of flowi to clean the code up.
    
    Signed-off-by: Changli Gao <xiaosuo@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit c753796769e4fb0cd813b6e5801b3c01f4681d4f
Author: David S. Miller <davem@davemloft.net>
Date:   Thu Nov 11 17:07:48 2010 -0800

    ipv4: Make rt->fl.iif tests lest obscure.
    
    When we test rt->fl.iif against zero, we're seeing if it's
    an output or an input route.
    
    Make that explicit with some helper functions.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

