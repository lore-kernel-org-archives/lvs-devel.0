Received: from mail-wm1-f44.google.com (mail-wm1-f44.google.com [209.85.128.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7B4ED408258
	for <lvs-devel@vger.kernel.org>; Tue, 24 Mar 2026 18:51:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.44
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774378287; cv=none; b=a9s97DO0Zb0ReYlm4H9qApdwJhmPcV0MG7ycDwMAqmfhNJEjOh5cbxOoQ4dClLUfSl+S7UltuFzqUdsddwk9AZYkZmoyF9cEkZw0Rr40mWdQEc3Kg6jvXN3uxEoykw8GL37/5PaGYkX1lUnfj/+ZFUvP13KRM5tGsUYbcakcogw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774378287; c=relaxed/simple;
	bh=JBmYqYj+ly1oO/Lbkh369Gp9ml6cCcDXXpGPuv/yl8s=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=cbidD/DnFt/fVzX1m3CDJUqKcdRNGWrvJFRlsxkJLLWORtO0Y73YV28PDUI0lQcDnc0+LcigDzmYhZAQGlX/mAKWmnJjuPYumAx62RxnF+NMLl+FxBz06b/ZgHoanse9PgiiimdpC0+6GHKS6lyDwoKzYz2USbnh7OOhU4ZIuL8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=g3bAiTbn; arc=none smtp.client-ip=209.85.128.44
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="g3bAiTbn"
Received: by mail-wm1-f44.google.com with SMTP id 5b1f17b1804b1-4852a9c6309so38167195e9.0
        for <lvs-devel@vger.kernel.org>; Tue, 24 Mar 2026 11:51:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1774378282; x=1774983082; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=JBmYqYj+ly1oO/Lbkh369Gp9ml6cCcDXXpGPuv/yl8s=;
        b=g3bAiTbn7Lp2p/Kme0nAWbH1GSV16HVsqyepLkbgGaoFBE7OOfZCUoEfZUcgEAtI6d
         msY22XW8662KOSyt3Sfv/QOWCTQs/D20bQMV61n346RWfg581BZYfYqLkMKLn2PirCCU
         xn896ur3rka2GmZNcCcNNlWyzTxCUOXeloFp9G0i1Z0lGg52yEiX+AE7JFavhnZjn/ES
         9770vxjmCSoHKuIZkfjaXWElRfXp0/TK+y6JW57V9A2jP0vdOHaumIM9gHuokB0EIUdy
         d5vmibaYR3iV6Xov0fwWQOcA5nAAhaFaIEYiUoV2USZdvxs+3xSje/EIrnBPinpnGNeN
         B3Wg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1774378282; x=1774983082;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to;
        bh=JBmYqYj+ly1oO/Lbkh369Gp9ml6cCcDXXpGPuv/yl8s=;
        b=of6RVOgqFGbVaDC9NiKKWlSHDxmgSjiIVM0WL2AHJpdisIxpKZ6fi3MDDzz1bk8Lxr
         8t6Z9+xufpn2E3qtrDejLy7bSyZ5A+YEJkRSIMABJldjvMBkDOtpkjeSZhpsw++Ey7hf
         /GwaCs/ezH26LVGtjLq0iPskbSCzs6NWMrvrnGUDlG2fpaPvOVC9iZpNNJ/dXBSK8fDq
         iq+3AsvL+FAF5CHquO/rAWSwpsw5J852OaimGDB6lwHb+qsawUDMYg323M1CJpfVRMy9
         3xzU+DFpsBhQ2k0UB6WTu1C/SMeS7yVM0bd71Tw4+cSBRIdfHlYx/Xh164EX3InUmGhE
         YXJw==
X-Forwarded-Encrypted: i=1; AJvYcCWQZqifBw7CD2HJwvYwNXRCIQjVnJzowr5zM3QHq3RQ9M+h4G57TV6V9nNv/TSDACcLF98ruvtmM6I=@vger.kernel.org
X-Gm-Message-State: AOJu0Yz2BRXw/GKP/K6E0AdnAdYhEElYVdaYqIwDivL5YjB7XmObsnHv
	DIznoZ3w3b1kU0H3laVIft2MPOVT1F6DzfpsAUKY7VsFb9HCWWZmX/2i
X-Gm-Gg: ATEYQzx+EEEgBTiChcOY7thAv9fkAgvVQquHTiV0nNqMCZ5kgOTLelWjtrQdPl3+jgG
	UTUtP8nNtSssxRZuQZlhl98h/tXxqsGTKs8F0TyXnaGDuMIdH+UvkODvNXGyIC6zdPMu0d+tCBk
	FZS4ET6EK5nVke0njpJlmmjnRqcEU5Qv76liMC5F2GhZjJzrByRAakE6O2LGt2sJCF2hbGvtJX5
	ilhPznvzuNQbUomVZfAZ6AKIzlSaREvSjnSyk8QFhRvDFZsAhgeMlExRp7VJtOgdfNXq2MhKPe4
	9CLqp7D+QKFnFTOVWprW3TXNsRxW4f/QJj/zdnDUqSkoNpB9geF6MOgvtLdB0/Dd7t/RbkzzAEQ
	ieNqqG6N/kZVkpl9Qawj3bmeO7l244pk+bPgKUuqg/9Niv9tsJZetZdrwm6eUu7ghpZWkit9PJu
	9uZna8GeqqwAHUF27PARUtgStEdqDMFebtGMr+L8I=
X-Received: by 2002:a05:600c:3b16:b0:485:45fb:3472 with SMTP id 5b1f17b1804b1-48715fc3a88mr12954475e9.7.1774378282409;
        Tue, 24 Mar 2026 11:51:22 -0700 (PDT)
Received: from localhost.localdomain ([102.164.100.74])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-487165bea11sm6528345e9.1.2026.03.24.11.51.19
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 24 Mar 2026 11:51:21 -0700 (PDT)
From: David Dull <monderasdor@gmail.com>
To: longman@redhat.com
Cc: linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	linux-sched@vger.kernel.org,
	kuba@kernel.org,
	pabeni@redhat.com,
	horms@kernel.org,
	David Dull <monderasdor@gmail.com>
Subject: Re: [PATCH net] netfilter: nfnetlink_queue: fix entry leak in bridge verdict error path
Date: Tue, 24 Mar 2026 20:51:09 +0200
Message-ID: <20260324185110.1651-1-monderasdor@gmail.com>
X-Mailer: git-send-email 2.49.0.windows.1
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Hyunwoo,=0D
=0D
I reviewed the change and the reasoning looks correct to me.=0D
=0D
nfqnl_recv_verdict() dequeues the entry using find_dequeue_entry(), which t=
ransfers ownership of the nf_queue_entry to this function. After that point=
 the function becomes responsible for either reinjecting or freeing the ent=
ry.=0D
=0D
In the PF_BRIDGE path the code calls nfqa_parse_bridge() to parse the VLAN =
attributes coming from userspace. If the attribute set is malformed (for ex=
ample NFQA_VLAN present but NFQA_VLAN_TCI missing), nfqa_parse_bridge() ret=
urns an error. Before this patch, the function would return immediately in =
that situation.=0D
=0D
Because the entry had already been dequeued, returning directly means the n=
f_queue_entry object and its associated sk_buff are never released. That al=
so leaves any held references such as net_device and struct net references =
alive. If a userspace program repeatedly sends malformed verdict messages, =
this path could leak queue entries and eventually exhaust kernel memory.=0D
=0D
Your change fixes this by calling nfqnl_reinject(entry, NF_DROP) before ret=
urning. This matches the error handling pattern used elsewhere in the file:=
 once the entry is owned by the verdict handler, it must be reinjected or d=
ropped so the resources are released correctly.=0D
=0D
So the logic now becomes:=0D
=0D
1. dequeue the entry=0D
2. attempt bridge attribute parsing=0D
3. if parsing fails, explicitly drop the packet via nfqnl_reinject()=0D
4. return the error to the caller=0D
=0D
That ensures the queue entry and skb are properly handled even in the malfo=
rmed attribute case.=0D
=0D
The Fixes tag also makes sense since the leak path was introduced when brid=
ge verdict handling started using NFQA_VLAN/NFQA_L2HDR.=0D
=0D
Overall the change is small, consistent with the existing reinjection model=
, and addresses a clear ownership leak in the error path.=0D
=0D
Reviewed by : David Dull=
