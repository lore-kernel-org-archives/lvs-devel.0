Received: from CH5PR02CU005.outbound.protection.outlook.com (mail-northcentralusazon11012005.outbound.protection.outlook.com [40.107.200.5])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 431D43CCFCC;
	Mon, 28 Sep 2026 11:15:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=40.107.200.5
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790594152; cv=fail; b=IukGE5gZ14OArN3v4yFJfOfSVMGg1DC/SCXddZkheLFU7EHEbh2jZaPXfOx/KXIyfrRHuYd1YtSNgdQNkYmi4Z6uFNrhcPUQ9zAc9YdXMdujPC7WWR8v+4dnUKtgrgO0TcsKmTeceSiCAMIypX+rPEAyA5dJh7O+QqsvdiwOkhA=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790594152; c=relaxed/simple;
	bh=68/PGj7fjqQVPogEAyncyPmU7vNRAQk8vX4JLzSMR08=;
	h=Date:From:To:Cc:Subject:Message-ID:References:Content-Type:
	 Content-Disposition:In-Reply-To:MIME-Version; b=ANjVMsjhsz5RIGIdfXZUky/pdxMEOmL1VWAuBDw8fSUxoIZRPeN66XAsP2BVHig7IVhLXIbyXUNA0Bubp9og0+Y7kDgEMiH1N8QCLTkGoi8vcPZ+qW2HxC3CTTRgQBo4q5TiEMkR2Wv1NuL19VGa5ffdH4MvYsVtHtXG5QCVTaU=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com; spf=fail smtp.mailfrom=nvidia.com; dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b=rphcV6gc; arc=fail smtp.client-ip=40.107.200.5
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=nvidia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b="rphcV6gc"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=lGMJxGSi5BcAltkjRxs/MLO6qBn3UHd+vbUIXMkLgKNkx9+wV9cc3zJslSubQ/tkMQzR6MbQ8M2cXnzxpvaFQbui9kZm4YagT9SPCSaoS3E1y3tQboSFSiQF2c8FdJC0NvQzfVR6msl+HwHVY4/ojSSAi+4lznf04laQNksKtxSBmaalQfEK+Dh6/wllH6ecGm4mCv99cxd05ye7s0L2gI3vj1QmdOyB8s33SyAHS8YA7Ol/ziBaYvXS66hqPECGUVxiwYe57k+y1F30n4fJ4cT5aHz9U23JZ/gTF8K7MdwSmbkRoVoqcHxh5jDHmnRUtYrqb9BMuDsvklr2WdX+pw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=4K5Cuf90MZmyV+ZDr35mSe43oXaLYtHs6WaGwBc8FXI=;
 b=obmXpAyaeBByErtnnsaItEb3Sg3uZUEfVqZOlKLKGbTulzJVQxU3WRV3xySu/GidK4NnbnqAwv8bMKg917jPbRvzwk3YaSgzCEwKyCEm2m8Hj9pq0TZZhc7WSkZVj7VeQBAciZ7uwsu9VdYU3u15qMEWei7+ji5Kj7yJRuHb2nllSj9WcjNkWLcF0donJKwQ74/wUcy0km61U6s0Fx2AIFLzjgZNivr6otXQAT6pEaxgfuor6yGPvx92aVeHCoh8+zgZGLMwzrmcD2NznBouZFKtAkggtGsXkFCenGnEV8XOTFbYb/jxFvNSeRBV2fCpAH6LGLIzIaK12kAfhegeXg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=nvidia.com; dmarc=pass action=none header.from=nvidia.com;
 dkim=pass header.d=nvidia.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Nvidia.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=4K5Cuf90MZmyV+ZDr35mSe43oXaLYtHs6WaGwBc8FXI=;
 b=rphcV6gcGkzi3fXOUZxbIzRi9KwgHXNt9DEcI7RDDrFvoCFbgrtrYS5BCiJXhzyrYYLEFTCPcmJOjyJXCHf8ilitV8aEBDy+VO5iqqwIR7Ofc8zf0aS+iiLgxVCDNnloRMJAFaCbOUSApe6gNmiFIWccoTY/dGiZCLOa9nYWryc2AMeZt3CCR9jYdE7XEVuIraXcN+/u4hXf16CVhMn/pXkJjuckdDnoKk8vtVj1hI1UO1W5AQ4db/P8GsiqRxrQljslaFjg93CUVHZBzd0YCbI6cvqEb+MEnU3v2SShNpF172ItE0ZMk4F7fFQx0HzZ1MR19f7EpVJRWpM8TsAaQw==
Authentication-Results: mx.microsoft.com 1; dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=nvidia.com;
Received: from PH0PR12MB7957.namprd12.prod.outlook.com (2603:10b6:510:281::22)
 by DS0PR12MB8527.namprd12.prod.outlook.com (2603:10b6:8:161::6) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.451.24; Mon, 28 Sep
 2026 11:15:47 +0000
Received: from PH0PR12MB7957.namprd12.prod.outlook.com
 ([fe80::9251:acc2:cc63:3499]) by PH0PR12MB7957.namprd12.prod.outlook.com
 ([fe80::9251:acc2:cc63:3499%3]) with mapi id 15.21.0451.022; Mon, 28 Sep 2026
 11:15:46 +0000
Date: Mon, 28 Sep 2026 14:15:38 +0300
From: Ido Schimmel <idosch@nvidia.com>
To: Julian Anastasov <ja@ssi.bg>
Cc: Axel Mierczuk <axel.mierczuk@1password.com>,
	Simon Horman <horms@verge.net.au>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
	David Ahern <dsahern@kernel.org>,
	Eric Dumazet <edumazet@google.com>, netfilter-devel@vger.kernel.org,
	lvs-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, Willy Tarreau <w@1wt.eu>,
	Keith Hoodlet <keith.hoodlet@1password.com>
Subject: Re: [PATCH nf 0/2] ipvs: fix OOB write when NATing ICMPv6 errors
 quoting non-first fragments
Message-ID: <20260928111538.GA389451@shredder>
References: <20260925141155.17603-1-axel.mierczuk@1password.com>
 <0458880e-5e0f-1f11-7ce2-e0490796c832@ssi.bg>
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0458880e-5e0f-1f11-7ce2-e0490796c832@ssi.bg>
X-ClientProxiedBy: TL2P290CA0029.ISRP290.PROD.OUTLOOK.COM
 (2603:1096:950:3::19) To PH0PR12MB7957.namprd12.prod.outlook.com
 (2603:10b6:510:281::22)
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: PH0PR12MB7957:EE_|DS0PR12MB8527:EE_
X-MS-Office365-Filtering-Correlation-Id: 6bc41fc5-670e-4a5e-3304-08df1d51d83a
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|376014|7416014|1800799024|366016|23010399003|10067099003|11063799006|56012099006|4143699003|3023799007|18002099003|22082099003;
X-Microsoft-Antispam-Message-Info:
	H4dMFRvxTHPJFsIGoi9hq486EMG4tEaltQ916FAhqc3qTFsl8rWFVU1HhFylCAvEHPkwMVEAQFWZA48EHbYc8gJChbter2ncT22/goLQz2Ir06nbuvFjrEkeWXneO0HjxGH2JuqqKxh83JgvPAeVI0C9Qr1VxTPAdb6+yq5M+zLQEGErSlynipYETt4uUdbae5Q07Ups520l11JUcULXz1gg0kRJQ7H7CB4CSnC2A6V0MqZRITXufqAdy9k82lXOwqBCntuXmE1mHGOeXHmg+0JnIM7XHjfP7wsh1jx6cc2Ts1PhuDUEMz2P7Y5AtuRHuONDeWzcHWdVbm9S9dlTbPCaQRjWe1rhUFdTK8vH9Ytl5XA8qistVDEo/TbzQ1CUiIo0JbNmts45K50SBljMkJSG2iCQJmLqWBjWjKv9uqPKDezmuyYebx92vuCCJDRNtZsxMR55KNm53iRmEK/jqCx1MA1Vo15UgGR1tDRguE6bWlEQXVYjlE21PHX2O/iK3/uzKHTCwq0TX8Ktg+AhWXUerIMRy1o08QCuZaUlB0toZI8t4Ih8WgLV5vgwXvDHaXFBPqGoHnN3ZXA/C8oGqLiCr4k/wjqVibvyU9mkerEp3f1OIGY5PLIoZm7InzaJqP6xUF4pHT3Z2P4biGAAqxWTa4D/msRQduXG8pp2zwM=
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:PH0PR12MB7957.namprd12.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(376014)(7416014)(1800799024)(366016)(23010399003)(10067099003)(11063799006)(56012099006)(4143699003)(3023799007)(18002099003)(22082099003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?us-ascii?Q?pz0xCKW1dn8TBn9dW00RUiy3Ml9QBXxeup+0n7zXtf7jjNGIJtMIHrphz5sf?=
 =?us-ascii?Q?uehBVV3xZuwQsDZlKlefO0+i5njwOEsfNarGGGiwrVntcyX9J2uhWZ6+ze/8?=
 =?us-ascii?Q?ij1EJYboNmqX8HwzlUSUOL/U2RJ4MRf2Fn0n3xC8SLt5NvCo0athmE/CC6r0?=
 =?us-ascii?Q?Ly3BGFevLpbxbs3sm3jB/Fidm42uXifwqD8RMIQm2S5A/AP1rWb9/LvUDl3T?=
 =?us-ascii?Q?r2OoeWb6jYD8BnUvt/Mb6R0EMXL1BfqDF3Cr7jERBRWUut7vOdoz9BOAYDj0?=
 =?us-ascii?Q?FqcftaFuKPYAjmqfbDFjkG9rDWrrKotw7S7T++ncrk++UwHSdxLemYwq8af4?=
 =?us-ascii?Q?OPBpd1MgBgtgTU9oWrbN0v1qlpIvV+5X1Wi1hO6A3j1WFA9zzxfhiuatO4KE?=
 =?us-ascii?Q?XUEoLRvrV0+GcNUOv0L6MSGqQmfCH3wD0+QqhQ2jeskPOKzmem00iHF+FRXf?=
 =?us-ascii?Q?n6APLhGGbVWtGt3DP5ghrSrUyYx0tuJT19rPIwJ0g1YK3qlqMmS99lhd2HxM?=
 =?us-ascii?Q?quMYWY3jr8tTsSBowIIOHIiqR72oMyz7jTDf6TbFOVR7Z9cgSmk6VMtJ8ksg?=
 =?us-ascii?Q?kNn7nuZn+Wm/3wek0s+HzBYwE5hDcuxFqps1fN7jM4e37QEYp/YIV2b8oa2g?=
 =?us-ascii?Q?KSHogDBnTbTkqAZ0Z14fGCcbHjEudv9L4Di76VSTNx6arQh/bT5I0s2yvrU7?=
 =?us-ascii?Q?TeXpSeRw/oE6xThX3A9EqKFBfbFQ5337THMBfhR/KLWNLqnVPEElrbKUQWPb?=
 =?us-ascii?Q?2hA7bklejNlerF30zYC1Q9oYH9UGO7dmtF00MZbj+KXxSBRmgCJksDDnc4KM?=
 =?us-ascii?Q?mPZKMMaQI8VziJujCxezIUkQHbsHNDdvzGC4LiVyJMV1eYieR9HijXoywCDc?=
 =?us-ascii?Q?M9/KtWhgtWh00CrmZNEZQLQYGtNY/Wd6rWyo7YzjPmZ1uKKxB+Eq0/3Rq6hZ?=
 =?us-ascii?Q?oo5la8FSSfqLVGUDppNPWg8b5jsVV4EcLl9IkLiv2F1oGhfld82ltyOVhUeI?=
 =?us-ascii?Q?LtPcC1wu9D4OHq/uhfyRS+GJsB+QW7o/IU2AuN6es0Tl6hycCkcj7nw8NXgR?=
 =?us-ascii?Q?v8VnuSsgA0xI+Rm+D11psxK4zjk4s4oeSxb+NE0d5FW/RLMuME/E7sqO3vdE?=
 =?us-ascii?Q?rvtbPX/EiCVx5Xg4CyCF0KQxsHOkc5P5L5uGBjKR4bHr6Pa/DztfH8T5JcJ7?=
 =?us-ascii?Q?ilg7j+IgbjI1wyKyATU6Xdq9IWSKNkxPxeZHEGvt9Bbs+Ym+8IgpZtlFYS1X?=
 =?us-ascii?Q?y2+7l8EV6cLnfpTbuPtP1h64fncHLA6RbL7mpVWtu4D/xCSUOahZdQGXWLtr?=
 =?us-ascii?Q?c7/+3wfF6g/ZXtWiYUPO2afH8NUPq9R1acLUn9JvSBjaTf+XLuhXWczM1+Bs?=
 =?us-ascii?Q?YADISvq//3NT+0XxKK5PYRIDXnCUoVwGOqBubA3AUEW9/ov4xxNZa37x9EmW?=
 =?us-ascii?Q?+rAS3qcfJNJADGUveVAGTqwq2VSoLbYmea+zTbSSMAGOJf+dOAeQfBAsL79X?=
 =?us-ascii?Q?e4S4r+VtxyNhiTpZdsncppUhcRDDGQzmmcyqvsAC1KSgjBpBvY1vNnx4p1He?=
 =?us-ascii?Q?GCY4O55HspL2irgTSAW/mezZZVJTwvaY1cOPob7z6YfUxKJCkbxk33zsFYij?=
 =?us-ascii?Q?9ApwGafXH59YbpWV+6dDH69fJL+KmiQI5OffkzFDyhB7RCl8o9cFpzj/ezZA?=
 =?us-ascii?Q?0umTIBWtnA0dNMEY0t4uyix3IRHEVSM3K673sg+pzr7HkGWE?=
X-OriginatorOrg: Nvidia.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 6bc41fc5-670e-4a5e-3304-08df1d51d83a
X-MS-Exchange-CrossTenant-AuthSource: PH0PR12MB7957.namprd12.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 28 Sep 2026 11:15:46.8483
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 43083d15-7273-40c1-b7db-39efd9ccc17a
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: l8q7ROZ4uRYD8nLQ0DLsSAHzr2D9iDIYEyp5Eros/BDhO3lQU1xz1pPFwFS/US5jEEsK9mAr9RgkxExEzGD+NQ==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DS0PR12MB8527

On Fri, Sep 25, 2026 at 08:50:58PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Fri, 25 Sep 2026, Axel Mierczuk wrote:
> 
> > This series fixes a 16-byte OOB write past the verified skb area,
> > reachable through ICMPv6 errors that quote non-first fragments.
> > Following Julian's suggestion, it preserves ESP ICMPv6 handling.
> > 
> > Patch 1 includes the embedded IP header in ciph.len at both ICMPv6
> > call sites when parsing stops at a non-first fragment. The change
> > follows the ip_vs_fill_iph_skb_icmp() calls and does not depend on
> > patch 2.
> > 
> > Patch 2 makes ipv6_find_hdr() set *offset to the fragment payload
> > for non-first fragments when target < 0, so every successful return
> > updates it. It carries no Fixes tag because it defines an offset
> > that was previously unspecified.
> > 
> > Axel Mierczuk (2):
> >   ipvs: avoid out-of-bounds write in ip_vs_nat_icmp_v6
> >   ipv6: update *offset for non-first fragments in ipv6_find_hdr()
> > 
> >  net/ipv6/exthdrs_core.c         |  6 +++++-
> >  net/netfilter/ipvs/ip_vs_core.c | 14 ++++++++++++++
> >  2 files changed, 19 insertions(+), 1 deletion(-)
> 
> 	Both patches look good to me, thanks!
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> 	The ipv6 patch needs review from the net team and
> may need some Fixes line:
> 
> Fixes: b777e0ce7437 ("[NETFILTER]: make ipv6_find_hdr() find transport protocol header")

Doesn't patch 2 make patch 1 redundant? It seems that the comments added
by patch 1 become stale with patch 2, no?

If so, why do we need both? Why not send only patch 2 and blame
63dca2c0b0e7a?
