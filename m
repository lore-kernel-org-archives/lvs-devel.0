Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com [115.124.30.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 334B62475CB;
	Fri, 17 Oct 2025 02:55:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=115.124.30.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1760669712; cv=none; b=Cevltd6J4Nsf2d+O20llCeldZWZONjqfCkcy/1L/ve0wOU9zYcT5ShMJvriJ6tBn0R+GldL0ObHxvl5FUZRITjyLQIHrn6innOaHO1cOpt8OgttZCEO37mX3o/5oxL5gRXdHmWfqILIVW1xprsplzTxPeKsdklblE8Nbnd5iXf0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1760669712; c=relaxed/simple;
	bh=QURLEDWP5884j9LwuE4mMY1mqzv44aXKnTuQFUEQcnU=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=RcAT1JYkq6K/sp535Q85Z3ApoyPPIU7G3qElkconNVRn3+JQpw7Y9D8kRgCL+UjIQmWJ0JkTNh0XslZoBngwiswLoJ+GV2l5BgfxdA8vE9eiqZv+GRu9mTtGnYKzE0ToU5qUv82umBrH/5FTvtjl6v4J7KMazpkOF9yteDlZnKo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com; spf=pass smtp.mailfrom=linux.alibaba.com; dkim=pass (1024-bit key) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.b=j61sKLhP; arc=none smtp.client-ip=115.124.30.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.b="j61sKLhP"
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1760669699; h=Date:From:To:Subject:Message-ID:MIME-Version:Content-Type;
	bh=8pdmBWhYD/jIQ8KGcQVFijwS0E4PNiF8bDa51ql5obs=;
	b=j61sKLhPpCY0r+1kt0KC5m6WQ0OivCPEopMLcM61P8g7W+m2+eq9xeRoeFfa9hz7VAR+bVVXChBBHbDQRhrbJJq1nbk2PYCt487yqxAHJ3oFpcNOC5la44CU5or8zkktAC+K3I2PsOcHaKS7YIJQ3VycmVfol/AyyZG3qhIVUl4=
Received: from localhost(mailfrom:dust.li@linux.alibaba.com fp:SMTPD_---0WqNQjE5_1760669698 cluster:ay36)
          by smtp.aliyun-inc.com;
          Fri, 17 Oct 2025 10:54:59 +0800
Date: Fri, 17 Oct 2025 10:54:58 +0800
From: Dust Li <dust.li@linux.alibaba.com>
To: Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Jiejian Wu <jiejian@linux.alibaba.com>, rcu@vger.kernel.org
Subject: Re: [PATCHv4 net-next 00/14] ipvs: per-net tables and optimizations
Message-ID: <aPGwAl_XsR-D93Li@linux.alibaba.com>
Reply-To: dust.li@linux.alibaba.com
References: <20240528080234.10148-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20240528080234.10148-1-ja@ssi.bg>

On 2024-05-28 11:02:20, Julian Anastasov wrote:
>	Hello,
>
>	This patchset targets more netns isolation when IPVS
>is used in large setups and also includes some optimizations.


Hi Julian,

It looks like this patchset is ready to be upstreamed, but progress may
have stalled. Just checking, do you still intend to move forward with it?

Best regards,
Dust

>
>	First patch adds useful wrappers to rculist_bl, the
>hlist_bl methods IPVS will use in the following patches. The other
>patches are IPVS-specific.
>
>	The following patches will:
>
>* Convert the global __ip_vs_mutex to per-net service_mutex and
>  switch the service tables to be per-net, cowork by Jiejian Wu and
>  Dust Li
>
>* Convert some code that walks the service lists to use RCU instead of
>  the service_mutex
>
>* We used two tables for services (non-fwmark and fwmark), merge them
>  into single svc_table
>
>* The list for unavailable destinations (dest_trash) holds dsts and
>  thus dev references causing extra work for the ip_vs_dst_event() dev
>  notifier handler. Change this by dropping the reference when dest
>  is removed and saved into dest_trash. The dest_trash will need more
>  changes to make it light for lookups. TODO.
>
>* On new connection we can do multiple lookups for services by tryng
>  different fallback options. Add more counters for service types, so
>  that we can avoid unneeded lookups for services.
>
>* Add infrastructure for resizable hash tables based on hlist_bl
>  which we will use for services and connections: hlists with
>  per-bucket bit lock in the heads. The resizing delays RCU lookups
>  on a bucket level with seqcounts which are protected with spin locks.
>  The entries keep the table ID and the hash value which allows to
>  filter the entries without touching many cache lines and to
>  unlink the entries without lookup by keys.
>
>* Change the 256-bucket service hash table to be resizable in the
>  range of 4..20 bits depending on the added services and use jhash
>  hashing to reduce the collisions.
>
>* Change the global connection table to be per-net and resizable
>  in the range of 256..ip_vs_conn_tab_size. As the connections are
>  hashed by using remote addresses and ports, use siphash instead
>  of jhash for better security.
>
>* As the connection table is not with fixed size, show its current
>  size to user space
>
>* As the connection table is not global anymore, the no_cport and
>  dropentry counters can be per-net
>
>* Make the connection hashing more secure for setups with multiple
>  services. Hashing only by remote address and port (client info)
>  is not enough. To reduce the possible hash collisions add the
>  used virtual address/port (local info) into the hash and as a side
>  effect the MASQ connections will be double hashed into the
>  hash table to match the traffic from real servers:
>    OLD:
>    - all methods: c_list node: proto, caddr:cport
>    NEW:
>    - all methods: hn0 node (dir 0): proto, caddr:cport -> vaddr:vport
>    - MASQ method: hn1 node (dir 1): proto, daddr:dport -> caddr:cport
>
>* Add /proc/net/ip_vs_status to show current state of IPVS, per-net
>
>cat /proc/net/ip_vs_status
>Conns:	9401
>Conn buckets:	524288 (19 bits, lfactor -5)
>Conn buckets empty:	505633 (96%)
>Conn buckets len-1:	18322 (98%)
>Conn buckets len-2:	329 (1%)
>Conn buckets len-3:	3 (0%)
>Conn buckets len-4:	1 (0%)
>Services:	12
>Service buckets:	128 (7 bits, lfactor -3)
>Service buckets empty:	116 (90%)
>Service buckets len-1:	12 (100%)
>Stats thread slots:	1 (max 16)
>Stats chain max len:	16
>Stats thread ests:	38400
>
>It shows the table size, the load factor (2^n), how many are the empty
>buckets, with percents from the all buckets, the number of buckets
>with length 1..7 where len-7 catches all len>=7 (zero values are
>not shown). The len-N percents ignore the empty buckets, so they
>are relative among all len-N buckets. It shows that smaller lfactor
>is needed to achieve len-1 buckets to be ~98%. Only real tests can
>show if relying on len-1 buckets is a better option because the
>hash table becomes too large with multiple connections. And as
>every table uses random key, the services may not avoid collision
>in all cases.
>
>* add conn_lfactor and svc_lfactor sysctl vars, so that one can tune
>  the connection/service hash table sizing
>
>Changes in v4:
>Patch 14:
>* the load factor parameters will be read-only for unprivileged
>  namespaces while we do not account the allocated memory
>Patch 5:
>* resync with changes in main tree
>
>Changes in v3:
>Patch 7:
>* change the sign of the load factor parameter, so that
>  2^lfactor = load/size
>Patch 8:
>* change the sign of the load factor parameter
>* fix 'goto unlock_sem' in svc_resize_work_handler() after the last
>  mutex_trylock() call, should be goto unlock_m
>* now cond_resched_rcu() needs to include linux/rcupdate_wait.h
>Patch 9:
>* consider that the sign of the load factor parameter is changed
>Patch 12:
>* consider that the sign of the load factor parameter is changed
>Patch 14:
>* change the sign of the load factor parameters in docs
>
>Changes in v2:
>Patch 1:
>* add comments to hlist_bl_for_each_entry_continue_rcu and fix
>  sparse warnings
>Patch 9:
>* Simon Kirby reports that backup server crashes if conn_tab is not
>  created. Create it just to sync conns before any services are added.
>Patch 11:
>* kernel test robot reported for dropentry_counters problem when
>  compiling with !CONFIG_SYSCTL, so it is time to wrap todrop_entry,
>  ip_vs_conn_ops_mode and ip_vs_random_dropentry under CONFIG_SYSCTL
>Patch 13:
>* remove extra old_gen assignment at start of ip_vs_status_show()
>
>Jiejian Wu (1):
>  ipvs: make ip_vs_svc_table and ip_vs_svc_fwm_table per netns
>
>Julian Anastasov (13):
>  rculist_bl: add hlist_bl_for_each_entry_continue_rcu
>  ipvs: some service readers can use RCU
>  ipvs: use single svc table
>  ipvs: do not keep dest_dst after dest is removed
>  ipvs: use more counters to avoid service lookups
>  ipvs: add resizable hash tables
>  ipvs: use resizable hash table for services
>  ipvs: switch to per-net connection table
>  ipvs: show the current conn_tab size to users
>  ipvs: no_cport and dropentry counters can be per-net
>  ipvs: use more keys for connection hashing
>  ipvs: add ip_vs_status info
>  ipvs: add conn_lfactor and svc_lfactor sysctl vars
>
> Documentation/networking/ipvs-sysctl.rst |   33 +
> include/linux/rculist_bl.h               |   49 +-
> include/net/ip_vs.h                      |  395 ++++++-
> net/netfilter/ipvs/ip_vs_conn.c          | 1074 ++++++++++++++-----
> net/netfilter/ipvs/ip_vs_core.c          |  177 +++-
> net/netfilter/ipvs/ip_vs_ctl.c           | 1236 ++++++++++++++++------
> net/netfilter/ipvs/ip_vs_est.c           |   18 +-
> net/netfilter/ipvs/ip_vs_pe_sip.c        |    4 +-
> net/netfilter/ipvs/ip_vs_sync.c          |   23 +
> net/netfilter/ipvs/ip_vs_xmit.c          |   39 +-
> 10 files changed, 2355 insertions(+), 693 deletions(-)
>
>-- 
>2.44.0
>
