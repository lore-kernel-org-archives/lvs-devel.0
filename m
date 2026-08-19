Received: from fanzine2.igalia.com (fanzine2.igalia.com [213.97.179.56])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C16F54A2E21;
	Wed, 19 Aug 2026 18:16:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.97.179.56
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787163370; cv=none; b=cBIJyl5e+NoJdUaTCXxvw8S+vpg9N2NcmRBgFYuqdo9bYib8PB+EciPSAEt5HVBVtp0lZD7Fj4IwHMvJf6Wi3REW6UZTeTR99EL9mJ9GbcSbw/9jgWmVJzW8PwTSSGWDEUOAe9yD9H+9UWH5zdqYOhkEvUEtstqfuInSoHEdt+0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787163370; c=relaxed/simple;
	bh=YGnndkyJz+5FcFnyiRJNeZgq4ppwAqnOYIuLjGZwL9I=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=rsQiebV1MAQxUgrp3U91rY6dgF7Tx2As0MCT63GsP/lDTFryBunC3pjnwGJd1MBLHQ3CiKhG/i6Pbbo0AxvpUOfe+5owggj0k+B9AFxrGCqbL6LEZ7PN1bRMROQ5pcODQ3hcHsgWZeuzqE5msGcfqkOz0i/s2Q6J5viuUBDZGUA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com; spf=pass smtp.mailfrom=igalia.com; dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b=qC3QekU8; arc=none smtp.client-ip=213.97.179.56
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=igalia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b="qC3QekU8"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=igalia.com;
	s=20170329; h=Cc:To:Message-Id:Content-Transfer-Encoding:Content-Type:
	MIME-Version:Subject:Date:From:From:Reply-To;
	bh=ejMylrBJLD/RiSl9pzRqjWJL0id2KLBq0dPByhCupIc=; b=qC3QekU8LcLUtIfZnNeTZcPd71
	p5zsUzeyCNS89SPyLFrKlih+UqpUsSnE1uYZQbCbJm4vLP80WBnOBfjuV+wOfWgWlZKCJ23fG7wIt
	MPNUl6u3dh5ohGQ9foDpzunb6pkidUsf4fFsBi3OjT41Ce0hEAcoR2SyZy/3lM05AaaIKQ2kFd+bt
	nfBElxipJVjzC6lbIGPtHN/ymdTmDBwXhrGF4NwPH4JZr5BbjlccQ+p9xodwaJRSTb1goQJo9umDb
	fcQ8+1iimu5Cr1rXCzQD+owsME2B+gArhPqTOelPBQ1c9ER0sOt52+dllNt8l722BfEvhNne2xk7/
	+9C2q/FA==;
Received: from 186-249-147-181.shared.desktop.com.br ([186.249.147.181] helo=[127.0.1.1])
	by fanzine2.igalia.com with esmtpsa 
	(Cipher TLS1.3:ECDHE_X25519__RSA_PSS_RSAE_SHA256__AES_256_GCM:256) (Exim)
	id 1wwkpV-006ENH-W9; Wed, 19 Aug 2026 20:16:02 +0200
From: Mauricio Faria de Oliveira <mfo@igalia.com>
Date: Wed, 19 Aug 2026 15:16:15 -0300
Subject: [PATCH RFC v3 02/13] proc: add config option SYSCTL_MODULE_ALIASES
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260819-sysctl-module-aliases-v3-2-aab90569365d@igalia.com>
References: <20260819-sysctl-module-aliases-v3-0-aab90569365d@igalia.com>
In-Reply-To: <20260819-sysctl-module-aliases-v3-0-aab90569365d@igalia.com>
To: Kees Cook <kees@kernel.org>, Joel Granados <joel.granados@kernel.org>, 
 Nathan Chancellor <nathan@kernel.org>, Nicolas Schier <nsc@kernel.org>, 
 "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, 
 Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, 
 Simon Horman <horms@kernel.org>
Cc: kernel-dev@igalia.com, linux-riscv@lists.infradead.org, 
 linux-kernel@vger.kernel.org, fsverity@lists.linux.dev, 
 keyrings@vger.kernel.org, bpf@vger.kernel.org, 
 linux-fsdevel@vger.kernel.org, linux-kbuild@vger.kernel.org, 
 netdev@vger.kernel.org, linux-wpan@vger.kernel.org, 
 lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, 
 coreteam@netfilter.org, linux-sctp@vger.kernel.org, 
 linux-rdma@vger.kernel.org, linux-s390@vger.kernel.org, 
 bridge@lists.linux.dev, mptcp@lists.linux.dev, rds-devel@oss.oracle.com, 
 virtualization@lists.linux.dev, Mauricio Faria de Oliveira <mfo@igalia.com>
X-Mailer: b4 0.14.2

Add a config option for the 'sysctl:' module aliases feature.

Signed-off-by: Mauricio Faria de Oliveira <mfo@igalia.com>
---
 fs/proc/Kconfig | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/fs/proc/Kconfig b/fs/proc/Kconfig
index 24f5a36f45df8b1d6831a0f4011c1f6b1987cb52..ea77cb2b0b0e3e52ff2d19d9bb16d5a3f5ab8162 100644
--- a/fs/proc/Kconfig
+++ b/fs/proc/Kconfig
@@ -98,6 +98,19 @@ config SYSCTL
 	  building a kernel for install/rescue disks or your system is very
 	  limited in memory.
 
+config SYSCTL_MODULE_ALIASES
+	bool "'sysctl:' module aliases (EXPERIMENTAL)"
+	depends on SYSCTL && MODULES
+	default n
+	help
+	  The /proc/sys files registered by a module do not exist until the
+	  module is loaded; meanwhile, userspace cannot find or access them.
+
+	  This option adds 'sysctl:*/<path>/<file>' module aliases for the
+	  /proc/sys files registered by modules, so modules for nonexistent
+	  files can be loaded with 'modprobe sysctl:/proc/sys/<path>/<file>'
+	  by userspace when needed.
+
 config PROC_PAGE_MONITOR
  	default y
 	depends on PROC_FS && MMU

-- 
2.47.3

