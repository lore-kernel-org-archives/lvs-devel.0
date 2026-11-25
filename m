Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=13.75.44.102
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795587762;
	b=UhMlkl6lp5DxG2xY0JuXkcg4Q5XiXHyvVMiQ9HcpXxx4RkM7szRUNrNYYCva8wbjXaDl
	 3MrCXXwTYP/VSwVNzvs7peg94gBJmOoh90bp7NfkwzNDe2bzM9BJfjPlDpMtxcUi6gZPD
	 Mak3vJpjynADS9QS1YKTdEtFnvL7yAWHvV1IjDhP+jrnSfvS9bASszg/pKJmaw9dBSOvy
	 8O2Ipp5wfv4oTQ9SkebHpeFJlOorgH3yAjNdx6XBMK2vrC/f9w8Z7G0agCaQwFDEmOyS/
	 CtpFSRlvF+pWH1U2ipvROjtODvRI/3NXmnxmNZVgWgpuIVQraqSqQVQBtP9OTohwEgw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795587762;
	h=DMARC-Filter:Received:Date:From:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:
	 X-CM-TRANSID:X-Coremail-Antispam:X-CM-SenderInfo;
	bh=ukAnIx9CIIZ9kjRSJQFLi2KYR1rvbJhbQwVVFeyyRFQ=;
	b=4YbhKejN782lphbMwDO6d/v2ELM6Kx4uSjtD/J+mQAEJd7ei0Ntq+QuTyBNXQPiJeBHo
	 8gJ1KazgMVdv3NpE3UyhvOK/1flkR/c2YAFo5XWW+GtysRKCRxKQZflzUFizAIahU3Mwp
	 YG6NRHqp9nbhI+rTVSFc8y1wL4FrdbudWEMuYblHByVrn75vZTjTxxHhd/Z3eu4Xd11pU
	 Do2XG0QlMfcfwY91iFulqRXBEPy6DWpf/fGGATe0NC26umeDRzN0vc0ABuDLLWpSFAeTl
	 SI/udM9R3Ij/I9k0cYGUDaNN+BTbfSgnQOucO4Ur94fi/OOkRTysdWWIRPJN4fYAKsg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=stu.xjtu.edu.cn;
	spf=pass smtp.mailfrom=stu.xjtu.edu.cn;
	arc=none smtp.remote-ip=13.75.44.102
Received: from azure-sdnproxy.icoremail.net (azure-sdnproxy.icoremail.net [13.75.44.102])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 81790606A32C;
	Wed, 25 Nov 2026 06:22:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 81790606A32C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=stu.xjtu.edu.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=stu.xjtu.edu.cn
Received: from fxxowodeMacBook-Pro.local (unknown [10.181.177.214])
	by app2 (Coremail) with SMTP id NAGowAB3KZasfgZrTAqDAA--.38917S2;
	Wed, 25 Nov 2026 14:22:37 +0800 (CST)
Date: Wed, 25 Nov 2026 01:22:31 -0500
From: "Zhenrong (Daniel) Gu" <zrgu@stu.xjtu.edu.cn>
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	Xing Feng <xingfeng@stu.xjtu.edu.cn>,
	Peng Zhang <p-zhang@xjtu.edu.cn>
Subject: Re: [BUG] ipvs: new connection on a reused port goes to the previous
 real server during conn_tab resize
Message-ID: <awZ-p0v7Cr2hBfon@fxxowodeMacBook-Pro.local>
References: <avx0_13w3xGNdZP8@fxxowodeMacBook-Pro.local>
 <d876f5ef-982a-0ddb-5e75-3434453c2ccf@ssi.bg>
 <av7f6F123V2WDd_u@fxxowodeMacBook-Pro.local>
 <a5aa2a54-d8ea-bbe1-3a72-d672d6fd92c4@ssi.bg>
 <awWHfO0EgdLoOxLi@fxxowodeMacBook-Pro.local>
 <4da25158-cbab-1186-b948-e17b13262bc3@ssi.bg>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4da25158-cbab-1186-b948-e17b13262bc3@ssi.bg>
X-CM-TRANSID:NAGowAB3KZasfgZrTAqDAA--.38917S2
X-Coremail-Antispam: 1UD129KBjvdXoWruw1kKrWDKw13CFyfZF17GFg_yoWDtFc_ur
	WfWF97Ca1qyay8Ca18AF1rArn3Ga4UWrZrZFn0yrWftFyDGayDCF4kWFWS9wn3X34fJF1a
	yrs0ga4akry29jkaLaAFLSUrUUUUjb8apTn2vfkv8UJUUUU8Yxn0WfASr-VFAUDa7-sFnT
	9fnUUIcSsGvfJTRUUUbVxFc2x0x2IEx4CE42xK8VAvwI8IcIk0rVWrJVCq3wAFIxvE14AK
	wVWUJVWUGwA2ocxC64kIII0Yj41l84x0c7CEw4AK67xGY2AK021l84ACjcxK6xIIjxv20x
	vE14v26r4j6ryUM28EF7xvwVC0I7IYx2IY6xkF7I0E14v26r4j6F4UM28EF7xvwVC2z280
	aVAFwI0_Cr1j6rxdM28EF7xvwVC2z280aVCY1x0267AKxVWxJr0_GcWle2I262IYc4CY6c
	8Ij28IcVAaY2xG8wAqx4xG64xvF2IEw4CE5I8CrVC2j2WlYx0E2Ix0cI8IcVAFwI0_JF0_
	Jw1lYx0Ex4A2jsIE14v26r4j6F4UMcvjeVCFs4IE7xkEbVWUJVW8JwACjcxG0xvEwIxGrw
	ACjI8F5VA0II8E6IAqYI8I648v4I1lc7CjxVAaw2AFwI0_JF0_Jw1lc2xSY4AK6svPMxAI
	w28IcxkI7VAKI48JMxAIw28IcVCjz48v1sIEY20_GF4UJr1UMxC20s026xCaFVCjc4AY6r
	1j6r4UMI8I3I0E5I8CrVAFwI0_Jr0_Jr4lx2IqxVCjr7xvwVAFwI0_JrI_JrWlx4CE17CE
	b7AF67AKxVWUAVWUtwCIc40Y0x0EwIxGrwCI42IY6xIIjxv20xvE14v26r1j6r1xMIIF0x
	vE2Ix0cI8IcVCY1x0267AKxVWUJVW8JwCI42IY6xAIw20EY4v20xvaj40_Jr0_JF4lIxAI
	cVC2z280aVAFwI0_Jr0_Gr1lIxAIcVC2z280aVCY1x0267AKxVWUJVW8JbIYCTnIWIevJa
	73UjIFyTuYvjfUeTmhDUUUU
X-CM-SenderInfo: 5hqgt5hwuh2iqrsqq2dwxo5ylwxovvfxof0/

Hello Julian,

On Wed, Nov 25, 2026 at 07:04:57AM +0200, Julian Anastasov wrote:
> 	Thank you for the testing! Due to the Sashiko concerns [1]
> I'll post new version later today:
> 
> [1]
> https://sashiko.dev/#/patchset/20261124160226.103532-1-ja%40ssi.bg
> 
> 	Here is the v2 that I'll post, in case you want to do
> the main test again. The difference is that we do not mark
> the connection as reused early because a retransmitted SYN
> should hit the old connection while it is using confirmed
> conntrack and is not expired yet (2nd SYN comes before the
> expiration):
> 
> [PATCH RFC nf v2] ipvs: fix connection reuse with the resizable hash tables

Thanks for the update. We reran the tests on v2 (same net tree
af6737b90, 7.4.0-rc3+ in the 8-vCPU KVM guest). All previous
tests continue to pass, and in addition, we ran a 30s force
mode test with net.ipv4.vs.conntrack=1 and active nf_conntrack
(7438 reused-port connections): 0 misrouted, delayed, or
failed connections.

Tested-by: Zhenrong (Daniel) Gu <zrgu@stu.xjtu.edu.cn>

Thanks,
Zhenrong (Daniel) Gu

