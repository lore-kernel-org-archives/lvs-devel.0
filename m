Received: from mail-pl1-f172.google.com (mail-pl1-f172.google.com [209.85.214.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C7D6230F944;
	Wed, 27 Aug 2025 22:52:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.214.172
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1756335124; cv=none; b=KZbu/iyMae0a2dheMNp8cX5OgijPTz/gTXnGJ+gEMPfPiJv3z9hr48Z41HLXncoJIr/wzrgANiqSG1f1/fyVHHLx2bFG1D1l64AJ3s5+3fDFZaZE4TclOvjUirLx9x+/xMJsmcDdJsnY5fSozAYtp2jUxYUZu5qdawYuC2RZ2A4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1756335124; c=relaxed/simple;
	bh=Uij0BhfOj+0ZidIGXIhukTZtp+Ut7e/aX0rtiSEevNc=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=EC1Cgla8X05do1NOEoNK2D1/F0H/aoe+jgVzBEbkKAAjU9+QHyqjIS0mb8ZkQ+S3VRodPF5f27nUHjuetXlFN0Vka+iViimYXe68T7AxN3hpZ1rRBtkQvZtBzXfGeOxrDqeNS6cGyivuRoHU+4KnKaJbIyFzFSR0lg03/s5nh2U=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=NG6IQqkw; arc=none smtp.client-ip=209.85.214.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NG6IQqkw"
Received: by mail-pl1-f172.google.com with SMTP id d9443c01a7336-246ef40cf93so3746125ad.0;
        Wed, 27 Aug 2025 15:52:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1756335122; x=1756939922; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=Uij0BhfOj+0ZidIGXIhukTZtp+Ut7e/aX0rtiSEevNc=;
        b=NG6IQqkwtW9TTdIlXdDF0h5212OG52qDVrW46uR0jft4tYMiHwuuC3JX5AGPrBbhA2
         9i4Fz8c7QPGNAb1HxFeMayfMSUqattGUaw64i7arE1b/1MJ7aMZYxfL9slr7bXN1LXRl
         vrZJUJTmsxDYnh+QbPytQHDeqc1GbEleEcyrVCOUhJMCf30sdXLKe1qcAgaeoiw9ulti
         pD/AVd5G6W6Mo/QqartGkDm8t83dKzeuEVPuGlQwqa8zjKlbKqKEROZ1NFxsV/umPhkW
         Xj0oMFTcOl+wIZy+aC3OMskYgb4vQoJxeI6j+uqw6D3X6cwPTBCi81K3p0BsDSCGGezo
         Hj1w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1756335122; x=1756939922;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=Uij0BhfOj+0ZidIGXIhukTZtp+Ut7e/aX0rtiSEevNc=;
        b=AS9iceYV2O8/gfYdxE2yW7jBiedC8D8qhUqGKiW4+w675IYVO5PY5CQpjUSeRtIM8Q
         H+S0sl6hw0qjpONRrvK0tO6St/VoyL0AlGwIU23SBTgno1cx3EIcJVOM7/KAclHo4pVJ
         ol7B5+nkhf/hlPwT5r0AjzAS3w1+wIJyZOPUhZ7qyHA97F2Hv3J6J7Z9GsYByAmQa50u
         Nzd26lEmutyNB4nZs7HgUnEyxoH/4RXjFXS1HQ4i7sm0PSy+OA7njlWe93RjGCeE3mZU
         Odk1inr0j3pamP5uKKCXmrBROJgsfS3RgccDjn8clAXkcf6L5Rtrp/XUixXilfBonwHs
         pWxg==
X-Forwarded-Encrypted: i=1; AJvYcCU5/jxc/zBtzCK1H2EK3s6AKsbXxSATMp01jpHQGTCoywHNEL7Xxi2TqmnOeKRG3Dq3WvRYaTbr5YN4us45Qd3q@vger.kernel.org, AJvYcCWbOPofAPX1rihS8T8ujpqsVPCt8D1HE4kHQYlRZW0dklY2R2X9zrSFoJJv4+veAgFPNjFhVYP5Kiw=@vger.kernel.org
X-Gm-Message-State: AOJu0YwmfA/JbzZLkGTL3N4wtQ0bD65ORlLle0rbUNB5SgWW2sHKBaSP
	APJrSLX8kbTk5ecKWtsyfzo0RiG8cM8W512Ahp25+k+nhecyW518UlMa
X-Gm-Gg: ASbGncv0jV94DUc4nXvGHBbzyLh9QzFofM3Bb5jiBr69yJ/Kk8Nv0bcyLuK0I4z9aET
	rjY5S4RDIYoVgVC1JzJLjMPuzD4ETtGTDoePibhpNxtUiGUiV5gDZc4g1962YjY9NwOHBEpI+/i
	LB3tdHe9IpZnmvRMWu2a2BrMu2mWYJhIZBFs/yHLlV/WpSUGzznahfTs08iXwPUQo9VjcWCe5g1
	UlDJtyk6MPOcv+3mW1lBnvX3zFfqCfL2pSSZDu4j8+CMp6RhgcNk+DcZONYLO4Rx0hLu/hjH57J
	5ACiVKYwuO5JnSkkIKiY8EteBA3r8LoUVERacgg7OD2akAK7gkDZn9GhrSDeu0TRhM6FjOM7HCD
	77qikvKFNCAykLw8I2NYr6Pzj/mDSTZogCpz02qzpcgxmKmZBc6g=
X-Google-Smtp-Source: AGHT+IHrVZuXjFa4lr5nFs4J6rEpTZ8Se3Vmi5RGE+6GXLQ+ei9Z9L7HolzM3L4ip5iP1jXxzEvhag==
X-Received: by 2002:a17:903:244b:b0:246:cc56:39e5 with SMTP id d9443c01a7336-246cc563f19mr170170815ad.17.1756335121960;
        Wed, 27 Aug 2025 15:52:01 -0700 (PDT)
Received: from DESKTOP-EOHBD4V.localdomain ([180.110.79.182])
        by smtp.gmail.com with ESMTPSA id d9443c01a7336-2467a6f5489sm125908415ad.144.2025.08.27.15.51.58
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 27 Aug 2025 15:52:01 -0700 (PDT)
From: Zhang Tengfei <zhtfdev@gmail.com>
To: zhtfdev@gmail.com
Cc: coreteam@netfilter.org,
	davem@davemloft.net,
	dsahern@kernel.org,
	edumazet@google.com,
	fw@strlen.de,
	horms@verge.net.au,
	ja@ssi.bg,
	kadlec@netfilter.org,
	kuba@kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	pabeni@redhat.com,
	pablo@netfilter.org,
	syzbot+1651b5234028c294c339@syzkaller.appspotmail.com
Subject: Re: [PATCH v2] net/netfilter/ipvs: Use READ_ONCE/WRITE_ONCE for ipvs->enable
Date: Thu, 28 Aug 2025 06:51:55 +0800
Message-Id: <20250827225155.4935-1-zhtfdev@gmail.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20250827223322.4896-1-zhtfdev@gmail.com>
References: <20250827223322.4896-1-zhtfdev@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Hi everyone,

My apologies for the noise and confusion with the multiple v2 submissions.
I sent a malformed reply earlier with no subject.

This patch in *this* thread is the correct and final version for review.
Please disregard the previous malformed email.

Many thanks to Pablo Neira Ayuso for pointing out the formatting error.
