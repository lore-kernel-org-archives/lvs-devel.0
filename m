Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=91.218.175.125
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794193045;
	b=WVBzNS18GVjHi3P01MlruxewUXs8QDUPZZVOpHV2zYmchcM8AMmDKEFzQM4UCYETfEYA
	 lge4aW8erU6AIDB0Ul3bg+zX8Cg4n5ssYYjN83ntWbnhCKc6hLVYUXM/U6PItvUrebRvi
	 xFBXYbzyD9NBRnUuEC6yUXKakZHysaSrSGXWjUiuNwWfic3sEs7vIKlAvZStZK9StX55O
	 IS0rokdR6Pb7VBSNGhyryqxW0gZA5F11fA1cLBDJ5DQOK1ylhnX9bRv4sVg4T5mwX4Od1
	 PERz/RL4wvqN7UJ8re1ylPaUgIxkLaEiYDXdGZofro2zjD1oPpdIrk5SV/XTnJM7gtA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794193045;
	h=DMARC-Filter:X-Envelope-To:DKIM-Signature:X-Envelope-To:Received:
	 X-Mizu-Trace-ID:X-Migadu-Flow:From:To:Cc:Subject:Date:Message-ID:
	 X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=slSez8APteyrjAQFVPi36IPS8gsYJrd9o7OEPdbfuX0=;
	b=mJWq/XfFl5ZSCa4Gg3HV+z2yikm+D0U+zmeG9et90HmLH50hwzZCHjR8ctriYfh2gDOU
	 hrcCU85fv5njlHDURia1A5pmWFE1rb49ruzVYtSnn2sscqC89/K4KbwFOWy+NPqtAo3Tc
	 Ah9koZJ3AdgP2OHnkgb2q0DZB+rCx0Zxzg7VPTTFs1rPEhCKxoLfm1aKKibRPrFPfZHE3
	 sqfjWBRtcYopY/ENYUIkcHs6jOxvt/cVo0uC2xDO5LW08YzV7h0Io/junQoOQr5R2JyLc
	 WG8a0zadj8bsq6N6wwPxDNHwKqQCLs2Ttep43UdPRcTC+GqAn/7OuViSBwcPkc7Jurg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=linux.dev;
	spf=pass smtp.mailfrom=linux.dev;
	dkim=pass header.d=linux.dev header.i=@linux.dev header.a=rsa-sha256 header.s=key1 header.b=UVo4mFcv;
	arc=none smtp.remote-ip=91.218.175.125
Received: from mta0.migadu.com (out-125.mta0.migadu.com [91.218.175.125])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 86A0D606A320
	for <lvs-devel@vger.kernel.org>; Mon,  9 Nov 2026 02:57:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 86A0D606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.dev
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux.dev header.i=@linux.dev header.a=rsa-sha256 header.s=key1 header.b=UVo4mFcv
X-Envelope-To: lvs-devel@vger.kernel.org
DKIM-Signature: a=rsa-sha256; bh=3ZW9WdZ2Gaii+5kPjGa0iMjjl+g4WUyJikDdM5XjZ10=;
 c=simple/simple; d=linux.dev;
 h=from:to:subject:date:message-id:mime-version:content-type; s=key1;
 t=1794193042; v=1; x=1794797842;
 b=UVo4mFcv9Q4H2cIE2qz310LcnD++QCHbOylIue1Vs0G6jgrLPp+xVvhGyNgSeXOl0pvzHqg3
 4fg7KzseuvrVEmjug3M7XgifnRXdeQ6dywNlzXN2u4Lvyv6LkO3SrcfLrs+JsCsbOeVx0MpIa2W
 gfPb8wsrXh3AUd5fkgs3vTKc=
X-Envelope-To: lvs-devel@vger.kernel.org
Received: by smtp.migadu.com with ESMTPS id e7634fc4ade2e7d9;
	Mon, 09 Nov 2026 02:57:22 +0000
X-Mizu-Trace-ID: e7634fc4ade2e7d9
X-Migadu-Flow: FLOW_OUT
From: Jiayuan Chen <jiayuan.chen@linux.dev>
To: netdev@vger.kernel.org
Cc: Jiayuan Chen <jiayuan.chen@linux.dev>,
	David Ahern <dsahern@kernel.org>,
	Ido Schimmel <idosch@nvidia.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@kernel.org>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Simon Horman <horms@kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	Phil Sutter <phil@nwl.cc>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	Paul Moore <paul@paul-moore.com>,
	Matthieu Baerts <matttbe@kernel.org>,
	Mat Martineau <martineau@kernel.org>,
	Geliang Tang <geliang@kernel.org>,
	Julian Anastasov <ja@ssi.bg>,
	Allison Henderson <achender@kernel.org>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Xin Long <lucien.xin@gmail.com>,
	"D. Wythe" <alibuda@linux.alibaba.com>,
	Dust Li <dust.li@linux.alibaba.com>,
	Sidraya Jayagond <sidraya@linux.ibm.com>,
	Mahanta Jambigi <mjambigi@linux.ibm.com>,
	Tony Lu <tonylu@linux.alibaba.com>,
	Wen Gu <guwen@linux.alibaba.com>,
	linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org,
	bridge@lists.linux.dev,
	linux-security-module@vger.kernel.org,
	mptcp@lists.linux.dev,
	lvs-devel@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	rds-devel@oss.oracle.com,
	linux-sctp@vger.kernel.org,
	linux-s390@vger.kernel.org
Subject: [PATCH net-next 05/14] calipso: annotate data-races around cache sysctls
Date: Mon,  9 Nov 2026 10:52:04 +0800
Message-ID: <20261109025425.328445-6-jiayuan.chen@linux.dev>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <20261109025425.328445-1-jiayuan.chen@linux.dev>
References: <20261109025425.328445-1-jiayuan.chen@linux.dev>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

calipso_cache_enabled and calipso_cache_bucketsize are read without any
lock while their sysctl handlers update them with WRITE_ONCE(). Add
READ_ONCE() to the readers.

Signed-off-by: Jiayuan Chen <jiayuan.chen@linux.dev>
---
 net/ipv6/calipso.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/calipso.c b/net/ipv6/calipso.c
index e399a42e30839..5e63212b60163 100644
--- a/net/ipv6/calipso.c
+++ b/net/ipv6/calipso.c
@@ -204,7 +204,7 @@ static int calipso_cache_check(const unsigned char *key,
 	struct calipso_map_cache_entry *prev_entry = NULL;
 	u32 hash;
 
-	if (!calipso_cache_enabled)
+	if (!READ_ONCE(calipso_cache_enabled))
 		return -ENOENT;
 
 	hash = calipso_map_cache_hash(key, key_len);
@@ -269,7 +269,7 @@ static int calipso_cache_add(const unsigned char *calipso_ptr,
 	struct calipso_map_cache_entry *old_entry = NULL;
 	u32 calipso_ptr_len;
 
-	if (!calipso_cache_enabled || calipso_cache_bucketsize <= 0)
+	if (!READ_ONCE(calipso_cache_enabled) || READ_ONCE(calipso_cache_bucketsize) <= 0)
 		return 0;
 
 	calipso_ptr_len = calipso_ptr[1];
@@ -289,7 +289,7 @@ static int calipso_cache_add(const unsigned char *calipso_ptr,
 
 	bkt = entry->hash & (CALIPSO_CACHE_BUCKETS - 1);
 	spin_lock_bh(&calipso_cache[bkt].lock);
-	if (calipso_cache[bkt].size < calipso_cache_bucketsize) {
+	if (calipso_cache[bkt].size < READ_ONCE(calipso_cache_bucketsize)) {
 		list_add(&entry->list, &calipso_cache[bkt].list);
 		calipso_cache[bkt].size += 1;
 	} else {
-- 
2.43.0

