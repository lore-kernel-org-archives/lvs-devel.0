Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=52.35.192.45
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795789494;
	b=WJaFoTrMRYHdfV96rJMXyW1sgQJ6AO/V3iElyEadzUEKLwjdwojIdP5kyCIUCqskH2hg
	 Ad6KuoVCgwlr0zLncyV9JxfJ1MCxlhvfmhyjfEU960c7gul1R4+JE1JvVi1IA3T5fmyBa
	 gz2xNmDp2prRxKLkqyHwNLlqCLpzdk6IylW1gZlfpAjE+EEfdaTVVsV/OKn27oomyHDvj
	 pYa0VWqLRsaJ02p/UTSYAHyCRvASSwvMazxLsUoLvCpjrWXQSEHZtYkCjRRHv3cybOsae
	 pvDum0eLLv6D6WfUbGKWxjBc8/uap36m5ZGl9unHDlRe0ZCGvj0/vMX+fCYhm/KktnQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795789494;
	h=DMARC-Filter:DKIM-Signature:X-CSE-ConnectionGUID:X-CSE-MsgGUID:
	 X-IronPort-AV:Received:Received:X-Farcaster-Flow-ID:Received:Received:
	 From:To:CC:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding:Content-Type:X-Originating-IP:
	 X-ClientProxiedBy;
	bh=0Hc5k4DsAxxmLwGYC+V1QGrOpstcjMHKcFIfgfKPwsU=;
	b=vK2WnXHHJF6AsnIGJkw5hnSadDbg5jqXGNJAdQ8cFn1H6wjYswIZpJK8SNgkrDGgs9Ej
	 6yQev9rXk7o2EcapY8hUkVsW+RAUkXhr6KDWnso24/35cvGttKASaNVHg839kbgk7BQYM
	 P8fpAALSMhgZs16K9PuKt1KbvjF6J/eAeZafm0/VV2LI5Cl0fXaRtR+75Rfj1h9WMzY92
	 jPPUybI3sX/eQlmS29IOKiND1FamA/a13WqIt++CJBxtc754lLVpUVQOssI4Y3rnivKPR
	 /Ny7i9wJXZFp58PUz11HFQdNzo2GXtVqcAbCVh0vBaDHAYkLnA452XY8DZ7ucQCn1VA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=amazon.de;
	spf=pass smtp.mailfrom=amazon.de;
	dkim=pass header.d=amazon.de header.i=@amazon.de header.a=rsa-sha256 header.s=amazoncorp2 header.b=oQ8fmAta;
	arc=none smtp.remote-ip=52.35.192.45
Received: from pdx-out-011.esa.us-west-2.outbound.mail-perimeter.amazon.com (pdx-out-011.esa.us-west-2.outbound.mail-perimeter.amazon.com [52.35.192.45])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2C70260A3834;
	Fri, 27 Nov 2026 14:24:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 2C70260A3834
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amazon.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amazon.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=amazon.de header.i=@amazon.de header.a=rsa-sha256 header.s=amazoncorp2 header.b=oQ8fmAta
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=amazon.de; i=@amazon.de; q=dns/txt; s=amazoncorp2;
  t=1795789494; x=1827325494;
  h=from:to:cc:subject:date:message-id:mime-version:
   content-transfer-encoding;
  bh=0Hc5k4DsAxxmLwGYC+V1QGrOpstcjMHKcFIfgfKPwsU=;
  b=oQ8fmAtaEqvteD1Zm/VatlyCeb6C9MRfIURHkdL1zRsaFkCbd118vOPh
   gkhu1kaZMwK9SxHlKjiUsNgvp9+Bjm+PFNskc2DzXe58Nhrvj/PmEABDI
   4P0g9fVYgdjReSDt7nuGZd6CGvl6UmjJzNcJ7ckIoEsC7kfEULSugSMkO
   ltkfpb+cN42mqttFTqIQE+QKzkZ+ON9R2laxD/ZHLj1iBaxTq2gzsYCcD
   mnfZX8KYVwibsUlsJwJ/xKzeUJ9EEWvwLNKUzbJA1INIV5g1LCnW2wzXe
   SxZb+bg/0gmtMqwi4bQiMkoSvET0p0NbpZb1/BUseDWx/LxBrYaosTsGk
   g==;
X-CSE-ConnectionGUID: +zfGw4f4Q6+6mKoSfTwc/g==
X-CSE-MsgGUID: V3bAQRhVRNe4bFTNWGJrHg==
X-IronPort-AV: E=Sophos;i="6.27,237,1787011200"; 
   d="scan'208";a="35012482"
Received: from ip-10-5-9-48.us-west-2.compute.internal (HELO smtpout.naws.us-west-2.prod.farcaster.email.amazon.dev) ([10.5.9.48])
  by internal-pdx-out-011.esa.us-west-2.outbound.mail-perimeter.amazon.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 27 Nov 2026 14:24:45 +0000
Received: from EX19MTAUWB001.ant.amazon.com [205.251.233.104:13917]
 by smtpin.naws.us-west-2.prod.farcaster.email.amazon.dev [10.0.27.12:2525] with esmtp (Farcaster)
 id 90356893-35b3-49c1-8940-66362bbb7f72; Fri, 27 Nov 2026 14:24:45 +0000 (UTC)
X-Farcaster-Flow-ID: 90356893-35b3-49c1-8940-66362bbb7f72
Received: from EX19D001UWA001.ant.amazon.com (10.13.138.214) by
 EX19MTAUWB001.ant.amazon.com (10.250.64.248) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.2562.57;
 Fri, 27 Nov 2026 14:24:44 +0000
Received: from dev-dsk-gyokhan-1a-87ab81cc.eu-west-1.amazon.com
 (10.253.85.128) by EX19D001UWA001.ant.amazon.com (10.13.138.214) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.2562.57; Fri, 27 Nov 2026
 14:24:43 +0000
From: Gyokhan Kochmarla <gyokhan@amazon.de>
To: <stable@vger.kernel.org>
CC: Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>,
	Simon Horman <horms@verge.net.au>, Florian Westphal <fw@strlen.de>,
	<lvs-devel@vger.kernel.org>, <netfilter-devel@vger.kernel.org>
Subject: [STABLE REQUEST] ipvs: two follow-up race fixes for 7.3.y and older
Date: Fri, 27 Nov 2026 14:24:32 +0000
Message-ID: <20261127142432.1266575-1-gyokhan@amazon.de>
X-Mailer: git-send-email 2.50.1
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-ClientProxiedBy: EX19D031UWC003.ant.amazon.com (10.13.139.252) To
 EX19D001UWA001.ant.amazon.com (10.13.138.214)

Hi,

Please consider these two mainline ipvs commits (v7.4-rc4) for the
stable trees. They fix regressions in commits that stable already
carries. Neither commit has Cc: stable, so they have not been picked
up yet:

  aa9afc79f57b ("ipvs: read flags and seqs in master atomically")
    Fixes: 3e3fe49e8678 ("ipvs: fix buffer overflow when sending sync messages")
    stable trees with 3e3fe49e8678: 7.3.y 6.18.y 6.12.y 6.6.y 6.1.y 5.15.y 5.10.y

  567ca80d77ba ("ipvs: honor the overload state and do not enter it forever")
    Fixes: 3ba20137287f ("ipvs: fix more races around the overload flag")
    stable trees with 3ba20137287f: 7.3.y 6.18.y 6.12.y 6.6.y 6.1.y 5.15.y
    (5.10.y does not have 3ba20137287f, so it is not needed there)

None of these trees has either fix yet. Both commits cherry-pick
cleanly, in the order above, onto the current tips: v7.3.6, v6.18.65,
v6.12.119, v6.6.163, v6.1.193, v5.15.226 and v5.10.275 (aa9afc79f57b
only for v5.10.275).

We carry both commits on 6.18.65 in the Amazon Linux kernel, and
net/netfilter/ipvs/ builds cleanly there.
The other trees are only checked for a clean cherry-pick, not
build-tested.

Thanks,
Gyokhan
