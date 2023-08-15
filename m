From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH RFC net-next 00/14] ipvs: per-net tables and optimizations
Date: Tue, 15 Aug 2023 20:30:17 +0300
Message-ID: <20230815173031.168344-1-ja@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <netdev+bounces-27740-gl-netdev-2=m.gmane-mx.org@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
	t=1692120736; bh=ciWA8brsNRv34nXH41CnmPTsBdnHMooPT+UbIQizqUc=;
	h=From:To:Cc:Subject:Date;
	b=aFGrbT1aJwmJkeRUkMlRtAQTBv3jOJGta1Yht2evC39kygSg9KO/dj5cRnGY1vPV8
	 13kUHJ8OVOsd85UPzs+xRr2beKZp1b7B/uyiWgFPRdEsv2lA5RF/6ZRNozZFRVTtAw
	 K9mNty254iafFK+6rrLxJsKW/hGdHRMFOD/j64jo=
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:netdev+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:netdev+unsubscribe@vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, "Paul E . McKenney" <paulmck@kernel.org>, rcu@vger.kernel.org, Dust Li <dust.li@linux.alibaba.com>, Jiejian Wu <jiejian@linux.alibaba.com>, Jiri Wiesner <jwiesner@suse.de>

	Hello,

	This patchset targets more netns isolation when IPVS
is used in large setups and also includes some optimizations.
This is a RFC submission to get wider review and comments.

	First patch adds useful wrappers to rculist_bl, the
hlist_bl methods IPVS will use in the following patches. The other
patches are IPVS-specific.

	The following patches will:

* Convert the global __ip_vs_mutex to per-net service_mutex and
  switch the service tables to be per-net, cowork by Jiejian Wu and
  Dust Li

* Convert some code that walks the service lists to use RCU instead of
  the service_mutex

* We used two tables for services (non-fwmark and fwmark), merge them
  into single svc_table

* The list for unavailable destinations (dest_trash) holds dsts and
  thus dev references causing extra work for the ip_vs_dst_event() dev
  notifier handler. Change this by dropping the reference when dest
  is removed and saved into dest_trash. The dest_trash will need more
  changes to make it light for lookups. TODO.

* On new connection we can do multiple lookups for services by tryng
  different fallback options. Add more counters for service types, so
  that we can avoid unneeded lookups for services.

* Add infrastructure for resizable hash tables based on hlist_bl
  which we will use for services and connections: hlists with
  per-bucket bit lock in the heads. The resizing delays RCU lookups
  on a bucket level with seqcounts which are protected with spin locks.

* Change the 256-bucket service hash table to be resizable in the
  range of 4..20 bits depending on the added services and use jhash
  hashing to reduce the collisions.

* Change the global connection table to be per-net and resizable
  in the range of 256..ip_vs_conn_tab_size. As the connections are
  hashed by using remote addresses and ports, use siphash instead
  of jhash for better security.

* As the connection table is not fixed size, show its current size
  to user space

* As the connection table is not global anymore, the no_cport and
  dropentry counters can be per-net

* Make the connection hashing more secure for setups with multiple
  services. Hashing only by remote address and port (client info)
  is not enough. To reduce the possible hash collisions add the
  used virtual address/port (local info) into the hash and as a side
  effect the MASQ connections will be double hashed into the
  hash table to match the traffic from real servers:
    OLD:
    - all methods: c_list node: proto, caddr:cport
    NEW:
    - all methods: hn0 node (dir 0): proto, caddr:cport -> vaddr:vport
    - MASQ method: hn1 node (dir 1): proto, daddr:dport -> caddr:cport

* Add /proc/net/ip_vs_status to show current state of IPVS, per-net

cat /proc/net/ip_vs_status
Conns:	9401
Conn buckets:	524288 (19 bits, lfactor 5)
Conn buckets empty:	505633 (96%)
Conn buckets len-1:	18322 (98%)
Conn buckets len-2:	329 (1%)
Conn buckets len-3:	3 (0%)
Conn buckets len-4:	1 (0%)
Services:	12
Service buckets:	128 (7 bits, lfactor 3)
Service buckets empty:	116 (90%)
Service buckets len-1:	12 (100%)
Stats thread slots:	1 (max 16)
Stats chain max len:	16
Stats thread ests:	38400

It shows the table size, the load factor, how many are the empty
buckets, with percents from the all buckets, the number of buckets
with length 1..7 where len-7 catches all len>=7 (zero values are
not shown). The len-N percents ignore the empty buckets, so they
are relative among all len-N buckets. It shows that large lfactor
is needed to achieve len-1 buckets to be ~98%. Only real tests can
show if relying on len-1 buckets is a better option because the
hash table becomes too large with multiple connections. And as
every table uses random key, the services may not avoid collision
in all cases.

* add conn_lfactor and svc_lfactor sysctl vars, so that one can tune
  the connection/service hash table sizing

Jiejian Wu (1):
  ipvs: make ip_vs_svc_table and ip_vs_svc_fwm_table per netns

Julian Anastasov (13):
  rculist_bl: add hlist_bl_for_each_entry_continue_rcu
  ipvs: some service readers can use RCU
  ipvs: use single svc table
  ipvs: do not keep dest_dst after dest is removed
  ipvs: use more counters to avoid service lookups
  ipvs: add resizable hash tables
  ipvs: use resizable hash table for services
  ipvs: switch to per-net connection table
  ipvs: show the current conn_tab size to users
  ipvs: no_cport and dropentry counters can be per-net
  ipvs: use more keys for connection hashing
  ipvs: add ip_vs_status info
  ipvs: add conn_lfactor and svc_lfactor sysctl vars

 Documentation/networking/ipvs-sysctl.rst |   31 +
 include/linux/rculist_bl.h               |   17 +
 include/net/ip_vs.h                      |  395 ++++++-
 net/netfilter/ipvs/ip_vs_conn.c          | 1079 ++++++++++++++-----
 net/netfilter/ipvs/ip_vs_core.c          |  171 ++-
 net/netfilter/ipvs/ip_vs_ctl.c           | 1233 ++++++++++++++++------
 net/netfilter/ipvs/ip_vs_est.c           |   18 +-
 net/netfilter/ipvs/ip_vs_pe_sip.c        |    4 +-
 net/netfilter/ipvs/ip_vs_xmit.c          |   39 +-
 9 files changed, 2304 insertions(+), 683 deletions(-)

-- 
2.41.0



