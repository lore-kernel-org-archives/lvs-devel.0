From: Simon Horman <horms@verge.net.au>
Subject: LVS changes in Linux 2.6.34 and 2.6.35
Date: Wed, 4 Aug 2010 12:34:56 +0900
Message-ID: <20100804033454.GA17639@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-users@linuxvirtualserver.org, lvs-devel@vger.kernel.org
Cc: Joseph Mack NA3T <jmack@wm7d.net>

Hi,

In an effort to keep people up to date about changes
to LVS I am trying to write a summary of changes each
time a new kernel is released.

Unfortunately I forgot to do this for the 2.6.34 release,
so this report covers changes included in both 2.6.34 and 2.6.35.

In 2.6.35 (released on the 1st August 2010):

* Bug-fix:
  - Fix connection table locking
    Potential crash-bug.
    There have been no manifestation of this bug reported.

In 2.6.34 (released on the 16th May 2010):

* Features:
  - SCTP load balancing

* Clean-up:
  - Various minor code clean-ups

----------------------------------------------------------------------

The following commands were used to generate data for this report:

$ git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6
$ cd linux-2.6
$ git log v2.6.33..v2.6.35 --grep=ipvs --no-merges

commit aea9d711f3d68c656ad31ab578ecfb0bb5cd7f97
Author: Sven Wegener <sven.wegener@stealer.net>
Date:   Wed Jun 9 16:10:57 2010 +0200

    ipvs: Add missing locking during connection table hashing and unhashing
    
    The code that hashes and unhashes connections from the connection table
    is missing locking of the connection being modified, which opens up a
    race condition and results in memory corruption when this race condition
    is hit.
    
    Here is what happens in pretty verbose form:
    
    CPU 0					CPU 1
    ------------				------------
    An active connection is terminated and
    we schedule ip_vs_conn_expire() on this
    CPU to expire this connection.
    
    					IRQ assignment is changed to this CPU,
    					but the expire timer stays scheduled on
    					the other CPU.
    
    					New connection from same ip:port comes
    					in right before the timer expires, we
    					find the inactive connection in our
    					connection table and get a reference to
    					it. We proper lock the connection in
    					tcp_state_transition() and read the
    					connection flags in set_tcp_state().
    
    ip_vs_conn_expire() gets called, we
    unhash the connection from our
    connection table and remove the hashed
    flag in ip_vs_conn_unhash(), without
    proper locking!
    
    					While still holding proper locks we
    					write the connection flags in
    					set_tcp_state() and this sets the hashed
    					flag again.
    
    ip_vs_conn_expire() fails to expire the
    connection, because the other CPU has
    incremented the reference count. We try
    to re-insert the connection into our
    connection table, but this fails in
    ip_vs_conn_hash(), because the hashed
    flag has been set by the other CPU. We
    re-schedule execution of
    ip_vs_conn_expire(). Now this connection
    has the hashed flag set, but isn't
    actually hashed in our connection table
    and has a dangling list_head.
    
    					We drop the reference we held on the
    					connection and schedule the expire timer
    					for timeouting the connection on this
    					CPU. Further packets won't be able to
    					find this connection in our connection
    					table.
    
    					ip_vs_conn_expire() gets called again,
    					we think it's already hashed, but the
    					list_head is dangling and while removing
    					the connection from our connection table
    					we write to the memory location where
    					this list_head points to.
    
    The result will probably be a kernel oops at some other point in time.
    
    This race condition is pretty subtle, but it can be triggered remotely.
    It needs the IRQ assignment change or another circumstance where packets
    coming from the same ip:port for the same service are being processed on
    different CPUs. And it involves hitting the exact time at which
    ip_vs_conn_expire() gets called. It can be avoided by making sure that
    all packets from one connection are always processed on the same CPU and
    can be made harder to exploit by changing the connection timeouts to
    some custom values.
    
    Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
    Cc: stable@kernel.org
    Acked-by: Simon Horman <horms@verge.net.au>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

commit 7911b5c75b613f533b6cb6f999041dd5ea3bb004
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Tue Mar 23 04:08:46 2010 +0100

    netfilter: ipvs: use NFPROTO values for NF_HOOK invocation
    
    Semantic patch:
    // <smpl>
    @@
    @@
     IP_VS_XMIT(
    -PF_INET6,
    +NFPROTO_IPV6,
     ...)
    
    @@
    @@
     IP_VS_XMIT(
    -PF_INET,
    +NFPROTO_IPV4,
     ...)
    // </smpl>
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

commit 1da05f50f6a766c7611102382f85183b4db96c2d
Author: Joe Perches <joe@perches.com>
Date:   Mon Mar 15 18:03:05 2010 +0100

    netfilter: net/netfilter/ipvs/ip_vs_ftp.c: Remove use of NIPQUAD
    
    NIPQUAD has very few uses left.
    
    Remove this use and make the code have the identical form of the only
    other use of "%u,%u,%u,%u,%u,%u" in net/ipv4/netfilter/nf_nat_ftp.c
    
    Signed-off-by: Joe Perches <joe@perches.com>
    Acked-by: Simon Horman <horms@verge.net.au>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

commit 2906f66a5682e5670a5eefe991843689b8d8563f
Author: Venkata Mohan Reddy <mohanreddykv@gmail.com>
Date:   Thu Feb 18 12:31:05 2010 +0100

    ipvs: SCTP Trasport Loadbalancing Support
    
    Enhance IPVS to load balance SCTP transport protocol packets. This is done
    based on the SCTP rfc 4960. All possible control chunks have been taken
    care. The state machine used in this code looks some what lengthy. I tried
    to make the state machine easy to understand.
    
    Signed-off-by: Venkata Mohan Reddy Koppula <mohanreddykv@gmail.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

commit a79e7ac4ad77e1833e8f69e99113204d03018255
Author: Joe Perches <joe@perches.com>
Date:   Mon Jan 11 11:53:31 2010 +0100

    ipvs: use standardized format in sprintf
    
    Use the same format string as net/ipv4/netfilter/nf_nat_ftp.c
    to encode an ipv4 address and port.
    
    Both uses should be a single common function.
    
    Signed-off-by: Joe Perches <joe@perches.com>
    Acked-by: Simon Horman <horms@verge.net.au>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

