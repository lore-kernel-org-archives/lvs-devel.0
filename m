Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=46.101.248.176
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795088377;
	b=bqh0TR4/acJ6SmgO1Uaq01az0yhMpK70gXG7qU8H9/bFkeiKv3mtO+0I5JFh4ZaTxtGu
	 N8T6VWsZuUIFMJ9d0i1WfAc2WsyKn89SR17Xy2rGm0s0/CNVl7CMZ9dr5wHBro/eE3pqn
	 jqlhjT1B+f5cRxIt1LT8LAKlUqo/6i1WBEmNkXlN1mpQBydjn4Mu58lTXoEesfq/RBF4Q
	 cDvJOVODPRDm3CodR8BZ2X+0eDWoXalgjggeXktwgZdU7JyKIsYD/sEzhCs7cy7o2bagP
	 VT2az3k7kC2+pVGPGd6jVGG4f5k8QL5AnA5Bkg72unOnhChpshYZxlUOwvmRxxGwxGg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795088377;
	h=DMARC-Filter:Received:Date:From:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:
	 X-CM-TRANSID:X-Coremail-Antispam:X-CM-SenderInfo;
	bh=oQTcKfcyCXeGD+xqwFFJmWR9/TyQjo19bKFT57u0lsk=;
	b=uLOplG1cvDTYvheLabbYEbUy2UCnTnORUiAQWPd3AGk2Ad+7Kv4sJUz0Wp1SHCj7z2WR
	 q/PLmPKIMaifSNZRLCJczHZvkbT3kq2kzWJrSvr53TdKOEcCEtim67p21M9uQNBc8kLeI
	 qeOJgODExUARJ3Ro8NqUCzUsWWLlcKptAlgN6tW6Vk7/rhf25j95PeSK7+ECtBD33HClA
	 bhR2rXXJBdfoFuHCZQw8fuOeq1rgY09DmMLrcUx+89K5UMIpcTYEJ5o9rxSkvJ3+iqZM/
	 T+4vI+AH1K+Fo9OoWtTyjfnHapcN1zaMiZRr4ajLzRtNrCOXCeoa7vZtmOmNSyZecHQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=stu.xjtu.edu.cn;
	spf=pass smtp.mailfrom=stu.xjtu.edu.cn;
	arc=none smtp.remote-ip=46.101.248.176
Received: from zg8tndyumtaxlji0oc4xnzya.icoremail.net (zg8tndyumtaxlji0oc4xnzya.icoremail.net [46.101.248.176])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id ACE4C606A325;
	Thu, 19 Nov 2026 11:39:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org ACE4C606A325
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=stu.xjtu.edu.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=stu.xjtu.edu.cn
Received: from fxxowodeMacBook-Pro.local (unknown [10.181.177.214])
	by app2 (Coremail) with SMTP id NAGowABnF5Tt3_5qovtSAA--.9121S2;
	Thu, 19 Nov 2026 19:39:26 +0800 (CST)
Date: Thu, 19 Nov 2026 06:39:20 -0500
From: "Zhenrong (Daniel) Gu" <zrgu@stu.xjtu.edu.cn>
To: Julian Anastasov <ja@ssi.bg>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	Xing Feng <xingfeng@stu.xjtu.edu.cn>,
	Peng Zhang <p-zhang@xjtu.edu.cn>
Subject: Re: [BUG] ipvs: new connection on a reused port goes to the previous
 real server during conn_tab resize
Message-ID: <av7f6F123V2WDd_u@fxxowodeMacBook-Pro.local>
References: <avx0_13w3xGNdZP8@fxxowodeMacBook-Pro.local>
 <d876f5ef-982a-0ddb-5e75-3434453c2ccf@ssi.bg>
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
In-Reply-To: <d876f5ef-982a-0ddb-5e75-3434453c2ccf@ssi.bg>
X-CM-TRANSID:NAGowABnF5Tt3_5qovtSAA--.9121S2
X-Coremail-Antispam: 1UD129KBjvdXoW7XrWxZF1Duw45XFW3AF17GFg_yoWfZFX_Ww
	s0v3WDAFWUX3WxAanxKa45tay3WF4vqrnxArWIvr1xta4kJry7ua1q93sav3yxZayIq3Z8
	C3Z8t3WUCwnIvjkaLaAFLSUrUUUUjb8apTn2vfkv8UJUUUU8Yxn0WfASr-VFAUDa7-sFnT
	9fnUUIcSsGvfJTRUUUbsAFc2x0x2IEx4CE42xK8VAvwI8IcIk0rVWrJVCq3wAFIxvE14AK
	wVWUJVWUGwA2ocxC64kIII0Yj41l84x0c7CEw4AK67xGY2AK021l84ACjcxK6xIIjxv20x
	vE14v26r4j6ryUM28EF7xvwVC0I7IYx2IY6xkF7I0E14v26r4j6F4UM28EF7xvwVC2z280
	aVAFwI0_GcCE3s1l84ACjcxK6I8E87Iv6xkF7I0E14v26rxl6s0DM2AIxVAIcxkEcVAq07
	x20xvEncxIr21l5I8CrVACY4xI64kE6c02F40Ex7xfMcIj6xIIjxv20xvE14v26r1j6r18
	McIj6I8E87Iv67AKxVWUJVW8JwAm72CE4IkC6x0Yz7v_Jr0_Gr1lF7xvr2IY64vIr41lF7
	I21c0EjII2zVCS5cI20VAGYxC7MxkF7I0En4kS14v26r126r1DMxkIecxEwVCm-wCF04k2
	0xvY0x0EwIxGrwCF04k20xvE74AGY7Cv6cx26r4xJr1UJwCFx2IqxVCFs4IE7xkEbVWUJV
	W8JwC20s026c02F40E14v26r1j6r18MI8I3I0E7480Y4vE14v26r106r1rMI8E67AF67kF
	1VAFwI0_JF0_Jw1lIxkGc2Ij64vIr41lIxAIcVC0I7IYx2IY67AKxVWUJVWUCwCI42IY6x
	IIjxv20xvEc7CjxVAFwI0_Jr0_Gr1lIxAIcVCF04k26cxKx2IYs7xG6r1j6r1xMIIF0xvE
	x4A2jsIE14v26r1j6r4UMIIF0xvEx4A2jsIEc7CjxVAFwI0_Jr0_GrUvcSsGvfC2KfnxnU
	UI43ZEXa7VUbSfO7UUUUU==
X-CM-SenderInfo: 5hqgt5hwuh2iqrsqq2dwxo5ylwxovvfxof0/

Hello Julian,

On Wed, Nov 18, 2026 at 05:26:40PM +0200, Julian Anastasov wrote:
> 
> 	We prefer not to unhash such connections because they will
> go out of our control, eg. we may want to delete them immediately
> on netns cleanup. May be we should add some check to make them
> invisible to packets, such as adding new bit in the cp->flags,
> not depending on the cp->timeout being 0 or not. I can prepare
> some patch to fix this problem.

Thanks, a flag that hides the entry from packet lookups makes sense
to us, and it also keeps ip_vs_conn_put() from re-arming the old
entry's timer. We would be glad to test the patch: we can run the
reproducer (force, grow and noresize modes) on 7.3.3 and report back.

> 	They end up in the same table but in reverse order. The
> old table is freed after RCU grace period, so it should not matter
> which table is checked first.

Understood, thanks for the explanation.

Best regards,
Zhenrong (Daniel) Gu

