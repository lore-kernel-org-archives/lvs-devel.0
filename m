Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.167.54
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795510367;
	b=W8mKJTaE1IFv2bXQEdUGyMMoOyD1XTeIVtZaSQnmiaQ8Z8u8fXCPD6YP7DnD87MxmNHo
	 epO2ziYecjvbE0gZl2quQvKVSe8W3Q3Td/aZKK5m8zlCPVghmUQMTqGGJNcglQNGY3cK/
	 shsd/gQl/kaOw9V4W3qGGsLosAzAbEc5o8ZqPoQWozDwwxpgQ/cq5neYrKv5pRk8eRad9
	 THiZC+I+l1RXkeCwkeLKUN/cAwjwP4mqCda644NzetfVD7wsFATnP7TDdnlLgOPOxuzF1
	 q2du3+BdbQ7u94qHjFoZuSS0fV+a7x57D+TObha2aYsBQRnavs7OriSQnCEyxVlpAXw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795510367;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-Id:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=TR53zPkVba88VfL7TptIVzoMfVRdSeP+zd0R3S3Wgso=;
	b=3wY2wBKONf6wDmASRcUxAHWtnPFTKhRjM0nYkGFiq83TdqfolS8+bN/4v1PVglcs2RNO
	 4e0MhitTYarNPo0vw9dOwBfU7FzYE2wVq2/frq9pnfh0y9yjoZNIPtsv+FjWfywzFdD5H
	 lv1qwwzD0FQ1XwguELaYNiGEx+fEXTzviImghkonns8sM/SDuaEwzarthK1t1QjtHwXcV
	 EEGZhcQWyRnJ7oYWrTw4ISNVenkZtaP9YspHzoVlUNhytO/WejhAp4qj25wcFaWwtx0/I
	 CCsPu6taogdVNPmuBI76RX3ksvXQ+OUs2/HrWl4gxlhkujijxK2lUsXSMQ/1acCOzHQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=uX79fbci;
	arc=none smtp.remote-ip=209.85.167.54
Received: from mail-lf1-f54.google.com (mail-lf1-f54.google.com [209.85.167.54])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C3CE3606A32E
	for <lvs-devel@vger.kernel.org>; Tue, 24 Nov 2026 08:52:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C3CE3606A32E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=uX79fbci
Received: by mail-lf1-f54.google.com with SMTP id 2adb3069b0e04-5be47aa555cso5274727e87.3
        for <lvs-devel@vger.kernel.org>; Tue, 24 Nov 2026 00:52:46 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795510365; x=1796115165; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=TR53zPkVba88VfL7TptIVzoMfVRdSeP+zd0R3S3Wgso=;
        b=uX79fbcioXcn+HG0sN8Id1Ql5mLaTWW7HjbIPCjEaGDwu39hMqQK2b04NGjw1LxZBL
         er8gkOQTqKf41KfD76JzTiyjxtw+v/1vnxHVjxj5xaeSd/PYlkcFExlDpNoUPhugYqHD
         Hu8gtZOXNTT47VIgSCEoSdlAVqFiHIc1r7nV7sjOW21WqLhJoffxqDF63kXI4UFmUXn4
         CZImKjDDhH7Nlotyu4w66d8E5RLauqnpIfpV7dtLEswiEnwg0Dv9z+9hlyMQtdT8w2JE
         2mu7mwUPFAokUfhYhNCnjD+aaV+3cx9v9C6TJJx2jeG5/V4E7wLoCiGQskV3XVU8ws5i
         QQJg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795510365; x=1796115165;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=TR53zPkVba88VfL7TptIVzoMfVRdSeP+zd0R3S3Wgso=;
        b=POfjQHIh4OHBcxJw2EFSfzQOqUKbTQsMYp+Svg8Ua57Px7SDli1J2HDfiFNWrff8Lq
         a9j1+w1/GP/fS1FkdNZ0Ff8vBFGwA/S5ps1uAd4iGjjznrE054rVMgsodO6kiEK+b5dG
         QD8d1at+QytyDnGxWe3oyTfUioRsWnX97v8MdP4fsXIhT0bDmh0Rl1CobxAuLbOfcY5o
         HuIJLgwMHM6D8kmwnpmfZlYiVBUAfSUP0iTyeVyeDimbWlh8kTWkidruE5cma/2aRafy
         MlAVS+xv9XvjV2zy7Ml9IOeDq7VJDTwd/YQPbNPh5/GyNeCdakH7Qu7g8KaXZklowAcp
         0rYQ==
X-Forwarded-Encrypted: i=1; AL+hErF5tK9ihcHuspZ5Fv7TuQwzhvmYJc6TOmwoAjz+RBNaTjqtcKbWfmv9Kdy+ia/x7n1cemXg7oCgG8w=@vger.kernel.org
X-Gm-Message-State: APuU4Z90gIik5XDwDFX+LiQRmZzFQRIt2+Ge45NxkXonGbx8FgGFV7K4
	DD9v9mDfZqlBLZz3LBwwbCEh6gYK7IAZMbY4fapqGUfxoANetibB51n8
X-Gm-Gg: AZFdTZeDhxAxKVo8r4/LSnbPyMjnVzxe4NdopjwtE3ub/rz6W+egloAPe0HhElmwLoa
	YvnsbnJVJijPGeUubRrR1x9cTJkesrKzs6sebnXpGog8Vrj4YzDK468j9bR9BPDJ4O+aFF34Mwp
	Afc033esDnygEgt6Nu8r5Sdd1n92SQChCy38g8LcCVDjviTnRoLHkgWAbB2G5W+k8W/41qDOPZg
	9xO44xyvYwaIa2IGKQuSD3oYTHNPxs6XLF3l3xndjvvNeUsSKAWrnyFR1Avl/97YRGIIUT0K+jq
	vtQsp5ZtDorGYE5BlsRGNFceqo4r0sGH3T2C8Dwzmu+lEdTQ2asOjg1igKCPr4CgC1u5LFNWJ9p
	4G4251NGe98qThxyafha8/IghTrATAYItbaoe8JNa+lxdlXsECXHFJFQl2FUERlMue6dkVrksZF
	uYj6Ln/hbAwISqmKx33P+f1xpaHGwcvqgvrU3onVQhEzSZWsCRXDCz09hjlYBLun0DYoQ6ePsAy
	YZgLY6GPEBmrXSTB8oALlPXnt83o8U4WOkO3ievIInM7Uy+H3/LwtTobM2GgZNbRah1CQNzuWOs
	4iyS0yhPyNZaDO4FX1ca/gc4b0kZqj7XXaw5nfFySoKG4Jv0GkQiuoo=
X-Received: by 2002:a05:6512:3e04:b0:5c1:5169:7d96 with SMTP id 2adb3069b0e04-5c1bc7bcc2fmr4609413e87.18.1795510364703;
        Tue, 24 Nov 2026 00:52:44 -0800 (PST)
Received: from theodors-laptop.dotcomltd.ru ([5.255.118.7])
        by smtp.gmail.com with ESMTPSA id 2adb3069b0e04-5c1bcf33576sm3575596e87.6.2026.11.24.00.52.43
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 24 Nov 2026 00:52:44 -0800 (PST)
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
Subject: [PATCH nf v6] ipvs: ftp: do not link expectations to unconfirmed conntracks
Date: Tue, 24 Nov 2026 11:52:39 +0300
Message-Id: <20261124085239.62750-1-theodorlarionov@gmail.com>
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
the seqadj extension. This makes the conntrack check before the mangling
redundant, so remove it.

Fixes: b25adce16064 ("ipvs: correct usage/allocation of seqadj ext in ipvs")
Suggested-by: Julian Anastasov <ja@ssi.bg>
Suggested-by: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: stable@vger.kernel.org
Signed-off-by: Theodor Arsenij Larionov Trichkine <theodorlarionov@gmail.com>
---
v6: remove the conntrack check before the mangling and the 'mangled'
variable, and unindent that block.
v5: drop the second nf_ct_get().
v4: check the conntrack at the start of ip_vs_ftp_out(). A server reply
that fails the check is now dropped even when it is not a PASV/EPSV
response. Without a conntrack, e.g. with a notrack rule, only PASV/EPSV
replies were dropped before.
Link to v5: https://lore.kernel.org/netfilter-devel/20261118151726.2509853-1-theodorlarionov@gmail.com/
Link to v4: https://lore.kernel.org/netfilter-devel/20261117123944.270667-1-theodorlarionov@gmail.com/

 net/netfilter/ipvs/ip_vs_ftp.c | 45 +++++++++++++++++-----------------
 1 file changed, 22 insertions(+), 23 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 44de99f4d187..c90f7a9e1452 100644
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
@@ -382,29 +389,21 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 	}
 	buf_len = strlen(buf);
 
-	ct = nf_ct_get(skb, &ctinfo);
-	if (ct && !nf_ct_is_template(ct)) {
-		bool mangled;
-
-		/* If mangling fails this function will return 0
-		 * which will cause the packet to be dropped.
-		 * Mangling can only fail under memory pressure,
-		 * hopefully it will succeed on the retransmitted
-		 * packet.
-		 */
-		mangled = nf_nat_mangle_tcp_packet(skb, ct, ctinfo,
-						   ipvsh->len,
-						   start - data,
-						   end - start,
-						   buf, buf_len);
-		if (mangled) {
-			ip_vs_nfct_expect_related(skb, ct, n_cp,
-						  ipvsh->protocol, 0, 0);
-			if (skb->ip_summed == CHECKSUM_COMPLETE)
-				skb->ip_summed = CHECKSUM_UNNECESSARY;
-			/* csum is updated */
-			ret = 1;
-		}
+	/* If mangling fails this function will return 0
+	 * which will cause the packet to be dropped.
+	 * Mangling can only fail under memory pressure,
+	 * hopefully it will succeed on the retransmitted
+	 * packet.
+	 */
+	if (nf_nat_mangle_tcp_packet(skb, ct, ctinfo, ipvsh->len,
+				     start - data, end - start,
+				     buf, buf_len)) {
+		ip_vs_nfct_expect_related(skb, ct, n_cp,
+					  ipvsh->protocol, 0, 0);
+		if (skb->ip_summed == CHECKSUM_COMPLETE)
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+		/* csum is updated */
+		ret = 1;
 	}
 
 	/* Not setting 'diff' is intentional, otherwise the sequence
-- 
2.34.1

