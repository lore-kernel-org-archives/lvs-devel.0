Received: from mail-vk1-f177.google.com (mail-vk1-f177.google.com [209.85.221.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2881333689D
	for <lvs-devel@vger.kernel.org>; Sat, 12 Sep 2026 01:32:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.221.177
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789176761; cv=none; b=LR+CfJokW11LtW73+En+ENu53dL4/7qsm0s6KziCI6aL94jeX4gN0ZEsi/6XCM+EECGLWAnwmEYcYWmjPl7qf6zZLHTwpR7xlpYv2G7CKg9YxFbxI6v5Lfn+F1yiPezybVCZhFtqLS6PyTGRR0nOv0YtmFlaygoz7vFM5rwHDkc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789176761; c=relaxed/simple;
	bh=iO5IsBdVcKSJKd6NiDoXmZ5UkiJqIiE+p+VNxy8J4R4=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=tOarMhaaHHfl53kAjGbokB70k+edkVHPYW0EjuFKyH/cCRzfkDK90Hc+8QBS2qCAVvumvL5ONy37C7iG4pfdb/b5P2Jx6s3ZmDyzocxyARg9g+4SL2ue3A6MY/lTdMHUMhEu+b7P27vdswYdEpIv2FuLGikQ/NB/SaWkEKyHY5g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Xd8xc5/c; arc=none smtp.client-ip=209.85.221.177
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Xd8xc5/c"
Received: by mail-vk1-f177.google.com with SMTP id 71dfb90a1353d-5c66eefc868so1652354e0c.3
        for <lvs-devel@vger.kernel.org>; Fri, 11 Sep 2026 18:32:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1789176758; x=1789781558; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=ZvfD/NIMhAY/sAhVFEMBC5cGXIs+97HZdpNLEZY0qTk=;
        b=Xd8xc5/cMoVy5cXn0lyTLg6FbvW3KammyCP2h7zw7rH+6Hsa8boFJtHmzWAdJusOqH
         qj6Ry3VEYCYFcA8Udv6Rs1JqimYGLf51n0yxG/iLgN/iMooU0E7MkhJbgZEmn5Bcbmhl
         hH9r18LjCq6W+9UIKzweaDqO4U8MwnrzKaDRnAXxIFxTIcfEJfWZbwOaqUK8xsFkeHdD
         GTPZTDvF48q/8jac7e5g07s3357wSdRLcLki3ymQZgd5NPxr8C5XoQSfKVwIlIcrIWex
         FzHTam4HB/7jLBF+HKmiulHhyHIQu5WYgaNrKcLUTGAurk6XR0QMVDU6G1D1JpytEBaP
         iF+g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1789176758; x=1789781558;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=ZvfD/NIMhAY/sAhVFEMBC5cGXIs+97HZdpNLEZY0qTk=;
        b=lBNPsSx4ThgUxV+LzZI3jxMgNzRjdYeGadIuwSjdCC6E/dEHXfMINlYQGT/PcDuKHZ
         8nni1hUn5rNKin4HmQN24CVV+RsT0lnGq0+8Vglxo/LBYQVhT9xNNOeDrXBUrMzAtHWG
         ZviRUfdMIM7Ys/ErpUKCGP7NK/UAEYKxq62BECwPn5fo38oP3KbDrDpBlKSugJ+GL6bg
         AvTpxtVrH+UBDMXeRsna5hS7KiLOQ/O23p/XB9u17jAYbw4NB7TG+5Jh2gUuL6acU0zl
         +NPDvzpx/nVmXXSba7/3FAEph5+uorYCCR3B70lkuj2uGLwMcVBFZdFD/lA0U314ixs7
         2tCg==
X-Forwarded-Encrypted: i=1; AKwUvBy1CrkqU6LEZBZo7pw1bMC7EPMeW2ItglonO+f/TzHmTsfD55ygIQ4xNucJgrLu3IUC0fMxiAAun0U=@vger.kernel.org
X-Gm-Message-State: AFuF++lm+sYVKSLEQoSINULogqLBgG2Z6sAL2oOh7avvuLrUFx7s9nHj
	NYhH1tzvD5EPXQinixnH8Dud254fttcH4YImuLoofGZmdrsN/o//514/
X-Gm-Gg: AYBFou2No+tF7j5m8td2fdwE9aAiCKhJ3Ccm6oh0qoincqaso3VzLoVYjbxX3w3vcCn
	Re5ODw2l9ZQxntIRFLx92/RAFs0TbdBvFkhiLzXm9uYoJ+2VAoSgriQzTYTzydPL7QS3rUYfxqZ
	v+kc0m8uWyxKxGErCs/ifb7LoAUlhO2XRByYFofkkUHhiYzxqj7Fcu/TYg5jXBl98NjbQbCDwAt
	+6mSgpteehTLllqzh0WXy7+huJTaSHKO3aJGX0ka4yAfmIknJHCvDFgR6oqMvN8wMdkyMS0gIG3
	E0+v9mPqmNxe672HIyHfLZaq3RCs+d1Tk/sQ/aDWLWpduqbsQtfqFKgwbLYBK8UaQGNIi5jFLZX
	aWZ/laNWxBnCqDNiLCMiQK1qoCBf4NGUJNmnwz6DKo0ZM3s3eV0fwKHP98BFm0yfz9YhUD0gdtB
	XVGmtqrfv2R8YG2wI329C6sUL9Kj4kbAXrVOjtACLaMqT9s+GYBDhB5LS3DjuoCoGUZ419o9dwa
	YI=
X-Received: by 2002:a05:6122:1c8e:b0:5c7:9445:f468 with SMTP id 71dfb90a1353d-5c8462bff30mr10202112e0c.6.1789176757830;
        Fri, 11 Sep 2026 18:32:37 -0700 (PDT)
Received: from adriano ([190.215.95.120])
        by smtp.gmail.com with ESMTPSA id 71dfb90a1353d-5c84714c380sm4738262e0c.15.2026.09.11.18.32.33
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 11 Sep 2026 18:32:37 -0700 (PDT)
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
Subject: [PATCH 0/4] ipvs: add per-service secure_tcp
Date: Fri, 11 Sep 2026 22:32:12 -0300
Message-ID: <20260912013216.588300-1-adrianox@gmail.com>
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

The flag is part of BACKUP_MASK, so it is preserved on sync to backups.

  1. uapi: define the per-service secure_tcp flags
  2. carry the flag on every connection-creation path (scheduler,
     persistence, RS-initiated, cache-bypass) and on FTP data channels
  3. honor it in the TCP state machine, resolving the stale FIXME
  4. kselftest contrasting a secure vs. a plain service.

Not sure about patch 4... could be dropped or absorbed into ipvs.sh

Adriano Cordova (4):
  ipvs: add flags for per-service secure TCP state table
  ipvs: stamp per-service secure_tcp on new connections
  ipvs: tcp: enable per-connection secure_tcp in state machine
  selftests: netfilter: ipvs: add per-service secure_tcp test

 include/uapi/linux/ip_vs.h                    |   5 +-
 net/netfilter/ipvs/ip_vs_core.c               |  23 +-
 net/netfilter/ipvs/ip_vs_ftp.c                |   8 +-
 net/netfilter/ipvs/ip_vs_proto_tcp.c          |  16 +-
 .../testing/selftests/net/netfilter/Makefile  |   6 +
 .../selftests/net/netfilter/gen_tcp_probe.c   | 127 +++++++
 .../net/netfilter/ipvs_secure_tcp.sh          | 158 +++++++++
 .../net/netfilter/ipvs_secure_tcp_mln.c       | 310 ++++++++++++++++++
 8 files changed, 638 insertions(+), 15 deletions(-)
 create mode 100644 tools/testing/selftests/net/netfilter/gen_tcp_probe.c
 create mode 100755 tools/testing/selftests/net/netfilter/ipvs_secure_tcp.sh
 create mode 100644 tools/testing/selftests/net/netfilter/ipvs_secure_tcp_mln.c

-- 
2.51.0

