Received: from mx0b-0064b401.pphosted.com (mx0b-0064b401.pphosted.com [205.220.178.238])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8DED42F42;
	Tue, 25 Mar 2025 05:57:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=205.220.178.238
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1742882254; cv=fail; b=B6mEwQ8yFDe4Dcf9A7M58Uai+16BTGbtKe82HykMQzh2+ARu4UosQFNJYhFnOBiYRRSfi94k4iV02s/PWSCKVzbTSehJFJYIxGpJDIVLqTsv5YNhNhgereuHh1FN2HPQ+jfwGpSUjiBQVC1sFtsyLWhumUdX33G4dvvSCSuPGjc=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1742882254; c=relaxed/simple;
	bh=JfLHv66jLGskheSUvxSYnd8m3yXqE/kHfsgdK4e2Ing=;
	h=From:To:Cc:Subject:Date:Message-ID:Content-Type:MIME-Version; b=Gaj+ySj2hjblmOryE6zn2wn5nD9kPAo/Vyw+snUE/ftBtFY21yqlQI2jaBGYoI4cvUghV0H3s6cv0eCwP2JNS7XhW9UBQLv6qey52lQ3jBD/vyMG4FK5E0TI8ExlJnWfPWaq2X+3Olum9dkgmqPhPU3DFgOvjQGhDPuBoJLOV1c=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=windriver.com; spf=pass smtp.mailfrom=windriver.com; arc=fail smtp.client-ip=205.220.178.238
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=windriver.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=windriver.com
Received: from pps.filterd (m0250811.ppops.net [127.0.0.1])
	by mx0a-0064b401.pphosted.com (8.18.1.2/8.18.1.2) with ESMTP id 52P4viKf014456;
	Tue, 25 Mar 2025 05:57:00 GMT
Received: from nam02-bn1-obe.outbound.protection.outlook.com (mail-bn1nam02lp2041.outbound.protection.outlook.com [104.47.51.41])
	by mx0a-0064b401.pphosted.com (PPS) with ESMTPS id 45hje1jxhc-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Tue, 25 Mar 2025 05:56:59 +0000 (GMT)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=iLW72jHw+wnZQPwX/sIpwYQ2J2gtAH1xUFgivjFRU61kZjosk5Q+0l3+IvYcAM1c0h+FaL8pMTLUf9MT51INyOOOxLOD6VaLawUtwAiKReVAPX2sLK68BT50X6BgcrbiGA/8AiFUhb4rXDNK566gxsEKNWDILKoYLefGLZyEDMzDJ8at00Kjrz4QJ14ZAwF3zQpTulWg/bsM6OaAKuZcLY+mLDh0cN7KspCCu1LxArtFszWiaw1beJChrvDkeFNURk2FOgk+1aCO238wIHur9UTBFO9HdypcM37oZ6wNbIlXuS8shHRT9wo/d1bYMGSpzLu+VWNqsStihPtRhHpuyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=7/8uubyoo8eaeBEI9leNhNWqrMOjzAbw6gdbCVEAPW8=;
 b=UVqTeJKn1Q4Xt0dgmSEmQ7iP2kd72q0hJ2ogyiGhJTebuxj5CRFJKzCzs/WVtY65JSaZwVMAgr79PuPdU3LpLWQtDJiZH6reMNgnMgRhfaKLjEF8dsFqKsDs5NCW27KCVDBE6a34/WYuYQ8Z04cJLUgrHq0RN1CHsSAgylk2kvevTR33uXqaNBLjiV+FL+cucGlMdnt8S1/agdhzl/Y1US4x23y9iNcgmA6yiCwNIOmbZzM3QbCGwMtQM0Q1vRSYwD3Rt/wsWL5AQWtZRJxGLj8F3/chYKCZt6JokDEVXvchfqKu6QBGKf7msf4a+Wb0mp5YFR/KTI6bLLS4vMBW8g==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=windriver.com; dmarc=pass action=none
 header.from=windriver.com; dkim=pass header.d=windriver.com; arc=none
Received: from CY8PR11MB7012.namprd11.prod.outlook.com (2603:10b6:930:54::6)
 by SA1PR11MB6759.namprd11.prod.outlook.com (2603:10b6:806:25e::10) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8534.42; Tue, 25 Mar
 2025 05:56:57 +0000
Received: from CY8PR11MB7012.namprd11.prod.outlook.com
 ([fe80::83d5:946f:3692:8c0d]) by CY8PR11MB7012.namprd11.prod.outlook.com
 ([fe80::83d5:946f:3692:8c0d%4]) with mapi id 15.20.8534.040; Tue, 25 Mar 2025
 05:56:57 +0000
From: Cliff Liu <donghua.liu@windriver.com>
To: stable@vger.kernel.org
Cc: horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kadlec@netfilter.org,
        fw@strlen.de, davem@davemloft.net, kuba@kernel.org,
        marcoangaroni@gmail.com, netdev@vger.kernel.org,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, linux-kernel@vger.kernel.org,
        chenhx.fnst@fujitsu.com, Zhe.He@windriver.com,
        donghua.liu@windriver.com
Subject: [PATCH 5.15.y] ipvs: properly dereference pe in ip_vs_add_service
Date: Tue, 25 Mar 2025 13:56:44 +0800
Message-ID: <20250325055644.3320017-1-donghua.liu@windriver.com>
X-Mailer: git-send-email 2.43.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-ClientProxiedBy: TYCPR01CA0044.jpnprd01.prod.outlook.com
 (2603:1096:405:1::32) To CY8PR11MB7012.namprd11.prod.outlook.com
 (2603:10b6:930:54::6)
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: CY8PR11MB7012:EE_|SA1PR11MB6759:EE_
X-MS-Office365-Filtering-Correlation-Id: 2556d2a1-6806-454b-bb9d-08dd6b61da1d
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|7416014|366016|1800799024|376014|52116014|38350700014;
X-Microsoft-Antispam-Message-Info:
	=?us-ascii?Q?G4cE/Fgx3yIb8yOzHW88BugHuZHzYhd+SnQpv2LeCOmruIkQnHLEcmcIEwEf?=
 =?us-ascii?Q?WZqZBE7ZxzPGY9XSlJ4yPpympE67QAZgOD/tF105myU6YkHJI32mCvlbHTg6?=
 =?us-ascii?Q?G9r8ERUm0ldRk06jCwtlWnRzuP22VTavfdaUldcnCDRIxVvMRJxrHZcuQToW?=
 =?us-ascii?Q?mo7q0vI8/UXmiKU7gVpkkhOfcFvotlWLDRsi5Rbed5tNiQsAMEua5nZEHdE9?=
 =?us-ascii?Q?FnsD8HY2LGK5aBlArYSvuwz/kpl2Yz2j5AmU9twymTInvQDlJy/mdef6obOn?=
 =?us-ascii?Q?nnWrEEe9fh4FLy9Nliu0hmAGMksdzEP1IzMrFfiqRO51yMHkQY4bhMYM9zrR?=
 =?us-ascii?Q?aluVgfVNK/KF8/NuHF3aW4NskYLTqCr+6X6Gp3r0MSZrZaF0bp88gmVQXFcI?=
 =?us-ascii?Q?G3w2c6B/XNTLbCQA3clIx3pV5lou61oyP+b9YUch2Laq/jh1UliFeDRtDO9d?=
 =?us-ascii?Q?e0J1x/xkgRb+rpMlOrV+Ehcx36D19b19G7sOkwlf+XTE2itCOisx5VA6DVfn?=
 =?us-ascii?Q?ed8v8mfUpQG3puE9ZS6+SFEXcLaqOBm4P2EzL7IZ18Ig+zom/+fIYrHm+C4/?=
 =?us-ascii?Q?4EirEfbR1vXY2yYxKJgCbv1LmGWERHmGuSRIPqCwRq3xxVc180nXqBgrvAAd?=
 =?us-ascii?Q?q3BmO/g1tYEGmV6kZbxTURC2uTSe5OBlsa6y6m8yjn7Bpv4yB1QlOAoBxEKP?=
 =?us-ascii?Q?0ag5OFBftaVcbNGl6W1JPF/iom8wqRC/SqiyKl72QCCB6KNZZfbGLRHI6t3Q?=
 =?us-ascii?Q?IGhJRP1mjhtNLki249Lg28rfNnfNVknF5TT+EGagL/js/IYZfg/zcGtMLsh5?=
 =?us-ascii?Q?oux4BULCyi1gLv/bG5Kdj1ZJPYYvJelYUcTRt9lcGFjrQAiLQdUvZfRQceEr?=
 =?us-ascii?Q?iV8bQWzW5PA/XYTmrcj8GZPhQhNCZ+s9z0gcIHKUNmKOXoL48Zjz7/zMBBV0?=
 =?us-ascii?Q?vjwDbtU++jlO1IpJgJEyZZk26c9yDTh7BVRFvDIeZxndRMX+VCz9ad7mjkOx?=
 =?us-ascii?Q?QQK0bVmpbDHoUV9ODz99tk5tcsDEvkaktzzKv4xod6h2S0Zb4qunV8gz1IWt?=
 =?us-ascii?Q?ARybsafdusp7XnTQqXLWxwwjfFCwHiaDt1f7lWA5bcwKaG6rY54mlU/a06Rd?=
 =?us-ascii?Q?GIBEt4kiHGJUOJHihKpc4hURL19nAzWHZk2UeUF0Gy6lnYeHDFVJvGlvDLFt?=
 =?us-ascii?Q?ozHmCL2/s4kX4yAbLFo1M05+KVy+PvGzMYuUvZg0dYkCy+9V+cr6ZwFrLBWw?=
 =?us-ascii?Q?n+V3gnbBqN8vWXVropCiEH5/u4n35Puz70Lipcxf5wvSTKs8wTQLn31dG4UP?=
 =?us-ascii?Q?qM0KC4skVf/QLFMhcqhgJSkGJCMds0cDGCB8y3hDVyK2cTCvu9qROaEeXFq7?=
 =?us-ascii?Q?9EYBqhoIEszfQ9/fSSjoiG9AvKzcPG788mKmIm4QtZ125fJfBoYTjHWkmYHF?=
 =?us-ascii?Q?G/oJWV562A+aAchWTyDRMNu1ysDA8OuJ?=
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:CY8PR11MB7012.namprd11.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(7416014)(366016)(1800799024)(376014)(52116014)(38350700014);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?us-ascii?Q?YxDJfgCEX8mOBHa6Gn5fo222YkMqGL8Yc3BVHzitBNAYmV0JV0km3UjoMdwV?=
 =?us-ascii?Q?sH9l0XFmhhXeJyKW74FKCtMMJopeTFXIk8WlndrVe4Gv6qU6hSScN7mQUzHO?=
 =?us-ascii?Q?A5u3lVktaXi+ARjgVXiijmbL2Ub3Rar2Uret85QK1wxv5TylzuEdIYtKlH2E?=
 =?us-ascii?Q?o0xR9JrJJyS9oG5Y7vlcQ/Ypc134s+82z45raZi1Yx48tsAnZAzjQ01VhT35?=
 =?us-ascii?Q?ul0/1dCVsTeXo0hkDPZxEiTST6WXep1Yny0XueJfIXaibur+GM1ZO9XEKhcM?=
 =?us-ascii?Q?UPBQfw5+JaGHPY9Y6MpELNqphGLZp1MEuLr0Zoka8Y24moikUpF5M+oyZtnp?=
 =?us-ascii?Q?WUYT2OdhSjQeXmT3sCJ3QKWfZdGy+Gcf0JHPFLhJq1XOy8+p3i0bwaY3Pv22?=
 =?us-ascii?Q?apRC81YLc1rVDoAD4Wf6PRSqgEt7jlPTG8Mj7cCKOC2TyFifGD+mHBcPgGry?=
 =?us-ascii?Q?TK3UiU95UXjHPceF9hivQFfJHmn2lXlRfBS8gZv8d7NoW9PwACBYpsrcoMZn?=
 =?us-ascii?Q?43QJs/QyZ69Oh3Q1r+Iih6IngerYDc+0dWB/MnLvlNgLT42czB9JKj9MC6OV?=
 =?us-ascii?Q?p3RWOTdpwfR7ehiqcIlXSw8raN0nTeBGtK7clSe/EE3LQ3R8kViR1eBTDDFf?=
 =?us-ascii?Q?HS6Wbaaxh5Kmf1j1IaL1POldFmq4ucx1rfgH6kVH5x28eWKbScaum6A7wTwX?=
 =?us-ascii?Q?vSXtynDsIH8iP0O5i0ltlxfI0af6ek3/iHzDJdrknUdDkjo2aH1rdEBA4GYN?=
 =?us-ascii?Q?ZPrvuQRvEu/D4bUBGrzXlaPyeBwemaAN7XsNFRM9GOOKC1/OvzQbIvh/Cl+z?=
 =?us-ascii?Q?str4Z/L62xB+R8nmg4k6oFvzEbkRRsP0vvCyAf9adOE+mh5dqkzZIikmJLIU?=
 =?us-ascii?Q?vGSMaba+sTxNDU18RAtq+snhlOJHu6erO7W+NUY2hINBiYbSNTXiJQPuBnMQ?=
 =?us-ascii?Q?78ysY4W/40+Iq1aPoyuWNsOkdIZRFhbx3xFq384dpPn01N9ymjfz6J8PfvtM?=
 =?us-ascii?Q?s7hye40mOED/ppYsrMowVtNWocyW8mYpRxFXF8943Fw4Ycb5z3ZI6ZM95tUc?=
 =?us-ascii?Q?0bMVvkpjUBhxPCot9q5vNBjZ9U48D4uN2QNWNnCsL3Pz1WzLGVYBHSSnbw5L?=
 =?us-ascii?Q?wVYCgrce2KOhuxhyHTiu9vRqQvyrnI8xsQ3LsDjfk9UoWZbhHDMnvdihivzk?=
 =?us-ascii?Q?zs/RwFZic6owwfzSogMIjpwRxhF6jXoho/RsHoI4dPvNT85un9Tq0Y9jfTBd?=
 =?us-ascii?Q?GoDIcS6XAHGPJ2ETIR914TkcVkDCPgGjY/9nI2w4zhxMe8KJ5mCEweaWHC/P?=
 =?us-ascii?Q?OsOAqePRTDOaO/xGOCNmie5KGjXH/js1e44J/nckFWtTgv4aQqtRW6MeAAhv?=
 =?us-ascii?Q?f34202ECxIZ6ghjC70An9iYbtdLTRhzzo/rwCNSTAo8N0+GnG+z0rG0AcVkI?=
 =?us-ascii?Q?2tu32mKhWkw+SYexCq2dyo1EBJVTaSUxLptaJduSt9eEcEAsvTMvqMM8bH69?=
 =?us-ascii?Q?KDa1T3xICSg5QTwNN/8gRdGWcQj97yAn81Eumr6N1LfPyx3bDNVa3jh6eDjF?=
 =?us-ascii?Q?MSPwgD99ZsWYai004d2LxkU4dxK1427teqmVWTyp3kwGyx4BJ0DfbX8Ik8zo?=
 =?us-ascii?Q?Hw=3D=3D?=
X-OriginatorOrg: windriver.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 2556d2a1-6806-454b-bb9d-08dd6b61da1d
X-MS-Exchange-CrossTenant-AuthSource: CY8PR11MB7012.namprd11.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 25 Mar 2025 05:56:57.3740
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 8ddb2873-a1ad-4a18-ae4e-4644631433be
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: z4dZ3WQeYOLDS7Gc9guc5Q+XCeMEjqSJmd8Dd87vGjQG0n72rOkM0gJXKZnNZHWjvBr4SQx8Sg3x2JTdTHMosTCeVKb7isPkKJki0ZwAQX8=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SA1PR11MB6759
X-Authority-Analysis: v=2.4 cv=KPVaDEFo c=1 sm=1 tr=0 ts=67e245ab cx=c_pps a=6H1ifQWhBrriiShMtbI+RA==:117 a=lCpzRmAYbLLaTzLvsPZ7Mbvzbb8=:19 a=wKuvFiaSGQ0qltdbU6+NXLB8nM8=:19 a=Ol13hO9ccFRV9qXi2t6ftBPywas=:19 a=xqWC_Br6kY4A:10 a=Vs1iUdzkB0EA:10
 a=H5OGdu5hBBwA:10 a=omOdbC7AAAAA:8 a=VwQbUJbxAAAA:8 a=3HDBlxybAAAA:8 a=t7CeM3EgAAAA:8 a=EJnz0eeEf27LpUW9eyUA:9 a=laEoCiVfU_Unz3mSdgXN:22 a=FdTzh2GWekK77mhwV6Dw:22
X-Proofpoint-GUID: ezNtkiO_izmIk5bYBZ-BbTwEUSnxXZCi
X-Proofpoint-ORIG-GUID: ezNtkiO_izmIk5bYBZ-BbTwEUSnxXZCi
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1093,Hydra:6.0.680,FMLib:17.12.68.34
 definitions=2025-03-25_02,2025-03-21_01,2024-11-22_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 suspectscore=0 mlxscore=0
 adultscore=0 impostorscore=0 mlxlogscore=999 malwarescore=0 spamscore=0
 bulkscore=0 lowpriorityscore=0 phishscore=0 priorityscore=1501
 clxscore=1011 classifier=spam authscore=0 authtc=n/a authcc=
 route=outbound adjust=0 reason=mlx scancount=1 engine=8.21.0-2502280000
 definitions=main-2503250039

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

