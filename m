Received: from mx0a-0064b401.pphosted.com (mx0a-0064b401.pphosted.com [205.220.166.238])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 93D666FC5;
	Tue, 25 Mar 2025 06:15:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=205.220.166.238
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1742883329; cv=fail; b=V7gOdP5/FOdLwcqxRWwZ0MAqgtuznUhORGe7A+Luo8+sqMVk/jigR6tGa/HjcP+rJD3E/kZ5XJaJ99Arz603v93Ss1BSQJ+wzztFSGegXbl61tfCFwvaUYx4/7J5dfkmIm6vrTotPhGRMRLV1AZQCwwkdlE+2LLlYFji7EZX5nU=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1742883329; c=relaxed/simple;
	bh=JfLHv66jLGskheSUvxSYnd8m3yXqE/kHfsgdK4e2Ing=;
	h=From:To:Cc:Subject:Date:Message-ID:Content-Type:MIME-Version; b=tPHTsp/C8CqdzgiOu6H/DbTVzt/ygQdvZ+eWSFujkHOEtb2ZB8rE4x7KC288/atld1W3hwyXvY4PU1wlkc2za1w/GSL3spYM7Og/9EB4GWvKN3o60pFOFCX4BhjUACv1op4y4w8UqjC/t0C5NkGTMNjivDWViQUumZzULHDESXQ=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=windriver.com; spf=pass smtp.mailfrom=windriver.com; arc=fail smtp.client-ip=205.220.166.238
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=windriver.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=windriver.com
Received: from pps.filterd (m0250809.ppops.net [127.0.0.1])
	by mx0a-0064b401.pphosted.com (8.18.1.2/8.18.1.2) with ESMTP id 52P60NIW027946;
	Mon, 24 Mar 2025 23:14:57 -0700
Received: from nam02-bn1-obe.outbound.protection.outlook.com (mail-bn1nam02lp2042.outbound.protection.outlook.com [104.47.51.42])
	by mx0a-0064b401.pphosted.com (PPS) with ESMTPS id 45hvqkakke-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Mon, 24 Mar 2025 23:14:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=mhi6D+4SLSoPLmYRO8YR40aLGqN6IL5i6VbpoS5EevCSkgbOWXsJ6Z6snrUNhipRgJTuCG4dUhf+fbE3BR7c7+5sSSMgKswHR/8WZOLQHwcM29eB0zTlTXH2jOVyUYsByLMOqhK2pMmM9B2kJ7ASeXUOeA7ClK82NkOEQ7A1xD3T3hR/AEcFr3+0AeTRQSDlHq3ID+O5TNgxlBK/35LGiHi5nwNpR/aooudhz2kOf2VRgCtTX1O2huuXgoZeDfTM4Cop/t3WzpEm/dCI9QBWyV5RIS43eAcRwnzfLL1EPNihd2+9rtQtUuBWObfgUlNgiG3r+snluroUC4W95f5R7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=7/8uubyoo8eaeBEI9leNhNWqrMOjzAbw6gdbCVEAPW8=;
 b=Pr0g0ddWh1pj2Ztz/KNNYoWrYcFtn5ayugcok/26GbTmdITwHyPWfVA8KPio4fHJRRYR0JdTzNNI/ABhIWGzCMPe2OigPrOXWhhmz1BEOtKpD6kFVqeEnxszXrQyTxpAinYO78/5KQ4sXkveSzZO/7aJEC3UFKpNr4p5OTiPvdONjLUJVwOU+YufRb9Nje3QqbQgM1dnUHKGbu625sEgsnBpL2LspBkLhCObIWC06WClQvtT1fR+f0uRVnGgyW6yhtDaWTtGtIwr0FV+AmnUnlpYK0+zz6ntGXAcdLNOe5YvKhMs/Ey9ojATMxyAyOw/IIGhqNprT0ufvAQo652sxQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=windriver.com; dmarc=pass action=none
 header.from=windriver.com; dkim=pass header.d=windriver.com; arc=none
Received: from CY8PR11MB7012.namprd11.prod.outlook.com (2603:10b6:930:54::6)
 by DM4PR11MB5246.namprd11.prod.outlook.com (2603:10b6:5:389::11) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8534.42; Tue, 25 Mar
 2025 06:14:52 +0000
Received: from CY8PR11MB7012.namprd11.prod.outlook.com
 ([fe80::83d5:946f:3692:8c0d]) by CY8PR11MB7012.namprd11.prod.outlook.com
 ([fe80::83d5:946f:3692:8c0d%4]) with mapi id 15.20.8534.040; Tue, 25 Mar 2025
 06:14:52 +0000
From: Cliff Liu <donghua.liu@windriver.com>
To: stable@vger.kernel.org
Cc: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org,
        kadlec@netfilter.org, fw@strlen.de, davem@davemloft.net,
        kuba@kernel.org, marcoangaroni@gmail.com, netdev@vger.kernel.org,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, linux-kernel@vger.kernel.org,
        chenhx.fnst@fujitsu.com, Zhe.He@windriver.com,
        donghua.liu@windriver.com
Subject: [PATCH 5.10.y] ipvs: properly dereference pe in ip_vs_add_service
Date: Tue, 25 Mar 2025 14:14:39 +0800
Message-ID: <20250325061439.3334363-1-donghua.liu@windriver.com>
X-Mailer: git-send-email 2.43.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-ClientProxiedBy: TYCP286CA0338.JPNP286.PROD.OUTLOOK.COM
 (2603:1096:400:38e::17) To CY8PR11MB7012.namprd11.prod.outlook.com
 (2603:10b6:930:54::6)
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: CY8PR11MB7012:EE_|DM4PR11MB5246:EE_
X-MS-Office365-Filtering-Correlation-Id: 0a6edc2d-1cc6-481e-56d5-08dd6b645afd
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|366016|376014|1800799024|7416014|52116014|38350700014;
X-Microsoft-Antispam-Message-Info:
	=?us-ascii?Q?R7NH+dj+eLGNOhmhSsV06/usOuX28AlGnaeihQYqUFfS7rIvK214lIZGA+YO?=
 =?us-ascii?Q?2y2H8Ba6LvuXVmm2YUvlKqKcKmb+QUUqoqSZ9ICJIxSDY8HZ6pkFDVWa4jl9?=
 =?us-ascii?Q?7m6KmeZsFBLfzfduQQs6+ODyVoUFPPhYWqlSIEUylLRaqLPkq/8VU9vKuUmU?=
 =?us-ascii?Q?db8Cta9EAeRK0EChB8nEMI48PHfdPrQ+7Bli+ld7dA/E+nmnKyKyjnz+6tNB?=
 =?us-ascii?Q?syrucemQXlgrVsksDI+4wP+rPhhpt/mJADwmhv40kNog4eoCx0/p5zW2uAi8?=
 =?us-ascii?Q?HQYvCYW+uvX7tSUFIdEgNXAy8AbIIlt2a+6jecKmZlQ6PVRQ4gQdcxnhGIu1?=
 =?us-ascii?Q?hS66m+RylP3BiDBDZZ1YrlVlkjGEPknzg6+m7EA8+uW1dFBsm6t9BLU9C2pg?=
 =?us-ascii?Q?SgW0jb52u6BKwCaoh8F1z+mrpHsXtfTdGcucTJFgyayGcPYAtfv+tx7eQYYD?=
 =?us-ascii?Q?3yYPiiqc7VJUdVZ+KOA/aOSZOcHqK/c8TmjiJF2cErb1tMwLg2GuZeBih3qC?=
 =?us-ascii?Q?EBwzgoTZ1otEUJRp/JU9T14R4LEdrruZkPkDdHLJy3CQXjK0zZlwTcl4HUM3?=
 =?us-ascii?Q?1ckfDVFFLKTpVn0pH1Cs8OCGtJv2oG4hxvAPhTGukTz1zN2giFH23i7Ap9jD?=
 =?us-ascii?Q?gP+RtMb1gOZH0CYDiVh1p5/HzLmYNR+4TXpXeFu7u+SdAhaL/MnmUVAqTixx?=
 =?us-ascii?Q?z+kVmPY5k7lw5CEKCxUfv57ZZq8Nauy33Es/BUdeIlb67f0GTxph1SCeYURp?=
 =?us-ascii?Q?mFK4wsbQdlmCUZhM+9GzJwkYsqCJF8OxBg6ZRhwB4dOGgb87bjTz2CJ/r6bK?=
 =?us-ascii?Q?gyCcayiQiuzS+vWbbEiMCnahxqrY1xgaeBLq2uXE8Jv/vG4D5znsRyi14nHr?=
 =?us-ascii?Q?9RlZCEi7lILrV5UrBsH/gr+wTRL79+JmAQZ67IZsHLIxip4knlXKhiK1s5cr?=
 =?us-ascii?Q?hiJSIJzkGI9KOvFu2tmTJCjFxAJHQCTeXr7GCaPlRiFpk9YIZU4+E7peyUqm?=
 =?us-ascii?Q?mWSSQSVHIKm0iqVfDvezEKAqeTK9b7hqVtGskGj8mYe0tpbvr/HsN+U2e0NX?=
 =?us-ascii?Q?/DOFF67k7LSbwhiOx926fOYQLD7MjCnzwM5bcSDT9O2I/U2xm76vcNgYwxDF?=
 =?us-ascii?Q?AgqFlo2RRKlMTyjBqQJ02Zksf97ynI7vqVqeWL66Wo6vZyEHB+RpqCaibZgh?=
 =?us-ascii?Q?Jo7BV2+c/RlY8Ds06K74W5jjZ3nGNsLEe65ZqTrf4w1ZZlN09lB17jQC/MIM?=
 =?us-ascii?Q?oEhDNJzh63GXu7LyeIP48NtHkqPqGA3AG1GphS7VAgxsFktJjpc6K8f6dXbc?=
 =?us-ascii?Q?WyDEPypHnB/Tj87SF/ugKSVnRxdelwtGj4aozOTMR1Rk2PsmL5LbfTYEY7ej?=
 =?us-ascii?Q?MNwqZHNqFGdXhbI5qv/tKBrs6Y6f587vpEPrrEm55aPPbcB7xELgXiR++CL0?=
 =?us-ascii?Q?GUKUEZtI1E1maRQc7a+GlzxfNzUC0RND?=
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:CY8PR11MB7012.namprd11.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(366016)(376014)(1800799024)(7416014)(52116014)(38350700014);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?us-ascii?Q?17+V7MUPfPrkCQGdf30KGcgefjUSJ97bE8PJpuZza7ZISYkdcoDB+oYfZoxQ?=
 =?us-ascii?Q?zKHH3dyQ88gDJFLJPlt4UdE1lG0QemujZaX6KVrUaruFjpbYQC/RE/bRb/RQ?=
 =?us-ascii?Q?FngA/L1KFOjEpB5Ub0hXAg0/pYVt6i8XKzJtC5tNtWqOnC/1IUGfCzFjp/bp?=
 =?us-ascii?Q?+ymY3p1ZEl3t9CbUieo9OJJ/1otkWtRwSORGqC/ESX+6WRN8yztUgQaqO8D/?=
 =?us-ascii?Q?yX6qO3jCscrHLKaoPQqm8iucQscMf7CJdtr0or8LgjR/af0zy5x+Z4DR1pyM?=
 =?us-ascii?Q?+Aqm/OcPxPoVlrQZ+RkE1EJGuJGyNy1Oub1VI8bFAAMu3XZYlfGgoF4FH0CT?=
 =?us-ascii?Q?vgusCQGrNITqE25Wis/tEuX4F/SvStInn7+ujj0zbOGdN5zY2ch+rO5EmOem?=
 =?us-ascii?Q?fcA02B4L1L2owtnTWCroODxgmS/ZFFtSny3kTeFrDWITWGKh/JqRy9nqBMli?=
 =?us-ascii?Q?nIyHfFK2/2cBNIzRAqyNWGsnMQE1N4YER4lP1qqJz39wEW+RpjL4KNi6WkKr?=
 =?us-ascii?Q?+zXNuvoUcvsV/BUVDN6YxPv6M55Hv9M9lYQ6aAgiZDR9fEJIHpjufo1/tWnt?=
 =?us-ascii?Q?fVtoft/b+D4xLnKiz8yDKgYSaMtWgHkFwzxmwe/p9ABXUw+Bc4hvOkXXgXHn?=
 =?us-ascii?Q?0R32M2pzy9MDg3uRljjnL0tdRHSnVTqGQ2WXOqvx0JWyLNXOtI+Ve/+cyNvX?=
 =?us-ascii?Q?U6MrCxBGA333yE61tUfME9xHmjRlAGOmirfxeicSyt7Tju7j9bz1f4GgZwXA?=
 =?us-ascii?Q?ttGJ6sB7ZGe4kiY3ekvFv0/+nGxgMSqXSL3NXh2DWCdF3h/2pR+ooGjMsxBP?=
 =?us-ascii?Q?5iBPatgXLOYhy0VXZ9KCq3aYO4RI+IaGmxTLYsrK8HJrlzSwGJDFnxJ6Pfv9?=
 =?us-ascii?Q?NLK2b1cBk8kIeYaBrrjtUeVGeUIjdMoGAAopQvTSh37zFsXPB6zsWKfpKlYb?=
 =?us-ascii?Q?j9vOT8l+me/h1YRsTo5yERjnG4Sg5YVWG2s3oObV6lpHcINJwTvjwgVwkYxN?=
 =?us-ascii?Q?msaiOlUjrnSi2k7Vxnd2/rmD8949v0A5Yo5reTFDV/hDo7Kpi95kuKw4qpfc?=
 =?us-ascii?Q?O85EFoEOBv0CmwzxWydsfsYN8QWL1iFqc5gedloCYeYf4ef4NPtG+42nIdss?=
 =?us-ascii?Q?YBhexObs9kfZ6uUxXdhXFVnPNlU6p7hXQqr5OBcM6Rb97tsbxPHECfE8mR/O?=
 =?us-ascii?Q?mxp8yVKtqcr+NfI4kmBZYmCuvRKLhlt+KeekGcMHJg1izWmT6cwesG0eb+49?=
 =?us-ascii?Q?ktHH+IDJHRVoIfXkeDqXcDsOF6Wkj3QUGj77Y8uPkWQBY7sKFK9cDn0Z6phP?=
 =?us-ascii?Q?n+1AWpXXeHbCcPFQaZANvU0MreVGeYjX0hrPlWKzI7Ch+tFEYJQTohjnfY51?=
 =?us-ascii?Q?oiazJhwr2VEEO2z5xvQ0XXwbKKAiKdxIQ+zX26P5L2VVEtONHvMQroeBnkXw?=
 =?us-ascii?Q?6IFP5Vf4ndfPveLctGkeuPERbEh99VfcSxhbO35pD0LE3TozDlutf+gubdY3?=
 =?us-ascii?Q?9ov7hi0vrDEhCLJbqT7ltUxZN8wci3VObeVjc6gWXpq36h1kmGEl6xfOYR/B?=
 =?us-ascii?Q?u0FCzAxfwuey8IF74kBgHB63/Q83WXp9MycZj1TJZIFxB40o+K2O7Fg8IgVv?=
 =?us-ascii?Q?2g=3D=3D?=
X-OriginatorOrg: windriver.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 0a6edc2d-1cc6-481e-56d5-08dd6b645afd
X-MS-Exchange-CrossTenant-AuthSource: CY8PR11MB7012.namprd11.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 25 Mar 2025 06:14:52.5876
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 8ddb2873-a1ad-4a18-ae4e-4644631433be
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: SdamOiwYyn4i0TY3rJQO8JZJcO+/kG6k9XweI3KlVzB7AMoS1qfCdAc8b3TkBImNMoMx4ClKrVOiLd2pbIMgZ+lAXyBIaDHFbHzsBkDsRVI=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM4PR11MB5246
X-Authority-Analysis: v=2.4 cv=XNkwSRhE c=1 sm=1 tr=0 ts=67e249e0 cx=c_pps a=x8A/wAfU1CBlff9R7r/2ew==:117 a=lCpzRmAYbLLaTzLvsPZ7Mbvzbb8=:19 a=wKuvFiaSGQ0qltdbU6+NXLB8nM8=:19 a=Ol13hO9ccFRV9qXi2t6ftBPywas=:19 a=xqWC_Br6kY4A:10 a=Vs1iUdzkB0EA:10
 a=H5OGdu5hBBwA:10 a=omOdbC7AAAAA:8 a=VwQbUJbxAAAA:8 a=3HDBlxybAAAA:8 a=t7CeM3EgAAAA:8 a=EJnz0eeEf27LpUW9eyUA:9 a=laEoCiVfU_Unz3mSdgXN:22 a=FdTzh2GWekK77mhwV6Dw:22
X-Proofpoint-GUID: uVQUOpABsmT-qriurU2m6PMdUCI-R-Va
X-Proofpoint-ORIG-GUID: uVQUOpABsmT-qriurU2m6PMdUCI-R-Va
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1093,Hydra:6.0.680,FMLib:17.12.68.34
 definitions=2025-03-25_02,2025-03-21_01,2024-11-22_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 clxscore=1011 bulkscore=0
 mlxscore=0 impostorscore=0 adultscore=0 spamscore=0 phishscore=0
 mlxlogscore=999 malwarescore=0 lowpriorityscore=0 suspectscore=0
 priorityscore=1501 classifier=spam authscore=0 authtc=n/a authcc=
 route=outbound adjust=0 reason=mlx scancount=1 engine=8.21.0-2502280000
 definitions=main-2503250041

From: Chen Hanxiao <chenhx.fnst@fujitsu.com>

[ Upstream commit cbd070a4ae62f119058973f6d2c984e325bce6e7 ]

Use pe directly to resolve sparse warning:

  net/netfilter/ipvs/ip_vs_ctl.c:1471:27: warning: dereference of noderef expression

Fixes: 39b972231536 ("ipvs: handle connections started by real-servers")
Signed-off-by: Chen Hanxiao <chenhx.fnst@fujitsu.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Acked-by: Simon Horman <horms@kernel.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Cliff Liu <donghua.liu@windriver.com>
Signed-off-by: He Zhe <Zhe.He@windriver.com>
---
Verified the build test.
---
 net/netfilter/ipvs/ip_vs_ctl.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index d0b64c36471d..0f1531e0ce4e 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1384,20 +1384,20 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
 		sched = NULL;
 	}
 
-	/* Bind the ct retriever */
-	RCU_INIT_POINTER(svc->pe, pe);
-	pe = NULL;
-
 	/* Update the virtual service counters */
 	if (svc->port == FTPPORT)
 		atomic_inc(&ipvs->ftpsvc_counter);
 	else if (svc->port == 0)
 		atomic_inc(&ipvs->nullsvc_counter);
-	if (svc->pe && svc->pe->conn_out)
+	if (pe && pe->conn_out)
 		atomic_inc(&ipvs->conn_out_counter);
 
 	ip_vs_start_estimator(ipvs, &svc->stats);
 
+	/* Bind the ct retriever */
+	RCU_INIT_POINTER(svc->pe, pe);
+	pe = NULL;
+
 	/* Count only IPv4 services for old get/setsockopt interface */
 	if (svc->af == AF_INET)
 		ipvs->num_services++;
-- 
2.43.0

