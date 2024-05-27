Received: from todd.t-8ch.de (todd.t-8ch.de [159.69.126.157])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D1BCF15A870;
	Mon, 27 May 2024 17:04:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=159.69.126.157
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1716829480; cv=none; b=gr9m070DRQ60oowKbSCgbRLQYNPCDe1fZAm8fVzSp9H3EXvfWbF8RZT/rDQTGAK9fJQa5weYRJdu1JaWMrRk2iHsKFp6XobITPZ0kC0CuQuVl4JiOVlFu/4P4to1k43LGvldp1sqBwA33mrjYAC8crT8B5yvmxrO5nNzVhioL0g=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1716829480; c=relaxed/simple;
	bh=H80RF2inJH8hQaBcuvduDFgfzcA+VjplAQ5kFQmL1Po=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=IBSJPBC9pT1sJ1+iCGITJAeIs/LjcZGyEXEIaVdiz4GZUeYY6XxXrTNZkOkgIxCZ3m9Iz8a1JLEiuwFh+TWKdom6/2HL0LJ9tBuT1t/PAfpRSny91Mb14pusV/aEmChCPWZP8iH/HLwxOkyDxb2kuxK/qxBHX34DZuDSUjv7xhE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=weissschuh.net; spf=pass smtp.mailfrom=weissschuh.net; dkim=pass (1024-bit key) header.d=weissschuh.net header.i=@weissschuh.net header.b=lykB7CEV; arc=none smtp.client-ip=159.69.126.157
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=weissschuh.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=weissschuh.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=weissschuh.net header.i=@weissschuh.net header.b="lykB7CEV"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=weissschuh.net;
	s=mail; t=1716829474;
	bh=H80RF2inJH8hQaBcuvduDFgfzcA+VjplAQ5kFQmL1Po=;
	h=From:Subject:Date:To:Cc:From;
	b=lykB7CEVDVoVA59YXs49BpHm+KO0HE1bRyCr4QnyY6p6dzahJubclXYE9w2KFZxsN
	 nlJ/Ak7Ll+fbij3g1EMOHNWJlC1HrhJjcvSJ2Zu87gAUibw+czUOOMaKfG62gaM9BI
	 Wxh1XNdhsZGUQ887OBq5Gcem/Mnr1f+g7bkN71l4=
From: =?utf-8?q?Thomas_Wei=C3=9Fschuh?= <linux@weissschuh.net>
Subject: [PATCH net-next 0/5] net: constify ctl_table arguments of utility
 functions
Date: Mon, 27 May 2024 19:04:18 +0200
Message-Id: <20240527-sysctl-const-handler-net-v1-0-16523767d0b2@weissschuh.net>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
X-B4-Tracking: v=1; b=H4sIABK9VGYC/x2MQQrDIBAAvxL2nAVjFEq/EnIQ3bYLYS2uhATJ3
 2N7HJiZBkqFSeE5NCi0s3KWDtM4QPwEeRNy6gzWWGe8nVFPjXXDmEUrdiNtVFCo4sO65ELyYfI
 Bev4t9OLjv17gJwgdFdbrugFryPDjdAAAAA==
To: "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, David Ahern <dsahern@kernel.org>, 
 Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, 
 Pablo Neira Ayuso <pablo@netfilter.org>, 
 Jozsef Kadlecsik <kadlec@netfilter.org>
Cc: Joel Granados <j.granados@samsung.com>, 
 Luis Chamberlain <mcgrof@kernel.org>, netdev@vger.kernel.org, 
 linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, 
 netfilter-devel@vger.kernel.org, coreteam@netfilter.org, 
 =?utf-8?q?Thomas_Wei=C3=9Fschuh?= <linux@weissschuh.net>
X-Mailer: b4 0.13.0
X-Developer-Signature: v=1; a=ed25519-sha256; t=1716829474; l=3222;
 i=linux@weissschuh.net; s=20221212; h=from:subject:message-id;
 bh=H80RF2inJH8hQaBcuvduDFgfzcA+VjplAQ5kFQmL1Po=;
 b=f4dtzPRwq7hYsYkNlNaMAgNAjPEchqO7TPLED6v0BvG/ikf1UG8uMn/l+V1i+txS4gPhKQtp4
 8/NtVLwuqwXDNf8sY091gbCsbUzHVD6WB09Nf02qaGf7uLoKHjT1P9b
X-Developer-Key: i=linux@weissschuh.net; a=ed25519;
 pk=KcycQgFPX2wGR5azS7RhpBqedglOZVgRPfdFSPB1LNw=

The sysctl core is preparing to only expose instances of
struct ctl_table as "const".
This will also affect the ctl_table argument of sysctl handlers.

As the function prototype of all sysctl handlers throughout the tree
needs to stay consistent that change will be done in one commit.

To reduce the size of that final commit, switch utility functions which
are not bound by "typedef proc_handler" to "const struct ctl_table".

No functional change.

This patch(set) is meant to be applied through your subsystem tree.
Or at your preference through the sysctl tree.

Motivation
==========

Moving structures containing function pointers into unmodifiable .rodata
prevents attackers or bugs from corrupting and diverting those pointers.

Also the "struct ctl_table" exposed by the sysctl core were never meant
to be mutated by users.

For this goal changes to both the sysctl core and "const" qualifiers for
various sysctl APIs are necessary.

Full Process
============

* Drop ctl_table modifications from the sysctl core ([0], in mainline)
* Constify arguments to ctl_table_root::{set_ownership,permissions}
  ([1], in mainline)
* Migrate users of "ctl_table_header::ctl_table_arg" to "const".
  (in mainline)
* Afterwards convert "ctl_table_header::ctl_table_arg" itself to const.
  (in mainline)
* Prepare helpers used to implement proc_handlers throughout the tree to
  use "const struct ctl_table *". ([2], in progress, this patch)
* Afterwards switch over all proc_handlers callbacks to use
  "const struct ctl_table *" in one commit. ([2], in progress)
  Only custom handlers will be affected, the big commit avoids a
  disruptive and messy transition phase.
* Switch over the internals of the sysctl core to "const struct ctl_table *" (to be done)
* Switch include/linux/sysctl.h to "const struct ctl_table *" (to be done)
* Transition instances of "struct ctl_table" through the tree to const (to be done)

A work-in-progress view containing all the outlined changes can be found at
https://git.sr.ht/~t-8ch/linux sysctl-constfy

[0] https://lore.kernel.org/lkml/20240322-sysctl-empty-dir-v2-0-e559cf8ec7c0@weissschuh.net/
[1] https://lore.kernel.org/lkml/20240315-sysctl-const-ownership-v3-0-b86680eae02e@weissschuh.net/
[2] https://lore.kernel.org/lkml/20240423-sysctl-const-handler-v3-0-e0beccb836e2@weissschuh.net/

---
Thomas Weißschuh (5):
      net/neighbour: constify ctl_table arguments of utility function
      net/ipv4/sysctl: constify ctl_table arguments of utility functions
      net/ipv6/addrconf: constify ctl_table arguments of utility functions
      net/ipv6/ndisc: constify ctl_table arguments of utility function
      ipvs: constify ctl_table arguments of utility functions

 net/core/neighbour.c           | 2 +-
 net/ipv4/sysctl_net_ipv4.c     | 6 ++++--
 net/ipv6/addrconf.c            | 8 ++++----
 net/ipv6/ndisc.c               | 2 +-
 net/netfilter/ipvs/ip_vs_ctl.c | 7 ++++---
 5 files changed, 14 insertions(+), 11 deletions(-)
---
base-commit: 1613e604df0cd359cf2a7fbd9be7a0bcfacfabd0
change-id: 20240523-sysctl-const-handler-net-824d4ad5a15a

Best regards,
-- 
Thomas Weißschuh <linux@weissschuh.net>

