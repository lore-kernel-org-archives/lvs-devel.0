Received: from fanzine2.igalia.com (fanzine2.igalia.com [213.97.179.56])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 561E1395AFA;
	Wed, 19 Aug 2026 02:29:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.97.179.56
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787106564; cv=none; b=ML0XQBlpOw3KVReLL8na+e+is5wRXSzpIv5rSChJsugZw7MhRDqqgLdGRCLgm2sWj6d09gcvAX/XXRbzJWSL13klbsnkNsepIXx70dx+PFVtnRbE6uA6JZYhLoKvRXkYoxQDAk2D85olX1aorjdZuqLv4cgUbSfyvbB/UsRKQtU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787106564; c=relaxed/simple;
	bh=xo2gf3wu4vuqcbt5RW3cYCzb8jBOHYN7pFK1H4VPmAk=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=BL4h7EJqcmBbs5HrToEfEiFssskcJytmTwWv3cXr4FFUQoHue3WGEuv+4Akc3Ehf+BBOAz5v8bSOfo8j9sIWoeVWadFKZKFYKO4FZRcoRMhsWaStxY9xL+b5VZRpuRS17D2ET/NUS91/PZNfsbFtU9slONd5aNribm2uZ1skGIc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com; spf=pass smtp.mailfrom=igalia.com; dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b=mGygRzJM; arc=none smtp.client-ip=213.97.179.56
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=igalia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b="mGygRzJM"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=igalia.com;
	s=20170329; h=Cc:To:Message-Id:Content-Transfer-Encoding:Content-Type:
	MIME-Version:Subject:Date:From:From:Reply-To;
	bh=rX/5Ncw6TkYVmkpNCpB1GzMuhqdAFux3EzHGz3ko38I=; b=mGygRzJMb4At3JlLUZ2Tw5P/gh
	o5C97RTeg2b/Rt6Q2d8QZ0eJhQSVhJiOv7v3hVBfNQMJ7Cu88OKJxSaWb/AclxAoh5QSctb5l51VP
	Oxp9QFhBLJ/Ac5uZMDWXW8emG8zspfpKKZadDzAsu9WynmP72ivYHVsHyJKb6c7jIOccteHDDSaQb
	8KT+ClPTJdD96fhNbSapoj1mRBnfGUIuOiHM56R6+hkoLIY781acUFmjVAKjlos6AOw/A6X7BoK6p
	/OBJnCBmnZGAYtPdChJBsxclxsMqBF8xHR+ARRw8ASvt8LYTqbgSfFvfV8F6qE3+LxwkN6hR7hn97
	XCDLWwRw==;
Received: from 186-249-144-28.shared.desktop.com.br ([186.249.144.28] helo=[127.0.1.1])
	by fanzine2.igalia.com with esmtpsa 
	(Cipher TLS1.3:ECDHE_X25519__RSA_PSS_RSAE_SHA256__AES_256_GCM:256) (Exim)
	id 1wwW3G-005tfG-5O; Wed, 19 Aug 2026 04:29:14 +0200
From: Mauricio Faria de Oliveira <mfo@igalia.com>
Date: Tue, 18 Aug 2026 23:28:01 -0300
Subject: [PATCH RFC v2 02/13] proc: add config option SYSCTL_MODULE_ALIASES
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260818-sysctl-module-aliases-v2-2-d5a69dae5798@igalia.com>
References: <20260818-sysctl-module-aliases-v2-0-d5a69dae5798@igalia.com>
In-Reply-To: <20260818-sysctl-module-aliases-v2-0-d5a69dae5798@igalia.com>
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
index 24f5a36f45df8b1d6831a0f4011c1f6b1987cb52..e6591ec4bcf0ab2ad96ca7dc90b831b2f9873ac2 100644
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
+	  This options adds 'sysctl:*/<path>/<file>' module aliases for the
+	  /proc/sys files registered by modules, so modules for nonexistent
+	  files can be loaded with 'modprobe sysctl:/proc/sys/<path>/<file>'
+	  by userspace when needed.
+
 config PROC_PAGE_MONITOR
  	default y
 	depends on PROC_FS && MMU

-- 
2.47.3

