Received: from mgamail.intel.com (mgamail.intel.com [198.175.65.10])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 40BEE1A27E;
	Mon,  5 Feb 2024 11:51:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=198.175.65.10
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1707133896; cv=fail; b=GO/w5J8pgwt70fmZoOnXSNGbt871QmnM5aWB6l/djB06VXX1BgSyv41D9UqRWFin4/Jv4ITebKeieksK3Cwk+XvXnBUJnsA9kNJkvKAP2VeNopWiePKMP1ADTzAQtLtPPUCKTXIMcAMB0wQYQ1J5bPbv2+t/GrIv8d6vmVyXyPE=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1707133896; c=relaxed/simple;
	bh=5SndGDgGKmBg/WeznQeJkZUwKMK1pBKjF6vY7wO9t+w=;
	h=Date:From:To:CC:Subject:Message-ID:Content-Type:
	 Content-Disposition:MIME-Version; b=XagkfDdA01tWtbISkChBJjtxi8X5PzoghcoQ+7godwxlPCfVGgYtdJ1jWR2NIw+x4qMMPF2S5RQwbJYSkvoLCfHSl//0uh4v0bRy8aiToIZdWduPvTPz5Uhz445ueN/UVYJYB/24g2Lz2HYA7pwcTswPa9Oi4WrImGFQ3nqxuEM=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com; spf=pass smtp.mailfrom=intel.com; dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b=LkINM+eq; arc=fail smtp.client-ip=198.175.65.10
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b="LkINM+eq"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1707133894; x=1738669894;
  h=date:from:to:cc:subject:message-id:mime-version;
  bh=5SndGDgGKmBg/WeznQeJkZUwKMK1pBKjF6vY7wO9t+w=;
  b=LkINM+eqgB5m7pzIDiKXFP97uN5rQAx2jefXY3OKUDvgV5WULIcDOI4E
   Cors3HRzc8pGkzS+8azzFc/1YiaFxSlLJupRkrscLCkYIYvEM3HEswG3b
   PfQGfa0Uhh9cex3pvAJQEwmVsneXFBNxf2pcfaFjNjFDQFJ6KTwYkzIgs
   hVm0Oo9+44vrxCZLo6abePDnV+UG7RH+QijyxIpTMfU416YKCT9+lcG2Q
   v9T1tb7q5HCWtipv/sFFdE0iGNSj9De8FsYLce5ZSXQDXkKb1PlZ2eAzx
   GxCaR/3wk61GI0tspV2vD5caQwIHvdkw7rjIQ5/Qx0obfpI18U83Sw1WW
   g==;
X-IronPort-AV: E=McAfee;i="6600,9927,10974"; a="17920966"
X-IronPort-AV: E=Sophos;i="6.05,245,1701158400"; 
   d="scan'208";a="17920966"
Received: from orviesa003.jf.intel.com ([10.64.159.143])
  by orvoesa102.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 05 Feb 2024 03:51:34 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.05,245,1701158400"; 
   d="scan'208";a="5330804"
Received: from orsmsx601.amr.corp.intel.com ([10.22.229.14])
  by orviesa003.jf.intel.com with ESMTP/TLS/AES256-GCM-SHA384; 05 Feb 2024 03:51:34 -0800
Received: from orsmsx610.amr.corp.intel.com (10.22.229.23) by
 ORSMSX601.amr.corp.intel.com (10.22.229.14) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.2507.35; Mon, 5 Feb 2024 03:51:33 -0800
Received: from orsmsx602.amr.corp.intel.com (10.22.229.15) by
 ORSMSX610.amr.corp.intel.com (10.22.229.23) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.2507.35; Mon, 5 Feb 2024 03:51:32 -0800
Received: from ORSEDG602.ED.cps.intel.com (10.7.248.7) by
 orsmsx602.amr.corp.intel.com (10.22.229.15) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.2507.35 via Frontend Transport; Mon, 5 Feb 2024 03:51:32 -0800
Received: from NAM11-BN8-obe.outbound.protection.outlook.com (104.47.58.169)
 by edgegateway.intel.com (134.134.137.103) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.1.2507.35; Mon, 5 Feb 2024 03:51:32 -0800
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=oezAtoP1/RmL7y2LHsvPr6uPnfEm2nWynZ2rnmsD+8xnDuMOV9aLq/oDjlBlBhok79ajMLWpbYjEMaqaX1kNmiftotc7VdG8X1csdrGoaGhJeyjyr0xqXC+o0l2PlL8SK0JAkFDr+h0GZ+xb3qeAX2T7q89ITWsLk7g6rLQNxQlENdsl3zV1OmhhT/gb5CHA5a78TC6B3dR7QqQJZMVCSBJ4J1SGuw+/otIhJRNBzOOeXIrm8uhc/DwZSLFtZLxr715mclHn8DQdUitjJtJ4nz+5yoC/fF6LEV6xWRwB4hj/GMCbk577oe++Ne+lsnkht/30kc/H07JQCgdeMspZEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=pzWzqDjR53BHuKmCuJKZr1C76UFQ2URA9Rtk68bZo4w=;
 b=WLmsn1/UPPMqjJleHGJWPdVFIEpMng9BDZv6kw2Xc6yBGh/TAnPM1mqOUg6ABWTW3F5QbBGL4HMg8j/Ep92DDv/Ef62w74zIho49BAnsKkg8kb5nDGzB02VJHl+2bIfPSJ+9qr3lawlMLLZxUtXaByBi+4nE8x4pJi5zmyorDPJS96NotDAI5Tc27l8D63PRAoMtYGhI3de0iF/v3umhwvJ6x1yDLDjbSLUG736/MvaffTRWN4xfJHBP4Tj4JEkbTjDHj5b/r7MAYmLZ53Lgn43O9QvrfsLOWjBo3bw2qAvho9aQ3eM7XjG58Nm/5EWmj9PD24Gj3ErStu/IXAcLcQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=intel.com; dmarc=pass action=none header.from=intel.com;
 dkim=pass header.d=intel.com; arc=none
Authentication-Results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=intel.com;
Received: from CH3PR11MB8414.namprd11.prod.outlook.com (2603:10b6:610:17e::19)
 by SJ0PR11MB5168.namprd11.prod.outlook.com (2603:10b6:a03:2dc::7) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.7249.34; Mon, 5 Feb
 2024 11:51:30 +0000
Received: from CH3PR11MB8414.namprd11.prod.outlook.com
 ([fe80::ed34:4cf2:df58:f708]) by CH3PR11MB8414.namprd11.prod.outlook.com
 ([fe80::ed34:4cf2:df58:f708%4]) with mapi id 15.20.7249.035; Mon, 5 Feb 2024
 11:51:29 +0000
Date: Mon, 5 Feb 2024 19:51:21 +0800
From: kernel test robot <lkp@intel.com>
To: Florian Westphal <fw@strlen.de>
CC: <llvm@lists.linux.dev>, <oe-kbuild-all@lists.linux.dev>,
	<netdev@vger.kernel.org>, <lvs-devel@vger.kernel.org>, Phil Sutter
	<phil@nwl.cc>
Subject: [horms-ipvs-next:main 7/9] ld.lld: error: undefined symbol: xt_recseq
Message-ID: <ZcDLuYTvcN/NVo9K@rli9-mobl>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
X-ClientProxiedBy: SG2PR04CA0173.apcprd04.prod.outlook.com (2603:1096:4::35)
 To CH3PR11MB8414.namprd11.prod.outlook.com (2603:10b6:610:17e::19)
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-Exchange-MessageSentRepresentingType: 1
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: CH3PR11MB8414:EE_|SJ0PR11MB5168:EE_
X-MS-Office365-Filtering-Correlation-Id: 445f93e0-35fa-4674-e2b2-08dc2640ca6b
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam: BCL:0;
X-Microsoft-Antispam-Message-Info: zNoA/03xCedeHhAPcPdafGoeTI2/2ynUQqU8OkCiioMUf42Zxjj0w+WSvENlsrOcn5D++EFkrlixprYoPaNW/zgMP3pxFab4W9FW38hVWbBt4Hc2yACBMtRET56Y+qV9cBoqO9pXto9npdwIObhpO9eQGgaNsMH7tv1nfqJJoRzZ553iWQhcUO5TvoWEgt5/Tlc+2MeVm2o5SJeFZYWT3WIz/1EoIHvxdgVi2OR+HcM7AkR2i+v3M18gYu5uESz4sEvlrI3kYpJLW7S2zA+V3cODvvjkU5wobS5iLJ2edCLH7d/Y4vSKTsCW6KfbXgg3BOosJRF7NNRczWb1oFKZsUV6TRXgxZkUObnRTy9SCelLSlm1UzaAglkVCVkERTsDmFpwgPiRwLVG3qe81BRCm9mA2WNhq5N+HZ5/cUI4Dk/QBTOosGHgTBq0vK6vbrfTvx3+izSC4hlPcp2IIAN0023I2azjfaCvaq9MS1FWSmSB0F6nnCyx/GUX3qBpm+SnZph8e/d1fd0OdPKe/zg4MVq5cBfrdPLHqxCTeltaBLY5LmhhF9TfMdM+lcnyGT3rZyjTrRIe4jK1+s6VX5gZ7A==
X-Forefront-Antispam-Report: CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:CH3PR11MB8414.namprd11.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230031)(7916004)(366004)(346002)(396003)(39860400002)(376002)(136003)(230922051799003)(1800799012)(64100799003)(451199024)(186009)(33716001)(41300700001)(82960400001)(2906002)(83380400001)(6506007)(6666004)(26005)(38100700002)(9686003)(6512007)(66946007)(66476007)(966005)(316002)(66556008)(478600001)(6916009)(6486002)(86362001)(8676002)(4326008)(5660300002)(8936002);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0: =?us-ascii?Q?F9YB/YcRNqJ7dNPTK7vAvuMS2PraCoEpzOQ0KbYNcu9DVsfuTJchivBaQV/0?=
 =?us-ascii?Q?OWkLMA7FX21zlp6kj3ERRnTLSXWNADhDJgz0ubJhzVgWs4x+A+NXCp8pon/5?=
 =?us-ascii?Q?OY9SmGxU4exSX2ZHUd9KTbmKvj2Lp87OxQUjYQJtf9tG/2BVy2JqvgNI4124?=
 =?us-ascii?Q?VksV+oq/kLQsXsCvsDnLkIQN22pEcpRlzB8wgNXW5u6eBglWP2jKaIQXKZnW?=
 =?us-ascii?Q?l/Pa2bTFx8njQNEGyqp9sDB/tMwNn7aj++GIXLgD0AfdmxdDXMrygplTS47e?=
 =?us-ascii?Q?wwYwL5qcd3IlDwe7skojd8U1phTLOt614+pr0oNL/WIgje/f+WP7yyMtAxJA?=
 =?us-ascii?Q?LFfOyvFePUc+XNRVXQ/Zp3AwARIqmxKo7IFmQ3Qn2pmlIP33I7vlveqkeMoV?=
 =?us-ascii?Q?Ll5AHA2JbgY+mi7SBNGEplRA+54H4Rz2x8DHc984AMZhx6BgVH3JYoT88PXg?=
 =?us-ascii?Q?4mtXE1mTjuszSm5GWBqc5WjhmHlr9BlcL4Y/1PnaDX2Zzk1WGrBl4C2TTpQB?=
 =?us-ascii?Q?4NkWikEpmvVXT0iCU/vI73JUlo6vsZuMCJ6RomCN0Npyxh7gmKnejV9qtg4l?=
 =?us-ascii?Q?guQSK6kig6qLKaJx4mmPseVBWnCcX/hOFDynC6yZNJ8TGIo2FrxjWgJe6fU4?=
 =?us-ascii?Q?0KQ4ex8b4IWYUDwe0cfwXatxqScIHTN+bkxDJXNsa38wBB1Ye6Fqc4gSD5pt?=
 =?us-ascii?Q?odepQNMahWCq9j+aOJs5Vn12oXmLbi1Ydh7HRMSQl05SBmGK4dGhTkykYSBG?=
 =?us-ascii?Q?OuHysXDrSPSutnPaQd42Fj+tJB8iWX9P8nSTATNp5Qra76XBsL6Mqs0bPpo1?=
 =?us-ascii?Q?BurgyI+5L0JwkLmJEpNO4mkJg0RckkIaXmwVc89wVN4x4l3B1nC2lYl6dGFk?=
 =?us-ascii?Q?lor2XQCpckSHa5ckSRS3F54ER0HaQv6ttxcEZTKWIO4nYADwSvqUvU4xn4y8?=
 =?us-ascii?Q?i/zD7yTx6osmj16HlQL4EIvPViDB/EaChtfa/N8fMsSkVH+DGqaLxiN6IXvk?=
 =?us-ascii?Q?mGojmBclJvMi3IbGx2Eki1DpgDo7CI88qlbUcZfZqKLU748O172w78JDqbUJ?=
 =?us-ascii?Q?M/INk4DaGQKffoq+HFmAX/uH73dymL07CQ3dqAhMTUrRKmTcm1CWIlR6MTJR?=
 =?us-ascii?Q?pFR55qczRD3Q2C+snRwhN8BsqEFMnrc8RJcFV2ciURXBewdybeehMHQ54/bV?=
 =?us-ascii?Q?D5K4m9J7I9iAVmcXmRY0W7VBIPyYZ82SvQH85P9XKDZL0wTZK2AwBb4E6Il6?=
 =?us-ascii?Q?H6I6083et4aF6cd/00KBUcFa2P2Q3qsX7Fb6fPrv+GwgZrNmGrt5hhJ78GEU?=
 =?us-ascii?Q?8YvBuigIzKRjWQlwbCEEZHs5YlTFC8QIFdOMCPVXxs6ZsUMp8wsGot3eYBkS?=
 =?us-ascii?Q?2+X6E0VMtnU/ubvtqtA+FeQyEw2Hb0Yn84iXjM+Rdwr3LjqOw4BuoWX1SpuG?=
 =?us-ascii?Q?o6/28aAEyzUjzCPxDJGp6zaaKQ666WKfDShOMDyVwgmYPg5jd9jPqX3Zx8Mv?=
 =?us-ascii?Q?Ws6clTddIf2qG2e9pl1kuyk/arQwU1YDNLk8jg3zANdHQsKJBge9ZA4l14J2?=
 =?us-ascii?Q?8+wTlUCpDQKni1wMk7WY07K5Knz8c+nQgpnfASjGI4oR+mc+3StgucY7ywXv?=
 =?us-ascii?Q?3w=3D=3D?=
X-MS-Exchange-CrossTenant-Network-Message-Id: 445f93e0-35fa-4674-e2b2-08dc2640ca6b
X-MS-Exchange-CrossTenant-AuthSource: CH3PR11MB8414.namprd11.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 05 Feb 2024 11:51:29.9143
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 46c98d88-e344-4ed4-8496-4ed7712e255d
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: mJYvXkaiC8nGzZsM4FcLjOhognAJR7OJ5MmLI8bXznv9ZrBPfj5Hs2ewV4Fylyn1JI+amgXTVL8qQ2f6r2WuKg==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SJ0PR11MB5168
X-OriginatorOrg: intel.com

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git main
head:   7ad269787b6615ca56bb161063331991fce51abf
commit: 4654467dc7e111e84f43ed1b70322873ae77e7be [7/9] netfilter: arptables: allow xtables-nft only builds
config: x86_64-randconfig-076-20240131 (https://download.01.org/0day-ci/archive/20240201/202402010345.MEUDOOiB-lkp@intel.com/config)
compiler: clang version 17.0.6 (https://github.com/llvm/llvm-project 6009708b4367171ccdbf4b5905cb6a803753fe18)
reproduce (this is a W=1 build): (https://download.01.org/0day-ci/archive/20240201/202402010345.MEUDOOiB-lkp@intel.com/reproduce)

If you fix the issue in a separate patch/commit (i.e. not just a new version of
the same patch/commit), kindly add following tags
| Reported-by: kernel test robot <lkp@intel.com>
| Closes: https://lore.kernel.org/r/202402010345.MEUDOOiB-lkp@intel.com/

All errors (new ones prefixed by >>):

>> ld.lld: error: undefined symbol: xt_recseq
   >>> referenced by x_tables.h:372 (include/linux/netfilter/x_tables.h:372)
   >>>               vmlinux.o:(arpt_do_table)
   >>> referenced by x_tables.h:379 (include/linux/netfilter/x_tables.h:379)
   >>>               vmlinux.o:(arpt_do_table)
   >>> referenced by x_tables.h:397 (include/linux/netfilter/x_tables.h:397)
   >>>               vmlinux.o:(arpt_do_table)
   >>> referenced 4 more times
--
>> ld.lld: error: undefined symbol: xt_alloc_table_info
   >>> referenced by arp_tables.c:1513 (net/ipv4/netfilter/arp_tables.c:1513)
   >>>               vmlinux.o:(arpt_register_table)
   >>> referenced by arp_tables.c:970 (net/ipv4/netfilter/arp_tables.c:970)
   >>>               vmlinux.o:(do_arpt_set_ctl)
--
>> ld.lld: error: undefined symbol: xt_request_find_target
   >>> referenced by arp_tables.c:417 (net/ipv4/netfilter/arp_tables.c:417)
   >>>               vmlinux.o:(translate_table)
--
>> ld.lld: error: undefined symbol: xt_check_target
   >>> referenced by arp_tables.c:401 (net/ipv4/netfilter/arp_tables.c:401)
   >>>               vmlinux.o:(translate_table)
--
>> ld.lld: error: undefined symbol: xt_unregister_table
   >>> referenced by arp_tables.c:1489 (net/ipv4/netfilter/arp_tables.c:1489)
   >>>               vmlinux.o:(__arpt_unregister_table)
--
>> ld.lld: error: undefined symbol: xt_find_table
   >>> referenced by arp_tables.c:1566 (net/ipv4/netfilter/arp_tables.c:1566)
   >>>               vmlinux.o:(arpt_unregister_table_pre_exit)
   >>> referenced by arp_tables.c:1575 (net/ipv4/netfilter/arp_tables.c:1575)
   >>>               vmlinux.o:(arpt_unregister_table)
--
>> ld.lld: error: undefined symbol: xt_copy_counters
   >>> referenced by arp_tables.c:1010 (net/ipv4/netfilter/arp_tables.c:1010)
   >>>               vmlinux.o:(do_arpt_set_ctl)
--
>> ld.lld: error: undefined symbol: xt_find_table_lock
   >>> referenced by arp_tables.c:1014 (net/ipv4/netfilter/arp_tables.c:1014)
   >>>               vmlinux.o:(do_arpt_set_ctl)
   >>> referenced by arp_tables.c:862 (net/ipv4/netfilter/arp_tables.c:862)
   >>>               vmlinux.o:(do_arpt_get_ctl)
--
>> ld.lld: error: undefined symbol: xt_table_unlock
   >>> referenced by arp_tables.c:1040 (net/ipv4/netfilter/arp_tables.c:1040)
   >>>               vmlinux.o:(do_arpt_set_ctl)
   >>> referenced by arp_tables.c:944 (net/ipv4/netfilter/arp_tables.c:944)
   >>>               vmlinux.o:(do_arpt_set_ctl)
   >>> referenced by arp_tables.c:924 (net/ipv4/netfilter/arp_tables.c:924)
   >>>               vmlinux.o:(do_arpt_set_ctl)
   >>> referenced 2 more times
--
>> ld.lld: error: undefined symbol: xt_counters_alloc
   >>> referenced by arp_tables.c:894 (net/ipv4/netfilter/arp_tables.c:894)
   >>>               vmlinux.o:(do_arpt_set_ctl)
--
>> ld.lld: error: undefined symbol: xt_request_find_table_lock
   >>> referenced by arp_tables.c:900 (net/ipv4/netfilter/arp_tables.c:900)
   >>>               vmlinux.o:(do_arpt_set_ctl)
   >>> referenced by arp_tables.c:808 (net/ipv4/netfilter/arp_tables.c:808)
   >>>               vmlinux.o:(do_arpt_get_ctl)
..

-- 
0-DAY CI Kernel Test Service
https://github.com/intel/lkp-tests/wiki

