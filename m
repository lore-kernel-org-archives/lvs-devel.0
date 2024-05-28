Received: from mg.ssi.bg (mg.ssi.bg [193.238.174.37])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 65B3E74424;
	Tue, 28 May 2024 08:03:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.37
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1716883387; cv=none; b=r0XPvW2zJMYnQ9Q6vpIp/pkbXrmY0N7m3REbXxQyICxM8KHUkVobzVmESNFBqB8e684tzOD+vAn4a51h6ZHVwNxCwqSdxhp7gaXEKQkUxgtFvZex5+4MkOJGkk1I49vRWK7sW3/Es9spaoixnRyqiWD2uyUTffh7yVzxIxfKkB4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1716883387; c=relaxed/simple;
	bh=A94f+PqoCPa3oRSc8RRJdAVA8f/YNkLb3mhcS1IwVI4=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=eoz3CS9tAP87LlvM40WA9R3K7INdq0nqe00Jdc2czY84RodqieT79v5v6ApHQGm+CulXakDb32q2ChPXrUKT8Zannd+1Wz33GNggj84FhB8JHrWfZbR/A55fSqrKuYSpvfGdsigo2vM9Mtiy6z19ehzfgh7nUv0y/SSGq7rd464=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=ByQnVQPf; arc=none smtp.client-ip=193.238.174.37
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="ByQnVQPf"
Received: from mg.ssi.bg (localhost [127.0.0.1])
	by mg.ssi.bg (Proxmox) with ESMTP id 38D868625;
	Tue, 28 May 2024 11:02:58 +0300 (EEST)
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mg.ssi.bg (Proxmox) with ESMTPS;
	Tue, 28 May 2024 11:02:54 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id 576BE9003B8;
	Tue, 28 May 2024 11:02:53 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
	t=1716883374; bh=A94f+PqoCPa3oRSc8RRJdAVA8f/YNkLb3mhcS1IwVI4=;
	h=From:To:Cc:Subject:Date;
	b=ByQnVQPfjRNPg6eIe5ZKUwq26tF0vJhoPFRP4KCjorl5eRuHsEpGp8VlLEk2E0WCq
	 YS1wwPNANt1hM97I0bJvoqjqUXjRrJOOy4sqr5jLAXyj5jB0NmCUHPqik62dZ1B4Yi
	 2u/hU+PLFwxrXSHe9iq8NBWflJkCRFIJFNpM0Wl4=
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.17.1) with ESMTP id 44S82rTf010178;
	Tue, 28 May 2024 11:02:53 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 44S82prl010176;
	Tue, 28 May 2024 11:02:51 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>, rcu@vger.kernel.org
Subject: [PATCHv4 net-next 00/14] ipvs: per-net tables and optimizations
Date: Tue, 28 May 2024 11:02:20 +0300
Message-ID: <20240528080234.10148-1-ja@ssi.bg>
X-Mailer: git-send-email 2.45.1
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

	Hello,

	This patchset targets more netns isolation when IPVS
is used in large setups and also includes some optimizations.

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
  The entries keep the table ID and the hash value which allows to
  filter the entries without touching many cache lines and to
  unlink the entries without lookup by keys.

* Change the 256-bucket service hash table to be resizable in the
  range of 4..20 bits depending on the added services and use jhash
  hashing to reduce the collisions.

* Change the global connection table to be per-net and resizable
  in the range of 256..ip_vs_conn_tab_size. As the connections are
  hashed by using remote addresses and ports, use siphash instead
  of jhash for better security.

* As the connection table is not with fixed size, show its current
  size to user space

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
Conn buckets:	524288 (19 bits, lfactor -5)
Conn buckets empty:	505633 (96%)
Conn buckets len-1:	18322 (98%)
Conn buckets len-2:	329 (1%)
Conn buckets len-3:	3 (0%)
Conn buckets len-4:	1 (0%)
Services:	12
Service buckets:	128 (7 bits, lfactor -3)
Service buckets empty:	116 (90%)
Service buckets len-1:	12 (100%)
Stats thread slots:	1 (max 16)
Stats chain max len:	16
Stats thread ests:	38400

It shows the table size, the load factor (2^n), how many are the empty
buckets, with percents from the all buckets, the number of buckets
with length 1..7 where len-7 catches all len>=7 (zero values are
not shown). The len-N percents ignore the empty buckets, so they
are relative among all len-N buckets. It shows that smaller lfactor
is needed to achieve len-1 buckets to be ~98%. Only real tests can
show if relying on len-1 buckets is a better option because the
hash table becomes too large with multiple connections. And as
every table uses random key, the services may not avoid collision
in all cases.

* add conn_lfactor and svc_lfactor sysctl vars, so that one can tune
  the connection/service hash table sizing

Changes in v4:
Patch 14:
* the load factor parameters will be read-only for unprivileged
  namespaces while we do not account the allocated memory
Patch 5:
* resync with changes in main tree

Changes in v3:
Patch 7:
* change the sign of the load factor parameter, so that
  2^lfactor = load/size
Patch 8:
* change the sign of the load factor parameter
* fix 'goto unlock_sem' in svc_resize_work_handler() after the last
  mutex_trylock() call, should be goto unlock_m
* now cond_resched_rcu() needs to include linux/rcupdate_wait.h
Patch 9:
* consider that the sign of the load factor parameter is changed
Patch 12:
* consider that the sign of the load factor parameter is changed
Patch 14:
* change the sign of the load factor parameters in docs

Changes in v2:
Patch 1:
* add comments to hlist_bl_for_each_entry_continue_rcu and fix
  sparse warnings
Patch 9:
* Simon Kirby reports that backup server crashes if conn_tab is not
  created. Create it just to sync conns before any services are added.
Patch 11:
* kernel test robot reported for dropentry_counters problem when
  compiling with !CONFIG_SYSCTL, so it is time to wrap todrop_entry,
  ip_vs_conn_ops_mode and ip_vs_random_dropentry under CONFIG_SYSCTL
Patch 13:
* remove extra old_gen assignment at start of ip_vs_status_show()

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

 Documentation/networking/ipvs-sysctl.rst |   33 +
 include/linux/rculist_bl.h               |   49 +-
 include/net/ip_vs.h                      |  395 ++++++-
 net/netfilter/ipvs/ip_vs_conn.c          | 1074 ++++++++++++++-----
 net/netfilter/ipvs/ip_vs_core.c          |  177 +++-
 net/netfilter/ipvs/ip_vs_ctl.c           | 1236 ++++++++++++++++------
 net/netfilter/ipvs/ip_vs_est.c           |   18 +-
 net/netfilter/ipvs/ip_vs_pe_sip.c        |    4 +-
 net/netfilter/ipvs/ip_vs_sync.c          |   23 +
 net/netfilter/ipvs/ip_vs_xmit.c          |   39 +-
 10 files changed, 2355 insertions(+), 693 deletions(-)

-- 
2.44.0


