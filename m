From: Simon Horman <horms@verge.net.au>
Subject: LVS changes in Linux 2.6.36
Date: Thu, 21 Oct 2010 20:37:11 +0200
Message-ID: <20101021183710.GA2088@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: lvs-users@linuxvirtualserver.org, lvs-devel@vger.kernel.org
Cc: Joseph Mack NA3T <jmack@wm7d.net>

Hi,

In an effort to keep people up to date about changes
to LVS I am trying to write a summary of changes each
time a new kernel is released.

In 2.6.35 (released on the 20th October 2010):

* Features
  - Full NAT
  - One packet Scheduling

----------------------------------------------------------------------

The following commands were used to generate data for this report:

$ git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linu=
x-2.6
$ cd linux-2.6
$ git log --no-merges v2.6.35..v2.6.36 \
	include/net/ip_vs.h include/linux/ip_vs.h net/netfilter/ipvs/

commit 6523ce1525e88c598c75a1a6b8c4edddfa9defe8
Author: Julian Anastasov <ja@ssi.bg>
Date:   Sun Sep 5 18:02:29 2010 +0000

    ipvs: fix active FTP
   =20
    - Do not create expectation when forwarding the PORT
      command to avoid blocking the connection. The problem is that
      nf_conntrack_ftp.c:help() tries to create the same expectation la=
ter in
      POST_ROUTING and drops the packet with "dropping packet" message =
after
      failure in nf_ct_expect_related.
   =20
    - Change ip_vs_update_conntrack to alter the conntrack
      for related connections from real server. If we do not alter the =
reply in
      this direction the next packet from client sent to vport 20 comes=
 as NEW
      connection. We alter it but may be some collision happens for bot=
h
      conntracks and the second conntrack gets destroyed immediately. T=
he
      connection stucks too.
   =20
    Signed-off-by: Julian Anastasov <ja@ssi.bg>
    Signed-off-by: Simon Horman <horms@verge.net.au>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit 7bcbf81a2296a8f71342445560dcbe16100b567c
Author: Julian Anastasov <ja@ssi.bg>
Date:   Wed Sep 1 23:07:10 2010 +0000

    ipvs: avoid oops for passive FTP
   =20
    Fix Passive FTP problem in ip_vs_ftp:
   =20
    - Do not oops in nf_nat_set_seq_adjust (adjust_tcp_sequence) when
      iptable_nat module is not loaded
   =20
    Signed-off-by: Julian Anastasov <ja@ssi.bg>
    Signed-off-by: Simon Horman <horms@verge.net.au>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit 5c0d2374a16fcb52096df914ee57720987677be5
Author: Simon Horman <horms@verge.net.au>
Date:   Mon Aug 2 17:12:44 2010 +0200

    ipvs: provide default ip_vs_conn_{in,out}_get_proto
   =20
    This removes duplicate code by providing a default implementation
    which is used by 3 of the 4 modules that provide these call.
   =20
    Signed-off-by: Simon Horman <horms@verge.net.au>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

commit 2890a1573d1ae859a4d77e2fdbecacf21f96c0db
Author: Simon Horman <horms@verge.net.au>
Date:   Mon Aug 2 17:08:11 2010 +0200

    ipvs: remove EXPERIMENTAL tag
   =20
    IPVS was merged into the kernel quite a long time ago and
    has been seeing wide-spread production use for even longer.
   =20
    It seems appropriate for it to be no longer tagged as EXPERIMENTAL
   =20
    Signed-off-as: Simon Horman <horms@verge.net.au>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

commit 7f1c407579519e71a0dcadc05614fd98acec585e
Author: Hannes Eder <heder@google.com>
Date:   Fri Jul 23 12:48:52 2010 +0200

    IPVS: make FTP work with full NAT support
   =20
    Use nf_conntrack/nf_nat code to do the packet mangling and the TCP
    sequence adjusting.  The function 'ip_vs_skb_replace' is now dead
    code, so it is removed.
   =20
    To SNAT FTP, use something like:
   =20
    % iptables -t nat -A POSTROUTING -m ipvs --vaddr 192.168.100.30/32 =
\
        --vport 21 -j SNAT --to-source 192.168.10.10
    and for the data connections in passive mode:
   =20
    % iptables -t nat -A POSTROUTING -m ipvs --vaddr 192.168.100.30/32 =
\
        --vportctl 21 -j SNAT --to-source 192.168.10.10
    using '-m state --state RELATED' would also works.
   =20
    Make sure the kernel modules ip_vs_ftp, nf_conntrack_ftp, and
    nf_nat_ftp are loaded.
   =20
    [ up-port and minor fixes by Simon Horman <horms@verge.net.au> ]
    Signed-off-by: Hannes Eder <heder@google.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

commit 7b215ffc3885a38182d3d49ceb41d0a81c3e041a
Author: Hannes Eder <heder@google.com>
Date:   Fri Jul 23 12:46:32 2010 +0200

    IPVS: make friends with nf_conntrack
   =20
    Update the nf_conntrack tuple in reply direction, as we will see
    traffic from the real server (RIP) to the client (CIP).  Once this =
is
    done we can use netfilters SNAT in POSTROUTING, especially with
    xt_ipvs, to do source NAT, e.g.:
   =20
    % iptables -t nat -A POSTROUTING -m ipvs --vaddr 192.168.100.30/32 =
--vport 80 \
    		  -j SNAT --to-source 192.168.10.10
   =20
    [ minor fixes by Simon Horman <horms@verge.net.au> ]
    Signed-off-by: Hannes Eder <heder@google.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

commit 9c3e1c39679144c250dda95098333ecb5f1f407a
Author: Hannes Eder <heder@google.com>
Date:   Fri Jul 23 12:42:58 2010 +0200

    netfilter: xt_ipvs (netfilter matcher for IPVS)
   =20
    This implements the kernel-space side of the netfilter matcher xt_i=
pvs.
   =20
    [ minor fixes by Simon Horman <horms@verge.net.au> ]
    Signed-off-by: Hannes Eder <heder@google.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>
    [ Patrick: added xt_ipvs.h to Kbuild ]
    Signed-off-by: Patrick McHardy <kaber@trash.net>

commit 8a0acaac807ec3fcb7b5a895c6bbb8e8b61e6275
Author: Xiaoyu Du <tingsrain@gmail.com>
Date:   Fri Jul 9 17:27:47 2010 +0200

    ipvs: lvs sctp protocol handler is incorrectly invoked ip_vs_app_pk=
t_out
   =20
    lvs sctp protocol handler is incorrectly invoked ip_vs_app_pkt_out
    Since there's no sctp helpers at present, it does the same thing as
    ip_vs_app_pkt_in.
   =20
    Signed-off-by: Xiaoyu Du <tingsrain@gmail.com>
    Acked-by: Simon Horman <horms@verge.net.au>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

commit 72c7664f9278b31fcf6b7828c1417caca5b68104
Author: Michal Marek <mmarek@suse.cz>
Date:   Mon Jul 5 10:42:37 2010 +0200

    ipvs: Kconfig cleanup
   =20
    IP_VS_PROTO_AH_ESP should be set iff either of IP_VS_PROTO_{AH,ESP}=
 is
    selected. Express this with standard kconfig syntax.
   =20
    Signed-off-by: Michal Marek <mmarek@suse.cz>
    Acked-by: Simon Horman <horms@verge.net.au>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

commit 26ec037f9841e49cc5c615deb8e1e73e5beab2ca
Author: Nick Chalk <nick@loadbalancer.org>
Date:   Tue Jun 22 08:07:01 2010 +0200

    IPVS: one-packet scheduling
   =20
    Allow one-packet scheduling for UDP connections. When the fwmark-ba=
sed or
    normal virtual service is marked with '-o' or '--ops' options all
    connections are created only to schedule one packet. Useful to sche=
dule UDP
    packets from same client port to different real servers. Recommende=
d with
    RR or WRR schedulers (the connections are not visible with ipvsadm =
-L).
   =20
    Signed-off-by: Nick Chalk <nick@loadbalancer.org>
    Signed-off-by: Simon Horman <horms@verge.net.au>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

commit 421f91d21ad6f799dc7b489bb33cc560ccc56f98
Author: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
Date:   Fri Jun 11 12:17:00 2010 +0200

    fix typos concerning "initiali[zs]e"
   =20
    Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.d=
e>
    Signed-off-by: Jiri Kosina <jkosina@suse.cz>

commit d8d1f30b95a635dbd610dcc5eb641aca8f4768cf
Author: Changli Gao <xiaosuo@gmail.com>
Date:   Thu Jun 10 23:31:35 2010 -0700

    net-next: remove useless union keyword
   =20
    remove useless union keyword in rtable, rt6_info and dn_route.
   =20
    Since there is only one member in a union, the union keyword isn't =
useful.
   =20
    Signed-off-by: Changli Gao <xiaosuo@gmail.com>
    Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
