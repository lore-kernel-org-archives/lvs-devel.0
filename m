Received: from esa12.fujitsucc.c3s2.iphmx.com (esa12.fujitsucc.c3s2.iphmx.com [216.71.156.125])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4620B101EC;
	Thu, 27 Jun 2024 02:58:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=216.71.156.125
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1719457127; cv=fail; b=JDe/YOhVSMILHyaaWm+J9OFBY3EwWrZh7itmYqGnem8wZ+wV5Cd+E59hY89bSNAwKqNgc/qK2kkgslfQXCeiGw0ifgor0NlKzlebwV4uZYYqnU7o74n0SIhC61vhbWpTO03tPwqI6zaPEh0kOWDJH3eXNds7Fj+bYmegIvC810Y=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1719457127; c=relaxed/simple;
	bh=PPnhEqqzwaz4cQBzWgDdMNnXIfU48P068NekKaZ+byk=;
	h=From:To:CC:Subject:Date:Message-ID:References:In-Reply-To:
	 Content-Type:MIME-Version; b=h22EBsN3I4EU/B2jX1jNPywWgdPVem3kPvkYYcc61IaDy8Yz+VhxYfXhaf1ilVe0VXbsXnrdzerCNQ/KWv4TG3cM3z70dN/dxyrpSv6T/UgqNWe/999Ec+f1WW2pgXgnbIcvIRv7ywSC2IAwds+kAfo1kcbHW1C9qjdkVvtv8X0=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=fujitsu.com; spf=pass smtp.mailfrom=fujitsu.com; dkim=pass (2048-bit key) header.d=fujitsu.com header.i=@fujitsu.com header.b=C70sNohK; arc=fail smtp.client-ip=216.71.156.125
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=fujitsu.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=fujitsu.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=fujitsu.com header.i=@fujitsu.com header.b="C70sNohK"
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=fujitsu.com; i=@fujitsu.com; q=dns/txt; s=fj1;
  t=1719457125; x=1750993125;
  h=from:to:cc:subject:date:message-id:references:
   in-reply-to:content-transfer-encoding:mime-version;
  bh=PPnhEqqzwaz4cQBzWgDdMNnXIfU48P068NekKaZ+byk=;
  b=C70sNohKWWeXO0Wvk6t3SqnwaqX34kmpEd866YJxwQ82Q5ySCvKJ/clR
   TZuunR4Iu0g+vULSod5eORxez+1jAvGyIZJz5KVFaQx4kgSgW+5xABaGZ
   PA2GXAaVTMlPfOt/zN3uHI4sqmuioSetiDgPxjyjCI6zW26EJtrYSmrlL
   59FUJgQ0NotVCP4BrsE8zKNQefSl8D5645p5mLbSJ2DZ9gE57KbTmmDhT
   h7zk13M15p1JVpTUHxdooTOy1T0sGp29/8dbnVNA4bEVaF/Eh2eo83gDn
   l6MsdhYY7hyUEGFmdJSFTNAdsEeG0hlCtq++nakiSC+crp8D2h9axYbfp
   A==;
X-IronPort-AV: E=McAfee;i="6700,10204,11115"; a="123691831"
X-IronPort-AV: E=Sophos;i="6.08,268,1712588400"; 
   d="scan'208";a="123691831"
Received: from mail-tycjpn01lp2168.outbound.protection.outlook.com (HELO JPN01-TYC-obe.outbound.protection.outlook.com) ([104.47.23.168])
  by ob1.fujitsucc.c3s2.iphmx.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 27 Jun 2024 11:57:31 +0900
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=iemPYmTKSLQS9hc/dYKHNFsHEMg1+9Ci1/dQ7SSR5FTjIXvXn/RKSSCywkprRA4pn6gjMoGnGQDujluYEC0aquW75cuzwqjS/alzfKU0ivdEaTOgcF3J/obWfnJQ4qeK+2N7V8ZqLGx08baGofJ/BHhOw35XW6OEGpouQi+Jq7rwC21ahtBx8jxGzpjiFV4Tt1SWCZMHAGnM4CR4V3223VWvoVgLBaZHxyn2FiA2145yPiOjOsjnNGJJaT0QctnlAIOAw6zLryQWgdM8Xad9bmcNzPxCXHIcb7rcYlbvK35Oa7lLmCn4SUOo2iPsZlMLvPcgipn5hdORJ2QkfdfKbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=PPnhEqqzwaz4cQBzWgDdMNnXIfU48P068NekKaZ+byk=;
 b=PxxyRtI/7F2MFuYUyHR3KeBz1o3o1goj/tMP9u4lfvagZ208LojfNXRjdfeU0dR+siM1ZgpcZgwXDUPJ8YrKEEU+tSbDHLGpU2OILAtNTa394pH1H+HV9wQbYhzIG5ZfsnzKLj5H+WweIj1RCh5bJmJbaKdoPw5kLMhJOqJUNtj7HAcK/n4XaUvDP/bk05f0dyQkbwGM59lyL9Xg27h3b2RQKpjURJEumU8rGiGA8QWZ2DftQNtDT4vZ2oQbXikE2oT+1RxzeQFcQ1iySeIqdXrPtEzfs3oT398Zyi4mI91Uc70zQ/chUH7g1hu0c2dOMnC8iaYItTsYUm512oPOBA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fujitsu.com; dmarc=pass action=none header.from=fujitsu.com;
 dkim=pass header.d=fujitsu.com; arc=none
Received: from TYWPR01MB12085.jpnprd01.prod.outlook.com (2603:1096:400:447::5)
 by TY3PR01MB11113.jpnprd01.prod.outlook.com (2603:1096:400:3d1::9) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.7698.32; Thu, 27 Jun
 2024 02:57:27 +0000
Received: from TYWPR01MB12085.jpnprd01.prod.outlook.com
 ([fe80::c7ba:1496:7444:dfe3]) by TYWPR01MB12085.jpnprd01.prod.outlook.com
 ([fe80::c7ba:1496:7444:dfe3%7]) with mapi id 15.20.7698.033; Thu, 27 Jun 2024
 02:57:27 +0000
From: "Hanxiao Chen (Fujitsu)" <chenhx.fnst@fujitsu.com>
To: Julian Anastasov <ja@ssi.bg>
CC: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso
	<pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, "David S .
 Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Jakub
 Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
Subject:
 =?gb2312?B?u9i4tDogW1BBVENIIG5ldC1uZXh0XSBpcHZzOiBwcm9wZXJseSBkZXJlZmVy?=
 =?gb2312?B?ZW5jZSBwZSBpbiBpcF92c19hZGRfc2VydmljZQ==?=
Thread-Topic: [PATCH net-next] ipvs: properly dereference pe in
 ip_vs_add_service
Thread-Index: AQHax/HkQ7DCYIv2d0yA9xp/3QMoyLHa6Jjg
Date: Thu, 27 Jun 2024 02:57:27 +0000
Message-ID:
 <TYWPR01MB120859EC748253B757BC413AAE6D72@TYWPR01MB12085.jpnprd01.prod.outlook.com>
References: <20240626081159.1405-1-chenhx.fnst@fujitsu.com>
 <721791d7-4070-a680-2dff-f56d10467494@ssi.bg>
In-Reply-To: <721791d7-4070-a680-2dff-f56d10467494@ssi.bg>
Accept-Language: zh-CN, en-US
Content-Language: zh-CN
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
msip_labels:
 MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_ActionId=d14f5455-650a-4c15-a0ff-8bd2b1a5941b;MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_ContentBits=0;MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_Enabled=true;MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_Method=Privileged;MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_Name=FUJITSU-PUBLIC?;MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_SetDate=2024-06-27T02:46:48Z;MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_SiteId=a19f121d-81e1-4858-a9d8-736e267fd4c7;
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=fujitsu.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: TYWPR01MB12085:EE_|TY3PR01MB11113:EE_
x-ms-office365-filtering-correlation-id: b5d32416-73bd-441a-0527-08dc9654e0c1
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam:
 BCL:0;ARA:13230040|366016|376014|7416014|1800799024|1580799027|38070700018;
x-microsoft-antispam-message-info:
 =?gb2312?B?aVpNcUJIWTBDTlpwbU5mdjlPQjRiZEFWOHRiT1dia1FQZVYzQXVuR3ZFcVdI?=
 =?gb2312?B?ejdNM2pNQVpOeGZ2STYrR3RRcmU3bUtYZnpMTEdkcXk2cXdLdEloOXN1UWhN?=
 =?gb2312?B?dE1qNUg2WDZOWFFwd0Z3V1ZhNjdFTzRsemtEd3krQ2E2OGVDTk0zU2ZwZlRJ?=
 =?gb2312?B?SVlFdEs5SytXbTZQYUxyaEY5Q0NsYnZXNmJhbWhpNUtYdXBKOEpNQXppTmkv?=
 =?gb2312?B?Y1VUNkdKSzRjRG5oNDU3TEVkbXpNaDJnZzlkcnJQUzZHNHk4Z003NmdNbWdr?=
 =?gb2312?B?ekNIWFRkQnNxYkVibStnaGVwZ095eUVCcyt4SHNudVJHd09zMjdrT0d2RTJO?=
 =?gb2312?B?cFc0aUx6dTNZdi9oNUdHY09PNFFEN2VCRlBKUHk3amlLWFF3aXdjZ0JCdDRr?=
 =?gb2312?B?ZGtZb3Z5YnBhQmc4STVqWFFzOStuZGFEdUU3UGE2aXdKc0owb0xhWnpUYjls?=
 =?gb2312?B?SlNZTERwVmlBNGo2Nm9DWjVzeS9NV1FiclVnR1BoWHJMYzJoSUs5MndEM2du?=
 =?gb2312?B?QnM2U0NIbGFaZHduTlZza20wanFhUi9WQytjbEdEOHVEc0x1UW4yZGF0NWw0?=
 =?gb2312?B?K1h3dDVuRlovMFZoSmZBcWoxeFFFejJGc3RPQ2ZVSzljVllodHFhMXI2cHpV?=
 =?gb2312?B?UXpBdGE5cEpzaUpUTENUWXlYRDZ0MmRUZWh3TVBLNm9UZjZPVmJraWV4RmxJ?=
 =?gb2312?B?QmpsMForNDNkMUpIZk9MZkpYdUFZdFlRemppQ2FoMjhpaGY5QlhlbXVYUENw?=
 =?gb2312?B?dG53WUp6aHNLY2FMS3cyaHZiVDUwY1Y1Zk1kV2lJakpMTW4rc1hVTWFRZHV5?=
 =?gb2312?B?aHUwOVVpbkpvb3M0YWs5QXhjYU43UmhiMjMzTjFPTVVkY0hGMzd4em5lbFc2?=
 =?gb2312?B?b0ZuTVJNcjkvM0pKUERaUlQ1clhlRDlScFBQVWdwSFFMTTIveitNNjR0cktV?=
 =?gb2312?B?Sll5VVVLZTZMY1o0RWJ2cjVOd2V1YnBNMWhXOE5tSmh3WlFiZGJGVi8wc1RD?=
 =?gb2312?B?UEdQdlZMaVZhaHJjN1pjNlVxY3FRdFp6WDVGaEFmUWhMeWo0RXBtLzc3Z1ls?=
 =?gb2312?B?Z2sxWUxSU2VqbEg3Ti9CeWZ4SExmTnhUY1BtYW9TdjYwSGlVY3JQaFIvMHJi?=
 =?gb2312?B?Q1dQMk56Um9kbzBTcWl1YnEwTXphMzhUMkhCdDYxaW9pSFA3OURJd2pGUGo5?=
 =?gb2312?B?S2RaZmNvbXJlZzF6T2RqWWhNb3RnZ3lZdHl6QnBrSnROOTN4YW0zaVRkRmwv?=
 =?gb2312?B?WXpXeG1MN0V4cXJ0S0w4UFJBaDdFcmdXTUdzeUk1M0xDMGRQWDE1NnFvT2hL?=
 =?gb2312?B?b1dGY0lrc1pTdFo5Q2RUQVpLN3gycXBmcGx2bkNycVMxQjlnME93aThpUGV5?=
 =?gb2312?B?R0FIMU44TVdZa2JLRDAwckZzZ1BhQ05PNTllaDRtZHhCbXlDTmRJaXgwQTYv?=
 =?gb2312?B?RVJyV0lVbmtPN0RUbmZWdVd6MzR4NGFsSjZWWVZ0OXlYWkx4WlN5MHYrems1?=
 =?gb2312?B?UEVqeG9pNWE5cjhVYmI5QjhWZk5CeWRJWVBhQXoxRWFCU2dtdDNZRjE4bVFv?=
 =?gb2312?B?aXZCbEZBQmpOU01tSkthVEN3NGM2WllCNTNadXJCRzlQVFFVZE9IM254ang0?=
 =?gb2312?B?SmR2b2dFRCsveGI1UmFUSkEva1Naa2szK1IvUktNMys5MHkySklKMFF3cmpi?=
 =?gb2312?B?NWlNWmdKYURqRzVjOHJieEJiNWVGSno5UklkZGpVRGs1NmlRTmpxSnBwSWNZ?=
 =?gb2312?B?a3VZL09LWEV0Ly84VTAySnlybW4rRUFocEovdjVYcng4UWNTcUhzRDZsQktj?=
 =?gb2312?B?V2Z0UEhiSGR4VE14VTkvZTdWQVJlUmErZTZ6RVZHeXBWRUFlcGsxM3h5Tm5X?=
 =?gb2312?B?QXpVbklLaGNLdFNoeFltM0Z4OHFjeHQ5SHo1eUVuMFBIbkxWVTVzOFlFV2dt?=
 =?gb2312?Q?8hKyW7v/YcY=3D?=
x-forefront-antispam-report:
 CIP:255.255.255.255;CTRY:;LANG:zh-cn;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:TYWPR01MB12085.jpnprd01.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(366016)(376014)(7416014)(1800799024)(1580799027)(38070700018);DIR:OUT;SFP:1101;
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0:
 =?gb2312?B?VU9XcWQ3OVlmOGpUOHMzbUNWdGhzTEhIeFoyd2daZFVaRlIwWHpXdGdBRUZl?=
 =?gb2312?B?emV4U1MrMncrTThnaVhNZGpZNHEvMVhxU2Fwd3JSRmZzaXE3ZHo1czMyM2da?=
 =?gb2312?B?TTVwUzV0N3pyWXJDMVppN2NSWGhHbGpkUzUvelNES2lqelRCWmtZd2dBaU1E?=
 =?gb2312?B?RVBmbGQ5ZmlZbWhQVERZZU1JeTJTRGwyQng0NkFsZy9KaVQ3R2JzOWQ0YlE4?=
 =?gb2312?B?c2UvSlowS3dNK3FCYThrSGZ2b25oUUdkODhxdVdkZDkyQzcrZ2tzZnhWeW9M?=
 =?gb2312?B?V2VYeCtGQ2p3dkxOdGZnWW9pTDFuTVZSaWRGOGJMSXhFOUtsNmtIVlgvU25s?=
 =?gb2312?B?Ty81Q2RMSDlQbHRkWjZDN200bVNTSGZldDNzdmVUbm5zdHMxOVZnRVd6OVBk?=
 =?gb2312?B?YnRLK2RBOHdMZTh4UEorTW42V2gwYjdEeDJtcEwwT3NCV1FFM0kxUVRaQUZl?=
 =?gb2312?B?NGJlQ09QaGxVdmtCUHVac2MwQ0JBV05xcWIwb2RGTXQ2Vkg2b1p3Nmp3Nm9y?=
 =?gb2312?B?MS9teU1VR3d0bk9KVGl0bkVleVhlbzc0Rzh5eVRNVFpyNzFDS0VqTm5FOGc0?=
 =?gb2312?B?K1BZQkZCTW5QUzNMUmVRSE1CSFN4dVI3aDc3NG5Dc2FKVWRqNnJZTXMvd25y?=
 =?gb2312?B?RHFSdFNIMVlDQzU4WUxaUzFGUEp6RlA0ajczak5LOHVsT3pBSjZ1Y0FyRHlN?=
 =?gb2312?B?emtIbk5JTFZCcWU1NkI4Ym0xcmNRQk44dVpha2lRbVVKUWNzRTQ5bjFUQklx?=
 =?gb2312?B?dytVTFVKTDN5Rlp2RHFoVHZ6emJGU3QxWXpyR3ZpSGd6S0ZRRk9PcWZoY2hk?=
 =?gb2312?B?Vzd5bkR0elc5V3BETENia1E0SEhGRkcyVzZFUjd6RHRabVZHSUJJbGQvRDdt?=
 =?gb2312?B?dzVGaGlwNWVpK2luamZuQ2dLK0JuWkJEYnZ4RzBQVWN6U1psTzg0VnN6TzJt?=
 =?gb2312?B?RERNQmM2b0FxYmptZitBeGhsS0Y4OWdJU2V3aDdpV2lzWG9jN254L3NqQ2FM?=
 =?gb2312?B?MzcxT1lLZFVab0FQWFlnNjRNWHBGRGFhMHJXY1RkMTNYNEUyK0NnQUQ5eUZ6?=
 =?gb2312?B?SGNkc3R6UzFDN0tkcEJFZzgxUzhiVENzYTZNU1J3aTFjaCtuUVZSOWNld2RE?=
 =?gb2312?B?cjFrYW9nKytRSGdQWkUzUVRCOXpkZXRIRDVIL0hkTzh0RmRRWFZkdFFURkVM?=
 =?gb2312?B?aFl0TDdXNzhTUGQ4YzFxaHdoSkMzaGFFT1JLY0ZIOTlZWldNU3FhREF6ZTlV?=
 =?gb2312?B?TEY2TTc1NFFPSVA2VW9TZWU5MGU2cFpQNW5VUWhabXhTOHJJdStrUCtrYnNm?=
 =?gb2312?B?ZzBQSitKZ2VSL2NTd21HNXBZZ1FDRENOeHpEMktPQTF4dVZ4dld1MnBRUEhM?=
 =?gb2312?B?N2E0OXgvSnIrSmdjQmhZc0dXNjJRTFVLRUtSUC9vYzBDMTJZZnNIMWI0RFRp?=
 =?gb2312?B?VkFRN0VPcHFKaFJ0Wk9NNUxDR0ZZWDkzVGNCY1phT3hkTVJQb0V0Ujk1aUs2?=
 =?gb2312?B?bHJnS2ZBNTlDUWNtK2dSZURZME1xeGNRdFZMRllBSXJXam1xRGZuZ01vb2Jh?=
 =?gb2312?B?ejdKWXpRL2VOK0hROE54VHlOczhCa0psN3JRMEJhcFdZZVF6OGg3OWFPcDha?=
 =?gb2312?B?aXMrRU55SDcwcU1sbllKRElxNlgyVGJCV05uTEtBOWd3cnFSZDhCZHhWLzY4?=
 =?gb2312?B?c0pqUXVhblcxV3VYYXhrYXhRS04rbU5uWGFJK3NkQ1NjN0RCdWpUSkRSMjRl?=
 =?gb2312?B?Qlk1TVM2NFRpVytIS01VWWpWVkF4Rm04cUFScUNrRjVraXBVdk5BSkJIZHZo?=
 =?gb2312?B?YTZMckdGQk9zVElQMStwWjNhejhxNUhvdTFjYzVhTFJyQ1ByNmU3YkVkODU4?=
 =?gb2312?B?TldkU1ZKdTVYcEZPbDhlaWp0VnBhSXlwQXVaRGxFc3V6cUM4akNIQ3NoeFBu?=
 =?gb2312?B?THJmZW5lbHlxTjB3ZW9VeHlTSGtrSVB6OE5MZHdvMzRKUm9uZnVMblFQUnd0?=
 =?gb2312?B?eWJOS2NVVEJ1aVY3dWh6em10Qm5qNEdaTkxoN0hMK2NIOWlHb3Exc3k1MWdO?=
 =?gb2312?B?ZGVlR096ZmpIRXdLdkc2Y3paMEQ3Wk1Vd0E2c0VUdW9zTVV4L3NHUUxmM1Av?=
 =?gb2312?Q?6sKoBXqCbCbS7r1T9qZ7lKzIQ?=
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0:
	2EnAnrtNFQ60CqRdW8fi/8jtRJxYtg5hVMYMt0+P+9Sr5sw/YKTlp6xFmy3tKMbPYoXy71I0DkiKOT+8bLqGHiDS+1wt/mWd3AidCGv9Rtha4Bsp5HKBMBGdwFTd/GKOrvdN4oogGddymK2SCgirTy7yPpReONuZMogdOpYVRkJlEkoFAgpsXBMBDrf7vajgMe984Duxi8jyjFjh35ufk0EGOmANYgSmSHT5Hmv43gsnFUlZuirHAzO2mX/w1kUMRgQWf2429R0bGO17XXK3TrKYVrlgxOWrYExjPGgyW2D+rYl36cjh+N+AlJYgpOUK7c+UOhu2ASClcmD5+PO8/N3M7L2BByZtVryxxbSYvp+NHBlnEFuRJpcT1Q2gnxZ/6oZm2IFEMx19f4GveA7nCo5KEpgtdSiNdk+mc2uzD4MIwywB/PuCHe10x/xLFpUY1MzNwkyayQiQm6cDYMngEAEmsJB3YjrpMUwqtzVhpdPM41D9uTZf3hQmGLMMZ3EYB6x8TdmgVyuSc75Ef4MH6WzgMZNScR7pk9Wd+rRZor/SizKW8GDITiQXN+jvcN67hwH08lrs9x0xcW9DSJwb0Ri69oVMkHjomn6b0VEjKeJkCvC1gk9u7E+ZewGiSjXY
X-OriginatorOrg: fujitsu.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: TYWPR01MB12085.jpnprd01.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: b5d32416-73bd-441a-0527-08dc9654e0c1
X-MS-Exchange-CrossTenant-originalarrivaltime: 27 Jun 2024 02:57:27.1376
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a19f121d-81e1-4858-a9d8-736e267fd4c7
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: vPdO4cqm5Zn9mIaI3/jjk8nXxxUiKnw7A9fZgkuRC71ocqHSwF5wTwRhbwM4AaMqzmBOMJAoNA4SO7w82rSQfA==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: TY3PR01MB11113

DQoNCj4gLS0tLS3Tyrz+1K28/i0tLS0tDQo+ILeivP7IyzogSnVsaWFuIEFuYXN0YXNvdiA8amFA
c3NpLmJnPg0KPiC3osvNyrG85DogMjAyNMTqNtTCMjfI1SAxOjU0DQo+IMrVvP7IyzogQ2hlbiwg
SGFueGlhbzxjaGVuaHguZm5zdEBmdWppdHN1LmNvbT4NCj4gs63LzTogU2ltb24gSG9ybWFuIDxo
b3Jtc0B2ZXJnZS5uZXQuYXU+OyBQYWJsbyBOZWlyYSBBeXVzbw0KPiA8cGFibG9AbmV0ZmlsdGVy
Lm9yZz47IEpvenNlZiBLYWRsZWNzaWsgPGthZGxlY0BuZXRmaWx0ZXIub3JnPjsgRGF2aWQgUyAu
IE1pbGxlcg0KPiA8ZGF2ZW1AZGF2ZW1sb2Z0Lm5ldD47IEVyaWMgRHVtYXpldCA8ZWR1bWF6ZXRA
Z29vZ2xlLmNvbT47IEpha3ViDQo+IEtpY2luc2tpIDxrdWJhQGtlcm5lbC5vcmc+OyBQYW9sbyBB
YmVuaSA8cGFiZW5pQHJlZGhhdC5jb20+Ow0KPiBuZXRkZXZAdmdlci5rZXJuZWwub3JnOyBsdnMt
ZGV2ZWxAdmdlci5rZXJuZWwub3JnOw0KPiBuZXRmaWx0ZXItZGV2ZWxAdmdlci5rZXJuZWwub3Jn
DQo+INb3zOI6IFJlOiBbUEFUQ0ggbmV0LW5leHRdIGlwdnM6IHByb3Blcmx5IGRlcmVmZXJlbmNl
IHBlIGluIGlwX3ZzX2FkZF9zZXJ2aWNlDQo+IA0KPiANCj4gCUhlbGxvLA0KPiANCj4gT24gV2Vk
LCAyNiBKdW4gMjAyNCwgQ2hlbiBIYW54aWFvIHdyb3RlOg0KPiANCj4gPiBVc2UgcmN1X2RlcmVm
ZXJlbmNlX3Byb3RlY3RlZCB0byByZXNvbHZlIHNwYXJzZSB3YXJuaW5nOg0KPiA+DQo+ID4gICBu
ZXQvbmV0ZmlsdGVyL2lwdnMvaXBfdnNfY3RsLmM6MTQ3MToyNzogd2FybmluZzogZGVyZWZlcmVu
Y2Ugb2Ygbm9kZXJlZg0KPiBleHByZXNzaW9uDQo+ID4NCj4gPiBGaXhlczogMzliOTcyMjMxNTM2
ICgiaXB2czogaGFuZGxlIGNvbm5lY3Rpb25zIHN0YXJ0ZWQgYnkgcmVhbC1zZXJ2ZXJzIikNCj4g
PiBTaWduZWQtb2ZmLWJ5OiBDaGVuIEhhbnhpYW8gPGNoZW5oeC5mbnN0QGZ1aml0c3UuY29tPg0K
PiA+IC0tLQ0KLi4uDQo+ID4gLQlpZiAoc3ZjLT5wZSAmJiBzdmMtPnBlLT5jb25uX291dCkNCj4g
PiArCXRtcF9wZSA9IHJjdV9kZXJlZmVyZW5jZV9wcm90ZWN0ZWQoc3ZjLT5wZSwgMSk7DQo+ID4g
KwlpZiAodG1wX3BlICYmIHRtcF9wZS0+Y29ubl9vdXQpDQo+ID4gIAkJYXRvbWljX2luYygmaXB2
cy0+Y29ubl9vdXRfY291bnRlcik7DQo+IA0KPiAJQWx0ZXJuYXRpdmUgb3B0aW9uIHdvdWxkIGJl
IHRvIHVzZSAncGUnIGFib3ZlIGFuZCB0byBtb3ZlDQo+IHRoZSBSQ1VfSU5JVF9QT0lOVEVSIGFu
ZCBwZSA9IE5VTEwgd2l0aCB0aGVpciBjb21tZW50IGhlcmUuDQo+IEl0IGlzIHVwIHRvIHlvdSB0
byBkZWNpZGUgd2hpY2ggb3B0aW9uIGlzIGJldHRlci4uLg0KPiANClRoYW5rcyBmb3IgdGhlIGFk
dmljZS4NClVzaW5nIHBlIGluc3RlYWQgb2YgUkNVIGRlcmVmZXJlbmNlIGxvb2tzIGxpa2UgYSBi
ZXR0ZXIgY2hvaWNlLg0KdjIgd2lsbCBjb21lIHNvb24uDQoNClJlZ2FyZHMsDQotIENoZW4NCg==
