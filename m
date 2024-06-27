Received: from mx0b-0016f401.pphosted.com (mx0b-0016f401.pphosted.com [67.231.156.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B670E1A702;
	Thu, 27 Jun 2024 05:08:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=67.231.156.173
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1719464913; cv=none; b=ENIs6PZDgMYjsOVCY9Fb2tY7KC0cO0VStyMcGl1EdLMyTXXw4lMXCWFYJlglYz+vJtbGIHjmEFQJqQk39tyEdWnjjiyo/RnqDwQykfkDswHwHexYO1q+t2oud4nP62ACCQ2J5gKUcCWZZ3DS4fpfboKlm/VZvLd4nFT3ageBhd4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1719464913; c=relaxed/simple;
	bh=MnxzPmERAtu+n6Ig3xdw80LnPjSGEE5nsAYiBqjVZYM=;
	h=Date:From:To:CC:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Jul2eofvfL2ElmbcxeQThqo9VGRmwo8wIWdRzEZGP5nwWr/Tfh09cDq+okUbjDS51dWmPdN1J6xYUJSdSFwu9adJE992RMtdUmIrzT0cT6O00VU68Yr29D7XsxY9ofA0mmeifbJIrJEg0O9IYVeSSuIfpojpSW8UNS0xka0XI44=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=marvell.com; spf=pass smtp.mailfrom=marvell.com; dkim=pass (2048-bit key) header.d=marvell.com header.i=@marvell.com header.b=DKE8m8HR; arc=none smtp.client-ip=67.231.156.173
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=marvell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=marvell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=marvell.com header.i=@marvell.com header.b="DKE8m8HR"
Received: from pps.filterd (m0045851.ppops.net [127.0.0.1])
	by mx0b-0016f401.pphosted.com (8.18.1.2/8.18.1.2) with ESMTP id 45QImo8V002400;
	Wed, 26 Jun 2024 22:07:55 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=marvell.com; h=
	cc:content-type:date:from:in-reply-to:message-id:mime-version
	:references:subject:to; s=pfpt0220; bh=Y2Zt/MQEYRuDjKW8UGc2Kvr4B
	O3jU7bpmwKvqLDFRIU=; b=DKE8m8HRzs8hdvGUquTcVaPB1Ojr0dN+GybLTzNU4
	kdEIkD/QROPSJLAqRiccWKZnWR/7hp09xIvkSlF29PN+ut1bOOGjJIp7Y1xl7LzU
	vAznEVLeKioqImz5wrSMxYM4I1ZJ3eUO6dxV78OWnCJ/GBrhjpWrvi5LPsOD9eZ4
	gponk0wAG2hGc0KLM5OxjRtOHwxiBC8rZDxyuD04iabrvRrfH2wpJi5FXpJijEqI
	nhZ2BgSkdZAQrg1AESqUAO2VCMKESaLgsb8PDzxuXkR5PcQFlhm0oYO/eKvkJQQI
	UNfh6ocouaeHeWaQXwCO/YMRCDMtOqxYFdZAHJ3bHNWDQ==
Received: from dc6wp-exch02.marvell.com ([4.21.29.225])
	by mx0b-0016f401.pphosted.com (PPS) with ESMTPS id 400rkg1ge0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Wed, 26 Jun 2024 22:07:55 -0700 (PDT)
Received: from DC6WP-EXCH02.marvell.com (10.76.176.209) by
 DC6WP-EXCH02.marvell.com (10.76.176.209) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.1544.4; Wed, 26 Jun 2024 22:07:55 -0700
Received: from maili.marvell.com (10.69.176.80) by DC6WP-EXCH02.marvell.com
 (10.76.176.209) with Microsoft SMTP Server id 15.2.1544.4 via Frontend
 Transport; Wed, 26 Jun 2024 22:07:55 -0700
Received: from maili.marvell.com (unknown [10.28.36.165])
	by maili.marvell.com (Postfix) with SMTP id 3B0283F7071;
	Wed, 26 Jun 2024 22:07:50 -0700 (PDT)
Date: Thu, 27 Jun 2024 10:37:50 +0530
From: Ratheesh Kannoth <rkannoth@marvell.com>
To: Chen Hanxiao <chenhx.fnst@fujitsu.com>
CC: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>,
        Pablo
 Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@netfilter.org>,
        "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>, <netdev@vger.kernel.org>,
        <lvs-devel@vger.kernel.org>, <netfilter-devel@vger.kernel.org>
Subject: Re: [PATCH net-next] ipvs: properly dereference pe in
 ip_vs_add_service
Message-ID: <20240627050750.GA1743080@maili.marvell.com>
References: <20240626081159.1405-1-chenhx.fnst@fujitsu.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20240626081159.1405-1-chenhx.fnst@fujitsu.com>
X-Proofpoint-GUID: wSXmmk9mMDWUa9I_0MY3ReWkEoncJWSr
X-Proofpoint-ORIG-GUID: wSXmmk9mMDWUa9I_0MY3ReWkEoncJWSr
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1039,Hydra:6.0.680,FMLib:17.12.28.16
 definitions=2024-06-27_01,2024-06-25_01,2024-05-17_01

On 2024-06-26 at 13:41:59, Chen Hanxiao (chenhx.fnst@fujitsu.com) wrote:
>
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index b6d0dcf3a5c3..925e2143ba15 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -1369,7 +1369,7 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
>  {
>  	int ret = 0;
>  	struct ip_vs_scheduler *sched = NULL;
> -	struct ip_vs_pe *pe = NULL;
> +	struct ip_vs_pe *pe = NULL, *tmp_pe = NULL;
Reverse xmas tree.
>  	struct ip_vs_service *svc = NULL;
>  	int ret_hooks = -1;
>
>
