Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=52.103.7.45
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1793513727;
	b=aboSMIovSXRyhJrkDJ5K2vbSUMrPWCWkKRvcP+0bFbeWn0q5LTpswxoFW4H5mvN46tVL
	 /v1WbDtmabJ1hm9mPKGw894QiS5q80i9yARAIdIZ3XJ8GBrItEC4SzAcb/bpfc1gaPDgb
	 5YJGf7euzQRuA2BTyfLCcCtkrSj30pGzlkhjTCz0rOeGUXUNDBo/zeIWW0r3pMUP/auuS
	 dGAjs8Qu3WPGmRzkhrDr7Qtr4HWvbbTcU0yWXrx184iLzsuI7b/kprbkOnZuRM/xn8Z7K
	 Ji0iTa63o9jmaU9EKlAlY3qtnoUDIJ3E490nbC4KSONOLchth6ZwXh+EoWmbHw4lW7Q==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793513727;
	h=DMARC-Filter:DKIM-Signature:Received:Received:From:To:CC:Subject:
	 Thread-Topic:Thread-Index:Date:Message-ID:Accept-Language:
	 Content-Language:X-MS-Has-Attach:X-MS-TNEF-Correlator:
	 x-ms-publictraffictype:x-ms-traffictypediagnostic:
	 x-ms-office365-filtering-correlation-id:x-microsoft-antispam:
	 x-microsoft-antispam-message-info:
	 x-ms-exchange-antispam-messagedata-chunkcount:
	 x-ms-exchange-antispam-messagedata-0:Content-Type:
	 Content-Transfer-Encoding:MIME-Version:X-OriginatorOrg:
	 X-MS-Exchange-CrossTenant-AuthAs:X-MS-Exchange-CrossTenant-AuthSource:
	 X-MS-Exchange-CrossTenant-RMS-PersistedConsumerOrg:
	 X-MS-Exchange-CrossTenant-Network-Message-Id:
	 X-MS-Exchange-CrossTenant-originalarrivaltime:
	 X-MS-Exchange-CrossTenant-fromentityheader:
	 X-MS-Exchange-CrossTenant-id:
	 X-MS-Exchange-CrossTenant-rms-persistedconsumerorg:
	 X-MS-Exchange-Transport-CrossTenantHeadersStamped;
	bh=k+CIKLK6abnHzaStWP3HNCnTnoKnzXzGYXGo7BwGd78=;
	b=JaCdXJv1Ze+hX3/8k89bLfvSzvx9SzcGOab9H3Q1t4Zeea8IK+4SCunyMnbplpE6Av2B
	 PatJ+AWuTr5ZRCHrxdRPaxBRME2kESri+4/Pci02f8+ixf3+rPdW1ZW0MhcFdBUH4pfjy
	 4z9FK2W/uX1H1Qi3KM0pCbxpAamijX3F/Wt81RmTXIiBize6OjqkkD8KuHqHcPnxVG42n
	 3btjZMG2x6mJ/Oq4TvbC4tEQ4R9FmPKPSiddU043XyFL38eVQ46uK6hQKSbIFFmjnn6Ux
	 7ZTzzsXzHnqPTx/yn0duyesIsaMofQGmrhKRLsgNqGkUVO/lDWNNxUxzu1ZyJqS+zzA==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=outlook.com;
	spf=pass smtp.mailfrom=outlook.com;
	dkim=pass header.d=outlook.com header.i=@outlook.com header.a=rsa-sha256 header.s=selector1 header.b=mYqEF4qX;
	arc=pass header.oldest-pass=0 smtp.remote-ip=52.103.7.45
Received: from CY7PR03CU001.outbound.protection.outlook.com (mail-westcentralusazolkn19010045.outbound.protection.outlook.com [52.103.7.45])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (secp384r1) server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 707C6606A332;
	Sun,  1 Nov 2026 06:15:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 707C6606A332
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=outlook.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=outlook.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=outlook.com header.i=@outlook.com header.a=rsa-sha256 header.s=selector1 header.b=mYqEF4qX
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=r2pTmNHQp8Dm+7fh2rnAk05Tm48ySsuU42m1uTP2kuEL5iGv8nMdEekmpp7hndT8eaSftFGWlaamDXs737G5iiCgr0xAGo3cQDPcWIxVQKcE5JUW+5WkkYWD+5aEzv23QOZ4mBNDwd5aLvAPRI+QRc0NWjJHARGFLRMB47YYRk3P7NmPexXvXl6G7M9w8j3WMdx8kdg/WWsYm2awAiM9a0+yxX4JWOdzBqm00SojtLCXPLnFdLekIuV+wwtnfD5o1ikrA3yJw3TkAcqQihoKhK/8ujSCsoUB/fQjrvk7G5ftkB7gFxvFDOxSe0Gjzqs9tWYZ7iR/Lg7az37PztxVjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001; h=From:Date:Subject:Message-ID:MIME-Version;
 bh=k+CIKLK6abnHzaStWP3HNCnTnoKnzXzGYXGo7BwGd78=;
 b=Sv/2F8KJDEYNBgUim1bmuoM+P/+uV/UPcy167Ruu4ghmexSts3G0aY+NLqCh+nmLL01bIYWFOWkGovwCQUdkTVPRn8fmZdBvzno5OSJ3wroMZ0H4NWV8Mt/46zGRFuurXfb8qT7QcOGNycJNaPbdFz1AxQ4kd1VEv4WiaQdpDV+5rJYGsLoDkE2/Zn9zdqFngJqm99z1iVDuJoTSHko23CZKEzrkXuJjJHiDK1tYmyrNPbJjS9T/fo7gqfVd760A3HZtB4oWSlMbS7n/tGXOBzKa//WG6JGRzhvZ4Xfn9J4kIZ2qVp97KU8MyK/2cll1YOMBzHcjM3fdrHn+cMw36A==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=none; dmarc=none;
 dkim=none; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=outlook.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=k+CIKLK6abnHzaStWP3HNCnTnoKnzXzGYXGo7BwGd78=;
 b=mYqEF4qXv7eF85m+IjijFMoBzEAqtWJP9Ta7ulJypgk7UpJ2Xm10VwwmbXm7HtY/5jxG52LlTWtfLFKwjYufCqK0y7mSG9/K6SWL2p/x3+JaGLPJlmpBtm4GdIy1o+WfJlefJOB44FNAX5nhxcWCs5LckVZq+6XGxBEf0LJtIaeDt3gRQMIzviujF1bfJP6ovM6tG7Mb1hbKM8mFCaiwiAIEMbaeRk1dC44yJw9GILyhMbs38Yvmhld9XBVCZxSYl6g2MV1yHF/8m7fqDzHNUB6TJ06TMVjgUn/Xbkmc+DIG8/Gn2KC+7+LJtjYan8v7RhR7HKlDaZVJ21Pkvc0Hsg==
Received: from SA3PR05MB10385.namprd05.prod.outlook.com
 (2603:10b6:806:39d::17) by SA1PR05MB8168.namprd05.prod.outlook.com
 (2603:10b6:806:1e3::13) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.569.11; Sun, 1 Nov
 2026 06:15:24 +0000
Received: from SA3PR05MB10385.namprd05.prod.outlook.com
 ([fe80::e22f:a0f5:fcb0:9b0d]) by SA3PR05MB10385.namprd05.prod.outlook.com
 ([fe80::e22f:a0f5:fcb0:9b0d%6]) with mapi id 15.21.0569.010; Sun, 1 Nov 2026
 06:15:24 +0000
From: Yingjie Wang <x-professor@outlook.com>
To: "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
CC: "horms@verge.net.au" <horms@verge.net.au>, "ja@ssi.bg" <ja@ssi.bg>,
	"pablo@netfilter.org" <pablo@netfilter.org>, "fw@strlen.de" <fw@strlen.de>,
	"phil@nwl.cc" <phil@nwl.cc>, "davem@davemloft.net" <davem@davemloft.net>,
	"edumazet@kernel.org" <edumazet@kernel.org>, "kuba@kernel.org"
	<kuba@kernel.org>, "pabeni@redhat.com" <pabeni@redhat.com>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"coreteam@netfilter.org" <coreteam@netfilter.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: [PATCH nf v2] ipvs: avoid wrapping persistent service timeouts
Thread-Topic: [PATCH nf v2] ipvs: avoid wrapping persistent service timeouts
Thread-Index: AQHdachhtPfP04y0I0S6y49AWMIhaQ==
Date: Sun, 1 Nov 2026 06:15:23 +0000
Message-ID:
 <969309eb180c2e577dd6bb54a7d28afcbb2efeb3.1793513714.git.x-professor@outlook.com>
Accept-Language: en-US, zh-CN
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: SA3PR05MB10385:EE_|SA1PR05MB8168:EE_
x-ms-office365-filtering-correlation-id: 5589d706-89e1-47a3-5455-08df37df83e8
x-microsoft-antispam:
 BCL:0;ARA:14566002|24021099003|4140399003|25010399006|38102599003|31061999003|41001999006|22091999003|15080799012|24121999003|51005399006|8060799015|8062599012|5062599005|19110799012|1602099012|10035399007|40105399003|26121999007|102099032|440099028|3412199025|4302099013;
x-microsoft-antispam-message-info:
 =?iso-8859-1?Q?YT3oUsCvg8w2gS81ELF5Mg5iRYp9TukLMWvYfAp0QdxMvXvv/uatYH0/vl?=
 =?iso-8859-1?Q?6vdpGwWt+MtKes29ULRk1GdMAVNAHkvtgEuWYcDlgESXrghjBTrh0pViNT?=
 =?iso-8859-1?Q?s7jScbx9eMfvlHRU/YSw57zTM3EWm/QSbhjvZ7rKQREWW5JK4fueXF42Nz?=
 =?iso-8859-1?Q?RGdC0Opkk0b7aKksE8e+nlm6ZZHifYDoIDpHxHspWnxx61M7v56MxmE8DZ?=
 =?iso-8859-1?Q?gYAewJ0hdoOmXj3MaKKPht5Bekwx8lK4xDUpoJOu9O6OTOqQqG7XIoNWIU?=
 =?iso-8859-1?Q?JA+pqZWz6A//IpWdaABsr+3dqpp1zORrKPnpFTm3f62D3fYrEKVcjykC1F?=
 =?iso-8859-1?Q?RhVf3eAn3A0dhN26StH6NPOU6Jhgf8E8+J5zwSQI09c0RXyxHq7SVJPb7R?=
 =?iso-8859-1?Q?IoP/rJ5ddIjuwsDZqFXs2hdrwQeLJWkAKSx+RsyTjgvLZx3Qab4mNG5lqg?=
 =?iso-8859-1?Q?jL008p6o5+KUuKd+NAkPTm1ojRetcLD70vbLonT+hw2lGLhociyh8djEay?=
 =?iso-8859-1?Q?Dv9oP2XjMgPnnihoTmaoSTaV8mKeefIKhhZv3y2nfnnspFpPExEnTw9G7D?=
 =?iso-8859-1?Q?Cd60sNCJNXYXkbCxAnUUyz49UeE3XJXdwlwjpOgZMaLbVuRoZ5d0vXH1jW?=
 =?iso-8859-1?Q?DOtBZfxUGzJUHQwA+Cj82TRF/Hm4fIaFstDRebP5vni87xCCmhCQ/2s6+t?=
 =?iso-8859-1?Q?ZPqrHBXpD7/wDLwthklWCuyMEVjCMZZGdwexEJOH7Bd9LQjBnAwubHF6MM?=
 =?iso-8859-1?Q?O7chXverg5keGYhke0itXW2Y487ZX56g+leZvFA2xhF5Y/ZobnTz/CaU1k?=
 =?iso-8859-1?Q?VGgcx/6jOUezTZ1Rz4gN/wqQl2zQuHbCLyEX4QMPkvHldX8ejFqNpxpfel?=
 =?iso-8859-1?Q?o27nMzjXYlvOzNiA1PKDZRwzDCPKlpTJ2QMuHteHNtHY09D4JlRBbEIKKb?=
 =?iso-8859-1?Q?eR3rFeFg8HAfXn9uufCEvmTt0jr7r1T5HdDQufg6mnrul0cB6cEoKyvQg6?=
 =?iso-8859-1?Q?KGLuForNKDNx++S6YjbZK/O9TLVzUeDE9nrHMv4K1OsrkYkxw440b2OwrW?=
 =?iso-8859-1?Q?FWwCjMfjGoW6+XkH1IL8LP2g6nTSrhKUbAhaBzgHqaV8dZtq7hQNdWWmzA?=
 =?iso-8859-1?Q?85cKJTLBg6FFpzFz+GKGfTwVD5c/49NuaeXI5TVZXbifD5wC/xlOU+w8+W?=
 =?iso-8859-1?Q?2QW59VP1+tnKNF4kKsB8P3gKfmzwOf1B2IA=3D?=
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0:
 =?iso-8859-1?Q?Y9w8nj/Y8vgVrFwjrS3fMKwaghd/mzeB686gULc2+Yqgye2lzUK9qfSXfW?=
 =?iso-8859-1?Q?ct4uj0SsZVk1xjj3nTEUgi5iam6utNLfKoUIOc5cHflsZKkjJ3vu1H2wy/?=
 =?iso-8859-1?Q?k2YrLf+QekWW4sNdvTXDm/GGqlp07gUZQVXPMDDe1JJ8H00tbLw/TerKm+?=
 =?iso-8859-1?Q?46didBiQ1zU1wGrm48mYMt1D35RdFnBCNdmxBC6xSnaUziw7+GFLm8qAXw?=
 =?iso-8859-1?Q?j2p+T5nVGjPSKYnOBXxQ/B7Ylto8/fo0DddV/iJRrDbzFxvNGHk3fnft7A?=
 =?iso-8859-1?Q?hFLyxgRnDv1ZjsJ/p+v1uRXwWEXxIR3+oYIafOwshE1+bzsgzSbQWLtFLW?=
 =?iso-8859-1?Q?2ZlEGi81/KZ2WVZAvWRiPJqTBmh2OGTP2b8WLagILDV7oyfEscOpWor1rB?=
 =?iso-8859-1?Q?EQ7LkeT/5i8I9MnYnfnOSx/56f72q/AdzCl2ddcJHkynWNSmf9ykV4uh3/?=
 =?iso-8859-1?Q?h3JBmCHw/lMbzsr7QmO5IY53AVnPx2mE/8ruzRgRRbS/YRCQK28UZYhqbn?=
 =?iso-8859-1?Q?8Y4Vx2cONRh0l/UQfGPhsVkxKUPqpzLw06EVeVeHCCav6m8GvsMFh9kzoO?=
 =?iso-8859-1?Q?h5bg3UkYx2pHm1RvJ4HzSsUxhnwxlKEGtythdevqAzoafpZm1+EJ6r7IeX?=
 =?iso-8859-1?Q?BuwxVtku5QSDyrnYHTtDHT6Bypp19Koiw/chreszk6yTyiLixkPf+2BvYn?=
 =?iso-8859-1?Q?24FGe2AVIJ2sUYMKcTuCaVfiQLp6Zv8M6IF7N1NN6qmnO3JAQaLFtJupNg?=
 =?iso-8859-1?Q?I6pEEuiX0ZOt7Km8s6xwSJpduRd/UnTodPyzIb3V4YE35woEWAovXvOtox?=
 =?iso-8859-1?Q?l9x2lR0zcyJyBt5WRuV7ozaYLI+Hr8aRdj5FY5Bnn/mxHbFRJ1zeHjVfTy?=
 =?iso-8859-1?Q?gotocJ0MFMcqr52U5g0z2YIU5pgpdqJadbo+7QUhedeATQfr6qSxBjd1hZ?=
 =?iso-8859-1?Q?EMQ5so4jUaX4cDjnK0n7wBHY5usQYGARBMWt78BjVAegmTh/RXEbwnNyB9?=
 =?iso-8859-1?Q?0qGjuUGBR2cpHJPRXt/JmKK30eB6SmZeFjOwWbTFy8FsH7SLtHhN2g33st?=
 =?iso-8859-1?Q?JxvkyKk2F5HqVLpbmEUWNivUuCqf6DhZKoFnCIIbJeZciHVW5Tg62KX5Ps?=
 =?iso-8859-1?Q?rIVQq3S+n1eV9tPpNTyHBzB+6QsN4BECodUoTtYXtJrkW+zaOiA9TakhzF?=
 =?iso-8859-1?Q?/ZWBP+eYiDFkjNKeI/0fBzsAfo5/OwXK7vTHe2PCDaOQvcCBH1IngE8q6/?=
 =?iso-8859-1?Q?oh6HcOjlFpDO8XlXrNI/Th596G5MnupDLfJVZ49gQYgG4Q0NLjSBrF+Nhs?=
 =?iso-8859-1?Q?iO7OPJ01hVziHa4OW7/OnVkIJkgWlDp6K3MrfcRuPtbtDC4+ZgOg+cbrEi?=
 =?iso-8859-1?Q?esFJbtb/BkrWucb+yaTT2ulgDQ/zjY/+8FziWUAPhAOmJAG142kYyY9p3S?=
 =?iso-8859-1?Q?VBg3+e0TLku3PLq/?=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-OriginatorOrg: outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: SA3PR05MB10385.namprd05.prod.outlook.com
X-MS-Exchange-CrossTenant-RMS-PersistedConsumerOrg: 00000000-0000-0000-0000-000000000000
X-MS-Exchange-CrossTenant-Network-Message-Id: 5589d706-89e1-47a3-5455-08df37df83e8
X-MS-Exchange-CrossTenant-originalarrivaltime: 01 Nov 2026 06:15:24.0114
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 84df9e7f-e9f6-40af-b435-aaaaaaaaaaaa
X-MS-Exchange-CrossTenant-rms-persistedconsumerorg: 00000000-0000-0000-0000-000000000000
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SA1PR05MB8168

ip_vs_add_service() and ip_vs_edit_service() convert an unchecked u32=0A=
timeout from seconds to jiffies with u->timeout * HZ. Both operands are=0A=
unsigned int, so values above UINT_MAX / HZ wrap.=0A=
=0A=
With HZ=3D1000, 4294968 seconds becomes 704 jiffies and is reported back=0A=
as 0 seconds. Persistence templates copy svc->timeout, so their timer is=0A=
armed for 0.7 seconds and a client can be moved to another real server=0A=
long before the configured timeout.=0A=
=0A=
ipvsadm limits service persistence and protocol timeouts to 31 days.=0A=
Enforce the same limit in the kernel and reject larger values with=0A=
-EINVAL. Convert accepted values through a common helper that clamps=0A=
them to MAX_JIFFY_OFFSET / HZ on 32-bit systems. Use the helper for=0A=
timeouts received from the synchronization protocol as well, since those=0A=
values do not pass through the service configuration checks.=0A=
=0A=
Change the service timeout and protocol timeout tables to unsigned long=0A=
because they store jiffies. With HZ=3D1000, 31 days is 2678400000 jiffies,=
=0A=
which does not fit in the signed int used by the protocol tables. This=0A=
also allows the global protocol timeout interface to represent the full=0A=
31-day range on 64-bit systems.=0A=
=0A=
The overflow was reproduced in an x86-64 QEMU guest with HZ=3D1000. A=0A=
persistent one-packet UDP service was set to 4294968 seconds, and two=0A=
datagrams sent 1.5 seconds apart were directed to different real servers=0A=
after the template expired.=0A=
=0A=
On the x86-64 test kernel with HZ=3D1000, 2678401-second service timeouts=
=0A=
were accepted and 4294968 seconds read back as 0, while a 2678400-second=0A=
protocol timeout was rejected. With this change, 2678401 and 4294968=0A=
seconds are rejected, a failed edit leaves the previous service timeout=0A=
unchanged, and 2678400-second service and protocol timeouts read back=0A=
unchanged.=0A=
=0A=
On an i386 test kernel with HZ=3D1000, the accepted 2678400-second values=
=0A=
were clamped to 1073741 seconds by the 32-bit jiffy limit and read back=0A=
as such through both interfaces.=0A=
=0A=
Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")=0A=
Suggested-by: Julian Anastasov <ja@ssi.bg>=0A=
Link: https://lore.kernel.org/r/4f420fda8690ac470be44b3da284b65501c77bb5.17=
93430892.git.x-professor@outlook.com=0A=
Link: https://lore.kernel.org/r/5fa37fba-530c-2c5b-038e-9cb95e34023d@ssi.bg=
=0A=
Signed-off-by: Yingjie Wang <x-professor@outlook.com>=0A=
---=0A=
=0A=
Notes:=0A=
    Changes since v1:=0A=
    - Follow Julian's suggestion to use the 31-day ipvsadm limit, reject=0A=
      larger configured values, and clamp accepted values only for the=0A=
      32-bit jiffy limit.=0A=
    - Move the conversion helper to include/net/ip_vs.h and use it for=0A=
      service, protocol and synchronized connection timeouts.=0A=
    - Store service and protocol timeout ticks in unsigned long values so=
=0A=
      the full range is representable.=0A=
    - Add runtime coverage for the 31-day boundary, failed service updates=
=0A=
      and global TCP/UDP timeout readback on x86-64 and i386. The i386 test=
=0A=
      also verifies the intended MAX_JIFFY_OFFSET clamp.=0A=
    =0A=
    v1: https://lore.kernel.org/r/4f420fda8690ac470be44b3da284b65501c77bb5.=
1793430892.git.x-professor@outlook.com=0A=
=0A=
 include/net/ip_vs.h                   | 20 ++++++++++++---=0A=
 net/netfilter/ipvs/ip_vs_app.c        |  3 +--=0A=
 net/netfilter/ipvs/ip_vs_ctl.c        | 35 ++++++++++++++++-----------=0A=
 net/netfilter/ipvs/ip_vs_proto.c      |  4 +--=0A=
 net/netfilter/ipvs/ip_vs_proto_sctp.c |  6 ++---=0A=
 net/netfilter/ipvs/ip_vs_proto_tcp.c  |  6 ++---=0A=
 net/netfilter/ipvs/ip_vs_proto_udp.c  |  6 ++---=0A=
 net/netfilter/ipvs/ip_vs_sync.c       |  6 ++---=0A=
 8 files changed, 52 insertions(+), 34 deletions(-)=0A=
=0A=
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h=0A=
index 9a83bff32569..4eaa06b5f991 100644=0A=
--- a/include/net/ip_vs.h=0A=
+++ b/include/net/ip_vs.h=0A=
@@ -18,6 +18,7 @@=0A=
 #include <linux/workqueue.h>=0A=
 =0A=
 #include <linux/compiler.h>=0A=
+#include <linux/jiffies.h>=0A=
 #include <linux/timer.h>=0A=
 #include <linux/bug.h>=0A=
 =0A=
@@ -55,6 +56,18 @@=0A=
 #define IP_VS_CONN_MAX	(1 << 24)=0A=
 #endif=0A=
 =0A=
+/* All timeouts up to 31 days */=0A=
+#define IP_VS_TIMEOUT_MAX_SECS	(86400U * 31)=0A=
+=0A=
+static inline unsigned long ip_vs_timeout_ticks(unsigned int secs)=0A=
+{=0A=
+	secs =3D min_t(unsigned int, secs, IP_VS_TIMEOUT_MAX_SECS);=0A=
+#if BITS_PER_LONG <=3D 32=0A=
+	secs =3D min_t(unsigned int, secs, MAX_JIFFY_OFFSET / HZ);=0A=
+#endif=0A=
+	return (unsigned long)secs * HZ;=0A=
+}=0A=
+=0A=
 /* svc_table limits */=0A=
 #define IP_VS_SVC_TAB_MIN_BITS	4=0A=
 #define IP_VS_SVC_TAB_MAX_BITS	20=0A=
@@ -776,7 +789,7 @@ struct ip_vs_protocol {=0A=
 struct ip_vs_proto_data {=0A=
 	struct ip_vs_proto_data	*next;=0A=
 	struct ip_vs_protocol	*pp;=0A=
-	int			*timeout_table;	/* protocol timeout table */=0A=
+	unsigned long		*timeout_table;	/* protocol timeout table */=0A=
 	atomic_t		appcnt;		/* counter of proto app incs. */=0A=
 	struct tcp_states_t	*tcp_state_table;=0A=
 };=0A=
@@ -938,7 +951,7 @@ struct ip_vs_service {=0A=
 	atomic_t		refcnt;   /* reference counter */=0A=
 	__be16			port;	  /* port number for the service */=0A=
 	unsigned int		flags;	  /* service status flags */=0A=
-	unsigned int		timeout;  /* persistent timeout in ticks */=0A=
+	unsigned long		timeout;  /* persistent timeout in ticks */=0A=
 	__be32			netmask;  /* grouping granularity, mask/plen */=0A=
 	struct netns_ipvs	*ipvs;=0A=
 =0A=
@@ -1844,7 +1857,8 @@ struct ip_vs_pe *__ip_vs_pe_getbyname(const char *pe_=
name);=0A=
 int ip_vs_protocol_init(void);=0A=
 void ip_vs_protocol_cleanup(void);=0A=
 void ip_vs_protocol_timeout_change(struct netns_ipvs *ipvs, int flags);=0A=
-int *ip_vs_create_timeout_table(int *table, int size);=0A=
+unsigned long *ip_vs_create_timeout_table(const unsigned long *table,=0A=
+					  size_t size);=0A=
 void ip_vs_tcpudp_debug_packet(int af, struct ip_vs_protocol *pp,=0A=
 			       const struct sk_buff *skb, int offset,=0A=
 			       const char *msg);=0A=
diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.=
c=0A=
index 11cbdbaf561d..89be90a2c383 100644=0A=
--- a/net/netfilter/ipvs/ip_vs_app.c=0A=
+++ b/net/netfilter/ipvs/ip_vs_app.c=0A=
@@ -93,8 +93,7 @@ ip_vs_app_inc_new(struct netns_ipvs *ipvs, struct ip_vs_a=
pp *app, __u16 proto,=0A=
 =0A=
 	if (app->timeouts) {=0A=
 		inc->timeout_table =3D=0A=
-			ip_vs_create_timeout_table(app->timeouts,=0A=
-						   app->timeouts_size);=0A=
+			kmemdup(app->timeouts, app->timeouts_size, GFP_KERNEL);=0A=
 		if (!inc->timeout_table) {=0A=
 			ret =3D -ENOMEM;=0A=
 			goto out;=0A=
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.=
c=0A=
index ce9fe20d6106..5f19fd9545a6 100644=0A=
--- a/net/netfilter/ipvs/ip_vs_ctl.c=0A=
+++ b/net/netfilter/ipvs/ip_vs_ctl.c=0A=
@@ -1766,6 +1766,9 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_=
vs_service_user_kern *u,=0A=
 	int ret =3D 0;=0A=
 	bool grow;=0A=
 =0A=
+	if (u->timeout > IP_VS_TIMEOUT_MAX_SECS)=0A=
+		return -EINVAL;=0A=
+=0A=
 	/* increase the module use count */=0A=
 	if (!ip_vs_use_count_inc())=0A=
 		return -ENOPROTOOPT;=0A=
@@ -1864,7 +1867,7 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_=
vs_service_user_kern *u,=0A=
 	svc->port =3D u->port;=0A=
 	svc->fwmark =3D u->fwmark;=0A=
 	svc->flags =3D u->flags & ~IP_VS_SVC_F_HASHED;=0A=
-	svc->timeout =3D u->timeout * HZ;=0A=
+	svc->timeout =3D ip_vs_timeout_ticks(u->timeout);=0A=
 	svc->netmask =3D u->netmask;=0A=
 	svc->ipvs =3D ipvs;=0A=
 =0A=
@@ -1971,6 +1974,9 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct =
ip_vs_service_user_kern *u)=0A=
 	struct netns_ipvs *ipvs =3D svc->ipvs;=0A=
 	int af_id =3D ip_vs_af_index(svc->af);=0A=
 =0A=
+	if (u->timeout > IP_VS_TIMEOUT_MAX_SECS)=0A=
+		return -EINVAL;=0A=
+=0A=
 	/*=0A=
 	 * Lookup the scheduler, by 'u->sched_name'=0A=
 	 */=0A=
@@ -2031,7 +2037,7 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct =
ip_vs_service_user_kern *u)=0A=
 	 * Set the flags and timeout value=0A=
 	 */=0A=
 	svc->flags =3D u->flags | IP_VS_SVC_F_HASHED;=0A=
-	svc->timeout =3D u->timeout * HZ;=0A=
+	svc->timeout =3D ip_vs_timeout_ticks(u->timeout);=0A=
 	svc->netmask =3D u->netmask;=0A=
 =0A=
 	old_pe =3D rcu_dereference_protected(svc->pe, 1);=0A=
@@ -3064,9 +3070,8 @@ static int ip_vs_info_seq_show(struct seq_file *seq, =
void *v)=0A=
 		}=0A=
 =0A=
 		if (svc->flags & IP_VS_SVC_F_PERSISTENT)=0A=
-			seq_printf(seq, "persistent %d %08X\n",=0A=
-				svc->timeout,=0A=
-				ntohl(svc->netmask));=0A=
+			seq_printf(seq, "persistent %lu %08X\n",=0A=
+				   svc->timeout, ntohl(svc->netmask));=0A=
 		else=0A=
 			seq_putc(seq, '\n');=0A=
 =0A=
@@ -3365,36 +3370,38 @@ static int ip_vs_set_timeout(struct netns_ipvs *ipv=
s, struct ip_vs_timeout_user=0A=
 		  u->udp_timeout);=0A=
 =0A=
 #ifdef CONFIG_IP_VS_PROTO_TCP=0A=
-	if (u->tcp_timeout < 0 || u->tcp_timeout > (INT_MAX / HZ) ||=0A=
-	    u->tcp_fin_timeout < 0 || u->tcp_fin_timeout > (INT_MAX / HZ)) {=0A=
+	if (u->tcp_timeout < 0 ||=0A=
+	    u->tcp_timeout > IP_VS_TIMEOUT_MAX_SECS ||=0A=
+	    u->tcp_fin_timeout < 0 ||=0A=
+	    u->tcp_fin_timeout > IP_VS_TIMEOUT_MAX_SECS) {=0A=
 		return -EINVAL;=0A=
 	}=0A=
 #endif=0A=
 =0A=
 #ifdef CONFIG_IP_VS_PROTO_UDP=0A=
-	if (u->udp_timeout < 0 || u->udp_timeout > (INT_MAX / HZ))=0A=
+	if (u->udp_timeout < 0 || u->udp_timeout > IP_VS_TIMEOUT_MAX_SECS)=0A=
 		return -EINVAL;=0A=
 #endif=0A=
 =0A=
 #ifdef CONFIG_IP_VS_PROTO_TCP=0A=
 	if (u->tcp_timeout) {=0A=
 		pd =3D ip_vs_proto_data_get(ipvs, IPPROTO_TCP);=0A=
-		pd->timeout_table[IP_VS_TCP_S_ESTABLISHED]=0A=
-			=3D u->tcp_timeout * HZ;=0A=
+		pd->timeout_table[IP_VS_TCP_S_ESTABLISHED] =3D=0A=
+			ip_vs_timeout_ticks(u->tcp_timeout);=0A=
 	}=0A=
 =0A=
 	if (u->tcp_fin_timeout) {=0A=
 		pd =3D ip_vs_proto_data_get(ipvs, IPPROTO_TCP);=0A=
-		pd->timeout_table[IP_VS_TCP_S_FIN_WAIT]=0A=
-			=3D u->tcp_fin_timeout * HZ;=0A=
+		pd->timeout_table[IP_VS_TCP_S_FIN_WAIT] =3D=0A=
+			ip_vs_timeout_ticks(u->tcp_fin_timeout);=0A=
 	}=0A=
 #endif=0A=
 =0A=
 #ifdef CONFIG_IP_VS_PROTO_UDP=0A=
 	if (u->udp_timeout) {=0A=
 		pd =3D ip_vs_proto_data_get(ipvs, IPPROTO_UDP);=0A=
-		pd->timeout_table[IP_VS_UDP_S_NORMAL]=0A=
-			=3D u->udp_timeout * HZ;=0A=
+		pd->timeout_table[IP_VS_UDP_S_NORMAL] =3D=0A=
+			ip_vs_timeout_ticks(u->udp_timeout);=0A=
 	}=0A=
 #endif=0A=
 	return 0;=0A=
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_pr=
oto.c=0A=
index 0046aed1fb38..3796cd93c028 100644=0A=
--- a/net/netfilter/ipvs/ip_vs_proto.c=0A=
+++ b/net/netfilter/ipvs/ip_vs_proto.c=0A=
@@ -185,8 +185,8 @@ void ip_vs_protocol_timeout_change(struct netns_ipvs *i=
pvs, int flags)=0A=
 }=0A=
 =0A=
 =0A=
-int *=0A=
-ip_vs_create_timeout_table(int *table, int size)=0A=
+unsigned long *=0A=
+ip_vs_create_timeout_table(const unsigned long *table, size_t size)=0A=
 {=0A=
 	return kmemdup(table, size, GFP_KERNEL);=0A=
 }=0A=
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_=
vs_proto_sctp.c=0A=
index fb8af6b15a39..7e447b99d94c 100644=0A=
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c=0A=
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c=0A=
@@ -327,7 +327,7 @@ static const __u8 sctp_states=0A=
 #define IP_VS_SCTP_MAX_RTO	((60 + 1) * HZ)=0A=
 =0A=
 /* Timeout table[state] */=0A=
-static const int sctp_timeouts[IP_VS_SCTP_S_LAST + 1] =3D {=0A=
+static const unsigned long sctp_timeouts[IP_VS_SCTP_S_LAST + 1] =3D {=0A=
 	[IP_VS_SCTP_S_NONE]			=3D 2 * HZ,=0A=
 	[IP_VS_SCTP_S_INIT1]			=3D (0 + 3 + 1) * HZ,=0A=
 	[IP_VS_SCTP_S_INIT]			=3D IP_VS_SCTP_MAX_RTO,=0A=
@@ -552,8 +552,8 @@ static int sctp_app_conn_bind(struct ip_vs_conn *cp)=0A=
 static int __ip_vs_sctp_init(struct netns_ipvs *ipvs, struct ip_vs_proto_d=
ata *pd)=0A=
 {=0A=
 	ip_vs_init_hash_table(ipvs->sctp_apps, SCTP_APP_TAB_SIZE);=0A=
-	pd->timeout_table =3D ip_vs_create_timeout_table((int *)sctp_timeouts,=0A=
-							sizeof(sctp_timeouts));=0A=
+	pd->timeout_table =3D=0A=
+		ip_vs_create_timeout_table(sctp_timeouts, sizeof(sctp_timeouts));=0A=
 	if (!pd->timeout_table)=0A=
 		return -ENOMEM;=0A=
 	return 0;=0A=
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_v=
s_proto_tcp.c=0A=
index fec0e8b47b71..923405b65a33 100644=0A=
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c=0A=
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c=0A=
@@ -326,7 +326,7 @@ static const int tcp_state_off[IP_VS_DIR_LAST] =3D {=0A=
 /*=0A=
  *	Timeout table[state]=0A=
  */=0A=
-static const int tcp_timeouts[IP_VS_TCP_S_LAST+1] =3D {=0A=
+static const unsigned long tcp_timeouts[IP_VS_TCP_S_LAST + 1] =3D {=0A=
 	[IP_VS_TCP_S_NONE]		=3D	2*HZ,=0A=
 	[IP_VS_TCP_S_ESTABLISHED]	=3D	15*60*HZ,=0A=
 	[IP_VS_TCP_S_SYN_SENT]		=3D	2*60*HZ,=0A=
@@ -665,8 +665,8 @@ void ip_vs_tcp_conn_listen(struct ip_vs_conn *cp)=0A=
 static int __ip_vs_tcp_init(struct netns_ipvs *ipvs, struct ip_vs_proto_da=
ta *pd)=0A=
 {=0A=
 	ip_vs_init_hash_table(ipvs->tcp_apps, TCP_APP_TAB_SIZE);=0A=
-	pd->timeout_table =3D ip_vs_create_timeout_table((int *)tcp_timeouts,=0A=
-							sizeof(tcp_timeouts));=0A=
+	pd->timeout_table =3D=0A=
+		ip_vs_create_timeout_table(tcp_timeouts, sizeof(tcp_timeouts));=0A=
 	if (!pd->timeout_table)=0A=
 		return -ENOMEM;=0A=
 	pd->tcp_state_table =3D tcp_states;=0A=
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_v=
s_proto_udp.c=0A=
index f32785682402..b4de47f8273e 100644=0A=
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c=0A=
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c=0A=
@@ -396,7 +396,7 @@ static int udp_app_conn_bind(struct ip_vs_conn *cp)=0A=
 }=0A=
 =0A=
 =0A=
-static const int udp_timeouts[IP_VS_UDP_S_LAST+1] =3D {=0A=
+static const unsigned long udp_timeouts[IP_VS_UDP_S_LAST + 1] =3D {=0A=
 	[IP_VS_UDP_S_NORMAL]		=3D	5*60*HZ,=0A=
 	[IP_VS_UDP_S_LAST]		=3D	2*HZ,=0A=
 };=0A=
@@ -432,8 +432,8 @@ udp_state_transition(struct ip_vs_conn *cp, int directi=
on,=0A=
 static int __udp_init(struct netns_ipvs *ipvs, struct ip_vs_proto_data *pd=
)=0A=
 {=0A=
 	ip_vs_init_hash_table(ipvs->udp_apps, UDP_APP_TAB_SIZE);=0A=
-	pd->timeout_table =3D ip_vs_create_timeout_table((int *)udp_timeouts,=0A=
-							sizeof(udp_timeouts));=0A=
+	pd->timeout_table =3D=0A=
+		ip_vs_create_timeout_table(udp_timeouts, sizeof(udp_timeouts));=0A=
 	if (!pd->timeout_table)=0A=
 		return -ENOMEM;=0A=
 	return 0;=0A=
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_syn=
c.c=0A=
index 157f5c8361ab..175b842cdfec 100644=0A=
--- a/net/netfilter/ipvs/ip_vs_sync.c=0A=
+++ b/net/netfilter/ipvs/ip_vs_sync.c=0A=
@@ -847,7 +847,7 @@ static void ip_vs_proc_conn(struct netns_ipvs *ipvs, st=
ruct ip_vs_conn_param *pa=0A=
 			    unsigned int flags, unsigned int state,=0A=
 			    unsigned int protocol, unsigned int type,=0A=
 			    const union nf_inet_addr *daddr, __be16 dport,=0A=
-			    unsigned long timeout, __u32 fwmark,=0A=
+			    unsigned int timeout, __u32 fwmark,=0A=
 			    struct ip_vs_sync_conn_options *opt)=0A=
 {=0A=
 	struct ip_vs_dest *dest;=0A=
@@ -939,9 +939,7 @@ static void ip_vs_proc_conn(struct netns_ipvs *ipvs, st=
ruct ip_vs_conn_param *pa=0A=
 	 *  - No problem.=0A=
 	 */=0A=
 	if (timeout) {=0A=
-		if (timeout > MAX_SCHEDULE_TIMEOUT / HZ)=0A=
-			timeout =3D MAX_SCHEDULE_TIMEOUT / HZ;=0A=
-		cp->timeout =3D timeout*HZ;=0A=
+		cp->timeout =3D ip_vs_timeout_ticks(timeout);=0A=
 	} else {=0A=
 		struct ip_vs_proto_data *pd;=0A=
 =0A=
=0A=
base-commit: 734bef548a96e8774d6eef5dfa2026c6edc4e80b=0A=
-- =0A=
2.43.0=0A=
=0A=
