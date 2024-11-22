Received: from mx0b-00007101.pphosted.com (mx0b-00007101.pphosted.com [148.163.139.28])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 90C92158DA3;
	Fri, 22 Nov 2024 18:03:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=148.163.139.28
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1732298631; cv=fail; b=D71MRwMX27U8RS3Vy185/aEl1u49sHl4jdh5Br92dzdxnJSthwvveCwAqSQcUr7OWqIb8TssijGDVldxn3bTs7eYmUytrYvhv9F40lCrPXxpISB0hh16nVpUZY/2G/vt8h1ZyAao2doT5K5OEw3MSD/iucBXyjPnsgFkUhHWMwk=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1732298631; c=relaxed/simple;
	bh=bhXYs+2Sroe4blji3ut+V6UOTAfvgEwVzFagLigoVbc=;
	h=Message-ID:Date:Subject:To:Cc:References:From:In-Reply-To:
	 Content-Type:MIME-Version; b=jzDlgsKB7VhX1967tMZvJKxR4AHWG1fgmOA5o3QG9a0RNkypxYK2gL6oiXoha0Jyoa8Nqp3ppbaxBL4/l1se1Q3CWr9uwo86xn6nM27d5rKKSAuAURzOM2l8t7z5zr9lFbanr7RW+/SeYof2iTHi2iJFixPGE/vf3UFD/qN9XC8=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=illinois.edu; spf=pass smtp.mailfrom=illinois.edu; dkim=pass (2048-bit key) header.d=illinois.edu header.i=@illinois.edu header.b=Adzrv1cE; arc=fail smtp.client-ip=148.163.139.28
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=illinois.edu
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=illinois.edu
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=illinois.edu header.i=@illinois.edu header.b="Adzrv1cE"
Received: from pps.filterd (m0166260.ppops.net [127.0.0.1])
	by mx0b-00007101.pphosted.com (8.18.1.2/8.18.1.2) with ESMTP id 4AMHSG8X032047;
	Fri, 22 Nov 2024 18:03:17 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=illinois.edu; h=
	cc:content-transfer-encoding:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to; s=campusrelays;
	 bh=Ur4zSmTzGmmYOv76CDETOG3DpgK28+D4jYyhcxIb6bA=; b=Adzrv1cEfgMe
	nsLXlps1vdDtbNMHhon4bnGpp3EwHTvf4R3++Yu1OyCwCRlqCJwkDmzKZ66u6JSN
	/ToiNLnzZlbU9jE9TKWTscVA/A/fVEo50Eyl7SqpFAnMtReBBvbLBWK1WHZmkvvc
	XSlPvVNyHm2zYZaiuPxA1/ZfA9VeZYWObYF9yT3OqM9Y6af7gYvbs1sCqCx5rBlz
	jYqQk1smF/pXvl/yHpdxytY/Sw3mNs0mcyQyrDRZF/oTzsQ1PAFBN7nE+NMhAT5U
	hjDxRqgzaqXSPVHfK8C9PviDZcH72zrdW7P9rc31ek+MNhk6NyplDNF7F2Oa8YEu
	3C2dOowFOg==
Received: from nam10-mw2-obe.outbound.protection.outlook.com (mail-mw2nam10lp2042.outbound.protection.outlook.com [104.47.55.42])
	by mx0b-00007101.pphosted.com (PPS) with ESMTPS id 432wf30vm1-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Fri, 22 Nov 2024 18:03:17 +0000 (GMT)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=s3YqrqJ9orxARW2GWOgHFM38hmKm4ks7wMcS0dyYS5MlBjV6TECsBBTbGZjpEjHwwufyDmMMDMcKB+gREKbtkYDWuUlpTp/QYgKgE7ol/w7uOTxzB0Jm+HC67aP4p3eeVoUFil1S23pEKAGULm51NA3iOXsydFiAeM/Anjl0K6kKWjdCrkgCipXzEz9RxXPCyfeagsz690pWeBuH68r+/WsXQTPv+q+SfKV79gqsePJ8paoPfcErKhaFZgz+CAxzXwUzbOPB9twr1y1sQj/QQsgXgbaRcGFBQCD6tTdaFhkRMC+9cGgyyfJFC/UIOjQF2GnV+tc77hM7I2EKbJvs5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=Ur4zSmTzGmmYOv76CDETOG3DpgK28+D4jYyhcxIb6bA=;
 b=Z79FXFacQkBOJbyzCCfh6fBZcWr744sD6hhKNLrOJkezNZZOcUs27dktgooai2Re2dvrP7SOlfhqAHLGkYg9ctCwkV1Sq2fp91pHpPtKQ8LglxHAA/80COBl60K8DKZioSIHEZHgF8mVCSPZ1M+8dpXTBVvguNQil+oE/iMDvJhvrvVNj+qrfQFH74ELdBMY55Nw2eAEm5wNrPsUx+xtALjWeL+e2PlhVjCXIppJHvig+H6uJpIIG8LHHQZ1C99GLzr2ONgJaETfDiqVPbhO+E87ggftkekHxEzNXU0KgPbbfZ4ku2SQNozlJKgp69v/AZXDVliC3F0KdNt8G+kDMw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=illinois.edu; dmarc=pass action=none header.from=illinois.edu;
 dkim=pass header.d=illinois.edu; arc=none
Received: from IA1PR11MB7272.namprd11.prod.outlook.com (2603:10b6:208:428::8)
 by SA0PR11MB4544.namprd11.prod.outlook.com (2603:10b6:806:92::18) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8158.27; Fri, 22 Nov
 2024 18:02:57 +0000
Received: from IA1PR11MB7272.namprd11.prod.outlook.com
 ([fe80::74b2:6bb6:a99c:9222]) by IA1PR11MB7272.namprd11.prod.outlook.com
 ([fe80::74b2:6bb6:a99c:9222%6]) with mapi id 15.20.8158.024; Fri, 22 Nov 2024
 18:02:48 +0000
Message-ID: <298cf980-b66e-4806-ad6b-8cfff4c3dd81@illinois.edu>
Date: Fri, 22 Nov 2024 12:02:46 -0600
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v2 net] ipvs: fix UB due to uninitialized stack access in
 ip_vs_protocol_init()
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>,
        Pablo Neira Ayuso
 <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@netfilter.org>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>, Nathan Chancellor <nathan@kernel.org>,
        Nick Desaulniers <ndesaulniers@google.com>,
        Bill Wendling
 <morbo@google.com>,
        Justin Stitt <justinstitt@google.com>, Kees Cook <kees@kernel.org>,
        netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org, llvm@lists.linux.dev,
        kernel test robot <lkp@intel.com>, Ruowen Qin <ruqin@redhat.com>
References: <20241122045257.27452-1-jinghao7@illinois.edu>
 <c65f0110-f5bf-c841-710e-2932cceec25a@ssi.bg>
Content-Language: en-US
From: Jinghao Jia <jinghao7@illinois.edu>
In-Reply-To: <c65f0110-f5bf-c841-710e-2932cceec25a@ssi.bg>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
X-ClientProxiedBy: CH0PR07CA0030.namprd07.prod.outlook.com
 (2603:10b6:610:32::35) To IA1PR11MB7272.namprd11.prod.outlook.com
 (2603:10b6:208:428::8)
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: IA1PR11MB7272:EE_|SA0PR11MB4544:EE_
X-MS-Office365-Filtering-Correlation-Id: 5d22399f-720b-4b48-d7df-08dd0b1fdfb9
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam: BCL:0;ARA:13230040|1800799024|7416014|376014|366016;
X-Microsoft-Antispam-Message-Info:
	=?utf-8?B?bVQrb3BUc1Y4dkF2NEJxZkRVc2QweFZLdUwvMjNldko3b3FoekpSdW1hcEhG?=
 =?utf-8?B?MmlRT2VIdDA4NjNnRlZSQytORFlCU3F3QU0xelRQN0ZOWTlIMnVVMk9EeGVs?=
 =?utf-8?B?VDUvM0w4MnorYythTUM1Tm1Gcjl6UzRGRDlsbUFkTWJiRGhYOTNsTURHOFR3?=
 =?utf-8?B?RkRvNEczdU1aVzNlOCtYd2M3Yk1JY3lad0txalFHMVYyTlZoaUFuVXkvTjlO?=
 =?utf-8?B?cWg2blhMazdTUWZkR2ZSRytXVlNRNXRBWi92ZFZmcEVWT1RFb0N2MG1ZYU5X?=
 =?utf-8?B?N2t0VDNkeFlWTDBUV1BLcHRCN0ZXaE0zYW12dmVqS1RLMFZjK3pqZDN3Z0Fo?=
 =?utf-8?B?cFphSHZqc0VpS1pHWVo3ejBSMXRRZmxidnR6TVpsaHB3Vmx4a0FJNCtLVExZ?=
 =?utf-8?B?Q2I5eHNXMWtBTWZ0YVEvTFpiOUlYclEwK1A0VS9iZHpuSGRvbXI3VTlWc0d5?=
 =?utf-8?B?cW5mUGhuUXZyTzNwS3U1MFU3cHJnbERZWVR4b3NkQStuMDQwd1VqUUtNck53?=
 =?utf-8?B?SHdrSHFqc0dWbytKcVM5WnFuVCs2QWc4ZXBHMkk5RW9EanRNZnFiNEltOXd3?=
 =?utf-8?B?eXpCUkh2UTlZR2VFVXpYbytZSnZ5MFBhVHVpT3hDVHJUNVY2b1pUYkhoZTQ1?=
 =?utf-8?B?cHNaUm1OSVRqVllqWjR3WVF0WTZSRUZiUEdwTG1oNStNa2lJNzhpSXVMUDhU?=
 =?utf-8?B?QkpEdGFoU1pnaEZpTTlCQ3NjZk1rNENMY2N1NENVcVVYMkVHR2VzUVM3UGZO?=
 =?utf-8?B?N2VYRW92N1NjbE13K0pCOUNQOTF6VGkwVVBSRHRxY3NYRDc1SU1yb1NMbVRH?=
 =?utf-8?B?bWhKSHhnaXNaVmJkeEZvbThFemRaSUc0bEg0MGJsZHg1MW1UY0tjdkJsTG5K?=
 =?utf-8?B?YjVscHdXSm5adUFTV09mTWt6TnREaXFnV2ozWDg1c1crelN1em9oUFhtMFFB?=
 =?utf-8?B?aG5iY3dRaXg2RWVlbE5NNGpBc1hHdFp1ZzBSNEhqdHpJL1ByVHQ0cHpMNWRi?=
 =?utf-8?B?UStFRHJEUmFLZldYVm50bldXb24rS0JLNTdnQjRuNjBFMEJxK3FuNmZsZEJB?=
 =?utf-8?B?ZlRxcDBPYi9BZUdDMDladGRsZ1REUmY1YkV1NW1KdExhM04xOTJpUDl0ci94?=
 =?utf-8?B?NWYxQ0VWVTVhUW5xNkZEWVh6SmNYc1VabUQ1a2FrR3ZubW13VDJRMUIwTi9V?=
 =?utf-8?B?WndBcDg0MG5jQ3FIRXpEbElkSjJGMTRza2N1TG0rOG56THR5RHhKa2R3V2or?=
 =?utf-8?B?S0JFL3BrbjRnNGtWS3VOcDNKTmVvcEhWb1M5UjNMR1JVTHUwZjBYczNrS1ZU?=
 =?utf-8?B?UEgxY081YlRFTTJzZTVnQUd3N2FJL0VZbFkva3BHaE9vWloxTU5KVTNrNFo0?=
 =?utf-8?B?R3ArbVdCWGtkMktHbG02cHgvYnZDN2k3YnQ4dnArZ2JwVUF1WHc3L0NFdldl?=
 =?utf-8?B?Q3h4bGJjZ3A5WFVURDlxalZaa21XLzJjZjR6RVVtc3VJMGJZaFBsY0M3QmV1?=
 =?utf-8?B?VjcyL2dBV0F4SGhFMGJYTjdYZkhPMjlVQzZYQmRwbVhFeFZUUVlST3lNTlZB?=
 =?utf-8?B?SzZvTFRCMVNic2JqQ2pQYVkyaC93bnVPMnVTbDEyTjZWUjQrYnlubVA4b29D?=
 =?utf-8?B?ZmhtR1dERHVtRzJRTFFjRGxoTlpWKy9TMzIxa0ZyaHlLeVpwT3NUbzk1WjNu?=
 =?utf-8?B?OHlyZmR3ZXVtNitPYmtBZmJrRG5aTHFtcWZYZFRRR0p1RUlkZ0RSeHJQSEhk?=
 =?utf-8?Q?0lvvAfQ+bqumx4qyoY=3D?=
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:IA1PR11MB7272.namprd11.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(1800799024)(7416014)(376014)(366016);DIR:OUT;SFP:1102;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?utf-8?B?T3FLTFR6R2ltdzdmdWdpZjd5UDBXQ2YwaU92bTh4aHRESTF0eXlBdXNWWitH?=
 =?utf-8?B?QWNINENsN28yanViV1BDcC9RLzlRa1pKOVBpWmNIazFhQ0lBeFg2bHRzelI1?=
 =?utf-8?B?WEdjNzBUV0pUM2FSZW1KMS8wL3d1R1ppcmxmeWJOb2VmemlXNUJpME5NbXd2?=
 =?utf-8?B?UC9sMHUrT3lnWlY5R2hMU1ZVN1pZdXNlRXdtblhTNm9jd2I3WnNKejZXeWpZ?=
 =?utf-8?B?VFdqejd3T1JvNEhXUy9SRW5ZaUo3YU1lYnY3aElVeHFVVWFDY0cvSDlaWTk5?=
 =?utf-8?B?OVh0c3d0WWgxVzhXZitjeGxGSXhDdmxDa3ptWEdpL2RPUENTWTI0SXJUdS9E?=
 =?utf-8?B?RnRmaklrejlyMUNnZW9uUUdFcDZxUDZGNWdrUGUzeUZPTktka2xyVzM1QWFm?=
 =?utf-8?B?Q3hRUUFGUXdScWV3K3VvRWZCV1BOUzRGUkR4VWgwTDFQalpsM0pXWG5acDIw?=
 =?utf-8?B?R2RFRFNsNVZ2SU81Yk5DZHhiUWVNL0gxNHMwNlB2ZjVWa2FOQ25NQk94bDhG?=
 =?utf-8?B?dFp3ZUlVMWcxeVp6RS94Y2JnSHhNQnREdEhJRmtLR0VQR2pPUitiNUlrYUFm?=
 =?utf-8?B?MXo0MS9rNG5YUUk5VkxZdTFWeld3UzBPaUlaeXBONkVEdWJQbTlBcFg5TmFZ?=
 =?utf-8?B?eGwyVnowWFFkQXN6d29XbEc0NnNRRUdMSEJOcE5zUWxuSVl2eFR3bkNBRitV?=
 =?utf-8?B?RVRGYzJyMVFiT2RXQk9qY1NaMW1udG14Q3gwRDRhZWp1M0RFNFRGcDYvbVZi?=
 =?utf-8?B?WjJvcEd1OFgwN0g4amd3TUVSUDVKamtyOHkranBockRtOStvL1J4K3lDYXIz?=
 =?utf-8?B?bnpMQ2QwSmRFMHFJYkpTSUJJR045cWxpRit6Q05CajV3cWN0MjJ5Tk9UcXFK?=
 =?utf-8?B?R08vQWhCY0l1TUQwK1VKM2hwREo5TXRZREJ4SjVVdWJqd3JrQTRRMHVLRVpE?=
 =?utf-8?B?NGZtRmMxR1g0MlJZL2FSUE1qVlNhS0ZqaVJnN2plS0JpK05WN1dQblpNSFdn?=
 =?utf-8?B?eEcycW5MT3JIWE5QOXNkVktXNVQxdGNCZFBWR1ZXQ0FMMzF3elNQNE9CeGpn?=
 =?utf-8?B?cHU4UUg2T1F1YXhOWjNiZWE5MTlmQmM4SVA5SHk4cGFZd0pXSU91TjRjUDkw?=
 =?utf-8?B?WUYrQk5kTlZ4RHdUcEViVmtNL3RWQVY2d015QW15SkZOaDg2VUZCeUZDblUz?=
 =?utf-8?B?NXphaTNuUzFsZm1xU2J2eE4rY0Q3d29UaU1MYVBtR0JBVzF4RTJzMCtxZ1dy?=
 =?utf-8?B?YkdyQWxrVWtjM2VZeHNWMG1oeUM2c1RnU0xmdGNXekJpMkx3dmhUQWhFQ01D?=
 =?utf-8?B?TWJVQmxkTndCeFNubzdXV1BONnBIcnIxdXVkNkV6RUxrRU5RVXo2L1JrQ05o?=
 =?utf-8?B?a295djc4VGQ5ZzJLSnVqVWFCdG55V1VwRVNIa1Boak9UVEpLajBpdURZRmRJ?=
 =?utf-8?B?ZGRZTHR2ZE9MeXRTb1EyS2pNeXNPQXlEZkVYS2srT3BEaGEycWNjclN3aDdn?=
 =?utf-8?B?dXJWVGNuYUJ2VjBTOUFaY05PZzE5QTJPTUdTY2FxZ1VlTmRYekJSVW1FT1gx?=
 =?utf-8?B?M3gwdHRIMkJNWDVjZDQ5WEN3ZUxENGVuS1hmd2ZMQ1dHSi9yWHl3WmQ4UlNU?=
 =?utf-8?B?OTA0d21GNXFCK3ljUGt3eFlBNDNQNDV6VnpTTE1nUjIzc2lTcENLV0IyR2JO?=
 =?utf-8?B?R1poTCtISzMvV3ZZMUthaEd3Z3ptMDdNd3lXZEZBMlpaV2F5YnVjUjdWcjA0?=
 =?utf-8?B?K0llcVEya2J0MW80VUR5aitrY2dPZC9rT2gxdElCQWd3OE1QWXZOY095SE5a?=
 =?utf-8?B?YjY5RiszQm02VlZSN2hJMDZDR3p0WWU3Q3d6M3dJZ00rc3EyZzB4WlllZURz?=
 =?utf-8?B?QjB3RDduQ2QxaG9zeHpNNUlyQTgzSlFOczVMMmgvYmJjT1pRNHlWakJkeHVL?=
 =?utf-8?B?ajIwQXB3QW9ZWlBoSVNhT3dmOGp2Qk45RmdxYVB0a2I4S3VGWDVBYmNTa1Zw?=
 =?utf-8?B?bWc0N21LT3BMR0pwa1JjK3BEeTVzWURlZHVYUEk3a0tIcDdNOXFUbEdZZ3VV?=
 =?utf-8?B?L3l2MURIeXd0TVk4RzFIQldtVHFQK0hYUlBqQmhBSEVZcEd2NmJ0NGtCME1Y?=
 =?utf-8?Q?L5O6gTMJDlEpo6JFbANKN9BbI?=
X-OriginatorOrg: illinois.edu
X-MS-Exchange-CrossTenant-Network-Message-Id: 5d22399f-720b-4b48-d7df-08dd0b1fdfb9
X-MS-Exchange-CrossTenant-AuthSource: IA1PR11MB7272.namprd11.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 22 Nov 2024 18:02:48.4050
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 44467e6f-462c-4ea2-823f-7800de5434e3
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: kxFrNuz59S45GU1KlpnAgY43LUOPwHkfeI4cfG8JkVUtOm3wixQBzNfHFPM1K5nBKBGSW8mi0/6I9bNm35F9XA==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SA0PR11MB4544
X-Proofpoint-GUID: Ny9gz6qUE9CkW8fpybex1LcnVTrUUa5p
X-Proofpoint-ORIG-GUID: Ny9gz6qUE9CkW8fpybex1LcnVTrUUa5p
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1051,Hydra:6.0.680,FMLib:17.12.62.30
 definitions=2024-10-05_03,2024-10-04_01,2024-09-30_01
X-Spam-Details: rule=cautious_plus_nq_notspam policy=cautious_plus_nq score=0
 suspectscore=0 clxscore=1015 priorityscore=1501 lowpriorityscore=0
 mlxscore=0 bulkscore=0 malwarescore=0 impostorscore=0 spamscore=0
 phishscore=0 adultscore=0 mlxlogscore=999 classifier=spam adjust=0
 reason=mlx scancount=1 engine=8.19.0-2409260000
 definitions=main-2411220152
X-Spam-Score: 0
X-Spam-OrigSender: jinghao7@illinois.edu
X-Spam-Bar: 

Hi Julian,

On 11/22/24 5:43 AM, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 21 Nov 2024, Jinghao Jia wrote:
> 
>> Under certain kernel configurations when building with Clang/LLVM, the
>> compiler does not generate a return or jump as the terminator
>> instruction for ip_vs_protocol_init(), triggering the following objtool
>> warning during build time:
>>
>>   vmlinux.o: warning: objtool: ip_vs_protocol_init() falls through to next function __initstub__kmod_ip_vs_rr__935_123_ip_vs_rr_init6()
>>
>> At runtime, this either causes an oops when trying to load the ipvs
>> module or a boot-time panic if ipvs is built-in. This same issue has
>> been reported by the Intel kernel test robot previously.
>>
>> Digging deeper into both LLVM and the kernel code reveals this to be a
>> undefined behavior problem. ip_vs_protocol_init() uses a on-stack buffer
>> of 64 chars to store the registered protocol names and leaves it
>> uninitialized after definition. The function calls strnlen() when
>> concatenating protocol names into the buffer. With CONFIG_FORTIFY_SOURCE
>> strnlen() performs an extra step to check whether the last byte of the
>> input char buffer is a null character (commit 3009f891bb9f ("fortify:
>> Allow strlen() and strnlen() to pass compile-time known lengths")).
>> This, together with possibly other configurations, cause the following
>> IR to be generated:
>>
>>   define hidden i32 @ip_vs_protocol_init() local_unnamed_addr #5 section ".init.text" align 16 !kcfi_type !29 {
>>     %1 = alloca [64 x i8], align 16
>>     ...
>>
>>   14:                                               ; preds = %11
>>     %15 = getelementptr inbounds i8, ptr %1, i64 63
>>     %16 = load i8, ptr %15, align 1
>>     %17 = tail call i1 @llvm.is.constant.i8(i8 %16)
>>     %18 = icmp eq i8 %16, 0
>>     %19 = select i1 %17, i1 %18, i1 false
>>     br i1 %19, label %20, label %23
>>
>>   20:                                               ; preds = %14
>>     %21 = call i64 @strlen(ptr noundef nonnull dereferenceable(1) %1) #23
>>     ...
>>
>>   23:                                               ; preds = %14, %11, %20
>>     %24 = call i64 @strnlen(ptr noundef nonnull dereferenceable(1) %1, i64 noundef 64) #24
>>     ...
>>   }
>>
>> The above code calculates the address of the last char in the buffer
>> (value %15) and then loads from it (value %16). Because the buffer is
>> never initialized, the LLVM GVN pass marks value %16 as undefined:
>>
>>   %13 = getelementptr inbounds i8, ptr %1, i64 63
>>   br i1 undef, label %14, label %17
>>
>> This gives later passes (SCCP, in particular) more DCE opportunities by
>> propagating the undef value further, and eventually removes everything
>> after the load on the uninitialized stack location:
>>
>>   define hidden i32 @ip_vs_protocol_init() local_unnamed_addr #0 section ".init.text" align 16 !kcfi_type !11 {
>>     %1 = alloca [64 x i8], align 16
>>     ...
>>
>>   12:                                               ; preds = %11
>>     %13 = getelementptr inbounds i8, ptr %1, i64 63
>>     unreachable
>>   }
>>
>> In this way, the generated native code will just fall through to the
>> next function, as LLVM does not generate any code for the unreachable IR
>> instruction and leaves the function without a terminator.
>>
>> Zero the on-stack buffer to avoid this possible UB.
>>
>> Changelog:
>> ---
> 
> 	You can not add --- before the following headers.
> 'git am file.patch' can show the result of applying the patch.

Oops my bad -- have never done a patch with changelogs inside the commit
message.

> 
>> v1 -> v2:
>> v1: https://urldefense.com/v3/__https://lore.kernel.org/lkml/20241111065105.82431-1-jinghao7@illinois.edu/__;!!DZ3fjg!45RxVgl4P0t8X0Vx6JFjX8J0xtWPfXijFBJTXvQ6B89xyEQqWT53QYyG9Ztlo3lfyadT2FdfZexm$ 
>> * Fix small error in commit message
>> * Address Julian's feedback:
>>   * Make this patch target the net tree rather than net-next
>>   * Add a "Fixes" tag for the initial git commit
>>
>> Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
>> Reported-by: kernel test robot <lkp@intel.com>
>> Closes: https://urldefense.com/v3/__https://lore.kernel.org/oe-kbuild-all/202402100205.PWXIz1ZK-lkp@intel.com/__;!!DZ3fjg!45RxVgl4P0t8X0Vx6JFjX8J0xtWPfXijFBJTXvQ6B89xyEQqWT53QYyG9Ztlo3lfyadT2Ko7xLwQ$ 
>> Co-developed-by: Ruowen Qin <ruqin@redhat.com>
>> Signed-off-by: Ruowen Qin <ruqin@redhat.com>
>> Signed-off-by: Jinghao Jia <jinghao7@illinois.edu>
>> ---
> 
> 	Please send v3, you can move your changelog here,
> after the above ---

Sounds good! I will roll out a v3 later today.

> 
>>  net/netfilter/ipvs/ip_vs_proto.c | 4 +---
>>  1 file changed, 1 insertion(+), 3 deletions(-)
>>
>> diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
>> index f100da4ba3bc..a9fd1d3fc2cb 100644
>> --- a/net/netfilter/ipvs/ip_vs_proto.c
>> +++ b/net/netfilter/ipvs/ip_vs_proto.c
>> @@ -340,7 +340,7 @@ void __net_exit ip_vs_protocol_net_cleanup(struct netns_ipvs *ipvs)
>>  
>>  int __init ip_vs_protocol_init(void)
>>  {
>> -	char protocols[64];
>> +	char protocols[64] = { 0 };
>>  #define REGISTER_PROTOCOL(p)			\
>>  	do {					\
>>  		register_ip_vs_protocol(p);	\
>> @@ -348,8 +348,6 @@ int __init ip_vs_protocol_init(void)
>>  		strcat(protocols, (p)->name);	\
>>  	} while (0)
>>  
>> -	protocols[0] = '\0';
>> -	protocols[2] = '\0';
>>  #ifdef CONFIG_IP_VS_PROTO_TCP
>>  	REGISTER_PROTOCOL(&ip_vs_protocol_tcp);
>>  #endif
>> -- 
>> 2.47.0
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 

Best,
Jinghao
