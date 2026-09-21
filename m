Received: from mail-vs2-f43.google.com (mail-vs2-f43.google.com [74.125.227.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DF5A54E06CD
	for <lvs-devel@vger.kernel.org>; Mon, 21 Sep 2026 20:57:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.43
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790024235; cv=none; b=Bxzj3RlKQ0+3QMhm+ILL8uswKbi2dVcq1mznRBmKJG2W3RD+aZuoFwukjWXDriMjCJLldnMVeGKqxMfC1e2Qa8lHz9EobUAG8ooY6p9lkl2FdWlmUEg8zNxwezyRimz02110Fzp9m1To1k+domt2tQ5aM2Spw3/pRIt8g05k2jw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790024235; c=relaxed/simple;
	bh=QBGnVsKL7XQ6CEv4zCqkLJszS+z3nzpJRHqlJUn7+kk=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=joa84PnNL487hy6KkNyoVyNUBpLABZ4hnmZ1JAeksUbW8au2UWz0vLZKpUziKTKlAHZxExfBmzgfPpp4m64zdi03/cARFPfVu+MMbOqBmbeYPcebfGL8Aucd27JVo+JB+as5Z2wu0CKo0WP5vtpwYAJEBZXMn1LLkG/Jxjgt4Zc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=CQNCXLC/; arc=none smtp.client-ip=74.125.227.43
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CQNCXLC/"
Received: by mail-vs2-f43.google.com with SMTP id ada2fe7eead31-78569cf871bso2264275137.2
        for <lvs-devel@vger.kernel.org>; Mon, 21 Sep 2026 13:57:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790024232; x=1790629032; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=NlPHnolCKbK4Um4HjBJGTEj15gE2VNMVPjQkwtQhdCo=;
        b=CQNCXLC/Egyi753be36mcjSPM9LAd79jOK4BEkUccMmj3KsKRH3IhRi/czF3th3Uhg
         KBDZfIOBV7QRtr6B8Hl9Uqwqh/Ywbz2mlT+IJopqUdPySv8W65F3JXF79KERT2/uQ3di
         ywfUWsY7T/KF4RG0D6ANDE5HURZlCMmd+vFt7y/fw0xhotOinBMIvRHKupB5qfXPmy9T
         7IwpTHToF/JRai2eibx/7DZr8oN7hUCrF/YnVwmAvoHShx5QlqaiKjoj+c3u365TexuS
         uOEC3fj763Px6K2voyeote4jasJfbal9El+ricZIAu+zuSfu4hHF9lxZKxGMKSap/+2b
         LlSw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790024232; x=1790629032;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=NlPHnolCKbK4Um4HjBJGTEj15gE2VNMVPjQkwtQhdCo=;
        b=PHNFQYSv9Msn+vKcePUC2XyLodNTgqauU8oNUeKHYLzC0YdygYe6bWDNY6DMMaWBdT
         +KuHeG8wm+octlM2Zn5XWL/5WYSUI6346fayupkTtBdWfyG+bpX1VmnguXx8vzwSHIvE
         zw6WsrOoZWGT1vJ+i03G20dlirf3rypaSQS5xzjr4o1GC2dJTMQT6QQ/0uaRKzlFcoYO
         t7hOhVsMExptOvugB9chFx0GxRqLD2aNyKz/wKIQl3097DxxSEmOhbF6/VUdlYnQiQna
         qfzVPEIoaSAQMHd8bfxN70B3I22YO+fQAnirCmvx1yhomoHMzxyVq51pKsF0YwaW/XCp
         8JsA==
X-Forwarded-Encrypted: i=1; AKwUvBzrtEcjwiqXCTUR3fidPFuxgZj/CtxIY9wGMdQZ9Q6OaPiTyQHxQMbLLmUZjXwFpiIht8AzASb5m5w=@vger.kernel.org
X-Gm-Message-State: AFuF++nOJW2D5434dMePECHmXFlaiuxzifCP2DTg4D/bwDyOXnIgSE5Y
	C5uk3VNuxAcgr54/0Grr4IzU80M6pwgvDg22eLHePmi5GTQyMxa+cLNvrHdQl0cm
X-Gm-Gg: AYBFou2VMqS6OMlVkweTIGiETzl6TJyDsoLLctjUPkC6emNHdNoyhUDUVj0GlCXzy6e
	a4apgIW/paDzlFw3LgetnkogQE2+EP9V5uCsQpk0Il9APh0w0mFLwLllO/X/H8tJueYWgCaYT+8
	dmRyjOS+l18eFaKmO1tpJgKutSpzn1xIVwjG+lx0XIpdj36tyRFCz6d/Vtc86ziOaMkbBjBlGHB
	yZHrXFnbxQP66pfgANgDxUTE464CKAMwkeyp+K+6hDM7P1hpu7GVdo8mIUbxlNBPS1aCAXl0mM9
	XhgP3Qk/ZxfXO3/VJ6puzZ2tuL5CURZn3zy5yri5S3q1MXslQWxnGvaI8lTVwqracbVEiyIIZc1
	eXt8N82yTF3D/z4f6kVgl4+tHX4QFLRTpcT+wBEF74mcJc2cx3g+quM41ntEn5qY8WJA+/2SNer
	H+7Sn9D1kAvgga/4Fd7qCMxvwQPm9hdncXTjsX5xg1dKRwIdFFks8f1Qt4ARwD+L8=
X-Received: by 2002:a05:6102:5120:b0:7a8:b017:1e3e with SMTP id ada2fe7eead31-7a8b01729b8mr3872343137.21.1790024231821;
        Mon, 21 Sep 2026 13:57:11 -0700 (PDT)
Received: from adriano ([190.215.95.120])
        by smtp.gmail.com with ESMTPSA id 71dfb90a1353d-5c9e591d496sm286884e0c.2.2026.09.21.13.57.09
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 21 Sep 2026 13:57:11 -0700 (PDT)
From: Adriano Cordova <adrianox@gmail.com>
To: Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Florian Westphal <fw@strlen.de>,
	netfilter-devel@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v5 nf-next 0/3] ipvs: add per-service secure_tcp
Date: Mon, 21 Sep 2026 17:57:03 -0300
Message-ID: <20260921205706.1055288-1-adrianox@gmail.com>
X-Mailer: git-send-email 2.51.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

IPVS currently exposes secure_tcp as a per-netns sysctl. It switches the
TCP state machine to the hardened tcp_states_dos table.

These patches make it per-service: a virtual service can set
IP_VS_SVC_F_SECURE_TCP which is passed into IP_VS_CONN_F_SECURE_TCP at
connection creation. set_tcp_state() then selects tcp_states_dos for those
connections with IP_VS_CONN_F_SECURE_TCP set and keeps pd->tcp_state_table
(the netns default, including the nomem floor) otherwise.

  1. uapi: define the per-service secure_tcp flags and stamp the flag in
     ip_vs_bind_dest() (cache-bypass has no dest)
  2. honor it in the TCP state machine, resolving the stale FIXME, and
     document the new default/opt-in split
  3. kselftest contrasting a secure vs. a plain service

Changes in v2:
- Let IP_VS_SVC_F_SECURE_TCP be 0x0100, leaving 0x0040/0x0080 for the
  scheduler flags. Let IP_VS_CONN_F_SECURE_TCP be (1 << 17) and no longer
  in IP_VS_CONN_F_BACKUP_MASK.
- Set flag in ip_vs_bind_dest() instead of at every ip_vs_conn_new()
  call site.
- selftest: send probes with TTL=1 instead of an nft drop, and fix
  Sashiko comments.

Changes in v3:
- Merge patch 1/4 and 2/4
- Re-send patches (v2 dropped patches 3/4 and 4/4)

Changes in v4:
- selftest: check the return values of setsockopt(IP_HDRINCL), sendto()
  and mnl_socket_bind(), and fail do_add() when IPVS does not reply.
- selftest: fix the remaining Sashiko comments: check inet_pton(),
  initialize fam and the parsed addresses, and verify the flags attribute
  length before copying it.

Changes in v5:
- Document secure_tcp as the netns-wide default and the new per-service
  IP_VS_SVC_F_SECURE_TCP opt-in.
- selftest: reword the changelog to "a bare SYN followed by a bare ACK".
- selftest: skip when the ip_vs or ip_vs_rr module is unavailable.
- selftest: check the probe exit status so that a probe which dies after
  the SYN cannot leave the secure-side SYN_RECV assertion passing.

Adriano Cordova (3):
  ipvs: add flags for per-service secure TCP state table
  ipvs: tcp: enable per-connection secure_tcp in state machine
  selftests: netfilter: ipvs: add per-service secure_tcp test

 Documentation/networking/ipvs-sysctl.rst      |   4 +
 include/uapi/linux/ip_vs.h                    |   2 +
 net/netfilter/ipvs/ip_vs_conn.c               |   4 +
 net/netfilter/ipvs/ip_vs_core.c               |   3 +
 net/netfilter/ipvs/ip_vs_proto_tcp.c          |  16 +-
 .../testing/selftests/net/netfilter/Makefile  |   6 +
 .../selftests/net/netfilter/gen_tcp_probe.c   | 158 ++++++++
 .../net/netfilter/ipvs_secure_tcp.sh          | 169 +++++++++
 .../net/netfilter/ipvs_secure_tcp_mln.c       | 337 ++++++++++++++++++
 9 files changed, 692 insertions(+), 7 deletions(-)
 create mode 100644 tools/testing/selftests/net/netfilter/gen_tcp_probe.c
 create mode 100755 tools/testing/selftests/net/netfilter/ipvs_secure_tcp.sh
 create mode 100644 tools/testing/selftests/net/netfilter/ipvs_secure_tcp_mln.c


base-commit: 87b80c2f6b05cad9f0ff9136709c62a0f59923e3
-- 
2.51.0

