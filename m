Received: from mx0b-00007101.pphosted.com (mx0b-00007101.pphosted.com [148.163.139.28])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9338F13D8B4;
	Tue, 19 Nov 2024 07:38:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=148.163.139.28
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1732001888; cv=fail; b=ZCLzTXUbEn0Lk8x2pnvNMKQBc7y3duTGAJSLqZAWVxaji70WdS9mAqK3igxTbCXucbukKkScBTfyGn9EMuScM1kjopFIAoYXkm/aZqwAp2AL1qSTA13elUixkEejFEy9IejAeFLVS1Gsj4M5ZEJ3LXdmLK5i2C7heA0uFg1Mrb0=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1732001888; c=relaxed/simple;
	bh=P0Hd6wkAjXYYbgT9bK2UPaQupcYxF0XVlflfPZqcgiY=;
	h=Message-ID:Date:Subject:To:Cc:References:From:In-Reply-To:
	 Content-Type:MIME-Version; b=hQslyZOdcl6ZIEh8mrjvARApQq1MPHlVlqirxyBo/BX07h4CuILgeLV8uOIjuzMDqD902aPdQMCu3QRqxiI+zT6mFtWN2AY4a8FNl4cAPWp8mGGCFrL4qRMQzSaagJ/y0pUdcNxC80nqv1bkzXGHOdqZvCsKwnJXjmRBGMruXCg=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=illinois.edu; spf=pass smtp.mailfrom=illinois.edu; dkim=pass (2048-bit key) header.d=illinois.edu header.i=@illinois.edu header.b=hRkAYdof; arc=fail smtp.client-ip=148.163.139.28
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=illinois.edu
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=illinois.edu
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=illinois.edu header.i=@illinois.edu header.b="hRkAYdof"
Received: from pps.filterd (m0272703.ppops.net [127.0.0.1])
	by mx0b-00007101.pphosted.com (8.18.1.2/8.18.1.2) with ESMTP id 4AJ76p1m024488;
	Tue, 19 Nov 2024 07:37:25 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=illinois.edu; h=
	cc:content-transfer-encoding:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to; s=campusrelays;
	 bh=2B1wx1586kTBMtDV9o0jNd2a26rA8+s0JPe55eXghDc=; b=hRkAYdofK6/o
	PTd+tBFAt8LowxITFPEvXdy+u9XLe4bCh4fJYZaMiBuByhochzY5ym2S34FCVXcM
	UANwXqrDC8rkNYNT82/OaTSihEJ6FpvGPdQg3c/Y5uCrwdh/Eud/m/ZSrfEE3vHi
	reKK2tDBKPHnNR1rj5dvfqSB7I8tLD9XSQ2O4ZMcaKbHMzYVBhQo7Kkuq1mzAsIc
	SacNZt4LOPnYmkLworRiLwjK4W/c8ZaLQFAxImPUhn+32XHn/riddMVnFwJCgJYi
	388XKpRyKjQ8q5Fi3oAkuEG2bZvGnluZtF1Q18FAdZS/tv+2t/5MUC+xxyjkL0+/
	VtTojDbCSw==
Received: from nam10-mw2-obe.outbound.protection.outlook.com (mail-mw2nam10lp2047.outbound.protection.outlook.com [104.47.55.47])
	by mx0b-00007101.pphosted.com (PPS) with ESMTPS id 430bhx491v-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Tue, 19 Nov 2024 07:37:25 +0000 (GMT)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=hqKda++Ei3mh+BZdRULN1y+qwiHBXWxEyzWbc1ZFbu6MOLKvqkzxqUjk/Poe7sdOovd6BU7FuWe3TgipAsZxOsCOHzuPc9A0jKCo/tqzhLjuuCLsoJh1GomVcw/5bgGljkSibJc3Br0RJtEMaCSHijHuDduOB1Rw1clCiLNzUP6BTDQgdHlui9YkpreFTOROhfZgZ/mzair2lASySukkYoCdDscGlXGy1UliMdlqyUBPzqIlYMnoLVUlU+diRvZhDxzW4z693nKrZGwQkCfb+qy/zt0gwT0pkOFQQJditlmgjks26ovv5+hsqwFQ6HJpVjPEGyngonFKHOHRSaA7tQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=2B1wx1586kTBMtDV9o0jNd2a26rA8+s0JPe55eXghDc=;
 b=q95T2//CNGkYM76Qsk8OKIWOEmHKEKK7YSdYMf+OZ0EDiq1HM92yYBZo9fuj5G2I9xjqV0+CMt6uy/k/3keTNp71rPVfeY0huyETjerPSuAOyDsPwxAt4HAGsyLTZAP2E1dlj1kCZzDQwB2QOfHShk41HTT9wEuEdOijevKFUEuPCcJdWo2+636pBi0evjwUyaLgxFIdffyUpz8ymfoB8bYDH1f16zmJzEAXrrMYp736ZLlnmrqSfZNx8+XZmVZicY+0lhKkUwV3u5YUR29ErI7aSslWURV3Qj+k3nfum/ZNEb2uV7hfY6k5B32whvc7Q3yxc+N3+hq1PrHx2FxNAQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=illinois.edu; dmarc=pass action=none header.from=illinois.edu;
 dkim=pass header.d=illinois.edu; arc=none
Received: from IA1PR11MB7272.namprd11.prod.outlook.com (2603:10b6:208:428::8)
 by SA2PR11MB5019.namprd11.prod.outlook.com (2603:10b6:806:f8::10) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8158.23; Tue, 19 Nov
 2024 07:37:22 +0000
Received: from IA1PR11MB7272.namprd11.prod.outlook.com
 ([fe80::74b2:6bb6:a99c:9222]) by IA1PR11MB7272.namprd11.prod.outlook.com
 ([fe80::74b2:6bb6:a99c:9222%6]) with mapi id 15.20.8158.023; Tue, 19 Nov 2024
 07:37:15 +0000
Message-ID: <a271e479-2a78-44b5-868d-3edc1f6c102a@illinois.edu>
Date: Tue, 19 Nov 2024 01:37:13 -0600
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] ipvs: fix UB due to uninitialized stack access in
 ip_vs_protocol_init()
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>,
        Pablo Neira Ayuso
 <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@netfilter.org>,
        Nathan Chancellor <nathan@kernel.org>,
        Nick Desaulniers <ndesaulniers@google.com>,
        Bill Wendling
 <morbo@google.com>,
        Justin Stitt <justinstitt@google.com>, Kees Cook <kees@kernel.org>,
        netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel <linux-kernel@vger.kernel.org>, llvm@lists.linux.dev,
        kernel test robot <lkp@intel.com>, Ruowen Qin <ruqin@redhat.com>
References: <20241111065105.82431-1-jinghao7@illinois.edu>
 <f97ef69b-a15e-03ab-5e24-c1dfd3c4542b@ssi.bg>
Content-Language: en-US
From: Jinghao Jia <jinghao7@illinois.edu>
In-Reply-To: <f97ef69b-a15e-03ab-5e24-c1dfd3c4542b@ssi.bg>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
X-ClientProxiedBy: CH3P220CA0009.NAMP220.PROD.OUTLOOK.COM
 (2603:10b6:610:1e8::27) To IA1PR11MB7272.namprd11.prod.outlook.com
 (2603:10b6:208:428::8)
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: IA1PR11MB7272:EE_|SA2PR11MB5019:EE_
X-MS-Office365-Filtering-Correlation-Id: 4d249748-07b1-4fc1-8750-08dd086cfd47
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam: BCL:0;ARA:13230040|7416014|1800799024|376014|366016;
X-Microsoft-Antispam-Message-Info:
	=?utf-8?B?QTFwQW1kRmRvTGZyMWxNZytmZHMyb2kyaHNCNjUzUjdQT2s3Q3VjUkkzNisv?=
 =?utf-8?B?MCtET0xmTkZOUE8zL0NXYnMvK1B5MGtncE1rMERreVJaV1hkL2tLaE9GeDZT?=
 =?utf-8?B?VWJpckZUZGdHdDlKMUYzd3J2M0N3b2l1WVd1Y1BYclVHV1crT0M3cGNTM0dB?=
 =?utf-8?B?SWx0cVhNa2JIOW9SdWlkTmtKOHNEdmx1c3l3SGZ5QnlqSVhoS0sxUEVSV2Q5?=
 =?utf-8?B?dmp2dWN4VzdoNXN4ajJnWFNheldDRlE1c2NBTWQzemlVVGk1VDhSWEhtNmk4?=
 =?utf-8?B?d1RCY0VoclI3QmVNd0pDZjJFTmIwYjUzbmNtQXJjaTRWUFBmNVV2L2VldmUz?=
 =?utf-8?B?RG42SWlUOTYrdVU0OTZNTzJhb3dISXhUUnlYbllDL3VLeEJ0YWFyNzBxTkp3?=
 =?utf-8?B?Uy9QOEREN3VRZ3NMS3NFSmZ2TFpQTC83cEV5QXlsUEU3bEVPVkpkb3lCQzZw?=
 =?utf-8?B?cGZ5MDVXUW9DbDV1cm8ycXE0THJQRG9FYUNuOE8wdU1DYytlUjN2L2d3YitE?=
 =?utf-8?B?R3lMeWtJR3ZnenhCdURMRzdZRm0rTXBQRUxBMlRoTnI4Q1hMZGMwa0xxTmNm?=
 =?utf-8?B?Q1FUYWg3MnFPZFZLV2psbGhmNHNndGRYbnVVK0xzTVBwWjZjTCtPMzJST256?=
 =?utf-8?B?ZWVvYTlxb3J0L2pjd21KRGdxSmlLbFZ4Tm8yWUx0RWVNZG5Ub25GMG8xUXRp?=
 =?utf-8?B?NkdSY2M5V2YxTnpMWlFQM1hKTWhxUE1qYW5wdG82TkRZcjRGaEl4QU5CdlVQ?=
 =?utf-8?B?MEpYOGRtZUg5WlA3dGpTdUlVd3lrY3QrdWs0L200WFkwQTJhQUtlQnYwWHBl?=
 =?utf-8?B?T0FGa1ZDczg2RWFtRkJ1Y0ZUSzlVTjgzTVNPMFdLRVFndFNTdy8vTGhQbnhE?=
 =?utf-8?B?Y0VxVWZHRjgxRkJCWVlvZWExeFNEd3FDZGNCdlpSY1lvbnBTSGZzTnR2RjBN?=
 =?utf-8?B?N3JocW5EWFMrWjlPTTJSMDFweTVUaFFrM0RTdUc1cVZtUVp6c2xNalhYdmIy?=
 =?utf-8?B?RUsxaFFkeXU5SUlpUlcvQ0RUWUQ1UXpaQzI5ZzJ3ZFhRWjdGODE5WXlVczBv?=
 =?utf-8?B?SHoxU1VhV1FMM00rUDQ0K0pZMFBzeFFYeWx0UjFiblloeGUxZGdGTHhzNlB1?=
 =?utf-8?B?cmR0RkRJYUVuVVc3dkJHUWxSNUhlNlY5TXdpVzBCWEpuZDQ3VG8zNTZ1Q0ph?=
 =?utf-8?B?ZUFOcXA0cVp4TDA2OFNhVFIrdERLSk5VQnZaU2ZmMDdBdGRHR2VqL0hOT2x4?=
 =?utf-8?B?VjA5ZGZJMUhCS01tbUtXVWZFdWp1UzBmVDhGWFFHWG1BdnhNWXpmUjRTTWhq?=
 =?utf-8?B?TEFiL0RvWmhCZEhWWHlXSkhpc1lWRTNuVHhOaVo4ZDFaYmlYd0JTL3N6SDVH?=
 =?utf-8?B?eURCSEJZa04yR21EanYyYkZZcFBYc3A3YS90VHJEMXRzK29ERkFBdG95U2VQ?=
 =?utf-8?B?TjBQVVRyZGYybjhQVzhhSTBic0MvSGdDQys2bGVPMGx3Zm1GNkZERVBEbG1M?=
 =?utf-8?B?Z3c3ZzV0eTk2eEVhVE1HQVRHNGZWWVNCOUZZMThpbHBsZ0lMQWlRVk9vK09K?=
 =?utf-8?B?NTBvUlRLOG5yZmM0ekpZcEcvVlRrVERYV0F4QUs5aHhsQktWRmlIVDJEYlB1?=
 =?utf-8?B?Q2l1R1NlU3VLQWtYeXZsTFJocXhPU2RVTTE2QUxONklaZ1MrcXdXQkJyZEFl?=
 =?utf-8?B?UnpLSTJwclQ0RHlsMi9Td25GekE5Y29JRjdTTXdhV1pUWVJXY2UyQlNFT3ZC?=
 =?utf-8?Q?rDhcHyJONSS6sq+vfaNcYEY4E+h2FxJdJ+4fMhL?=
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:IA1PR11MB7272.namprd11.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(7416014)(1800799024)(376014)(366016);DIR:OUT;SFP:1102;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?utf-8?B?UDRTT2N0QWtaZWo5MXgyaXdoYjAxQ2duNGgvL2svNWJBeW1YUVRpUGp0VTNn?=
 =?utf-8?B?V1gwcDFGdkdRS0N3ZDFrd1pFYjFrSUVzSFFzTzhyRldhWWdVeUFOVTVSZzVn?=
 =?utf-8?B?UjJ5OFpXZlNYeE1ER1J5bmk0elJ6WlM4ZVBiVE9VM25aR3VGWFlSNEFzdExx?=
 =?utf-8?B?UFJsUlRiRVdQTUl3dmhBeEd4WWpHNUhWK3lBR05QaW11ZkJzTFFOWHJUUGpN?=
 =?utf-8?B?NFZrZmc2UEZDMTFCN3E1YWZWMWFLUnc0ZFFZZGJUSnNCYkxNMnhicEVoNXJy?=
 =?utf-8?B?V2RxS2RoVHJrOVl0MlE0bnJMMkR4TFlXNDZrQTdRbGJERHNiODRjWUc4RDRY?=
 =?utf-8?B?b3JFQlp3S3MySHFDMk15eHYrc3pxbWRKSk9OMDJjbWFlbGl0QitndkZBYnBk?=
 =?utf-8?B?TDBKZjJIUmNpcGt2bXZhTHgvSFJtTHNaZ1UyUTZQVmtodGh3Y1NlRWQzNTFv?=
 =?utf-8?B?UFkvTUpiUVlSTHJPaCtqZCs5eHpNcWcxdGo2M2Zqb01EVDRzSkwyTUZiRzQ3?=
 =?utf-8?B?M0JRRUNkZDMrL05mRGdoTzJxeVpjRnp4QmozZ25rTis1a2NzSy9TRW5kd0pz?=
 =?utf-8?B?UlFHOUpUL3dBdUxubG1vQU5WK2VNWWErOC9xK1BuMkJxdU9RWis0V0I0Q3BT?=
 =?utf-8?B?OG1BV0VvZDRGMy9jeUo3bkE1Q0NaQnd3anlSUFdibkpEOTZRVEQ0UHN5OGp6?=
 =?utf-8?B?NnhEaTU4eU9ES29yVk9hUEU1VTBleVcxUFR5SFIzMDVvQnJkb21lUzJaa2Ra?=
 =?utf-8?B?K3ZWSCtMZENyUmlITFRnUVpCcDJNMXMyOEVKenVhUmJyUzN5TXNsU1p0Rk1q?=
 =?utf-8?B?QStIdytGRVRyT1VtOC9HSkVkVkwyRHZpeUN4NVk3ZVlyQnU1alhaTmRxR08r?=
 =?utf-8?B?THhhb3QxVS9kemFWR2xpZFhDbkUwUHVCdktBUUprczkvWEVXVlMzZ1ZuWjRN?=
 =?utf-8?B?RWUrYm05RnR5TUtmdGpUK3dqMUdJampnZmhjM1VZeVlYL1BRTFdLMEZSWUtG?=
 =?utf-8?B?cGdUMW1MU05Mc3JaYWdaVnhlRGM2MUt6SW5GVTVyUnFQUUQrSUN4RER6T2or?=
 =?utf-8?B?SEFDN2tiU3lkNW1vaVhZSkNYdHNUejJaRUVVSldPUm1qZ01YamJKZ3Q4UEk0?=
 =?utf-8?B?cWorZyswK2RpRGE3RHpITlJQYVk1RUh5L1poTXU2eU12MDkxUXlwSUtETGxQ?=
 =?utf-8?B?aW9wYmJucHI2SnZZNDdUMk9HNWgvb3pROFY0SFJGODNLUTNTZDRLTTJqLzVk?=
 =?utf-8?B?TEtFMnkvSmJLLzNWa1FCS2tyMTJNLys1a0I0TGpuaVNYaWg0SVhiVHRCejUz?=
 =?utf-8?B?VUwvRTdHVUQwUTBKa0c3YjhXZ3VKQllwcDlQY0ljOGtTZXV4MVlzVVluSDdv?=
 =?utf-8?B?WVhCbmNjaDVidElaVENtb2ZZaWNYY2VxaysramQvMitPZTJ3cEtSaFpkaU9i?=
 =?utf-8?B?eUZ5YXMwcENKdDFBUjRrMnY3RXpkUEF6MXhjNGN5M2ZSaDZDTXRCN2J3Y3hQ?=
 =?utf-8?B?WjZnM3hGR0RYM1BoR09mRmIvOVBIZ3FwWUY2TVdLZGsxQ01SWHdMbVVJRjN4?=
 =?utf-8?B?MnBuaU5GMlc2VlJsYjBtK3FxZnlZM2laN2ttblcvK2N6S2hsWGJ5b1IrcXdW?=
 =?utf-8?B?d3d5LzBubkdzWVVoNEp5OExaOUxtZ0wxZ1BIRnJiYi9pWDFNVmFmbWdJclJr?=
 =?utf-8?B?THFibStGdFdxRHVjb1YwbTVQVTFTREJteTFpWHlKMUJSMENIN1ZxNUxzdGs4?=
 =?utf-8?B?N1dqMGFRbW9xVktJcDNLaHF3WkpwVWpmaE5vVCswSUVXUW96VHVBbUp5Q3FD?=
 =?utf-8?B?bHg2RkpUMUswWHJzSmJGbWQxT1UyN211eWF6cDAyN1VveTFUYk9Da0RFcTFa?=
 =?utf-8?B?SXFPRGcveElNZG14Ym1FdHIxbFVOWUZmOFJTOHYzK3ZTc083b1RpMFNUMzFK?=
 =?utf-8?B?NFlrQjJzQ3pUOFVpeE5Ia2Z2ZHVXWWxzZFpUSUJ5TUlVSkxJakZNZ00rRm53?=
 =?utf-8?B?OElQaWFBd0FSN2VRblRTaTRwUnVVZW1MVTAvbWF1ZFJhcTV6S1orakdtdE41?=
 =?utf-8?B?NExaYlVya0pPMFVnY3BpSGFyV0c5blJjclF5eEpPTFJzRktVM2VMaVUvTUlV?=
 =?utf-8?Q?tR0QImkBHlb3ouCnHVo/JXDjz?=
X-OriginatorOrg: illinois.edu
X-MS-Exchange-CrossTenant-Network-Message-Id: 4d249748-07b1-4fc1-8750-08dd086cfd47
X-MS-Exchange-CrossTenant-AuthSource: IA1PR11MB7272.namprd11.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 19 Nov 2024 07:37:15.6502
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 44467e6f-462c-4ea2-823f-7800de5434e3
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: 5iosAJHqMbkN1pcP/RrpnNt1x+NeqJ66au7gkweyzP8OZqfOKLe66miG3dYyKU7ZkaMG2n4bplUTB0rjBqZPqA==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SA2PR11MB5019
X-Proofpoint-GUID: iqzVfAkFOShEUaNKK61az-Zfhw-jLqyw
X-Proofpoint-ORIG-GUID: iqzVfAkFOShEUaNKK61az-Zfhw-jLqyw
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1051,Hydra:6.0.680,FMLib:17.12.62.30
 definitions=2024-10-05_03,2024-10-04_01,2024-09-30_01
X-Spam-Details: rule=cautious_plus_nq_notspam policy=cautious_plus_nq score=0
 suspectscore=0 malwarescore=0 phishscore=0 impostorscore=0 clxscore=1015
 lowpriorityscore=0 bulkscore=0 adultscore=0 priorityscore=1501
 mlxlogscore=999 mlxscore=0 spamscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.19.0-2409260000 definitions=main-2411190054
X-Spam-Score: 0
X-Spam-OrigSender: jinghao7@illinois.edu
X-Spam-Bar: 

Hi Julian,

Thanks for getting back to us!

On 11/18/24 6:41 AM, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 11 Nov 2024, Jinghao Jia wrote:
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
>> This gives later passes (SCCP, in particular) to more DCE opportunities

One small request: if you could help us remove the extra "to" in the above
sentence when committing this patch, it would be great.

>> by propagating the undef value further, and eventually removes
>> everything after the load on the uninitialized stack location:
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
>> Reported-by: kernel test robot <lkp@intel.com>
>> Closes: https://urldefense.com/v3/__https://lore.kernel.org/oe-kbuild-all/202402100205.PWXIz1ZK-lkp@intel.com/__;!!DZ3fjg!823fsY09q3IcP8uThu-yUuuQaiwQOR7gZJhV9JNWdxzerlkYJ4JkZGYuq4iO1DKqaErCulk1CGir$ 
>> Co-developed-by: Ruowen Qin <ruqin@redhat.com>
>> Signed-off-by: Ruowen Qin <ruqin@redhat.com>
>> Signed-off-by: Jinghao Jia <jinghao7@illinois.edu>
> 
> 	Looks good to me, thanks! I assume it is for
> net-next/nf-next, right?

I am actually not familiar with the netfilter trees. IMHO this should also be
back-ported to the stable kernels -- I wonder if net-next/nf-next is a good
tree for this?

> 
> Acked-by: Julian Anastasov <ja@ssi.bg>
> 
>> ---
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

