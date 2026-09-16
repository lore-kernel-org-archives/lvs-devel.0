Received: from mail-vs2-f12.google.com (mail-vs2-f12.google.com [74.125.227.12])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 975AB4DA9D6
	for <lvs-devel@vger.kernel.org>; Wed, 16 Sep 2026 20:50:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.12
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789591851; cv=none; b=Pvz5z/MmjSVlhRPmNrG9yjOR8zWjYQ9HA5sOLtehvBwpM7gNc70zU+vPs0EkmRZDgIf9yzDNyX2vpE8fzrdloqAGBBAEkEnpgkfdVqxFzTUWYMUC7p9g4qZ/hh6rsMdZWq6++n/nnmwr2BSk/RKOFIYdL/bATX3NksaTadyGm6M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789591851; c=relaxed/simple;
	bh=bEtEzsnXYYFLAJt9P+qU2PoYTGjg6T24CauSUDL8WF8=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=fEBCm0gpePycMzXw+ICKV9/2/2enBJyI5u7DevoOvQF5vTEouYZTbXyQGZ4IE1JAc5qYz8pYKs+DYmPgGA6T3ebTx2Nlk9OUFDhyj3jxYTcxZ8aDhF7U6p0JZsOpU3NXMGducpBiT0WWJl2jodfuK95kub7v9VI0tp1jGPuawwM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=J4dVqgsN; arc=none smtp.client-ip=74.125.227.12
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="J4dVqgsN"
Received: by mail-vs2-f12.google.com with SMTP id ada2fe7eead31-78a7003f9f5so96803137.1
        for <lvs-devel@vger.kernel.org>; Wed, 16 Sep 2026 13:50:26 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1789591824; x=1790196624; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=Maxm8CxuPA4nCelqWyiYlq1sMsSnvsLzLF802cTMgp4=;
        b=J4dVqgsNyphdYMuxc+UxuXr4kUIVvIpw6daBwE6XAiHytFg/fFRsCR/5cnqZ1vD23L
         Kcu2OcyWhrDhffk6KqUEsMXKjDHp4pt6DF26TVzoaY19VsA3WKn7tJJ6tnlparSo6/5r
         u0e3253zSTU0d1aSj+mWkoIVvTuT3AXoDgKmi1Ecw/iWfZ01nnZGLOWCH0S2HOSr+y/P
         LbBiDeDzrIMoQQZuQQXcgktX8Fk56Jf2Zp0ofNth6q/ZlKmqejOKOLClSMMXHiPxRpIk
         zZokK1rnirR4jBgc2b3311B+NINkzczYtnI+4Y8ufF/LMpn0QXTsRRVQ/jh0O9gJR52P
         IpcA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789591824; x=1790196624;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=Maxm8CxuPA4nCelqWyiYlq1sMsSnvsLzLF802cTMgp4=;
        b=wTLZY94n0hKrR9PrHNcSvms6sQEd3j5YStoC8F+nTe3FCAg3F+mbdLE+sCQY8JMKO1
         4Bgv9B5kHgcBsPNMFZ1axUDdiWFoL54Tt5DRB1CpVsO9nBQB3gQtOM5twYWcfDlscErU
         P2Zb3wkVzSrstAhpgag9BAsztt8aXVsf/+Hxyq3tS1WRKDGOxIhStJcRWkMP4DFvCM0A
         BR+WZegqxnOC3wduSyYv1vUi2+dRkIODLFFbnXI/4GXnXs98DLLZP+S9w3q+hx01KNXZ
         px0L19CE/k4/kVfHfkc1UKpFfFqI4ttCiP7FN8C1PKSe5hakoPpsCQERm92UXigePTUi
         cckg==
X-Forwarded-Encrypted: i=1; AKwUvBw5legnXoC9cezsgaTFxp4jbjya44Phd8MJ/5uyxepqYAPmY/NdOcJZlP1J1Jb9yTEuSy2h6vABSvQ=@vger.kernel.org
X-Gm-Message-State: AFuF++kxlRgpqLItMwrOq81qjKvkQjWUcpY3NyzxxSJMQZUx0AY/k+yu
	n/yJEuSJGWfWjd70UMNX2ml6nj7X1OQ5T0T2D4zsc36NnCoUuXoeybl7
X-Gm-Gg: AYBFou2z4QLibaNoTg3CC/7lTRwfWpg701BigZMrmQfqILmiZC/NdpZs8IZFHVzVdzr
	+nHjDittcMo/pF4nDe3IsAyQburp3D7y61tPwwX2/waegBH4oAFdgGDFy2VKrMTBV6evWqOJweD
	lBaHEbqZx5Peb3rFCBY+K624GN1szvnDsnI9nYnbOl0bnLyzU8ScqswUHDuJZQNlOjmiD8UEQQq
	MFY5eI/TgkgPVqhJ/TBghAjL2roRD3oZ4cyDEz+g8Vr60/Pwu5bbK3lytzut9dGEX4mjvcsKq2n
	rmtazcCTrUYq/YuOh7kUf3u0lmypoBRZqseukvqiDql5YyfrBrstEeai7eKEGsAC+m6JldiObAq
	+aJIqVPPXDyvOd6A20HJhPKvSvObGvm+fIQgY8Tm522tgu6qeYP/vLtjYIPtyN/5EEyWLGUcyaV
	Vn2F3rMW1rGRSjy8FKYBkt6LSej4chUQFNtIB3wqfOnHgzI7OmRYeC0BlvQBVEP6E=
X-Received: by 2002:a05:6102:d88:b0:79f:c4b7:1b20 with SMTP id ada2fe7eead31-7a2024bd8f3mr233309137.10.1789591824134;
        Wed, 16 Sep 2026 13:50:24 -0700 (PDT)
Received: from adriano ([190.215.95.120])
        by smtp.gmail.com with ESMTPSA id a1e0cc1a2514c-9832354a8aasm947799241.10.2026.09.16.13.50.20
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 16 Sep 2026 13:50:23 -0700 (PDT)
From: Adriano Cordova <adrianox@gmail.com>
To: Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	Phil Sutter <phil@nwl.cc>,
	"David S . Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Shuah Khan <shuah@kernel.org>,
	netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Adriano Cordova <adrianox@gmail.com>
Subject: [PATCH v3 nf-next 0/3] ipvs: add per-service secure_tcp
Date: Wed, 16 Sep 2026 17:50:01 -0300
Message-ID: <20260916205004.647194-1-adrianox@gmail.com>
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

  1. uapi: define the per-service secure_tcp flags
  2. stamp the flag in ip_vs_bind_dest() (cache-bypass has no dest)
  3. honor it in the TCP state machine, resolving the stale FIXME
  4. kselftest contrasting a secure vs. a plain service

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

Adriano Cordova (3):
  ipvs: add flags for per-service secure TCP state table
  ipvs: tcp: enable per-connection secure_tcp in state machine
  selftests: netfilter: ipvs: add per-service secure_tcp test

 include/uapi/linux/ip_vs.h                    |   2 +
 net/netfilter/ipvs/ip_vs_conn.c               |   4 +
 net/netfilter/ipvs/ip_vs_core.c               |   3 +
 net/netfilter/ipvs/ip_vs_proto_tcp.c          |  16 +-
 .../testing/selftests/net/netfilter/Makefile  |   6 +
 .../selftests/net/netfilter/gen_tcp_probe.c   | 141 ++++++++
 .../net/netfilter/ipvs_secure_tcp.sh          | 153 +++++++++
 .../net/netfilter/ipvs_secure_tcp_mln.c       | 323 ++++++++++++++++++
 8 files changed, 641 insertions(+), 7 deletions(-)
 create mode 100644 tools/testing/selftests/net/netfilter/gen_tcp_probe.c
 create mode 100755 tools/testing/selftests/net/netfilter/ipvs_secure_tcp.sh
 create mode 100644 tools/testing/selftests/net/netfilter/ipvs_secure_tcp_mln.c

-- 
2.51.0

