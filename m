Received: from mail-vs2-f41.google.com (mail-vs2-f41.google.com [74.125.227.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0A83F4E06F9
	for <lvs-devel@vger.kernel.org>; Wed, 16 Sep 2026 20:50:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.41
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789591851; cv=none; b=QsjT2M+wKbeCNqTlidJpdyHov8F2tXY+cUG6ZgQPzrJZv9L20doJQUIpUURI/88rjbgZ17Sxn2MG1+Y7eP+PySIbP1H9SzM+dcmJHAAvIKix9hfW8QGm1slzyb5+t0RWpe/22nSlfvX8LcbuV9Eq0oBtuLeYEc0xIt0EbqiLRnI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789591851; c=relaxed/simple;
	bh=vGxo+U1sJMCVsq3sDI08zPDza2WpfMA+ZZBuxg0Rgp4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=PRXYXBu95KrXaVUS58cFgYoF9KY5kHAi2/hf/5YUT5Q33NeacSy/k5tw0sNuNYy/b0RYx3GD8/aV/ZK1yxfdGDrTK+jQPJYaFVxDB3gE0dSFM1frB/ol67wfkZR3fChUVLFonTTyK1TfOtGNCQ4zUfhMIvK1ApvdH9AVuOS0HK8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=rF1hUmsI; arc=none smtp.client-ip=74.125.227.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rF1hUmsI"
Received: by mail-vs2-f41.google.com with SMTP id ada2fe7eead31-78564319a92so52528137.1
        for <lvs-devel@vger.kernel.org>; Wed, 16 Sep 2026 13:50:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1789591832; x=1790196632; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=+xdh7oWEQ9m8Qy+E3UVjKRIovBOhuQDCeQrchOYtk/I=;
        b=rF1hUmsIT9igjP5btpGYCBgF2a1mg1PwA+mRm9EJo6bGZCYDlfaauCJICTLok1pQI6
         CVczDKxp5D2yAxbN+Fzh+x/xS1YKwrc+RHWnlYTzywaiinQtePqm7Ki4dEhOTzw/wVJH
         HgjNwwl/GPtd3Iji71u1zZXBSavBK0RacrVFxEnwNu+jSkB8ark0r00bEeMk1WZSAgLF
         9GhIPDtJBtUYBx5SdLTVS9G0Fp7C3COCqt3UHm6V+6IF9WzSFNMyqo1/WR61/VcOyX9Y
         tgA5a+EdSnTRGVn5U/DfGpekzYL3CQ/BoEoi+OawtccoFAyhG1dHYySNxRvym1cj4kjr
         c+EA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789591832; x=1790196632;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=+xdh7oWEQ9m8Qy+E3UVjKRIovBOhuQDCeQrchOYtk/I=;
        b=kLKeIY1NWTi4zohyzYjTVQLD02y0NIneCYlf5+kntQfnm8xVqiC8ejmeP8d6nlRO0U
         umbiEOkBkNzn3xMOceK6+p6py98aK250fxgdKNAV6zoDubZ7DBoCLprnRIXFxs63O4m0
         QK5/yOimjkcMX8T/Rr3s68fqaSMaCk733Sz7qWKbZvdSRNMtlYDJyAivItfX0tyhZ3nb
         HYxivEB7lN0EzmwHNv8T1j16bcRFPJnwrzrUgkOnrvvwbY2Jcf9UQ3w34C7ZlL6C34TV
         1SBfpor8qC4zDMpCOS9ju7mT3dpqDX3hCtm1k5bFPG1XX/tjf8htFj3SHrzI6RreQx47
         7vFA==
X-Forwarded-Encrypted: i=1; AKwUvByYwzasptu0Vlw6pyuvBXSi8CWSWnCXXyFzj02k3wlfT78j7znZIc1LhhwzTrrrWn5SpFroCbdmkZY=@vger.kernel.org
X-Gm-Message-State: AFuF++ms0QjWwuAbPTxuIQPpwcm/bBdkVLouOPDCYhq+FbrfHMSw3aIW
	PmIwybdS8kRzkN+/aPLstwE2y6N/XbxcfqdamepQVF5uylTkm+4EBaS5
X-Gm-Gg: AYBFou0P767GH1jfYW55WRfwWg4b6e7/mVsg5TECZYdmVOUsc8HHAIofDiD8DG0YsLx
	OzgMRr/WqAQdFSrVRBwU05g9YYo/gJWYIdpBuLhT80jKZHRWr64ESwBjTbNNWjtjawwEu35mmWj
	/FRPq24fzwFqSXXyBy08GRWYGbY4YU8Mp7GaXNG7NNnJpVSoli+oDms7nzNETR6gToQE7RSc+8L
	EdFlKxVMr7dI7fWq9ZZ5K/AGr7xk0BU0uANa5w6xg5sS4m5hzbkKu8RFcmUGNcP5qK2VFT+/FKL
	RJBIbD4bRudIy58F0xV5UxjX/DzON+Cp28uxH3jc1Jl6wKtOq3mfnOF9bvMknI/B4bnphB4Dcr3
	CNhSwCbqNTglW3jq9F0PPOFnkTZ/GNUQkcAJTViicURr31h7Y6H7w6qkqX2rEK6dS8FSfLuLnLB
	vfgB/90NNieEXZCM6oMV2mMh3bLPxbAY1tEU4BqOergVV+SRYy8D1GLBbV/vCgM6U=
X-Received: by 2002:a67:f095:0:b0:7a0:eb10:76aa with SMTP id ada2fe7eead31-7a0eb108b2amr3649070137.2.1789591832274;
        Wed, 16 Sep 2026 13:50:32 -0700 (PDT)
Received: from adriano ([190.215.95.120])
        by smtp.gmail.com with ESMTPSA id a1e0cc1a2514c-9832354a8aasm947799241.10.2026.09.16.13.50.28
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 16 Sep 2026 13:50:31 -0700 (PDT)
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
Subject: [PATCH v3 nf-next 2/3] ipvs: tcp: enable per-connection secure_tcp in state machine
Date: Wed, 16 Sep 2026 17:50:03 -0300
Message-ID: <20260916205004.647194-3-adrianox@gmail.com>
X-Mailer: git-send-email 2.51.0
In-Reply-To: <20260916205004.647194-1-adrianox@gmail.com>
References: <20260916205004.647194-1-adrianox@gmail.com>
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
(no changes since v1)

 net/netfilter/ipvs/ip_vs_proto_tcp.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

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

