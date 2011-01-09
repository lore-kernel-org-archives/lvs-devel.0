From: Simon Horman <horms@verge.net.au>
Subject: LVS changes in Linux 2.6.37
Date: Sun, 9 Jan 2011 09:29:02 +0900
Message-ID: <20110109002902.GA28535@verge.net.au>
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

In 2.6.37 (released on the 5th January 2011):
  - Full NAT improvements
  - SIP persistence engine

Scheduled for inclusion in 2.6.38-rc1
  - New connection synchronisation protocol
    + IPv6 synchronisation
    + fwmark synchronisation
    + Timeout synchronisation
    + Psersistence engine data synchronisation
  - Net namespace support

----------------------------------------------------------------------

The following commands were used to generate data for this report.
The output indicates IPVS (LVS) changes between 2.6.36 and 2.6.37:

$ git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6
$ cd linux-2.6
$ git log --grep=IPVS v2.6.36..v2.6.37

commit b0aeef30433ea6854e985c2e9842fa19f51b95cc
Author: Julian Anastasov <ja@ssi.bg>
Date:   Mon Oct 11 11:23:07 2010 +0300

    nf_nat: restrict ICMP translation for embedded header
    
     	Skip ICMP translation of embedded protocol header
    if NAT bits are not set. Needed for IPVS to see the original
    embedded addresses because for IPVS traffic the IPS_SRC_NAT_BIT
    and IPS_DST_NAT_BIT bits are not set. It happens when IPVS performs
    DNAT for client packets after using nf_conntrack_alter_reply
    to expect replies from real server.
    
    Signed-off-by: Julian Anastasov <ja@ssi.bg>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit 0d79641a96d612aaa6d57a4d4f521d7ed9c9ccdd
Author: Julian Anastasov <ja@ssi.bg>
Date:   Sun Oct 17 16:46:17 2010 +0300

    ipvs: provide address family for debugging
    
     	As skb->protocol is not valid in LOCAL_OUT add
    parameter for address family in packet debugging functions.
    Even if ports are not present in AH and ESP change them to
    use ip_vs_tcpudp_debug_packet to show at least valid addresses
    as before. This patch removes the last user of skb->protocol
    in IPVS.
    
    Signed-off-by: Julian Anastasov <ja@ssi.bg>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit f5a41847acc535e2e2018e397b1876ba7577d9d9
Author: Julian Anastasov <ja@ssi.bg>
Date:   Sun Oct 17 16:35:46 2010 +0300

    ipvs: move ip_route_me_harder for ICMP
    
     	Currently, ip_route_me_harder after ip_vs_out_icmp
    is called even if packet is not related to IPVS connection.
    Move it into handle_response_icmp. Also, force rerouting
    if sending to local client because IPv4 stack uses addresses
    from the route.
    
    Signed-off-by: Julian Anastasov <ja@ssi.bg>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit 5bc9068e9d962ca6b8bec3f0eb6f60ab4dee1d04
Author: Julian Anastasov <ja@ssi.bg>
Date:   Sun Oct 17 16:14:31 2010 +0300

    ipvs: fix CHECKSUM_PARTIAL for TCP, UDP
    
     	Fix CHECKSUM_PARTIAL handling. Tested for IPv4 TCP,
    UDP not tested because it needs network card with HW CSUM support.
    May be fixes problem where IPVS can not be used in virtual boxes.
    Problem appears with DNAT to local address when the local stack
    sends reply in CHECKSUM_PARTIAL mode.
    
     	Fix tcp_dnat_handler and udp_dnat_handler to provide
    vaddr and daddr in right order (old and new IP) when calling
    tcp_partial_csum_update/udp_partial_csum_update (CHECKSUM_PARTIAL).
    
    Signed-off-by: Julian Anastasov <ja@ssi.bg>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit a91fd267e327ca7599654b4e9ed7b62c5adaccee
Author: Simon Horman <horms@verge.net.au>
Date:   Wed Oct 13 21:22:35 2010 +0200

    IPVS: ip_vs_dbg_callid() is only needed for debugging
    
    ip_vs_dbg_callid() and IP_VS_DEBUG_CALLID() are only needed
    it CONFIG_IP_VS_DEBUG is defined.
    
    This resolves the following build warning when CONFIG_IP_VS_DEBUG is
    not defined.
    
    net/netfilter/ipvs/ip_vs_pe_sip.c:11: warning: 'ip_vs_dbg_callid' defined but not used
    
    Reported-by: Patrick McHardy <kaber@trash.net>
    Signed-off-by: Simon Horman <horms@verge.net.au>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

commit 758ff03387228824617cef9507e5682488bf9e0c
Author: Simon Horman <horms@verge.net.au>
Date:   Sun Aug 22 21:37:55 2010 +0900

    IPVS: sip persistence engine
    
    Add the SIP callid as a key for persistence.
    
    This allows multiple connections from the same IP address to be
    differentiated on the basis of the callid.
    
    When used in conjunction with the persistence mask, it allows connections
    from different  IP addresses to be aggregated on the basis of the callid.
    
    It is envisaged that a persistence mask of 0.0.0.0 will be a useful
    setting.  That is, ignore the source IP address when checking for
    persistence.
    
    It is envisaged that this option will be used in conjunction with
    one-packet scheduling.
    
    This only works with UDP and cannot be made to work with TCP
    within the current framework.
    
    Signed-off-by: Simon Horman <horms@verge.net.au>
    Acked-by: Julian Anastasov <ja@ssi.bg>

commit f71499aa11f884255b69ce6c3b3c398c821591a1
Author: Simon Horman <horms@verge.net.au>
Date:   Sun Aug 22 21:37:54 2010 +0900

    IPVS: Fallback if persistence engine fails
    
    Fall back to normal persistence handling if the persistence
    engine fails to recognise a packet.
    
    This way, at least the packet will go somewhere.
    
    It is envisaged that iptables could be used to block packets
    such if this is not desired although nf_conntrack_sip would
    likely need to be enhanced first.
    
    Signed-off-by: Simon Horman <horms@verge.net.au>
    Acked-by: Julian Anastasov <ja@ssi.bg>

commit 0d1e71b04a04b6912e50926b9987c1e72facb1f3
Author: Simon Horman <horms@verge.net.au>
Date:   Sun Aug 22 21:37:54 2010 +0900

    IPVS: Allow configuration of persistence engines
    
    Allow the persistence engine of a virtual service to be set, edited
    and unset.
    
    This feature only works with the netlink user-space interface.
    
    Signed-off-by: Simon Horman <horms@verge.net.au>
    Acked-by: Julian Anastasov <ja@ssi.bg>

commit 8be67a6617b3403551fccb67b1c624c659419515
Author: Simon Horman <horms@verge.net.au>
Date:   Sun Aug 22 21:37:54 2010 +0900

    IPVS: management of persistence engine modules
    
    This is based heavily on the scheduler management code
    
    Signed-off-by: Simon Horman <horms@verge.net.au>
    Acked-by: Julian Anastasov <ja@ssi.bg>

commit a3c918acd29a96aba3b46bf50136e7953a480d17
Author: Simon Horman <horms@verge.net.au>
Date:   Sun Aug 22 21:37:53 2010 +0900

    IPVS: Add persistence engine data to /proc/net/ip_vs_conn
    
    This shouldn't break compatibility with userspace as the new data
    is at the end of the line.
    
    I have confirmed that this doesn't break ipvsadm, the main (only?)
    user-space user of this data.
    
    Signed-off-by: Simon Horman <horms@verge.net.au>
    Acked-by: Julian Anastasov <ja@ssi.bg>

commit 85999283a21ab2dd37427fdd8c8e8af57223977c
Author: Simon Horman <horms@verge.net.au>
Date:   Sun Aug 22 21:37:53 2010 +0900

    IPVS: Add struct ip_vs_pe
    
    Signed-off-by: Simon Horman <horms@verge.net.au>
    Acked-by: Julian Anastasov <ja@ssi.bg>

commit 2fabf35bfcd89445c54cf1e6a5437dd3cf924a92
Author: Simon Horman <horms@verge.net.au>
Date:   Sun Aug 22 21:37:52 2010 +0900

    IPVS: ip_vs_{un,}bind_scheduler NULL arguments
    
    In general NULL arguments aren't passed by the few callers that exist,
    so don't test for them.
    
    The exception is to make passing NULL to ip_vs_unbind_scheduler() a noop.
    
    Signed-off-by: Simon Horman <horms@verge.net.au>
    Acked-by: Julian Anastasov <ja@ssi.bg>

commit 6e08bfb879574524cc9a67be960c684989fd986c
Author: Simon Horman <horms@verge.net.au>
Date:   Sun Aug 22 21:37:52 2010 +0900

    IPVS: Allow null argument to ip_vs_scheduler_put()
    
    This simplifies caller logic sightly.
    
    Signed-off-by: Simon Horman <horms@verge.net.au>
    Acked-by: Julian Anastasov <ja@ssi.bg>

commit f11017ec2d1859c661f4e2b12c4a8d250e1f47cf
Author: Simon Horman <horms@verge.net.au>
Date:   Sun Aug 22 21:37:52 2010 +0900

    IPVS: Add struct ip_vs_conn_param
    
    Signed-off-by: Simon Horman <horms@verge.net.au>
    Acked-by: Julian Anastasov <ja@ssi.bg>

commit 5b57a98c1f0d78a4c238d83c4ac70de3bd237b2f
Author: Simon Horman <horms@verge.net.au>
Date:   Sun Aug 22 21:37:51 2010 +0900

    IPVS: compact ip_vs_sched_persist()
    
    Compact ip_vs_sched_persist() by setting up parameters
    and calling functions once.
    
    Signed-off-by: Simon Horman <horms@verge.net.au>
    Acked-by: Julian Anastasov <ja@ssi.bg>

commit f4bc17cdd205ebaa3807c2aa973719bb5ce6a5b2
Author: Julian Anastasov <ja@ssi.bg>
Date:   Tue Sep 21 17:35:41 2010 +0200

    ipvs: netfilter connection tracking changes
    
    	Add more code to IPVS to work with Netfilter connection
    tracking and fix some problems.
    
    - Allow IPVS to be compiled without connection tracking as in
    2.6.35 and before. This can avoid keeping conntracks for all
    IPVS connections because this costs memory. ip_vs_ftp still
    depends on connection tracking and NAT as implemented for 2.6.36.
    
    - Add sysctl var "conntrack" to enable connection tracking for
    all IPVS connections. For loaded IPVS directors it needs
    tuning of nf_conntrack_max limit.
    
    - Add IP_VS_CONN_F_NFCT connection flag to request the connection
    to use connection tracking. This allows user space to provide this
    flag, for example, in dest->conn_flags. This can be useful to
    request connection tracking per real server instead of forcing it
    for all connections with the "conntrack" sysctl. This flag is
    set currently only by ip_vs_ftp and of course by "conntrack" sysctl.
    
    - Add ip_vs_nfct.c file to hold all connection tracking code,
    by this way main code should not depend of netfilter conntrack
    support.
    
    - Return back the ip_vs_post_routing handler as in 2.6.35 and use
    skb->ipvs_property=1 to allow IPVS to work without connection
    tracking
    
    Connection tracking:
    
    - most of the code is already in 2.6.36-rc
    
    - alter conntrack reply tuple for LVS-NAT connections when first packet
    from client is forwarded and conntrack state is NEW or RELATED.
    Additionally, alter reply for RELATED connections from real server,
    again for packet in original direction.
    
    - add IP_VS_XMIT_TUNNEL to confirm conntrack (without altering
    reply) for LVS-TUN early because we want to call nf_reset. It is
    needed because we add IPIP header and the original conntrack
    should be preserved, not destroyed. The transmitted IPIP packets
    can reuse same conntrack, so we do not set skb->ipvs_property.
    
    - try to destroy conntrack when the IPVS connection is destroyed.
    It is not fatal if conntrack disappears before that, it depends
    on the used timers.
    
    Fix problems from long time:
    
    - add skb->ip_summed = CHECKSUM_NONE for the LVS-TUN transmitters
    
    Signed-off-by: Julian Anastasov <ja@ssi.bg>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

commit 2c70b5196262f29b10eb1886293e0c2d75dc3dd9
Author: Stephen Rothwell <sfr@canb.auug.org.au>
Date:   Sun Aug 29 17:04:53 2010 +0000

    IPVS: include net/ip6_checksum.h for csum_ipv6_magic
    
    Fixes this build error:
    
    net/netfilter/ipvs/ip_vs_core.c: In function 'ip_vs_nat_icmp_v6':
    net/netfilter/ipvs/ip_vs_core.c:640: error: implicit declaration of function 'csum_ipv6_magic'
    
    Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
    Signed-off-by: Simon Horman <horms@verge.net.au>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit 4f72816ef07fdf49338ee0e6764a3961d552994a
Author: Simon Horman <horms@verge.net.au>
Date:   Thu Aug 26 02:54:30 2010 +0000

    IPVS: convert __ip_vs_securetcp_lock to a spinlock
    
    Also rename __ip_vs_securetcp_lock to ip_vs_securetcp_lock.
    
    Spinlock conversion was suggested by Eric Dumazet.
    
    Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit bd144550489270a32a531e84a2b4bb6882096236
Author: Simon Horman <horms@verge.net.au>
Date:   Thu Aug 26 02:54:29 2010 +0000

    IPVS: convert __ip_vs_sched_lock to a spinlock
    
    Also rename __ip_vs_sched_lock to ip_vs_sched_lock.
    
    Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit 8870f8427b8fe30b2684b9e569e5ce038faf41ac
Author: Simon Horman <horms@verge.net.au>
Date:   Thu Aug 26 13:21:26 2010 -0700

    IPVS: ICMPv6 checksum calculation
    
    Cc: Xiaoyu Du <tingsrain@gmail.com>
    Signed-off-by: Julian Anastasov <ja@ssi.bg>
    Signed-off-by: Simon Horman <horms@verge.net.au>
    Signed-off-by: David S. Miller <davem@davemloft.net>

----------------------------------------------------------------------

The following commands were used to generate data for this report.
The output indicates IPVS (LVS) changes between 2.6.37 and the
HEAD of the current LVS development tree.

$ git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6
$ cd linux-2.6
$ git remote add lvs-test-2.6 git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git
$ git log --grep=IPVS v2.6.37..lvs-test-2.6/master

commit d49b19477be479e336c4b1299035710d7d85d8dd
Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date:   Mon Jan 3 14:45:03 2011 +0100

    IPVS: netns, final patch enabling network name space.
    
    all init_net removed, (except for some alloc related
    that needs to be there)
    
    Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit 224fc51affd17dbd1902f3eed52acce295385ebd
Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date:   Mon Jan 3 14:45:02 2011 +0100

    IPVS: netns, misc init_net removal in core.
    
    init_net removed in __ip_vs_addr_is_local_v6, and got net as param.
    
    Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit c8e8c0445b6c72bc8c4eefaf3d8ab4b1c2a4ca08
Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date:   Mon Jan 3 14:45:01 2011 +0100

    IPVS: netns, svc counters moved in ip_vs_ctl,c
    
    Last two global vars to be moved,
    ip_vs_ftpsvc_counter and ip_vs_nullsvc_counter.
    
    Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit cd5294c9c30bc90d21357d817db8c0804cd3fd1b
Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date:   Mon Jan 3 14:45:00 2011 +0100

    IPVS: netns, trash handling
    
    trash list per namspace,
    and reordering of some params in dst struct.
    
    Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit f853b3b0f206a749da12f1f0403f59f0c0308792
Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date:   Mon Jan 3 14:44:59 2011 +0100

    IPVS: netns, defense work timer.
    
    This patch makes defense work timer per name-space,
    A net ptr had to be added to the ipvs struct,
    since it's needed by defense_work_handler.
    
    Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit fcae9ecea72b193e990ad34e29f0fdbb165d46fc
Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date:   Mon Jan 3 14:44:58 2011 +0100

    IPVS: netns, ip_vs_ctl local vars moved to ipvs struct.
    
    Moving global vars to ipvs struct, except for svc table lock.
    Next patch for ctl will be drop-rate handling.
    
    *v3
    __ip_vs_mutex remains global
     ip_vs_conntrack_enabled(struct netns_ipvs *ipvs)
    
    Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit 4ad36644b3b58a96fd9dffe5121fc71554d18fc2
Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date:   Mon Jan 3 14:44:57 2011 +0100

    IPVS: netns, connection hash got net as param.
    
    Connection hash table is now name space aware.
    i.e. net ptr >> 8 is xor:ed to the hash,
    and this is the first param to be compared.
    The net struct is 0xa40 in size ( a little bit smaller for 32 bit arch:s)
    and cache-line aligned, so a ptr >> 5 might be a more clever solution ?
    
    All lookups where net is compared uses net_eq() which returns 1 when netns
    is disabled, and the compiler seems to do something clever in that case.
    
    ip_vs_conn_fill_param() have *net as first param now.
    
    Three new inlines added to keep conn struct smaller
    when names space is disabled.
    - ip_vs_conn_net()
    - ip_vs_conn_net_set()
    - ip_vs_conn_net_eq()
    
    *v3
      moved net compare to the end in "fast path"
    
    Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit 1e12db37ea84cbf7453451ddecd1be934eca4b54
Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date:   Mon Jan 3 14:44:56 2011 +0100

    IPVS: netns, ip_vs_stats and its procfs
    
    The statistic counter locks for every packet are now removed,
    and that statistic is now per CPU, i.e. no locks needed.
    However summing is made in ip_vs_est into ip_vs_stats struct
    which is moved to ipvs struc.
    
    procfs, ip_vs_stats now have a "per cpu" count and a grand total.
    A new function seq_file_single_net() in ip_vs.h created for handling of
    single_open_net() since it does not place net ptr in a struct, like others.
    
    /var/lib/lxc # cat /proc/net/ip_vs_stats_percpu
           Total Incoming Outgoing         Incoming         Outgoing
    CPU    Conns  Packets  Packets            Bytes            Bytes
      0        0        3        1               9D               34
      1        0        1        2               49               70
      2        0        1        2               34               76
      3        1        2        2               70               74
      ~        1        7        7              18A              18E
    
         Conns/s   Pkts/s   Pkts/s          Bytes/s          Bytes/s
               0        0        0                0                0
    
    *v3
    ip_vs_stats reamains as before, instead ip_vs_stats_percpu is added.
    u64 seq lock added
    
    *v4
    Bug correction inbytes and outbytes as own vars..
    per_cpu counter for all stats now as suggested by Julian.
    
    Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit d34e9f1b91560cdf649098da71f9ffe7867e6d27
Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date:   Mon Jan 3 14:44:55 2011 +0100

    IPVS: netns awareness to ip_vs_sync
    
    All global variables moved to struct ipvs,
    most external changes fixed (i.e. init_net removed)
    in sync_buf create  + 4 replaced by sizeof(struct..)
    
    Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit dcbccd026fd0a16f57bd1d513493f341e131435e
Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date:   Mon Jan 3 14:44:54 2011 +0100

    IPVS: netns awareness to ip_vs_est
    
    All variables moved to struct ipvs,
    most external changes fixed (i.e. init_net removed)
    
    *v3
     timer per ns instead of a common timer in estimator.
    
    Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit 0c4852e5036571644548d246997c126e1d6f8c05
Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date:   Mon Jan 3 14:44:53 2011 +0100

    IPVS: netns awareness to ip_vs_app
    
    All variables moved to struct ipvs,
    most external changes fixed (i.e. init_net removed)
    
    in ip_vs_protocol param struct net *net added to:
     - register_app()
     - unregister_app()
    This affected almost all proto_xxx.c files
    
    Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit 45fa1174b5c50e7975603ccd4757d7e7b43f2f5b
Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date:   Mon Jan 3 14:44:52 2011 +0100

    IPVS: netns, common protocol changes and use of appcnt.
    
    appcnt and timeout_table moved from struct ip_vs_protocol to
    ip_vs proto_data.
    
    struct net *net added as first param to
     - register_app()
     - unregister_app()
     - app_conn_bind()
     - ip_vs_conn_new()
    
    Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit 5e0300fa9d7775f0518ce984834da3320f0600b7
Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date:   Mon Jan 3 14:44:51 2011 +0100

    IPVS: netns, use ip_vs_proto_data as param.
    
    ip_vs_protocol *pp is replaced by ip_vs_proto_data *pd in
    function call in ip_vs_protocol struct i.e. :,
     - timeout_change()
     - state_transition()
    
    ip_vs_protocol_timeout_change() got ipvs as param, due to above
    and a upcoming patch - defence work
    
    Most of this changes are triggered by Julians comment:
    "tcp_timeout_change should work with the new struct ip_vs_proto_data
            so that tcp_state_table will go to pd->state_table
            and set_tcp_state will get pd instead of pp"
    
    *v3
    Mostly comments from Julian
    The pp -> pd conversion should start from functions like
    ip_vs_out() that use pp = ip_vs_proto_get(iph.protocol),
    now they should use ip_vs_proto_data_get(net, iph.protocol).
    conn_in_get() and conn_out_get() unused param *pp, removed.
    
    *v4
    ip_vs_protocol_timeout_change() walk the proto_data path.
    
    Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit 4f989e02be72cf596f9791fedb5fba172a5abcf3
Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date:   Mon Jan 3 14:44:50 2011 +0100

    IPVS: netns preparation for proto_ah_esp
    
    In this phase (one), all local vars will be moved to ipvs struct.
    
    Remaining work, add param struct net *net to a couple of
    functions that common for all protos.
    
    Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit d4b2560f264dcdc59b5c8a2612bfd9042b9ed5d9
Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date:   Mon Jan 3 14:44:49 2011 +0100

    IPVS: netns preparation for proto_sctp
    
    In this phase (one), all local vars will be moved to ipvs struct.
    
    Remaining work, add param struct net *net to a couple of
    functions that is common for all protos and use ip_vs_proto_data
    
    *v3
     Removed unuset function set_state_timeout()
    
    Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit d4b2a7147cbfb455512d66ed52f8c7655d55ff80
Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date:   Mon Jan 3 14:44:48 2011 +0100

    IPVS: netns preparation for proto_udp
    
    In this phase (one), all local vars will be moved to ipvs struct.
    
    Remaining work, add param struct net *net to a couple of
    functions that is common for all protos and use ip_vs_proto_data
    
    *v3
    Removed unused function set_state_timeout()
    
    Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit 2be1884a8749ac6cfa7ecdc10121e39af3d7956e
Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date:   Mon Jan 3 14:44:47 2011 +0100

    IPVS: netns preparation for proto_tcp
    
    In this phase (one), all local vars will be moved to ipvs struct.
    
    Remaining work, add param struct net *net to a couple of
    functions that is common for all protos and use all
    ip_vs_proto_data
    
    *v3
    Removed unused function as sugested by Simon
    
    Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit b33567fe5932346b0d1743034d9a19ac73b731a3
Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date:   Mon Jan 3 14:44:46 2011 +0100

    IPVS: netns, prepare protocol
    
    Add support for protocol data per name-space.
    in struct ip_vs_protocol, appcnt will be removed when all protos
    are modified for network name-space.
    
    This patch causes warnings of unused functions, they will be used
    when next patch will be applied.
    
    Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit a7f0a91d4f792ce6444d5e4cf69f5118841f4a8d
Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date:   Mon Jan 3 14:44:45 2011 +0100

    IPVS: netns awarness to lblc sheduler
    
    var sysctl_ip_vs_lblc_expiration moved to ipvs struct as
        sysctl_lblc_expiration
    
    procfs updated to handle this.
    
    Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit 65ce823463932543e615ea1b372e9eb7cb8d7307
Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date:   Mon Jan 3 14:44:44 2011 +0100

    IPVS: netns awarness to lblcr sheduler
    
    var sysctl_ip_vs_lblcr_expiration moved to ipvs struct as
        sysctl_lblcr_expiration
    
    procfs updated to handle this.
    
    Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit c8fd7a7fad1e86ff4189082744852cda9aced805
Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date:   Mon Jan 3 14:44:43 2011 +0100

    IPVS: netns to services part 1
    
    Services hash tables got netns ptr a hash arg,
    While Real Servers (rs) has been moved to ipvs struct.
    Two new inline functions added to get net ptr from skb.
    
    Since ip_vs is called from different contexts there is two
    places to dig for the net ptr skb->dev or skb->sk
    this is handled in skb_net() and skb_sknet()
    
    Global functions, ip_vs_service_get() ip_vs_lookup_real_service()
    etc have got  struct net *net as first param.
    If possible get net ptr skb etc,
     - if not &init_net is used at this early stage of patching.
    
    ip_vs_ctl.c  procfs not ready for netns yet.
    
    *v3
     Comments by Julian
    - __ip_vs_service_find and __ip_vs_svc_fwm_find are fast path,
      net_eq(svc->net, net) so the check is at the end now.
    - net = skb_net(skb) in ip_vs_out moved after check for skb_dst.
    
    Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit 089db4f34c5aef10784853e65eecad5e72d8d64a
Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date:   Mon Jan 3 14:44:42 2011 +0100

    IPVS: netns, add basic init per netns.
    
    Preparation for network name-space init, in this stage
    some empty functions exists.
    
    In most files there is a check if it is root ns i.e. init_net
    if (!net_eq(net, &init_net))
            return ...
    this will be removed by the last patch, when enabling name-space.
    
    *v3
     ip_vs_conn.c merge error corrected.
     net_ipvs #ifdef removed as sugested by Jan Engelhardt
    
    Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit b880c1f077000956b9f475d5f3b6c5e45ff2e342
Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date:   Fri Nov 19 14:25:14 2010 +0100

    IPVS: Backup, adding version 0 sending capabilities
    
    This patch adds a sysclt net.ipv4.vs.sync_version
    that can be used to send sync msg in version 0 or 1 format.
    
    sync_version value is logical,
         Value 1 (default) New version
               0 Plain old version
    
    Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
    Acked-by: Julian Anastasov <ja@ssi.bg>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit 986a075795339c5ea1122ce9290dfd5504252eb0
Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date:   Fri Nov 19 14:25:13 2010 +0100

    IPVS: Backup, Change sending to Version 1 format
    
    Enable sending and removal of version 0 sending
    Affected functions,
    
    ip_vs_sync_buff_create()
    ip_vs_sync_conn()
    
    ip_vs_core.c removal of IPv4 check.
    
    *v5
     Just check cp->pe_data_len in ip_vs_sync_conn
     Check if padding needed before adding a new sync_conn
     to the buffer, i.e. avoid sending padding at the end.
    
    *v4
     moved sanity check and pe_name_len after sloop.
     use cp->pe instead of cp->dest->svc->pe
     real length in each sync_conn, not padded length
     however total size of a sync_msg includes padding.
    
    *v3
     Sending ip_vs_sync_conn_options in network order.
     Sending Templates for ONE_PACKET conn.
     Renaming of ip_vs_sync_mesg to ip_vs_sync_mesg_v0
    
    Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
    Acked-by: Julian Anastasov <ja@ssi.bg>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit fe5e7a1efb664df0280f10377813d7099fb7eb0f
Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date:   Fri Nov 19 14:25:12 2010 +0100

    IPVS: Backup, Adding Version 1 receive capability
    
    Functionality improvements
     * flags  changed from 16 to 32 bits
     * fwmark added (32 bits)
     * timeout in sec. added (32 bits)
     * pe data added (Variable length)
     * IPv6 capabilities (3x16 bytes for addr.)
     * Version and type in every conn msg.
    
    ip_vs_process_message() now handles Version 1 messages
    and will call ip_vs_process_message_v0() for version 0 messages.
    
    ip_vs_proc_conn() is common for both version, and handles the update of
    connection hash.
    
    ip_vs_conn_fill_param_sync()    - Version 1 messages only
    ip_vs_conn_fill_param_sync_v0() - Version 0 messages only
    
    Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
    Acked-by: Julian Anastasov <ja@ssi.bg>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit 2981bc9a63456500037ca1f434b93a561e63f384
Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date:   Fri Nov 19 14:25:11 2010 +0100

    IPVS: Backup, Adding structs for new sync format
    
    New structs defined for version 1 of sync.
    
     * ip_vs_sync_v4       Ipv4 base format struct
     * ip_vs_sync_v6       Ipv6 base format struct
    
    Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
    Acked-by: Julian Anastasov <ja@ssi.bg>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit a5959d53d6048a56103ee0ade1eb6f2c0c733b1d
Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date:   Fri Nov 19 14:25:10 2010 +0100

    IPVS: Handle Scheduling errors.
    
    If ip_vs_conn_fill_param_persist return an error to ip_vs_sched_persist,
    this error must propagate as ignored=-1 to ip_vs_schedule().
    Errors from ip_vs_conn_new() in ip_vs_sched_persist() and ip_vs_schedule()
    should also return *ignored=-1;
    
    This patch just relies on the fact that ignored is 1 before calling
    ip_vs_sched_persist().
    
    Sent from Julian:
      "The new case when ip_vs_conn_fill_param_persist fails
       should set *ignored = -1, so that we can use NF_DROP,
       see below. *ignored = -1 should be also used for ip_vs_conn_new
       failure in ip_vs_sched_persist() and ip_vs_schedule().
       The new negative value should be handled in tcp,udp,sctp"
    
    "To summarize:
    
    - *ignored = 1:
          protocol tried to schedule (eg. on SYN), found svc but the
          svc/scheduler decides that this packet should be accepted with
          NF_ACCEPT because it must not be scheduled.
    
    - *ignored = 0:
          scheduler can not find destination, so try bypass or
          return ICMP and then NF_DROP (ip_vs_leave).
    
    - *ignored = -1:
          scheduler tried to schedule but fatal error occurred, eg.
          ip_vs_conn_new failure (ENOMEM) or ip_vs_sip_fill_param
          failure such as missing Call-ID, ENOMEM on skb_linearize
          or pe_data. In this case we should return NF_DROP without
          any attempts to send ICMP with ip_vs_leave."
    
    More or less all ideas and input to this patch is work from
    Julian Anastasov
    
    Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
    Acked-by: Julian Anastasov <ja@ssi.bg>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit 3716522653a79b724b02ee911f1b60c41932f847
Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date:   Fri Nov 19 14:25:09 2010 +0100

    IPVS: skb defrag in L7 helpers
    
    L7 helpers like sip needs skb defrag
    since L7 data can be fragmented.
    
    This patch requires "IPVS Break ports-2 into src_port and dst_port" patch
    
    Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
    Acked-by: Julian Anastasov <ja@ssi.bg>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit ce144f249f3f21a095a093d5d1ebd845177858da
Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date:   Fri Nov 19 14:25:08 2010 +0100

    IPVS: Split ports[2] into src_port and dst_port
    
    Avoid sending invalid pointer due to skb_linearize() call.
    This patch prepares for next patch where skb_linearize is a part.
    
    In ip_vs_sched_persist() params the ports ptr will be replaced by
    src and dst port.
    
    Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
    Acked-by: Julian Anastasov <ja@ssi.bg>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit 0e051e683ba4acb4e67c272c6a89707d974099d1
Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date:   Fri Nov 19 14:25:07 2010 +0100

    IPVS: Backup, Prepare for transferring firewall marks (fwmark) to the backup daemon.
    
    One struct will have fwmark added:
     * ip_vs_conn
    
    ip_vs_conn_new() and ip_vs_find_dest()
    will have an extra param - fwmark
    The effects of that, is in this patch.
    
    Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
    Acked-by: Julian Anastasov <ja@ssi.bg>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit 8aadf93c9c1ff1a53aafd18d038be0d709b5ebc0
Author: Simon Horman <horms@verge.net.au>
Date:   Tue Nov 9 09:33:28 2010 +0900

    IPVS: buffer argument to ip_vs_process_message() should not be const
    
    It is assigned to a non-const variable and its contents are modified.
    
    Acked-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit 7ae246a15a5c9d26cfb572d36794325db0400b18
Author: Simon Horman <horms@verge.net.au>
Date:   Tue Nov 9 09:33:25 2010 +0900

    IPVS: Remove useless { } block from ip_vs_process_message()
    
    Acked-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit d494262b8a0f3507b62104a565849124abe29827
Author: Simon Horman <horms@verge.net.au>
Date:   Tue Nov 9 09:33:15 2010 +0900

    IPVS: Make the cp argument to ip_vs_sync_conn() static
    
    Acked-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit ea2c73afc23db3084fd857b027446c38fc7ff2c9
Author: Simon Horman <horms@verge.net.au>
Date:   Mon Nov 8 20:06:30 2010 +0900

    IPVS: Only match pe_data created by the same pe
    
    Only match persistence engine data if it was
    created by the same persistence engine.
    
    Reported-by: Julian Anastasov <ja@ssi.bg>
    Signed-off-by: Simon Horman <horms@verge.net.au>

commit e9e5eee8733739f13a204132b502494b3f494f3b
Author: Simon Horman <horms@verge.net.au>
Date:   Mon Nov 8 20:05:57 2010 +0900

    IPVS: Add persistence engine to connection entry
    
    The dest of a connection may not exist if it has been created as the result
    of connection synchronisation. But in order for connection entries for
    templates with persistence engine data created through connection
    synchronisation to be valid access to the persistence engine pointer is
    required.  So add the persistence engine to the connection itself.
    
    Signed-off-by: Simon Horman <horms@verge.net.au>
