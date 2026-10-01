Received: from SN4PR0501CU005.outbound.protection.outlook.com (mail-southcentralusazon11011053.outbound.protection.outlook.com [40.93.194.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D66823815DE;
	Thu,  1 Oct 2026 16:11:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=40.93.194.53
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790871064; cv=fail; b=Oi0BVPyINtjPpRLrl+UF4S2izvCuAC9fhRLKVCYKsiq64NZgiK1vqNZPbxgG4KOmOtANAaI1RsHu8fXcFayMxdXO4VQnFs5Llsa1moYDzYy+g41GpbFnE9b1P+cEcIM1oaOqRKgjqHIBjls4ACZT5myMoNmkEE35lIy3YeLvHco=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790871064; c=relaxed/simple;
	bh=cpHaIV9fMtH2LWs9vezDR6+j1tgkNFAWiZMe1gUtOEI=;
	h=Date:From:To:Cc:Subject:Message-ID:References:Content-Type:
	 Content-Disposition:In-Reply-To:MIME-Version; b=q6fpZxIQB8vLo4btQOcPw2R1xPzURJ0IoRnFEX0xEtFDqDcbtgZ9EmwjAXXUTbmukRi4+jI9D0OkuazQMD/8B5nWzeL+FFs+RhLa/W4BxsMzJYgvAPo0wgecOxqKIeqrMobmtSrFN/RSYsZpRunBNZ2pWrq9o5gAh8lsAIjpmOI=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com; spf=fail smtp.mailfrom=nvidia.com; dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b=lMYHehXD; arc=fail smtp.client-ip=40.93.194.53
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=nvidia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b="lMYHehXD"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=e2XNBrRKt4XGLwscRWkZ3nJZBhzO6bEda6EG71IEuZz3V06HQ1yD6nfwm9efZqDloKfA1Geacnlf14eTpQ9KEmCkItLjEh9Az5ZfDouwAmsmWLUaxMcU4HYzxUyuI+Ew7J+4IH+rsh7BFJg/gvhle5VjHPLDQgl23PFLIGBdJPTTl1V4vNHoadayBn58fV1S254bhUIP25V/fCKkwaWp0d7im+CQVMuY1v5qNb7BPr9AeGvwqUJIbvb8G5MiZ5d08TA/cntzCpxkCb+2tgti2JN48Q8I/aQcdAcuVrUCuMne2O4sf5lnB3IKmTJyFQj18MKKi11RuqDpyEGauNPWag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=1avhGSQtlOfyZJfx4JUppdMkXBfcp4OXejpuDlxkMOE=;
 b=wrLMB2uFcfIf8W0Qx+QWPwb8aUFtCJRQQbFmwEAxI/1QXd681VsTtwzgTSPvvNCLDE2mHe6WcWJilBhUy/lZXu44st3+3j9udKkOPM220SItv3E4gIUUbXDBe591Ne7tMls5sc6ec0kUIGDNUMUbrbFdeqJA3gdpl5+tJRpF2NbCUGcp7O5aZXFzPISpLqKprltCD1KhJdACwkEA9XHk2ZVmdXjxeJNokdhtJcpaBFBshrAdGW7bLvHjv4gowEVnbjV7T8MM/k2EhX4LJawKLivP+n1Dvte49wPEBMq3rGK1IQcGlnpisFrF7v3CB6k9PpdJJvuGc589EMY25mZzjA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=nvidia.com; dmarc=pass action=none header.from=nvidia.com;
 dkim=pass header.d=nvidia.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Nvidia.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=1avhGSQtlOfyZJfx4JUppdMkXBfcp4OXejpuDlxkMOE=;
 b=lMYHehXDn+9lA5dQcQ3ahqSTNC3oBH+dgh5MFEzZ+7uWVKgzDhkcvmUtYgdLndjynUzPOHpxryIsCKxdxxC5PMYGRYUDlef1eN73tPrq79oT/UkPd0JXuWA0q1UAifZNLSVkh85IuvoQlSTVKsD3NG1Dipn7SusRBbYayEiUa4D5ENpO4rTb3VG6Ovyy+Hmi9T7iMrs5raNrj6FMIyVID1bpOSWJXgU0HgcizKaBTzGT0/FJpowg02V/UMAY9iYtDRcHUk7WdMdRH8NLUBgGfBPZzF1C/kD5k+9O9nkFkwYqWA/MEtM6XL/loo0yPBNTBkqXFONbR05/s/Dq/unATA==
Authentication-Results: mx.microsoft.com 1; dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=nvidia.com;
Received: from PH0PR12MB7957.namprd12.prod.outlook.com (2603:10b6:510:281::22)
 by MN2PR12MB4343.namprd12.prod.outlook.com (2603:10b6:208:26f::9) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.472.18; Thu, 1 Oct
 2026 16:10:58 +0000
Received: from PH0PR12MB7957.namprd12.prod.outlook.com
 ([fe80::9251:acc2:cc63:3499]) by PH0PR12MB7957.namprd12.prod.outlook.com
 ([fe80::9251:acc2:cc63:3499%3]) with mapi id 15.21.0451.026; Thu, 1 Oct 2026
 16:10:57 +0000
Date: Thu, 1 Oct 2026 19:10:47 +0300
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
Message-ID: <20261001161047.GA1631784@shredder>
References: <20260925141155.17603-1-axel.mierczuk@1password.com>
 <0458880e-5e0f-1f11-7ce2-e0490796c832@ssi.bg>
 <20260928111538.GA389451@shredder>
 <faecbb5a-01bc-ccc3-95e1-03579ba98a4e@ssi.bg>
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <faecbb5a-01bc-ccc3-95e1-03579ba98a4e@ssi.bg>
X-ClientProxiedBy: FR0P281CA0091.DEUP281.PROD.OUTLOOK.COM
 (2603:10a6:d10:a9::11) To PH0PR12MB7957.namprd12.prod.outlook.com
 (2603:10b6:510:281::22)
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: PH0PR12MB7957:EE_|MN2PR12MB4343:EE_
X-MS-Office365-Filtering-Correlation-Id: de1b806c-45f0-4518-29fa-08df1fd693d8
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|366016|7416014|376014|23010399003|1800799024|22082099003|18002099003|4143699003|3023799007|10067099003|56012099006|11063799006;
X-Microsoft-Antispam-Message-Info:
	iObRYCfQmcR2ROy+lok08PAEH+pH5ZLOumWGDpZEMFCM+v/YKuWAvG64B1r5MmZbk4Oicb2PypWgqHCogt92CZ+uoTVaen9OGhX81BT7cemPVYOyH4cy35jhvZ03kVpi4bKSPaRq/MhQF+3e7rVoP9c5d3KHRnXHvpmBxhOsFqGaiR/zAXnluU4bWHNj5iI/HXZjXpXm1+ENM+rgrEpY7Ap2g6LKYCxQUxDKCBwrn81Ah/QlQ4xa2cfEKlOldZpjNvJY7k1vS+ahKTBh1he2mQWvkJCpyJb59H5yClIeEBpsRGrgqKC5FF2r8d4SrDaglqtrarT//VUm/OfZGZXTmsKOfIBR1QSD0oqBr4gukjKmxFrwPKTbdvbX0Zz6jCvxI3h7rgF6mOjFPCRVh0sO1RwmCpz5SnmNWH0wK+IsBKohZLcUS1dzFb+A9NHdu1IQsw0jsaLEkcg1XVxmyu1WHTUAC7cTZFpl01yj+CCF7Rbs6VQxyPTTn6KliuPp1PLnCM88EP9klNpjzyIJ26NeC/tEBZ1NLfOM2s1vbt/6j3Eynco+QkNuBIFWxAnZiKyPnpjEr3cWsVPDcXrDNJyIWp3pTXBR0WaesZwekOpgv5zNy0+NoVT1YezOvMzJxrc+WLbZHfK7dj40XtnzXb0oqfW84JNPf9XJXg1xxrRGG3I=
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:PH0PR12MB7957.namprd12.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(366016)(7416014)(376014)(23010399003)(1800799024)(22082099003)(18002099003)(4143699003)(3023799007)(10067099003)(56012099006)(11063799006);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?us-ascii?Q?U5PbuwygNCRlT6hn/A6wNkH5WQPZ6EiPJrP99+eeHbGIGzaOEf/zLxpq+IpZ?=
 =?us-ascii?Q?hxaMgiGNbOzYfIdy57S88iPgReHfalGYY71irjHA9+GHzk3fkwHFs+AJjFNg?=
 =?us-ascii?Q?t8H9CHlvjp4Rl0gdtzeBYeD2kYR1B9Ye/amH9pgjUv/aNSlZ/84P8GTw6IbQ?=
 =?us-ascii?Q?VkoSdp0HGNdWW0m+B9vycznve690OQd7e1MHTPRdOPVtbzF93DjbxC2hGm1A?=
 =?us-ascii?Q?zlbqOudk5UBzrDlXhDxYkPlhStCpXfBKEqaUQvU30c4iABya7Xb8FymPAYbS?=
 =?us-ascii?Q?lBOLu4gN9Z9RKpkgajIp55ANoVCyA+QHQ2z0CYAp4XuewIRNej96Fb23XRjt?=
 =?us-ascii?Q?3BIHYdEcNZYBtdYAn3Yz81v6YVvhbz7/aCveTqKoEgkdEdqf8P0U8wR86CnM?=
 =?us-ascii?Q?d4FohbIKob6HasK74E2+nJ5XFBsQQ4plHLoKN/jb1oNoB4Kjyj8IRcWYeUSl?=
 =?us-ascii?Q?W23hXjY//7z5XAlFUSw4yQTd9uKAEDjzU3arFBaKOpDvzT6ygIXlUgCoaqnD?=
 =?us-ascii?Q?CqVUy397a7rDdQbPd3fnEM3BEPtfvFKss5ZU8JOV4JJQB6zKQWyL1z6bwMum?=
 =?us-ascii?Q?h6QqC7hWvzgVX4njMIuKJTsQZR1vAOlDm1Aj37stiZl989nQllecpj2cH7ar?=
 =?us-ascii?Q?OfI0cPnv4dQ0R23Er1+AYRbqyWdxgQH3ukqsAc6GJz8hA2uU2I2szfVOkNMf?=
 =?us-ascii?Q?ih3LoKmsKi3lVhoPkeooKEoX0s+M6qH1XteD72nHNPJMT/r9bjt9D/CCBBB/?=
 =?us-ascii?Q?IYS/xG2LenOI9rL7icdDrly1DNX0A+FXHhDXvXRWtHW2b5cDBPno79PBcOOj?=
 =?us-ascii?Q?L3CEeaxK3sk6zzc4B7v2hbm0mRrsyrdS9YP3gi/rkM5ZkXaOXmK3CUCoRDfo?=
 =?us-ascii?Q?1YKtzTI+HT7jmLemAX1k/hodWr5RXLKD1Z2a8AEBABSFO/KuwUB/CWlrlpmO?=
 =?us-ascii?Q?VjnPpg6nlummQIFHwlVBuApS+VBgfbaIx3TY/TN769QewGuAxtxJNBfYrUWi?=
 =?us-ascii?Q?8AoooTFdxYBn3OtOuUNyE0UiG9q8/hgwRaqrI78DlWo7TWLOCzAtJs4NDJis?=
 =?us-ascii?Q?466FlwSMaeeH2aj3ShappYhe/GlgnynNMY37LQCAxZKfC5JRSNArNCJOGSb2?=
 =?us-ascii?Q?Oo13PvLzKtjj9jBBUxR5dR1DCoss8U56ZnSJbjesOl0evaFRWOygbhrJqSDy?=
 =?us-ascii?Q?EIk3lLRXleMKY/Fg1bj1V8CgD+UW+yQ2nQJYUSiFhewboVUo4T6gIwDU41ts?=
 =?us-ascii?Q?Zf2iUKVOyWbTNCCILLBa2kw8UA2cBo/i2NkJPj8kXVZPATmwwc99FQ22Pxpq?=
 =?us-ascii?Q?tDDPwwPIgN7plzfrdpWVkInXp+kotFZHpYAE0O6LsO9mFC+iCqE2avnkdzD4?=
 =?us-ascii?Q?JJOAmjWm074wMBA2aMDqKrTOJ4i3qz/HcqtE3/Oycgukc04RkFQx38yg0tLf?=
 =?us-ascii?Q?L+Qkw4q8CW+FG8d/E6FEjjIoUFqqLZejhvLS8NGxv7AMu68DC1/gFInSxYLQ?=
 =?us-ascii?Q?3dmVuFdjwXPV+u6s0Iij4+KnMByiDxXNekIr1Xd93PNG87BgnLCrpW4bK9YQ?=
 =?us-ascii?Q?mBsm4ljfYVeNZKM5jOZZRqG66j15EVPbeUgeOZ1eiMSPDZdcZCgjK+phrL4o?=
 =?us-ascii?Q?nNlu8e5I5539gw488o31tsDyLyqmNuZXibjshRb1pHU++joFWxSxpS6wAOU7?=
 =?us-ascii?Q?1HO3m1sDg15wLLx6/x003AHCW6+ku6HJw7qoqCs6EHbhaXOdsvSo/L3pnpCm?=
 =?us-ascii?Q?4e7iWxOWTw=3D=3D?=
X-OriginatorOrg: Nvidia.com
X-MS-Exchange-CrossTenant-Network-Message-Id: de1b806c-45f0-4518-29fa-08df1fd693d8
X-MS-Exchange-CrossTenant-AuthSource: PH0PR12MB7957.namprd12.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 01 Oct 2026 16:10:57.5298
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 43083d15-7273-40c1-b7db-39efd9ccc17a
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: LbZrFPew3VgDa8EmOgsIGPejmnNt0ysRIM+onUBDoxceS/ibCqDyefox3H8AZPFbXtCi76Su6bA0edGZY5+DsA==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR12MB4343

On Wed, Sep 30, 2026 at 08:34:57PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 28 Sep 2026, Ido Schimmel wrote:
> 
> > On Fri, Sep 25, 2026 at 08:50:58PM +0300, Julian Anastasov wrote:
> > > 
> > > > Axel Mierczuk (2):
> > > >   ipvs: avoid out-of-bounds write in ip_vs_nat_icmp_v6
> > > >   ipv6: update *offset for non-first fragments in ipv6_find_hdr()
> > > > 
> > > >  net/ipv6/exthdrs_core.c         |  6 +++++-
> > > >  net/netfilter/ipvs/ip_vs_core.c | 14 ++++++++++++++
> > > >  2 files changed, 19 insertions(+), 1 deletion(-)
> > > 
> > > 	Both patches look good to me, thanks!
> > > 
> > > Acked-by: Julian Anastasov <ja@ssi.bg>
> > > 
> > > 	The ipv6 patch needs review from the net team and
> > > may need some Fixes line:
> > > 
> > > Fixes: b777e0ce7437 ("[NETFILTER]: make ipv6_find_hdr() find transport protocol header")
> > 
> > Doesn't patch 2 make patch 1 redundant? It seems that the comments added
> > by patch 1 become stale with patch 2, no?
> > 
> > If so, why do we need both? Why not send only patch 2 and blame
> > 63dca2c0b0e7a?
> 
> 	The idea was to have IPVS fix that can be backported
> alone, if needed.

I assumed this was the case and it's your call, but then the appropriate
thing to do would be to wait with patch 2 until patch 1 is in net-next
and change it so that it removes the now dead code. At least that's how
I handle similar cases with my submissions.
