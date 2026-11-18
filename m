Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.218.53
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795015064;
	b=YRfUzxiRLQh6Mc6vGzFjd2RhDAhzIxJOBjn9evjV/ut8uZFaS+mFP+lP8D8JeEVid45H
	 gUloAgE+4YyIIWP90mxgi6GRX5z07MaCEZzQCPl3NteWgpg9x64MvZvndM198pg7YJuZn
	 Ebqgf10qojzkodNYM4sXUPDy309TaHE5FQODVDAkfgBG6Igc+CEBR1Gm9bdy0Cjmmb7e4
	 ZCr8gH9WskCUP+IM+NaUv9Cy3eJSpuM8Qtqb089EpbQHqR57FEIdPN78+5MxJG0FGWrBJ
	 KaQo1gRk6mDszKksqYLrm1R2S/F7CnKymP6Es73V88Gi7KCuG1LMg9RrAhtA9srXLDg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795015064;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-Id:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=CvfmLkDBN8I5nxmJLaVmq3PqMym7xUmGtMx0tuqzeb8=;
	b=xuroENg/E9gnWXXV6DIAv4uVhHePggQb9RzJZ4TEBrByrica3bA+HNIRICxkbjxSrgk/
	 SKQHtXtLF+/4PaZgJ2bqurvwO8afujx4w5WSBX7cbr9n/1cB2CfAMODWhNgM8fgd+9ez3
	 IB23ELpqZgX31EZpP2RVZude2MXQyIltcBEoIKJyvKE2Wd/J8dARXpc/EOkH9tr5HbciR
	 Hzhq4qMvghwtMv6h5GouOkm/JM1K02X+n3xv6q0QODCBvdbTCD4ZE2hh9qqv2vkdZOh7F
	 ZNRfYu76vk8+2RZvGSfomVLgbvo5qYgktHZnmLHG5Y7n52sTjwp5x+FspPyT3wzpbNg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=WkxoNCmH;
	arc=none smtp.remote-ip=209.85.218.53
Received: from mail-ej1-f53.google.com (mail-ej1-f53.google.com [209.85.218.53])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 77E88606A331
	for <lvs-devel@vger.kernel.org>; Wed, 18 Nov 2026 15:17:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 77E88606A331
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=WkxoNCmH
Received: by mail-ej1-f53.google.com with SMTP id a640c23a62f3a-c5067a2411bso158979266b.2
        for <lvs-devel@vger.kernel.org>; Wed, 18 Nov 2026 07:17:43 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795015062; x=1795619862; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=CvfmLkDBN8I5nxmJLaVmq3PqMym7xUmGtMx0tuqzeb8=;
        b=WkxoNCmHgt1cV07ODAtkzGUMS3QEMg/pCYKSsi7za96v7vCk70HO1zqPcE+MRzXRE8
         3Ug+iZhmPZawGyCXpg5TaA9LDGM+5cwSQlDPvnZAS96WzWkFIuLV7BO2ijuec4pvTQaO
         jhvx1sf59NiMJ23lRpkoDMvQaNjUNNKWTMm39AMZmGrJcYc4rRpQTohXAFM9uMAlIPVa
         yEEIp/WRsoOJgDL1T2bqbtafeyS/7mB8YOYKV3gx2K3sKVE7JFUEo8AEMHtpIBEcy6lu
         pNNCyqBz+rDVZmvcdXLNAK42YxSJcqZkrDf+iIldG59pYVnhkSNZobaVYgcPOQZjVa4t
         qIVQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795015062; x=1795619862;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=CvfmLkDBN8I5nxmJLaVmq3PqMym7xUmGtMx0tuqzeb8=;
        b=s84gP36UsoBxYhbT6c06ViIHN+seoiocB2aEV60I2simMKOrVAuHU5ea7+CSWhHCBJ
         DsCQm9qg/HHzGqaIKGDCAVIdW1xymiLn7tii55OFF9db+8GIGvspCxX7yuqb3n6EU9/Q
         XG28YoMOCUztXcTiQqrrsHwCjNuSS2htmrbrjOQZwQWqLXv0ZU4TK5MhMZSZ3pVGr013
         P8EXRpOA0sZYoeZZe9+uhWiqdZXlHG6wiBCr6x1Y8pmYGTHEZun35+CUsWGJ0QmvpYjg
         igm5UnUU8UNYK1c4lZMo9PSb9Lf+HU6EPRwSCXG+xbD9Of3OxcT/tX2MSGaAQL2Tef/F
         OmRA==
X-Forwarded-Encrypted: i=1; AL+hErGrVI77qyE1qGsenmoKmFb7Ba/tGrc+ZDTKigni3VfdLo2FkN3FJOMvjnIETyll9IujiYHM+Zodyyw=@vger.kernel.org
X-Gm-Message-State: APuU4Z83ynVSKAKUZYYoT4kXxcLQxgwvRdIWn1z2iExCZUJ2dVi1fcf8
	mtOUmxkLY16VqeHsD7RnZ69kQiCClFfBL4OY0CKW1g7wQDOGyF21L9A5ccv90cUhawUWh+5C
X-Gm-Gg: AYBFou24NlbXsvlXS9AcOtERxDLN17DePwYh+1hu8ggPQaJO+eWIo4YQ2e4zm5QKSrc
	/JsYrk13MuOLk/nOdyuhC0YW/rZvHWA1g1STl4jPLEToZHVSyeiQhbb9qTK/UDVfhZOgjKEXu2K
	RcPvkJA3U35PBgNEN0f+WAbDPZnUS/L9l1DGxrPKNFr0tu9Qhe+KKG/bmc1vGgygNt2d08Xf50C
	Vn/kkLqbhZ5KOEEQNqZsEl2WZfQUzxgpMvY7BT8aTmA5HUKkXSiDu34GAO9syojbBgWxdqxuU6L
	TrZImaRC5Y2J74siq4StY9doQGMYxE/NzhEMkM7NwRVwqaZ3zIHzOA5YWLwfhbVjR7SMUwCOnoy
	D3OTpF1v+UYUtLW45bemHXvwW6Wk+7Up+E6Av42dJhQ3x5nLKkClz8BXg5bo00aW0QOTQSH7sao
	le7cRudX1egncDaaELCLisycPU27THSLzxLCsFbmXOImhT6TI1ZeAkdQRwYMX19s7RfMstChw27
	SJeR5apD7h4EQgSCRN69HZnxgVFqha/66+g0MIb4F5oIeoXA1MEhS/NO4pIwX5wAxAwUrJ2OxwU
	bIgjut5sndsWP5HahHfXkLCnwWarfTt+NOJ0pnTv
X-Received: by 2002:a17:907:7f91:b0:c29:f5d5:5a9c with SMTP id a640c23a62f3a-c510e32a1a6mr291758866b.38.1795015061528;
        Wed, 18 Nov 2026 07:17:41 -0800 (PST)
Received: from theodors-laptop.. ([5.255.118.7])
        by smtp.gmail.com with ESMTPSA id 4fb4d7f45d1cf-6b888ef94b0sm1226142a12.5.2026.11.18.07.17.39
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 18 Nov 2026 07:17:41 -0800 (PST)
From: Theodor Arsenij Larionov Trichkine <theodorlarionov@gmail.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Julian Anastasov <ja@ssi.bg>,
	Simon Horman <horms@verge.net.au>,
	Florian Westphal <fw@strlen.de>,
	Phil Sutter <phil@nwl.cc>,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org,
	coreteam@netfilter.org,
	Theodor Arsenij Larionov Trichkine <theodorlarionov@gmail.com>
Subject: [PATCH nf v5] ipvs: ftp: do not link expectations to unconfirmed conntracks
Date: Wed, 18 Nov 2026 18:17:26 +0300
Message-Id: <20261118151726.2509853-1-theodorlarionov@gmail.com>
X-Mailer: git-send-email 2.34.1
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

ip_vs_ftp_out() can link an expectation to an unconfirmed conntrack. A
later extension add on the same packet, such as seqadj in
ip_vs_update_conntrack() or NAT, then reallocates ct->ext and leaves the
expectation pointing into the freed area:

  BUG: KASAN: slab-use-after-free in nf_ct_unlink_expect_report+0x490/0x4c0
  Write of size 8 at addr ffff888004dd4e48 by task syz.2.17/649

Check the conntrack at the start of ip_vs_ftp_out() and drop the packet
unless the conntrack is confirmed, is not a template and already carries
the seqadj extension.

Fixes: b25adce16064 ("ipvs: correct usage/allocation of seqadj ext in ipvs")
Suggested-by: Julian Anastasov <ja@ssi.bg>
Suggested-by: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: stable@vger.kernel.org
Signed-off-by: Theodor Arsenij Larionov Trichkine <theodorlarionov@gmail.com>
---
v5: drop the second nf_ct_get().
v4: check the conntrack at the start of ip_vs_ftp_out(). A server reply
that fails the check is now dropped even when it is not a PASV/EPSV
response. Without a conntrack, e.g. with a notrack rule, only PASV/EPSV
replies were dropped before.
Link to v4: https://lore.kernel.org/netfilter-devel/20261117123944.270667-1-theodorlarionov@gmail.com/

 net/netfilter/ipvs/ip_vs_ftp.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 44de99f4d187..cf640cba0b12 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -29,6 +29,7 @@
 #include <linux/netfilter.h>
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_expect.h>
+#include <net/netfilter/nf_conntrack_seqadj.h>
 #include <net/netfilter/nf_nat.h>
 #include <net/netfilter/nf_nat_helper.h>
 #include <linux/gfp.h>
@@ -283,6 +284,12 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 	if (cp->state != IP_VS_TCP_S_ESTABLISHED)
 		return 1;
 
+	ct = nf_ct_get(skb, &ctinfo);
+	if (!ct || !nf_ct_is_confirmed(ct) || nf_ct_is_template(ct))
+		return 0;
+	if (!nfct_seqadj(ct))
+		return 0;
+
 	/* Linear packets are much easier to deal with. */
 	if (skb_ensure_writable(skb, skb->len))
 		return 0;
@@ -382,7 +389,6 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 	}
 	buf_len = strlen(buf);
 
-	ct = nf_ct_get(skb, &ctinfo);
 	if (ct && !nf_ct_is_template(ct)) {
 		bool mangled;
 
-- 
2.34.1

