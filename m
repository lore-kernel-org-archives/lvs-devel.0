Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.218.42
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794919198;
	b=oIXN5vVQbpIftHzrZiqDCorHzscGC9VYr1PO6vcwez63rZl1zMKhfZ4Kq25HL61kBGTt
	 AkmU4YVP6ecYeq3vRlFgD875qeCKUunEPv5T7NVhnb+O9+nzGf2zYsckv3sKfcqRGmrjw
	 F1xUlPhMRcIGSm8bc73fSbLYkbLQfYPfuXw3hqV/3o+Ce2zxUiK9If0D4ekrju/8tcfBZ
	 oeEdnQVYzzi2wuYADEGS7MpGVHPENQlqPojovheYKpQD+McNih3Y4GH5aL8IRWuTiYb7w
	 Tf5j1rzfUb9taTlBZ92/oUI7ORA+GJJgML0kcgELH1QVqZtwDLO+PGp1WcrAULPa4AA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794919198;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-Id:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=KhOt0cRnKYV36pufkweOfchwWzEZ+liNrgU+2GDZ2tM=;
	b=EQBaiJRjr4qONNnE8hzmTA8V4c9obBM6mD0SMBQcYXr9chkgogBmrBphBDQ6YvVuzNOS
	 lrfrefjHwhL7VSRQGzlMsxgR3Kc3Z+ymRRqDSM4F6jcf54D5ODmcH5BEdH1aF4sZkQeby
	 B90U27t3F3DJqzCj8siMiB3Z/+mK3tMUEMq43/ZjkOI+iUajtKN0AY3gmGdRzP1yCOnGX
	 vGyKCKfx9/87MSfdRQeCibnCJYEl8f8kyIcbgxshkPKcybT3J5vrgQF8i8R8Jl3IY2WxB
	 Bg3IYS7JT7sCzzG9+q4cKihWgp17AxGpnKpHAyC2KJRLVD7Zv3B3hLM+gtwRLSZ9jSw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b="Z+o3y/xe";
	arc=none smtp.remote-ip=209.85.218.42
Received: from mail-ej1-f42.google.com (mail-ej1-f42.google.com [209.85.218.42])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E41B160A382D
	for <lvs-devel@vger.kernel.org>; Tue, 17 Nov 2026 12:39:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E41B160A382D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=Z+o3y/xe
Received: by mail-ej1-f42.google.com with SMTP id a640c23a62f3a-c45551fa84eso857073466b.3
        for <lvs-devel@vger.kernel.org>; Tue, 17 Nov 2026 04:39:57 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794919196; x=1795523996; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=KhOt0cRnKYV36pufkweOfchwWzEZ+liNrgU+2GDZ2tM=;
        b=Z+o3y/xeqrCWgUnciSXgqXTvKZXDUNgxhFOeohIWAz2lHSZDsIpFgtW92+/ECzkP4/
         tdGYlRJR8Bep+VubJLpJvM8Rrpm/tfnKbg/1PotIYPmy1H3kHUiAGeFaC9AKeZhzIbLA
         0OS04vBCxQnKt1BDrIxiMLppZIGYI9wfB0xtmH1K/7JFDLo0LIEx0k2/Hn1O6AXl8VsA
         aUR1ZhsuZzNLCcLOAL/zuqqCE2lrLISii7Usv9C0gOOedV5nm8LyBooafuWNGMl0V8Ss
         0foEh2ocfyd3GV3dDQm9jw9t/Jv9vFD3+SjlX3GIdKcamGZqG9kfozc20DII3fvaXGPW
         rmtg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794919196; x=1795523996;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=KhOt0cRnKYV36pufkweOfchwWzEZ+liNrgU+2GDZ2tM=;
        b=FJAS4YRwRN8PNKMxhLhrX+UxnBUfSoHN9tZUPVoQ2dHjXz/O/BQZIfaJp25QpSQvQs
         akBAwTpcvawUgvH7IEzRu2RrnaNJkMFGhn03yCi6V9J3iOzbuURnkFP9BU3Diunn2as+
         rEGHXw0btzjduMBeQAejSjaDt97b1M+73uwV/9c4CYcrRJIpMHrQLhvL7/klwmTKqSsT
         UR/oXzAi7ljUOi1+MxBhFQY/JoDN0iNQPQDV5VRnxZmy93YOlOb9wmG+9+5nmU8DSfNd
         QaW0P+F8enL9MWSsvUoPFNslQJZXcLOlH+EMmrylmldP3XU47G+fz1B3fmAAhDFEf9bl
         WajQ==
X-Forwarded-Encrypted: i=1; AL+hErEQ3IVfUWzqEHnIiLvZlcEZbCEjYIy/RMIEUEwmHswCbx9YHYFTG+VPAHres7dI05drP2JwEEQAp40=@vger.kernel.org
X-Gm-Message-State: APuU4Z8KU6RyI9xKb8SeC3Ehw6l6SWPHRvXn1woKaEWQaDihUBkoGnvL
	STAf9oqr8KHXQz3pfeedKJDrSyHxGdJGnD/zxx70RPeyMhxALsuoByUI
X-Gm-Gg: AYBFou3DgcGa/mu9WYW2kmb4CLKwsqt7qChovR95Mn24SeuOQUfJQTQNogNS/X/2aU1
	PP+pGw2cRDgd9cUzXa1yAfTS4VFGFkrefoBFx5xelopOeNe6i6fQfx+wrynF7ReL3qzjIHp3Rzi
	GiQiH4OSqCpwciy+57cW/2oOQbvFzUFdkMMd5hBZ/HGoJW1EZA4rwzOKjL8GIeR9UlE3xmFXjEB
	IlAVnXQeTagLSFD7mmQ5D/D73os6+es6UFfyjshVw4AN2GIcSWYnhYcgJWvF6EoZQo0vHSysQnv
	3YEBApStfVh0WYIA+EAm9LcLvTXCIoUXCgr5oIPWfDTzTPJG+tGDHBnBx7dooBw9oCm5YUu6M1+
	ztVS+FTAEJRbPFgLoSSBt4VbT3KO1hC2WBmlRnQexJxKAl78ydbUQkvdZ1RO4/FE33LPp4vRamI
	VOTo2AL/rhFwg0d1rCqNxHE3Rj/AyHCSj93XnpZJtzC0f9L+pxYfeg3wtyeuL2d/w5yENsoTxe3
	PL+mG9BWy66uuOwV8Ih65vRgIEbIzBSY64UIuC3H3v34KFRxmFr32R+Zt22U8Ioa36HiBr6l/FN
	zkc3g6t7nuJnb13hG+40iDZ7qTVT/QvHz7dnD1AgrUJTD/hlTRLsAjyUJqYp
X-Received: by 2002:a17:907:8e08:b0:c31:c767:ae0b with SMTP id a640c23a62f3a-c5095db2440mr1272747066b.0.1794919196151;
        Tue, 17 Nov 2026 04:39:56 -0800 (PST)
Received: from theodors-laptop.. ([5.255.118.7])
        by smtp.gmail.com with ESMTPSA id a640c23a62f3a-c5095a5c520sm532332666b.9.2026.11.17.04.39.54
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 17 Nov 2026 04:39:55 -0800 (PST)
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
Subject: [PATCH nf v4] ipvs: ftp: do not link expectations to unconfirmed conntracks
Date: Tue, 17 Nov 2026 15:39:44 +0300
Message-Id: <20261117123944.270667-1-theodorlarionov@gmail.com>
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
unless the conntrack is confirmed, is not a template and has the seqadj
extension that ip_vs_update_conntrack() adds on the first packet.

Fixes: b25adce16064 ("ipvs: correct usage/allocation of seqadj ext in ipvs")
Suggested-by: Julian Anastasov <ja@ssi.bg>
Suggested-by: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: stable@vger.kernel.org
Signed-off-by: Theodor Arsenij Larionov Trichkine <theodorlarionov@gmail.com>
---
v4: check the conntrack at the start of ip_vs_ftp_out(), as suggested
by Julian. A server reply that fails the check is now dropped even when
it is not a PASV/EPSV response. Without a conntrack, e.g. with a notrack
rule, only PASV/EPSV replies were dropped before.
v3: https://lore.kernel.org/netfilter-devel/20261116101506.98853-1-theodorlarionov@gmail.com/

 net/netfilter/ipvs/ip_vs_ftp.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 44de99f4d187..216be082162f 100644
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
-- 
2.34.1

