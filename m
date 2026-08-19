Received: from fanzine2.igalia.com (fanzine2.igalia.com [213.97.179.56])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 71B064B8DDA;
	Wed, 19 Aug 2026 18:16:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.97.179.56
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787163388; cv=none; b=I5WB/iBLEfJNmkn0dSFFyeaJ1MeEGdKjTruaBcpZnEgvBjPlNoFBGBdwOztrHXMuq+Qpt8HQp1qklmebrfDlTENt+8D6OZTC/Um3tlmg2SiwEdi3fZn85gF7ezk5WGqAoLfg1UhYEjI6cMO+CdW7083YOWuTc4n13r0iLZd3oMs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787163388; c=relaxed/simple;
	bh=6sl9aUdgsqr1MH5G5ILk8v03G3sClQ3TxOzzAtQ4RdI=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=putuNIWa9/xnAgJ9uDDUFsSnIglDpcHN4VOvZzdmfUg6jIBPExz5IwB2LMIFt0om1+mAWd0adEq99oaEout5Sd3uKxKLp5PW4KlaSDZqxLALU4vlsWJ3mNUjPlca0rfaf17+RmA3+OY/iVTVKIMfLUZdN+ThUP6gy70JBfIWX4s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com; spf=pass smtp.mailfrom=igalia.com; dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b=FDOOVmnE; arc=none smtp.client-ip=213.97.179.56
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=igalia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b="FDOOVmnE"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=igalia.com;
	s=20170329; h=Cc:To:Message-Id:Content-Transfer-Encoding:Content-Type:
	MIME-Version:Subject:Date:From:From:Reply-To;
	bh=joqvbHqdM9HpjwaYMD+5G7FBevrqRTEc0btSZWyP7jQ=; b=FDOOVmnEQUiY/vACI1d5qtUYpE
	L4yHNPeTmCytvNHHbIcvv+Yp03iI8RpOe8mEW9LqX+tIRa774tmLLgCG2KSW9q/oA1jK3fI1ow9yA
	U94MJCsZyG3xSiOtUAN/8KikJ/hoZOXhWq9ZfxUxwpT+MehaeOdKScINDMNzW3P4WRG0+lftHhyB7
	4xmfXmBa5oaF5ALkEHCVD6olVN7IcueXx/aypnA2nkREVfJpE2Y2n0BQI+Cs2pTMJW2Gmk70OucwW
	tHlQeqjYCanmvCTkPwDkPSiX4RUn/OA/a+RCffMtM4gvXx5i39FYab6cZKyM4lCfjxwMi1PH2Pfcj
	h4ihah+Q==;
Received: from 186-249-147-181.shared.desktop.com.br ([186.249.147.181] helo=[127.0.1.1])
	by fanzine2.igalia.com with esmtpsa 
	(Cipher TLS1.3:ECDHE_X25519__RSA_PSS_RSAE_SHA256__AES_256_GCM:256) (Exim)
	id 1wwkpr-006ENH-JA; Wed, 19 Aug 2026 20:16:23 +0200
From: Mauricio Faria de Oliveira <mfo@igalia.com>
Date: Wed, 19 Aug 2026 15:16:18 -0300
Subject: [PATCH RFC v3 05/13] sysctl, parport: update register_sysctl()
 callers with template arguments
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260819-sysctl-module-aliases-v3-5-aab90569365d@igalia.com>
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

Update callers with dynamic table/path to use template arguments.

Signed-off-by: Mauricio Faria de Oliveira <mfo@igalia.com>
---
 drivers/parport/procfs.c | 26 +++++++++++++++++++-------
 1 file changed, 19 insertions(+), 7 deletions(-)

diff --git a/drivers/parport/procfs.c b/drivers/parport/procfs.c
index cda3221e386ed7a4afc898b3d0313081dee5b49b..7c048e9a973aa96251930e21581aed045c41cc35 100644
--- a/drivers/parport/procfs.c
+++ b/drivers/parport/procfs.c
@@ -13,7 +13,7 @@
  * Cleaned up include files - Russell King <linux@arm.uk.linux.org>
  */
 
-#define SYSCTL_MODULE_ALIASES_DISABLE
+#define SYSCTL_MODULE_ALIASES_UNIQUE_ID
 
 #include <linux/string.h>
 #include <linux/init.h>
@@ -434,13 +434,17 @@ int parport_proc_register(struct parport *port)
 #endif /* IEEE 1284 support */
 	}
 
-	tmp_dir_path = kasprintf(GFP_KERNEL, "dev/parport/%s/devices", port->name);
+#define tmp_dir_tmpl "dev/parport/%s/devices"
+	tmp_dir_path = kasprintf(GFP_KERNEL, tmp_dir_tmpl, port->name);
 	if (!tmp_dir_path) {
 		err = -ENOMEM;
 		goto exit_free_t;
 	}
 
-	t->devices_header = register_sysctl(tmp_dir_path, t->device_dir);
+	t->devices_header = register_sysctl(tmp_dir_path, t->device_dir,
+					    parport_sysctl_template.device_dir,
+					    tmp_dir_tmpl);
+#undef tmp_dir_tmpl
 	if (t->devices_header == NULL) {
 		err = -ENOENT;
 		goto  exit_free_tmp_dir_path;
@@ -448,13 +452,17 @@ int parport_proc_register(struct parport *port)
 
 	kfree(tmp_dir_path);
 
-	tmp_dir_path = kasprintf(GFP_KERNEL, "dev/parport/%s", port->name);
+#define tmp_dir_tmpl "dev/parport/%s"
+	tmp_dir_path = kasprintf(GFP_KERNEL, tmp_dir_tmpl,  port->name);
 	if (!tmp_dir_path) {
 		err = -ENOMEM;
 		goto unregister_devices_h;
 	}
 
-	t->port_header = register_sysctl(tmp_dir_path, t->vars);
+	t->port_header = register_sysctl(tmp_dir_path, t->vars,
+					 parport_sysctl_template.vars,
+					 tmp_dir_tmpl);
+#undef tmp_dir_tmpl
 	if (t->port_header == NULL) {
 		err = -ENOENT;
 		goto unregister_devices_h;
@@ -500,7 +508,8 @@ int parport_device_proc_register(struct pardevice *device)
 		return -ENOMEM;
 
 	/* Allocate a buffer for two paths: dev/parport/PORT/devices/DEVICE. */
-	tmp_dir_path = kasprintf(GFP_KERNEL, "dev/parport/%s/devices/%s", port->name, device->name);
+#define tmp_dir_tmpl "dev/parport/%s/devices/%s"
+	tmp_dir_path = kasprintf(GFP_KERNEL, tmp_dir_tmpl, port->name, device->name);
 	if (!tmp_dir_path) {
 		err = -ENOMEM;
 		goto exit_free_t;
@@ -508,7 +517,10 @@ int parport_device_proc_register(struct pardevice *device)
 
 	t->vars[0].data = &device->timeslice;
 
-	t->sysctl_header = register_sysctl(tmp_dir_path, t->vars);
+	t->sysctl_header = register_sysctl(tmp_dir_path, t->vars,
+					   parport_device_sysctl_template.vars,
+					   tmp_dir_tmpl);
+#undef tmp_dir_tmpl
 	if (t->sysctl_header == NULL) {
 		kfree(t);
 		t = NULL;

-- 
2.47.3

