Received: from mgamail.intel.com (mgamail.intel.com [198.175.65.12])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8DB543A75BE;
	Tue,  7 Apr 2026 12:23:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.175.65.12
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775564612; cv=none; b=e0GfHSmF/ssW5UGvIw/cV+RP0oNjFnQmiWez0sgUniLRHDFKn8xVIxOnkPcPgUuMAr4VU6IC3lTOpunVAPUNpCJZ7TNL6IhRZJzcq+4Q/3OEbsgb1szBSVNmHDmf52pQknzqQuoxqNEGwnq3bYvQx7DFOpM+iNJdoc/7ju5JHnE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775564612; c=relaxed/simple;
	bh=98kZ9Mf9OPvpt9oCK2NNyluJd0um+U6c6PA+N42I7n8=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=QkUtfW41Jt37WO/RNEgSbFEg+/5FcOjcKtDccWydpPP51FPbGttrWn56Ce31STADwdHmiS72LPEPIx9XZjCXp5dhtYpgu3dpiLjuCNGOtn2MCGtEOYGu3nxwS5vChHcbI4776MbaLA68o5kfaTeBCGptH3ODsNjnkzUYxuVScn4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com; spf=pass smtp.mailfrom=intel.com; dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b=Cy2BnuPc; arc=none smtp.client-ip=198.175.65.12
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b="Cy2BnuPc"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1775564612; x=1807100612;
  h=date:from:to:cc:subject:message-id:references:
   mime-version:in-reply-to;
  bh=98kZ9Mf9OPvpt9oCK2NNyluJd0um+U6c6PA+N42I7n8=;
  b=Cy2BnuPcxivNf15SjUrxiXV/EGb0wZmmQj5GhYRLRzlrnwkkjWAwSzPX
   v41Ccsc2sTluexpdD5vFhBuCXlMchoQ9Tt0FpKuriyRlf3ze9yoRDWg9u
   HiVeRT0rlwJrfXzokDzONaqaFCAXbziQ9pioO+nJVsNTnmA1ZzEvTfdHE
   S71C4O/46ahZeKgC3WjlU1eC5S+Sv1Ap6OblqbVCgmU5FfxOqC4IMYWgC
   ELvsBPYlo9c3kpQkxScyEkDuscBJBh/29niwBq/HjDtB7YjrF5QNNxObR
   0zn43+6vZWRCD18WTyrB20VHLa6szlMFhRKaMS2gJs6AW+ZZPrKruk5P7
   Q==;
X-CSE-ConnectionGUID: F2638YfATj+hlHa0aAuQiA==
X-CSE-MsgGUID: /fa/hCI4SbOdQkNdn/lGIw==
X-IronPort-AV: E=McAfee;i="6800,10657,11752"; a="87976293"
X-IronPort-AV: E=Sophos;i="6.23,165,1770624000"; 
   d="scan'208";a="87976293"
Received: from orviesa010.jf.intel.com ([10.64.159.150])
  by orvoesa104.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 07 Apr 2026 05:23:31 -0700
X-CSE-ConnectionGUID: Jt71wybuSW6FMim4uXeCUw==
X-CSE-MsgGUID: z1Z1hX0kRuaJE2YH5TjLvQ==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.23,165,1770624000"; 
   d="scan'208";a="227319123"
Received: from lkp-server01.sh.intel.com (HELO d00eb8a6782a) ([10.239.97.150])
  by orviesa010.jf.intel.com with ESMTP; 07 Apr 2026 05:23:28 -0700
Received: from kbuild by d00eb8a6782a with local (Exim 4.98.2)
	(envelope-from <lkp@intel.com>)
	id 1wA5Sm-000000000ZN-1WtB;
	Tue, 07 Apr 2026 12:23:24 +0000
Date: Tue, 7 Apr 2026 20:22:48 +0800
From: kernel test robot <lkp@intel.com>
To: Yingnan Zhang <342144303@qq.com>, horms@verge.net.au, ja@ssi.bg
Cc: oe-kbuild-all@lists.linux.dev, pablo@netfilter.org, fw@strlen.de,
	phil@nwl.cc, davem@davemloft.net, edumazet@google.com,
	kuba@kernel.org, pabeni@redhat.com, netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, linux-kernel@vger.kernel.org,
	Yingnan Zhang <342144303@qq.com>
Subject: Re: [PATCH net v2] ipvs: fix MTU check for GSO packets in tunnel mode
Message-ID: <202604072049.zQPE6QFA-lkp@intel.com>
References: <tencent_CA2C1C219C99D315086BE55E8654AF7E6009@qq.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <tencent_CA2C1C219C99D315086BE55E8654AF7E6009@qq.com>

Hi Yingnan,

kernel test robot noticed the following build errors:

[auto build test ERROR on net/main]

url:    https://github.com/intel-lab-lkp/linux/commits/Yingnan-Zhang/ipvs-fix-MTU-check-for-GSO-packets-in-tunnel-mode/20260407-141549
base:   net/main
patch link:    https://lore.kernel.org/r/tencent_CA2C1C219C99D315086BE55E8654AF7E6009%40qq.com
patch subject: [PATCH net v2] ipvs: fix MTU check for GSO packets in tunnel mode
config: nios2-allmodconfig (https://download.01.org/0day-ci/archive/20260407/202604072049.zQPE6QFA-lkp@intel.com/config)
compiler: nios2-linux-gcc (GCC) 11.5.0
reproduce (this is a W=1 build): (https://download.01.org/0day-ci/archive/20260407/202604072049.zQPE6QFA-lkp@intel.com/reproduce)

If you fix the issue in a separate patch/commit (i.e. not just a new version of
the same patch/commit), kindly add following tags
| Reported-by: kernel test robot <lkp@intel.com>
| Closes: https://lore.kernel.org/oe-kbuild-all/202604072049.zQPE6QFA-lkp@intel.com/

All error/warnings (new ones prefixed by >>):

>> net/netfilter/ipvs/ip_vs_xmit.c:115:11: error: expected identifier or '(' before 'else'
     115 |         } else if (skb->len > mtu &&
         |           ^~~~
>> net/netfilter/ipvs/ip_vs_xmit.c:119:9: error: expected identifier or '(' before 'return'
     119 |         return false;
         |         ^~~~~~
>> net/netfilter/ipvs/ip_vs_xmit.c:120:1: error: expected identifier or '(' before '}' token
     120 | }
         | ^
   net/netfilter/ipvs/ip_vs_xmit.c: In function '__mtu_check_toobig_v6':
>> net/netfilter/ipvs/ip_vs_xmit.c:115:9: warning: control reaches end of non-void function [-Wreturn-type]
     115 |         } else if (skb->len > mtu &&
         |         ^


vim +115 net/netfilter/ipvs/ip_vs_xmit.c

   104	
   105	static inline bool
   106	__mtu_check_toobig_v6(const struct sk_buff *skb, u32 mtu)
   107	{
   108		if (IP6CB(skb)->frag_max_size) {
   109			/* frag_max_size tell us that, this packet have been
   110			 * defragmented by netfilter IPv6 conntrack module.
   111			 */
   112			if (IP6CB(skb)->frag_max_size > mtu)
   113				return true; /* largest fragment violate MTU */
   114		}
 > 115		} else if (skb->len > mtu &&
   116			   !(skb_is_gso(skb) && skb_gso_validate_network_len(skb, mtu))) {
   117			return true; /* Packet size violate MTU size */
   118		}
 > 119		return false;
 > 120	}
   121	

-- 
0-DAY CI Kernel Test Service
https://github.com/intel/lkp-tests/wiki
