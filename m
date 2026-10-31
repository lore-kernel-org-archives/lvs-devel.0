Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=52.103.20.0
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1793430906;
	b=MDuooPaZOk4OJ3nNUy8++LXpIHD8vJ0EZ7mXsNf0csJUH2cn/8e4fekTZRPdj4R/aNoV
	 Zkslca6+6wii5KN0LfGzoAxjaoHu57SNBXMCHE65XKs7I7U18r+kstpxnoTji9s1Wmt1b
	 q/lBnIPkyZMH6faS0i0KZ0+BG9hiLTGe5QUPQAZwJDRvjiy14wYlN3B8K3JzNOkRib+ld
	 2fkrgUsFYT7lHMW2vtwgxny1nIAi7jtV5amuDN+uhmzVzSao54mvjehimxZE8Vk8a782h
	 xow/tWxOTScy9GrKAay5HcfMBS65Gn59Z9Hh9/QjZbHukuO7eTNc7DpUwQ1aYbOdL+Q==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793430906;
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
	bh=iwTbLKKB0FXtTquVDPBygpbHylUcKBmPr4bwM4ZIhtM=;
	b=43E30FGjfQuScgfa4tmQb850nvJQ2IFAJETXwJVWyVjck8mF0xAvQ9i+cMAHexIRKHe9
	 8Ud3wWeQaAikdpM2V2hf3UV4b/1JjopN0Gq94ggQ3ylWghlBPHgxmdX2hDAwXke9DbORi
	 e8yo9sNRAOi7q6gM+G7DXegMvlnCZZE1He81snbF3EfLjbZMd4r8WhlbobQX4qQX4RMEh
	 GWwuznN7+AUD7EOMTVTJJeUxpStVJ2i7RHGgjNXItyNbziiIWFjRMKYLhDdeXuOdvIiZ9
	 QhLE5raH0C6OkLmp3er7hlcO7rHhA9xAtJzNuAZVse/Uv6ahv36dTUxYqfg1DYFW5Bw==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=outlook.com;
	spf=pass smtp.mailfrom=outlook.com;
	dkim=pass header.d=outlook.com header.i=@outlook.com header.a=rsa-sha256 header.s=selector1 header.b=Lnige2OC;
	arc=pass header.oldest-pass=0 smtp.remote-ip=52.103.20.0
Received: from CH1PR05CU001.outbound.protection.outlook.com (mail-northcentralusazolkn19010000.outbound.protection.outlook.com [52.103.20.0])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (secp384r1) server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C98AD606A31E;
	Sat, 31 Oct 2026 07:15:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C98AD606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=outlook.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=outlook.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=outlook.com header.i=@outlook.com header.a=rsa-sha256 header.s=selector1 header.b=Lnige2OC
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=xkRMKd3ueFJdCj7WWRz6XG4bXnSlTLHgv6eEAjkZNXRX7LzaydeYTtzt7VUjLAE065E0lDc8rJ3QobRtPfr4VTxj5ytFKkd050BhHxmhUqgw1xGRGljuuAbEJgQPKMvsI9HIVpN8lYxKivLy4guH80G9pTpHYN95nhA+O/j94b7KP7F8++DCp8/HFbtea/j6V2reCVBukNnVRQSh0A8Q6zImHKm5PLdDrBPzZulA7rijldGNkytwdI+K6Qw91HSXQEVWu4+e7zrUPcr06a2gvAz8bWycoP4qfi66ePDAR9glsXkla3VK4L9WvLltLYpm9FoLMEsaqeTwOCYNfDxjdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001; h=From:Date:Subject:Message-ID:MIME-Version;
 bh=iwTbLKKB0FXtTquVDPBygpbHylUcKBmPr4bwM4ZIhtM=;
 b=fb8RL2UQIa+4FEG0MRPOUzOhXR4OAzuhLhvk3Mz5eQ/HH06X6UlOA8ARrksmv9QEejy0CqizkQs5se8xHFzsIu1n0sh98DApDAguSt1LjT0TqVtOzL8Fi868DQ9xxGePM5HI2TKTV7AsBaWLYJZUVFhL0GieDOAhfJjIBpZLL9UtFzbTPWoR3Hq3tRFvZcCwHdzeBWtiLeyhtrDF16sCaPX1SXPVpZ5snvvtAH/Z0b5s1CroSgJ0ou/TtMuEfe11MVHTlx9cwDttmqvoIsNNdpEx6XToDTn1Rlkp7heMiqv/eXomyFbahZBSNMMTnU6WcDXO9mvRY9qtUoDK0LnXGQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=none; dmarc=none;
 dkim=none; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=outlook.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=iwTbLKKB0FXtTquVDPBygpbHylUcKBmPr4bwM4ZIhtM=;
 b=Lnige2OCFq7LmobityNvs+19VfeVW7idd6x1lJrZcf5aCat16KtKaPmnRHVXTpM6UUCzick6mAsoQH84Ey1G1+qIUWyc8xE/6cnUiTy3ixUc3Sjp6DBJKTF+cB632iQPj7aRZ975A2TJDOEnMcAWB9JF0BLNq60zQpg6sDIdaB9QJi65w5VtXedU2+orbCCKk8ZwaCODNSY2AJK74VYi6cgB8FeOk2s2aVUKYjo2835IV4FNaKcYhT0tGOQGKnpvuiqMMD9hXVjaFE4XK5lHfv7pn2PFAhPGJvzj3Wldcg08fx1jSUNzIwftUXaW9gnmvTm9+VfNW3T31a5r1q6DZQ==
Received: from SA3PR05MB10385.namprd05.prod.outlook.com
 (2603:10b6:806:39d::17) by DS3PR05MB998472.namprd05.prod.outlook.com
 (2603:10b6:8:347::16) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.569.11; Sat, 31 Oct
 2026 07:15:02 +0000
Received: from SA3PR05MB10385.namprd05.prod.outlook.com
 ([fe80::e22f:a0f5:fcb0:9b0d]) by SA3PR05MB10385.namprd05.prod.outlook.com
 ([fe80::e22f:a0f5:fcb0:9b0d%6]) with mapi id 15.21.0569.009; Sat, 31 Oct 2026
 07:15:02 +0000
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
Subject: [PATCH nf] ipvs: avoid wrapping persistent service timeouts
Thread-Topic: [PATCH nf] ipvs: avoid wrapping persistent service timeouts
Thread-Index: AQHdaQeL/AXiqOgATESGwGnp87Bw1A==
Date: Sat, 31 Oct 2026 07:15:01 +0000
Message-ID:
 <4f420fda8690ac470be44b3da284b65501c77bb5.1793430892.git.x-professor@outlook.com>
Accept-Language: en-US, zh-CN
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: SA3PR05MB10385:EE_|DS3PR05MB998472:EE_
x-ms-office365-filtering-correlation-id: 94770a04-f803-41e2-060c-08df371eae1e
x-microsoft-antispam:
 BCL:0;ARA:14566002|31061999003|19110799012|8060799015|8062599012|24021099003|25010399006|4140399003|38102599003|15080799012|24121999003|22091999003|41001999006|16041099003|53005399003|40105399003|26121999007|102099032|3412199025|440099028;
x-microsoft-antispam-message-info:
 =?iso-8859-1?Q?01SMxDF7RBXb5oherXraFLqXQgm0WjMszbjQEDERrMvxtJdLY/KTydB189?=
 =?iso-8859-1?Q?gDKCB0sHKHDM9KoxJAwLPRPwMARf6fIMWgKEr+xzDBSSnTSzpd3jOJHqai?=
 =?iso-8859-1?Q?ysrsCsHu9apEi+KVqjc5ul6ni/lP0E6tZTsE8ZLI5rzKK57V36dd93o4oB?=
 =?iso-8859-1?Q?STGVn/+117I1jUMQY1XkblUvECrnaMhL6yyp/eX36fjljxsKxqtSjTFj+J?=
 =?iso-8859-1?Q?KIPk+CE2GekmwHo0fyBjffPGvKyiaPr4gVNltboUJrJe5SIQcegDjT2RtW?=
 =?iso-8859-1?Q?+KBcBU5vNFrfJHOslaqj9dlqqQsg25Elq+UMohPSBqVUluKfs4ltxHutta?=
 =?iso-8859-1?Q?2Rxp3SsedoWT5dgOLW6Sz59EkAZErvH+M96KqsX0GZ2p9VwjtfswIb8gS8?=
 =?iso-8859-1?Q?nF5XfdyYpyyKuAqWwBj+tfKnEVCsu1cYci4X2assEnCteDGMkNPL675WZu?=
 =?iso-8859-1?Q?gPMS0msTXZH+nOA667Lb9tXhVDXMo86rV8XxHPt8o2z0Hk0sqiwbLu0nrv?=
 =?iso-8859-1?Q?qiIZPQ0LXIBErriqCz4aohHZrQo1rlLpPJdnFRmsT99r+4Egc3K1IZDY/U?=
 =?iso-8859-1?Q?lQ5ZG6ZqWGIQ0t3UHGeiDCwssJroRRy2a8fyHJWbaJshqj0nt/DCcEjyzY?=
 =?iso-8859-1?Q?zHvgX8u5CQYlX7XnyCgSRZWQ/xgZJiodzVpBoALn5oZuxxYnZIyo52/WQ7?=
 =?iso-8859-1?Q?dv+be8CwAYchs0qF4Uk+XEo2PlccYuYcew0Mj5DZqZfQNtgbQt61u61vZR?=
 =?iso-8859-1?Q?zBiK/0ksTDuUvBAilUSqRgBEnki9nXU0lTR3QPCabRHOxnPeYaMlAxulTq?=
 =?iso-8859-1?Q?6119LleANX35EyVSLiklwSrerGaJyEb+GM4790CkjqFvc+cHltPUFg5EOr?=
 =?iso-8859-1?Q?ywXSjJY8qLBKmPNLrw+N6gsEkj20AuZX3lLxBlJrk6NnWRL4G24qIc4jhJ?=
 =?iso-8859-1?Q?EWvDQyaRikpr24Pdz7fqt+O+fSxmtCeDmdV4nPE7nCYCt+cf9B0G4tco9R?=
 =?iso-8859-1?Q?wycws/P6r9/EkNKFgqiSqkLYdbnakMwZSKnwEHtuz3SOKu1SHqvR4hByqK?=
 =?iso-8859-1?Q?X7pOs611swGhrmXwkcQ0wWdhAWoUrCoqpMTb1YbikbhSxDGYO2H5aPxAk2?=
 =?iso-8859-1?Q?fc/X3eobllIgPcCjYiGtT141lrpwLLCZ7HACGjkchjqgf64bSY?=
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0:
 =?iso-8859-1?Q?I+OJv8EhE4KyApttztgw7nBPMwnLTbGGRFCPmwogzRWq4qZnjBRu1kvrX0?=
 =?iso-8859-1?Q?b2o93BoCUzmwHJoiYNgpuyu2GN1x2WoUvpHV7WhymGFwdMyzIUxW87w40a?=
 =?iso-8859-1?Q?oUSAXQVLzz9jJcXb9mxusTIHzauXuq3S0FWpTMyNjQQ+rg2PmqpHQjYDcw?=
 =?iso-8859-1?Q?4XmN60SLsypXnHxfw6KmO5EfkrnprS1b72VYavW2TsTeSR4s01BF36oX7N?=
 =?iso-8859-1?Q?1996PsQWN9Gg0fS4s98pug+SRLDGd9aau5zxMmnfnho2RsRSdT2OVNSx6W?=
 =?iso-8859-1?Q?baBmXQLSSWNn2854tqKAg1GXsqxmcFV5PcvdKECvgGJutkf+93/kVELa6u?=
 =?iso-8859-1?Q?rV4SttRA1llyhfVoClqVXgVIR+Rp4yd60c+mId/g7HusDT6s0dtTvJmWlV?=
 =?iso-8859-1?Q?OZOdmsCA6RcK+z96jBBziW5YkGwd7HS1bGYIzwTbovszsQpMY9YfATDLoN?=
 =?iso-8859-1?Q?vISL/He/KBnrkUwtRHENRNRfQvhcG3Ik7N0t2wXVWliM66m8AbZkLbMTLq?=
 =?iso-8859-1?Q?NdP/m2IlqbRaC0SrE62ajp15wjW6t9qmG8ZEU9rh6DRpZv6j9JdOMqepFL?=
 =?iso-8859-1?Q?16ENYaOBY+S8+cXn0xCKaFCxHrPDkuA4/KMtoZIaxyBHsEMhIPQTcbNTKb?=
 =?iso-8859-1?Q?fB7Ao07GJgslp6BtcVQrmd0rQA9hRLE5eDQvgjCN046L4Nwhf+tNcoDWPX?=
 =?iso-8859-1?Q?IBth48vem8Y37K1HbeSNLZvl72VzDuOubzj0Xz0sIkUlEynPv6ncwbSulx?=
 =?iso-8859-1?Q?Y5ImowtmeQTyYbQRYfguAffhvJnkc4b5UWRuRtBid08PlnqTjknoqvjqhj?=
 =?iso-8859-1?Q?NOBgZpbhDkH9niQYuQ/wcJ7r7YWxARD5EBuVUbBoErth1+sSOTy+qziBWZ?=
 =?iso-8859-1?Q?gmKnf0LcPNBMMIM2c2k5HSal0dWNtS1vndcia6EEqshHxSNUIq7Blaf4dT?=
 =?iso-8859-1?Q?f2aMzsBRCg53+SjLWabn2/Toi9NBc/dcPHNd8H8dzROcp30bngeLgmazJb?=
 =?iso-8859-1?Q?qQ9B+FEoUi89BdgbhMKyikRkfswh563h8FosHtK/o6nNA5MHglMZUsycB9?=
 =?iso-8859-1?Q?0gAxJufTzU2bTAriC7E7s2gi05S3jGKLP5MSUIiErgpBTfdnHCL1st3PcA?=
 =?iso-8859-1?Q?ARqUtP+pGXQeAap6xRc9hNdcHW0G1uehKhGACmqaC2Afr0Mubt457wrGjt?=
 =?iso-8859-1?Q?ztdlw/X9Kqerb1YrdMHfPV6P1dXrl5ISO90eKR/m+D+1hM9FjSj5LdQQpr?=
 =?iso-8859-1?Q?6W3Fn0wWD1CfwtwT5is47+bsK40GkkEx0Y+gzXH/XBKFCJCIpRF2Qxi41/?=
 =?iso-8859-1?Q?KGat5Nuh7ErW3qavHlrm15ZdBr/u81iPGbTErGt5q+EPHrO8sK/B2AgCUA?=
 =?iso-8859-1?Q?uxIT7C30T71lQDr80i3hr82aCKQjgxubUwDWxvxCuRni49rwrFduAF3nce?=
 =?iso-8859-1?Q?9wEvLWe7NDtCtShd?=
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
X-MS-Exchange-CrossTenant-Network-Message-Id: 94770a04-f803-41e2-060c-08df371eae1e
X-MS-Exchange-CrossTenant-originalarrivaltime: 31 Oct 2026 07:15:01.9185
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 84df9e7f-e9f6-40af-b435-aaaaaaaaaaaa
X-MS-Exchange-CrossTenant-rms-persistedconsumerorg: 00000000-0000-0000-0000-000000000000
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DS3PR05MB998472

ip_vs_add_service() and ip_vs_edit_service() convert the persistent=0A=
timeout from seconds to jiffies with u->timeout * HZ. Both operands are=0A=
unsigned int and the value comes unchecked from the socket API or from=0A=
IPVS_SVC_ATTR_TIMEOUT, so timeouts above UINT_MAX / HZ wrap.=0A=
=0A=
With HZ=3D1000, 4294968 seconds becomes 704 jiffies and is reported back=0A=
as 0 seconds. Persistence templates copy svc->timeout, so their timer is=0A=
armed for 0.7 seconds and a client can be moved to another real server=0A=
long before the configured timeout.=0A=
=0A=
A related boundary exists on 32-bit kernels. Some products that fit in=0A=
unsigned int exceed the maximum safe jiffy delay. For example, 4294967=0A=
seconds becomes 4294967000 jiffies with HZ=3D1000. Adding that delay to=0A=
jiffies wraps, and the timer code can treat the result as already expired.=
=0A=
=0A=
Limit the seconds value using both the storage width and=0A=
MAX_JIFFY_OFFSET before multiplying by HZ. Saturate out-of-range values=0A=
instead of rejecting requests that previously succeeded. Also print the=0A=
stored unsigned timeout with %u in /proc/net/ip_vs, since a valid stored=0A=
value can exceed INT_MAX.=0A=
=0A=
The overflow was reproduced in an x86-64 QEMU guest (HZ=3D1000) through=0A=
the IPVS socket API. A persistent one-packet UDP service with two real=0A=
servers was set to 4294968 seconds, and a client in another network=0A=
namespace sent two datagrams 1.5 seconds apart. On the base kernel the=0A=
template expired between the datagrams, as it did for a 1-second=0A=
control, and the second datagram went to the other real server. With=0A=
this change the template remained present and both datagrams went to the=0A=
same server. The 300-second control was unchanged.=0A=
=0A=
Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")=0A=
Signed-off-by: Yingjie Wang <x-professor@outlook.com>=0A=
---=0A=
=0A=
Notes:=0A=
    ip_vs_set_timeout() rejects global TCP/UDP timeouts above INT_MAX / HZ=
=0A=
    with -EINVAL. This path saturates instead because the persistent timeou=
t=0A=
    is a __u32 whose full range has always been accepted. Saturation avoids=
=0A=
    adding a new error result while keeping the stored delay within both th=
e=0A=
    storage width and the safe jiffy range.=0A=
=0A=
 net/netfilter/ipvs/ip_vs_ctl.c | 19 ++++++++++++++-----=0A=
 1 file changed, 14 insertions(+), 5 deletions(-)=0A=
=0A=
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.=
c=0A=
index ce9fe20d6106a..0d4a113eb5a7f 100644=0A=
--- a/net/netfilter/ipvs/ip_vs_ctl.c=0A=
+++ b/net/netfilter/ipvs/ip_vs_ctl.c=0A=
@@ -1749,6 +1749,15 @@ static void ip_vs_dest_trash_expire(struct timer_lis=
t *t)=0A=
 	spin_unlock(&ipvs->dest_trash_lock);=0A=
 }=0A=
 =0A=
+/* Convert seconds without overflowing or exceeding a safe jiffy delay. */=
=0A=
+static unsigned int ip_vs_svc_timeout(unsigned int timeout)=0A=
+{=0A=
+	unsigned long max_secs;=0A=
+=0A=
+	max_secs =3D min_t(unsigned long, UINT_MAX, MAX_JIFFY_OFFSET) / HZ;=0A=
+	return min_t(unsigned long, timeout, max_secs) * HZ;=0A=
+}=0A=
+=0A=
 /*=0A=
  *	Add a service into the service hash table=0A=
  */=0A=
@@ -1864,7 +1873,7 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_=
vs_service_user_kern *u,=0A=
 	svc->port =3D u->port;=0A=
 	svc->fwmark =3D u->fwmark;=0A=
 	svc->flags =3D u->flags & ~IP_VS_SVC_F_HASHED;=0A=
-	svc->timeout =3D u->timeout * HZ;=0A=
+	svc->timeout =3D ip_vs_svc_timeout(u->timeout);=0A=
 	svc->netmask =3D u->netmask;=0A=
 	svc->ipvs =3D ipvs;=0A=
 =0A=
@@ -2031,7 +2040,7 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct =
ip_vs_service_user_kern *u)=0A=
 	 * Set the flags and timeout value=0A=
 	 */=0A=
 	svc->flags =3D u->flags | IP_VS_SVC_F_HASHED;=0A=
-	svc->timeout =3D u->timeout * HZ;=0A=
+	svc->timeout =3D ip_vs_svc_timeout(u->timeout);=0A=
 	svc->netmask =3D u->netmask;=0A=
 =0A=
 	old_pe =3D rcu_dereference_protected(svc->pe, 1);=0A=
@@ -3064,9 +3073,9 @@ static int ip_vs_info_seq_show(struct seq_file *seq, =
void *v)=0A=
 		}=0A=
 =0A=
 		if (svc->flags & IP_VS_SVC_F_PERSISTENT)=0A=
-			seq_printf(seq, "persistent %d %08X\n",=0A=
-				svc->timeout,=0A=
-				ntohl(svc->netmask));=0A=
+			seq_printf(seq, "persistent %u %08X\n",=0A=
+				   svc->timeout,=0A=
+				   ntohl(svc->netmask));=0A=
 		else=0A=
 			seq_putc(seq, '\n');=0A=
 =0A=
=0A=
base-commit: 734bef548a96e8774d6eef5dfa2026c6edc4e80b=0A=
-- =0A=
2.43.0=0A=
=0A=
