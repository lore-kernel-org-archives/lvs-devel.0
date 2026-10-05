Received: from mail-dy1-f180.google.com (mail-dy1-f180.google.com [74.125.82.180])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 34E8E445AD5
	for <lvs-devel@vger.kernel.org>; Mon,  5 Oct 2026 23:08:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.82.180
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791241705; cv=none; b=EVAItCxL4LkuU0Qe/qI70RMAyRHnLW6x6USbpbP244JHR3wfBHbP3BYIAtH4CmifoTTdRycIfuhCjbVF9w4dOQUJZKS69cyy0LIZaL05I5uLz/wRv+NYAcxQR8oUheDgV9CJvTRnH6f/oB8ndwyRMWyIQTkfjgaTL4AE+qF2xxA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791241705; c=relaxed/simple;
	bh=HvIdQDLYa1Lul0YF3dB9ewaICFXf/uHdEyk3gBqpQVA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=MhzWSHNiWhB+ncl9IuBNGtKI0vApxTl6t8VWrHvxaPQrpA+01JeqP7HSbRwNrkN8blLh2t+3wJXylwMuDc+KIwsLPq+6rK5WCjDosKHxm3Jmjn6sR22NrgJJYstoalFGZAy48ijXMfQhH8GrCuqqJmjmltYzjTuAtTmI2M0Qo38=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=TnB+ZiKS; arc=none smtp.client-ip=74.125.82.180
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TnB+ZiKS"
Received: by mail-dy1-f180.google.com with SMTP id 5a478bee46e88-351297d9f8fso888087eec.1
        for <lvs-devel@vger.kernel.org>; Mon, 05 Oct 2026 16:08:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1791241700; x=1791846500; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=AXTKrz4VGvcWU+Xa9prrE8tXzfiajVxX/35uOYLtN8Q=;
        b=TnB+ZiKSgP9CfAPlKo/UJyDWvYx8fKrAW8IKySUj19IP9hZGel0iWxGYWFCb4YhtGg
         Z80EWA8ryrrz9sRc3I9ifqZWtFrTAsxZIqeKFg98imCQjeb3qW1lZPy39Fl32XL34xm1
         6so4PQN4342Za9x6U368r5ZXTmbrSt0CCqatg4LnDZTnDSDtZVZc+t+Ww0ZFo9rbE4D5
         69BMQ8BhFdIhl1GafUJqNJk7q2V0L6GxaKcz+cDL+myHQqpZOlku0ehfOiJhuvSka6TC
         E+0Ai7ZS4/EggjpE0g5uRovWfAPPk1hpf16KzwQ7u1TePdvmQKIBEk6BuMMqzzCVa52P
         aocA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791241700; x=1791846500;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=AXTKrz4VGvcWU+Xa9prrE8tXzfiajVxX/35uOYLtN8Q=;
        b=YQtHJ/Tf3ZiUWcIJcLryPIXSS5fnbaBE7B1c3cGMeEHNjBxaW5gdsNLBGEmWfoJa59
         eIIUH/xsAqrzBKUBW1m8f+sDSW6Ot6jZ4bsCUkSVfUz2OaQ1FNv2CS1/KA+Q780ho/1P
         g86ancQ/dRVsikeGt6Ur2/a5J6LDh64Fgw0WkdhqXEB+/dTfaUgpEa0JBkwjfLtff2r5
         JYiH08TUhzV7VpnhybUup8KkEIoAqUq95qqVbdHZLa0wGQi2rN2wed1lmsSvogNJ2HOM
         LXg21EbFN1YyZMkH0Cpmdu48BqfC9TX2splimj6WkQiF5vqoQtJfcaiLzdRywmLnyfRD
         hehQ==
X-Forwarded-Encrypted: i=1; AKwUvBy9iC6FzdKT9jVdtO8MBFYLQGilaJQyHrTJrl3DC5mb0PvfGswWXKlue1+yzG+dXV7cAHdmWs2t9DQ=@vger.kernel.org
X-Gm-Message-State: AFuF++muS9KMklbPPmVoZE54hV7mSkqYInmtkaGnY248XGuoOu+k6Tdi
	e6cy1Clt1sCLmZgUwD8hOkwZoIMoiTLG/Gx2waOpdVDWAStt+a4IimA4
X-Gm-Gg: AYBFou2aEBHeI1jOft6FtM4p7p4owGSAVe4w/5jhYnjNHWgc7xTsQucMgOKLvUdOJ2Z
	UXHjxOCILCQ3U2bsZVDtNMMkeaDbeSJRp7Ricbrr7zIhIls/6VRtkcF1xlJ9doUjNtrXIB9VGcY
	YNuAO/m8du4waBddZByvlShw0q+GVyrKx0Y7Lveh6cPqysIHO+BzCyygxCsmzS3tEPeirpCpaUa
	Mv+FCPLfp+2PBrCfmGOVWgj1hkdl/+EtOu7XIy/HZTmypWkYz+JQONoRggdna6eEzqLZrLa3qPm
	G+lkr+3upeGDqCiz1rUoMFMk4VNBHgvI7vv8yXwaD0haYfX+olksCdXvTST2VZ0h+dJNwMgp05z
	tsnwQ59nwMqvDdKZysZWWRJXFE3q35CBvbAQycEJbDwLsJhtVLfzuSmX4SQ70dPYtAYFTlh3vGH
	eAowj54cVad8Zxsy6S4thgVT0oa9yJBbYRowMZkJRcwj2ZT0hjmMzftp03g7bMCsI=
X-Received: by 2002:a05:7300:e9d4:20b0:34b:6f6c:2274 with SMTP id 5a478bee46e88-351451ff5d8mr1320467eec.5.1791241699900;
        Mon, 05 Oct 2026 16:08:19 -0700 (PDT)
Received: from adriano ([190.215.95.120])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-35146a5b004sm1859493eec.18.2026.10.05.16.08.17
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 05 Oct 2026 16:08:19 -0700 (PDT)
From: Adriano Cordova <adrianox@gmail.com>
To: Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Florian Westphal <fw@strlen.de>,
	netfilter-devel@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v6 nf-next 2/3] ipvs: tcp: enable per-connection secure_tcp in state machine
Date: Mon,  5 Oct 2026 20:08:07 -0300
Message-ID: <20261005230808.148478-3-adrianox@gmail.com>
X-Mailer: git-send-email 2.51.0
In-Reply-To: <20261005230808.148478-1-adrianox@gmail.com>
References: <20261005230808.148478-1-adrianox@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Let set_tcp_state select tcp_states_dos when the connection
carries IP_VS_CONN_F_SECURE_TCP, otherwise keep using the
global pd->tcp_state_table (the netns default / or if nomem).

Signed-off-by: Adriano Cordova <adrianox@gmail.com>
---
Changes in v5:
- Document that secure_tcp is the netns-wide default and that a service
  can opt in to the hardened table with IP_VS_SVC_F_SECURE_TCP.

 Documentation/networking/ipvs-sysctl.rst |  4 ++++
 net/netfilter/ipvs/ip_vs_proto_tcp.c     | 16 +++++++++-------
 2 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/Documentation/networking/ipvs-sysctl.rst b/Documentation/networking/ipvs-sysctl.rst
index fe36f4fcd3a0..5fc6afd2d39a 100644
--- a/Documentation/networking/ipvs-sysctl.rst
+++ b/Documentation/networking/ipvs-sysctl.rst
@@ -290,6 +290,10 @@ secure_tcp - INTEGER
 	The value definition is the same as that of drop_entry and
 	drop_packet.
 
+	This is the network-namespace default. A virtual service can opt
+	in to the hardened table regardless of this setting by setting
+	IP_VS_SVC_F_SECURE_TCP (0x0100) in its service flags.
+
 svc_lfactor - INTEGER
 	Possible values: -8 (larger table) .. 8 (smaller table)
 
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index fec0e8b47b71..3b9a2c8e9a52 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -451,11 +451,10 @@ static void tcp_timeout_change(struct ip_vs_proto_data *pd, int flags)
 	int on = (flags & 1);		/* secure_tcp */
 
 	/*
-	** FIXME: change secure_tcp to independent sysctl var
-	** or make it per-service or per-app because it is valid
-	** for most if not for all of the applications. Something
-	** like "capabilities" (flags) for each object.
-	*/
+	 * This remains the netns-wide default / global floor (e.g. when
+	 * memory pressure kicks in). Per-service hardening is now carried
+	 * by IP_VS_CONN_F_SECURE_TCP on each connection (set_tcp_state).
+	 */
 	pd->tcp_state_table = (on ? tcp_states_dos : tcp_states);
 }
 
@@ -479,6 +478,7 @@ set_tcp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
 	int state_idx;
 	int new_state = IP_VS_TCP_S_CLOSE;
 	int state_off = tcp_state_off[direction];
+	const struct tcp_states_t *table;
 
 	/*
 	 *    Update state offset to INPUT_ONLY if necessary
@@ -496,8 +496,10 @@ set_tcp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
 		goto tcp_state_out;
 	}
 
-	new_state =
-		pd->tcp_state_table[state_off+state_idx].next_state[cp->state];
+	table = pd->tcp_state_table;
+	if (cp->flags & IP_VS_CONN_F_SECURE_TCP)
+		table = tcp_states_dos;
+	new_state = table[state_off + state_idx].next_state[cp->state];
 
   tcp_state_out:
 	if (new_state != cp->state) {
-- 
2.51.0

