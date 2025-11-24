Received: from mail.netfilter.org (mail.netfilter.org [217.70.190.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 214512EAB71;
	Mon, 24 Nov 2025 21:46:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.190.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1764020817; cv=none; b=B+Z76JKFNsH5KTBf4t2Ot3yk5eekRD/tJAK1t1ofHAGO7cyr6jw9mIz7nsPktcjLj0xf3a+rVsE+KSzcHuuNOXXFVj4IiAvsd09HgS6ZqWR4mLSZU8xLa13bR4bEKICVexQfWXqrM8Telh8Uy2KmVpNxF6Gwsu/5rjS3A6s5FNU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1764020817; c=relaxed/simple;
	bh=oVQAuOeiQ/Zk+IClaAt2RiMTiY1BoVKgLQZJhrGFu3M=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=IlZBfxlIbbT6sqGtrhvw3up7/DpJpHfecz4uXLLCNs5iMFYf4IfcWPRtQToWxspDwq9rVH8+9kfmSpYJXsHE/qMSDun6X8bJYxFOrzidDsTyHyT8pg7vYRP0S2B584QB0Gph5AOAoa6fGgqE3TQkX7NFG3Owy2D9xs1YyeJzoOE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org; spf=pass smtp.mailfrom=netfilter.org; dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b=end0qxEQ; arc=none smtp.client-ip=217.70.190.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netfilter.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b="end0qxEQ"
Received: from netfilter.org (mail-agni [217.70.190.124])
	by mail.netfilter.org (Postfix) with ESMTPSA id 502EA602B8;
	Mon, 24 Nov 2025 22:46:52 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netfilter.org;
	s=2025; t=1764020812;
	bh=gzcByO0VE7hJf+pitzU6Ynj5uN40d+2muUCWvNpTVYk=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=end0qxEQPN1oohSB/vhD68KD/Ml8Ocij7aON2sAfEG8BVqW6Wmz0nVFC6LD5saOQ9
	 Vj+cceuP/5K7eYfyEY+XtRCgaTlF/CjH1tDo9jG9Gs5mxdiu/Db0PdUBamefnzhg0W
	 Q2C/StDLkfKOaJ6tIlIIhUz8OLWyNs85Ar043NqKPS79kuT2oJMGASeF3ZBsv90ygF
	 gFfT5IpDQZNbB75yz6YfzZLJG3LAYn5fuz96/Nw/NLcl+Fr9uRcJxD8zgbCHSXPH3A
	 YBJbSuzXTgKwl5w0/hxRQ3isOUQhXWMUmaahKiMYeMwWnDHjeugxaZJjeV89D/tAGr
	 UtKEeNAWhOn2A==
Date: Mon, 24 Nov 2025 22:46:49 +0100
From: Pablo Neira Ayuso <pablo@netfilter.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Dust Li <dust.li@linux.alibaba.com>,
	Jiejian Wu <jiejian@linux.alibaba.com>, rcu@vger.kernel.org
Subject: Re: [PATCHv6 net-next 00/14] ipvs: per-net tables and optimizations
Message-ID: <aSTSSTFT9j5eldzv@calendula>
References: <20251019155711.67609-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20251019155711.67609-1-ja@ssi.bg>

Hi Julian,

This is v6 and you have work hard on this, and I am coming late to
review... but may I suggest to split this series?

From my understanding, here I can see initial preparation patches,
including improvements, that could be applied initially before the
per-netns support.

Then, follow up with initial basic per-netns conversion.

Finally, pursue more advanced datastructures / optimizations.

If this is too extreme/deal breaker, let me know.

Thanks a lot for your work on IPVS.

On Sun, Oct 19, 2025 at 06:56:57PM +0300, Julian Anastasov wrote:
> 	Hello,
> 
> 	This patchset targets more netns isolation when IPVS
> is used in large setups and also includes some optimizations.
> 
> 	First patch adds useful wrappers to rculist_bl, the
> hlist_bl methods IPVS will use in the following patches. The other
> patches are IPVS-specific.
> 
> 	The following patches will:
> 
> * Convert the global __ip_vs_mutex to per-net service_mutex and
>   switch the service tables to be per-net, cowork by Jiejian Wu and
>   Dust Li
> 
> * Convert some code that walks the service lists to use RCU instead of
>   the service_mutex
> 
> * We used two tables for services (non-fwmark and fwmark), merge them
>   into single svc_table
> 
> * The list for unavailable destinations (dest_trash) holds dsts and
>   thus dev references causing extra work for the ip_vs_dst_event() dev
>   notifier handler. Change this by dropping the reference when dest
>   is removed and saved into dest_trash. The dest_trash will need more
>   changes to make it light for lookups. TODO.
> 
> * On new connection we can do multiple lookups for services by tryng
>   different fallback options. Add more counters for service types, so
>   that we can avoid unneeded lookups for services.
> 
> * Add infrastructure for resizable hash tables based on hlist_bl
>   which we will use for services and connections: hlists with
>   per-bucket bit lock in the heads. The resizing delays RCU lookups
>   on a bucket level with seqcounts which are protected with spin locks.
>   The entries keep the table ID and the hash value which allows to
>   filter the entries without touching many cache lines and to
>   unlink the entries without lookup by keys.
> 
> * Change the 256-bucket service hash table to be resizable in the
>   range of 4..20 bits depending on the added services and use jhash
>   hashing to reduce the collisions.
> 
> * Change the global connection table to be per-net and resizable
>   in the range of 256..ip_vs_conn_tab_size. As the connections are
>   hashed by using remote addresses and ports, use siphash instead
>   of jhash for better security.
> 
> * As the connection table is not with fixed size, show its current
>   size to user space
> 
> * As the connection table is not global anymore, the no_cport and
>   dropentry counters can be per-net
> 
> * Make the connection hashing more secure for setups with multiple
>   services. Hashing only by remote address and port (client info)
>   is not enough. To reduce the possible hash collisions add the
>   used virtual address/port (local info) into the hash and as a side
>   effect the MASQ connections will be double hashed into the
>   hash table to match the traffic from real servers:
>     OLD:
>     - all methods: c_list node: proto, caddr:cport
>     NEW:
>     - all methods: hn0 node (dir 0): proto, caddr:cport -> vaddr:vport
>     - MASQ method: hn1 node (dir 1): proto, daddr:dport -> caddr:cport
> 
> * Add /proc/net/ip_vs_status to show current state of IPVS, per-net
> 
> cat /proc/net/ip_vs_status
> Conns:	9401
> Conn buckets:	524288 (19 bits, lfactor -5)
> Conn buckets empty:	505633 (96%)
> Conn buckets len-1:	18322 (98%)
> Conn buckets len-2:	329 (1%)
> Conn buckets len-3:	3 (0%)
> Conn buckets len-4:	1 (0%)
> Services:	12
> Service buckets:	128 (7 bits, lfactor -3)
> Service buckets empty:	116 (90%)
> Service buckets len-1:	12 (100%)
> Stats thread slots:	1 (max 16)
> Stats chain max len:	16
> Stats thread ests:	38400
> 
> It shows the table size, the load factor (2^n), how many are the empty
> buckets, with percents from the all buckets, the number of buckets
> with length 1..7 where len-7 catches all len>=7 (zero values are
> not shown). The len-N percents ignore the empty buckets, so they
> are relative among all len-N buckets. It shows that smaller lfactor
> is needed to achieve len-1 buckets to be ~98%. Only real tests can
> show if relying on len-1 buckets is a better option because the
> hash table becomes too large with multiple connections. And as
> every table uses random key, the services may not avoid collision
> in all cases.
> 
> * add conn_lfactor and svc_lfactor sysctl vars, so that one can tune
>   the connection/service hash table sizing
> 
> Links to downloadable patchset versions:
> v6 (19 Oct 2025):
> https://ja.ssi.bg/tmp/rht_v6.tgz
> 
> v5 (16 Sep 2024):
> https://ja.ssi.bg/tmp/rht_v5.tgz
> 
> v4 (28 May 2024):
> https://ja.ssi.bg/tmp/rht_v4.tgz
> 
> v3 (31 Mar 2024):
> https://ja.ssi.bg/tmp/rht_v3.tgz
> 
> v2 (12 Dec 2023):
> https://ja.ssi.bg/tmp/rht_v2.tgz
> 
> v1 (15 Aug 2023):
> https://ja.ssi.bg/tmp/rht_v1.tgz
> 
> Changes in v6:
> Patch 5:
> * resync
> Patch 8:
> * resync: use READ_ONCE for ipvs->enable
> * resync: use %zu for size_t
> Patch 9:
> * resync: use the new skip_elems value
> * resync: use READ_ONCE for ipvs->enable
> Patch 12:
> * resync: use the new skip_elems value
> 
> Changes in v5:
> Patch 6:
> * resync with changes in main tree (6.11)
> Patch 8:
> * resync with changes in main tree (6.11)
> Patch 9:
> * resync with changes in main tree (6.11)
> Patch 14:
> * resync with changes in main tree (6.11)
> 
> Changes in v4:
> Patch 14:
> * the load factor parameters will be read-only for unprivileged
>   namespaces while we do not account the allocated memory
> Patch 5:
> * resync with changes in main tree
> 
> Changes in v3:
> Patch 7:
> * change the sign of the load factor parameter, so that
>   2^lfactor = load/size
> Patch 8:
> * change the sign of the load factor parameter
> * fix 'goto unlock_sem' in svc_resize_work_handler() after the last
>   mutex_trylock() call, should be goto unlock_m
> * now cond_resched_rcu() needs to include linux/rcupdate_wait.h
> Patch 9:
> * consider that the sign of the load factor parameter is changed
> Patch 12:
> * consider that the sign of the load factor parameter is changed
> Patch 14:
> * change the sign of the load factor parameters in docs
> 
> Changes in v2:
> Patch 1:
> * add comments to hlist_bl_for_each_entry_continue_rcu and fix
>   sparse warnings
> Patch 9:
> * Simon Kirby reports that backup server crashes if conn_tab is not
>   created. Create it just to sync conns before any services are added.
> Patch 11:
> * kernel test robot reported for dropentry_counters problem when
>   compiling with !CONFIG_SYSCTL, so it is time to wrap todrop_entry,
>   ip_vs_conn_ops_mode and ip_vs_random_dropentry under CONFIG_SYSCTL
> Patch 13:
> * remove extra old_gen assignment at start of ip_vs_status_show()
> 
> Jiejian Wu (1):
>   ipvs: make ip_vs_svc_table and ip_vs_svc_fwm_table per netns
> 
> Julian Anastasov (13):
>   rculist_bl: add hlist_bl_for_each_entry_continue_rcu
>   ipvs: some service readers can use RCU
>   ipvs: use single svc table
>   ipvs: do not keep dest_dst after dest is removed
>   ipvs: use more counters to avoid service lookups
>   ipvs: add resizable hash tables
>   ipvs: use resizable hash table for services
>   ipvs: switch to per-net connection table
>   ipvs: show the current conn_tab size to users
>   ipvs: no_cport and dropentry counters can be per-net
>   ipvs: use more keys for connection hashing
>   ipvs: add ip_vs_status info
>   ipvs: add conn_lfactor and svc_lfactor sysctl vars
> 
>  Documentation/networking/ipvs-sysctl.rst |   33 +
>  include/linux/rculist_bl.h               |   49 +-
>  include/net/ip_vs.h                      |  395 ++++++-
>  net/netfilter/ipvs/ip_vs_conn.c          | 1052 +++++++++++++-----
>  net/netfilter/ipvs/ip_vs_core.c          |  177 +++-
>  net/netfilter/ipvs/ip_vs_ctl.c           | 1232 ++++++++++++++++------
>  net/netfilter/ipvs/ip_vs_est.c           |   18 +-
>  net/netfilter/ipvs/ip_vs_pe_sip.c        |    4 +-
>  net/netfilter/ipvs/ip_vs_sync.c          |   23 +
>  net/netfilter/ipvs/ip_vs_xmit.c          |   39 +-
>  10 files changed, 2340 insertions(+), 682 deletions(-)
> 
> -- 
> 2.51.0
> 
> 
> 
