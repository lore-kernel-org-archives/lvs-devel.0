Received: from mgamail.intel.com (mgamail.intel.com [198.175.65.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BBCD61DB122;
	Sat,  8 Mar 2025 19:03:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.175.65.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1741460641; cv=none; b=ncflCNlrttDBnBXkqQVjWE4Ss+618qho37T2fRvx8q2kQfrEPEUn/Bi7ptwvD2X9cdQ00ihnb6YNAfeVW8Z9LjUwOb/OWupkUuj9kcrdWrmoJQZT7A8ulOcTNjGMSKm3tfE9zjXM8ZNxNaYhubiNqCatxMVksICPiHNA7li+nbA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1741460641; c=relaxed/simple;
	bh=+rxHqt446zRcVp/SCTQfHaohEqfDFE3SarBqTFs0xy0=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=LyTZwDF5Mtzstac5raDf89lSc1i96pIwkMSa/TJouw3Eo84DZtK8dU1WAdQO/hxwv+Kewr8ggizx/ps4c9HdZiuTYFVmGht1do80IzrLtinnul4T8Kji3garFWzZNj6W45Yy3PTXhCpZaigXNMCwCFtIou9zt7NKb6k7XbyDjnI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com; spf=pass smtp.mailfrom=intel.com; dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b=hY00UVYT; arc=none smtp.client-ip=198.175.65.18
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b="hY00UVYT"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1741460640; x=1772996640;
  h=date:from:to:cc:subject:message-id:references:
   mime-version:in-reply-to;
  bh=+rxHqt446zRcVp/SCTQfHaohEqfDFE3SarBqTFs0xy0=;
  b=hY00UVYTAO3BTX7uTiXxnvL+d2yrJhK2osKlaKQxtGotYc08az+5FYin
   HGZdwu0GvnWugXBxJjESYuP2dU4n1rgFtBhz31q6Gb2pdRRy+bJH5dm//
   tgBKtApi3NXDUDL7475w+Lc8Kqypztv3NCYi7ubIbqafbO3JIUC9zCN1O
   Wxr5zDH4ORK/ZdfOOGvjaQ4dzXOM2gzIz9tlHxGeEIXGLvuAFnjMx845i
   rrcVRH446zxvVUHkj+0polxk36azNAJcyH+BparwjXbxdP1/FUTCyKkHn
   LPW4reqqi5z5HBnh4oV+JwKPtSvkTzhlzg0Qonu29cId8nuam8JFk1m3/
   Q==;
X-CSE-ConnectionGUID: Cll8ojllRWup3CVeYar1bA==
X-CSE-MsgGUID: m+d7Qls7SOGmaIrtS3nx8g==
X-IronPort-AV: E=McAfee;i="6700,10204,11367"; a="42690740"
X-IronPort-AV: E=Sophos;i="6.14,232,1736841600"; 
   d="scan'208";a="42690740"
Received: from fmviesa010.fm.intel.com ([10.60.135.150])
  by orvoesa110.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 08 Mar 2025 11:03:59 -0800
X-CSE-ConnectionGUID: 1Cr9wz4dQZCCRWNT40jMKQ==
X-CSE-MsgGUID: E7ZWhpblThK2hTv2JJbWzw==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.14,232,1736841600"; 
   d="scan'208";a="120087334"
Received: from lkp-server02.sh.intel.com (HELO a4747d147074) ([10.239.97.151])
  by fmviesa010.fm.intel.com with ESMTP; 08 Mar 2025 11:03:55 -0800
Received: from kbuild by a4747d147074 with local (Exim 4.96)
	(envelope-from <lkp@intel.com>)
	id 1tqzSi-0002Dk-2a;
	Sat, 08 Mar 2025 19:03:52 +0000
Date: Sun, 9 Mar 2025 03:03:17 +0800
From: kernel test robot <lkp@intel.com>
To: Dan Carpenter <error27@gmail.com>,
	"Gustavo A. R. Silva" <gustavo@embeddedor.com>
Cc: llvm@lists.linux.dev, oe-kbuild-all@lists.linux.dev,
	Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@netfilter.org>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
	netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: Re: [PATCH net] ipvs: prevent integer overflow in do_ip_vs_get_ctl()
Message-ID: <202503090225.vNvZGEfz-lkp@intel.com>
References: <6dddcc45-78db-4659-80a2-3a2758f491a6@stanley.mountain>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6dddcc45-78db-4659-80a2-3a2758f491a6@stanley.mountain>

Hi Dan,

kernel test robot noticed the following build warnings:

[auto build test WARNING on net/main]

url:    https://github.com/intel-lab-lkp/linux/commits/Dan-Carpenter/ipvs-prevent-integer-overflow-in-do_ip_vs_get_ctl/20250307-214537
base:   net/main
patch link:    https://lore.kernel.org/r/6dddcc45-78db-4659-80a2-3a2758f491a6%40stanley.mountain
patch subject: [PATCH net] ipvs: prevent integer overflow in do_ip_vs_get_ctl()
config: hexagon-allyesconfig (https://download.01.org/0day-ci/archive/20250309/202503090225.vNvZGEfz-lkp@intel.com/config)
compiler: clang version 18.1.8 (https://github.com/llvm/llvm-project 3b5b5c1ec4a3095ab096dd780e84d7ab81f3d7ff)
reproduce (this is a W=1 build): (https://download.01.org/0day-ci/archive/20250309/202503090225.vNvZGEfz-lkp@intel.com/reproduce)

If you fix the issue in a separate patch/commit (i.e. not just a new version of
the same patch/commit), kindly add following tags
| Reported-by: kernel test robot <lkp@intel.com>
| Closes: https://lore.kernel.org/oe-kbuild-all/202503090225.vNvZGEfz-lkp@intel.com/

All warnings (new ones prefixed by >>):

>> net/netfilter/ipvs/ip_vs_ctl.c:3099:40: warning: format specifies type 'unsigned long' but the argument has type 'size_t' (aka 'unsigned int') [-Wformat]
    3099 |                         pr_err("length: %u != %lu\n", *len, size);
         |                                               ~~~           ^~~~
         |                                               %zu
   include/linux/printk.h:544:33: note: expanded from macro 'pr_err'
     544 |         printk(KERN_ERR pr_fmt(fmt), ##__VA_ARGS__)
         |                                ~~~     ^~~~~~~~~~~
   include/linux/printk.h:501:60: note: expanded from macro 'printk'
     501 | #define printk(fmt, ...) printk_index_wrap(_printk, fmt, ##__VA_ARGS__)
         |                                                     ~~~    ^~~~~~~~~~~
   include/linux/printk.h:473:19: note: expanded from macro 'printk_index_wrap'
     473 |                 _p_func(_fmt, ##__VA_ARGS__);                           \
         |                         ~~~~    ^~~~~~~~~~~
   net/netfilter/ipvs/ip_vs_ctl.c:3140:40: warning: format specifies type 'unsigned long' but the argument has type 'size_t' (aka 'unsigned int') [-Wformat]
    3140 |                         pr_err("length: %u != %lu\n", *len, size);
         |                                               ~~~           ^~~~
         |                                               %zu
   include/linux/printk.h:544:33: note: expanded from macro 'pr_err'
     544 |         printk(KERN_ERR pr_fmt(fmt), ##__VA_ARGS__)
         |                                ~~~     ^~~~~~~~~~~
   include/linux/printk.h:501:60: note: expanded from macro 'printk'
     501 | #define printk(fmt, ...) printk_index_wrap(_printk, fmt, ##__VA_ARGS__)
         |                                                     ~~~    ^~~~~~~~~~~
   include/linux/printk.h:473:19: note: expanded from macro 'printk_index_wrap'
     473 |                 _p_func(_fmt, ##__VA_ARGS__);                           \
         |                         ~~~~    ^~~~~~~~~~~
   2 warnings generated.


vim +3099 net/netfilter/ipvs/ip_vs_ctl.c

  3012	
  3013	static int
  3014	do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
  3015	{
  3016		unsigned char arg[MAX_GET_ARGLEN];
  3017		int ret = 0;
  3018		unsigned int copylen;
  3019		struct net *net = sock_net(sk);
  3020		struct netns_ipvs *ipvs = net_ipvs(net);
  3021	
  3022		BUG_ON(!net);
  3023		BUILD_BUG_ON(sizeof(arg) > 255);
  3024		if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
  3025			return -EPERM;
  3026	
  3027		if (cmd < IP_VS_BASE_CTL || cmd > IP_VS_SO_GET_MAX)
  3028			return -EINVAL;
  3029	
  3030		copylen = get_arglen[CMDID(cmd)];
  3031		if (*len < (int) copylen) {
  3032			IP_VS_DBG(1, "get_ctl: len %d < %u\n", *len, copylen);
  3033			return -EINVAL;
  3034		}
  3035	
  3036		if (copy_from_user(arg, user, copylen) != 0)
  3037			return -EFAULT;
  3038		/*
  3039		 * Handle daemons first since it has its own locking
  3040		 */
  3041		if (cmd == IP_VS_SO_GET_DAEMON) {
  3042			struct ip_vs_daemon_user d[2];
  3043	
  3044			memset(&d, 0, sizeof(d));
  3045			mutex_lock(&ipvs->sync_mutex);
  3046			if (ipvs->sync_state & IP_VS_STATE_MASTER) {
  3047				d[0].state = IP_VS_STATE_MASTER;
  3048				strscpy(d[0].mcast_ifn, ipvs->mcfg.mcast_ifn,
  3049					sizeof(d[0].mcast_ifn));
  3050				d[0].syncid = ipvs->mcfg.syncid;
  3051			}
  3052			if (ipvs->sync_state & IP_VS_STATE_BACKUP) {
  3053				d[1].state = IP_VS_STATE_BACKUP;
  3054				strscpy(d[1].mcast_ifn, ipvs->bcfg.mcast_ifn,
  3055					sizeof(d[1].mcast_ifn));
  3056				d[1].syncid = ipvs->bcfg.syncid;
  3057			}
  3058			if (copy_to_user(user, &d, sizeof(d)) != 0)
  3059				ret = -EFAULT;
  3060			mutex_unlock(&ipvs->sync_mutex);
  3061			return ret;
  3062		}
  3063	
  3064		mutex_lock(&__ip_vs_mutex);
  3065		switch (cmd) {
  3066		case IP_VS_SO_GET_VERSION:
  3067		{
  3068			char buf[64];
  3069	
  3070			sprintf(buf, "IP Virtual Server version %d.%d.%d (size=%d)",
  3071				NVERSION(IP_VS_VERSION_CODE), ip_vs_conn_tab_size);
  3072			if (copy_to_user(user, buf, strlen(buf)+1) != 0) {
  3073				ret = -EFAULT;
  3074				goto out;
  3075			}
  3076			*len = strlen(buf)+1;
  3077		}
  3078		break;
  3079	
  3080		case IP_VS_SO_GET_INFO:
  3081		{
  3082			struct ip_vs_getinfo info;
  3083			info.version = IP_VS_VERSION_CODE;
  3084			info.size = ip_vs_conn_tab_size;
  3085			info.num_services = ipvs->num_services;
  3086			if (copy_to_user(user, &info, sizeof(info)) != 0)
  3087				ret = -EFAULT;
  3088		}
  3089		break;
  3090	
  3091		case IP_VS_SO_GET_SERVICES:
  3092		{
  3093			struct ip_vs_get_services *get;
  3094			size_t size;
  3095	
  3096			get = (struct ip_vs_get_services *)arg;
  3097			size = struct_size(get, entrytable, get->num_services);
  3098			if (*len != size) {
> 3099				pr_err("length: %u != %lu\n", *len, size);
  3100				ret = -EINVAL;
  3101				goto out;
  3102			}
  3103			ret = __ip_vs_get_service_entries(ipvs, get, user);
  3104		}
  3105		break;
  3106	
  3107		case IP_VS_SO_GET_SERVICE:
  3108		{
  3109			struct ip_vs_service_entry *entry;
  3110			struct ip_vs_service *svc;
  3111			union nf_inet_addr addr;
  3112	
  3113			entry = (struct ip_vs_service_entry *)arg;
  3114			addr.ip = entry->addr;
  3115			rcu_read_lock();
  3116			if (entry->fwmark)
  3117				svc = __ip_vs_svc_fwm_find(ipvs, AF_INET, entry->fwmark);
  3118			else
  3119				svc = __ip_vs_service_find(ipvs, AF_INET,
  3120							   entry->protocol, &addr,
  3121							   entry->port);
  3122			rcu_read_unlock();
  3123			if (svc) {
  3124				ip_vs_copy_service(entry, svc);
  3125				if (copy_to_user(user, entry, sizeof(*entry)) != 0)
  3126					ret = -EFAULT;
  3127			} else
  3128				ret = -ESRCH;
  3129		}
  3130		break;
  3131	
  3132		case IP_VS_SO_GET_DESTS:
  3133		{
  3134			struct ip_vs_get_dests *get;
  3135			size_t size;
  3136	
  3137			get = (struct ip_vs_get_dests *)arg;
  3138			size = struct_size(get, entrytable, get->num_dests);
  3139			if (*len != size) {
  3140				pr_err("length: %u != %lu\n", *len, size);
  3141				ret = -EINVAL;
  3142				goto out;
  3143			}
  3144			ret = __ip_vs_get_dest_entries(ipvs, get, user);
  3145		}
  3146		break;
  3147	
  3148		case IP_VS_SO_GET_TIMEOUT:
  3149		{
  3150			struct ip_vs_timeout_user t;
  3151	
  3152			__ip_vs_get_timeouts(ipvs, &t);
  3153			if (copy_to_user(user, &t, sizeof(t)) != 0)
  3154				ret = -EFAULT;
  3155		}
  3156		break;
  3157	
  3158		default:
  3159			ret = -EINVAL;
  3160		}
  3161	
  3162	out:
  3163		mutex_unlock(&__ip_vs_mutex);
  3164		return ret;
  3165	}
  3166	

-- 
0-DAY CI Kernel Test Service
https://github.com/intel/lkp-tests/wiki
