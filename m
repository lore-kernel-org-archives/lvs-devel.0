Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.208.44
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794824133;
	b=Ze5QyXgZGons/IdKcbAC1xYFqMY2o2LaPoGI3J01TMB4A8gtktvdPOjRhz8+ZVEoKOq9
	 QaAZQgMu9Eechbo9pa3hjs+MSzXZyqD6M1K6PcdH9BIGY/Lp67uOacd2sdqC2dSq7r7Gx
	 NH68+Y5OLB82f1iZEZkqc4tBI5YrKk2JU1Hlw2VlPk4tLBRU0A4BUCoJ/3Wmlv/vkyCfx
	 CxbENk5TK0sf+OsEUEAgtskOZl7BXc8qwlJO316+QPbtVLePLqBUv6rJE1GzfBzN80qkf
	 iXvQjoChAq4lS/m9iHrJNom3N/hcuWPw1zMmc7H9wmY0v1K8Ct1E+raeUsPsMlrAu6Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794824133;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-Id:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=MmFHwFEuMpLfLRAKJJjBjIdikYWgskAg6Z40N1h66qk=;
	b=s5OQa+NJAgH7K7/kZ55t+LCOp6cWxI3RV3Qf1lY1WmBULqRTtmiIs08XcP5bgm7MAtYa
	 HRWxTrn1drU1TY5+WB4ECNX/1DOIsBhAoqU88tQm8ad2DERfUkq7rdN9qdp0kYpIyyxXe
	 E8ENmFml1nCkTeSTBKGBmvoSZ2usYR8wyMTP4qDYz2I8HMQGquK4RYWIiXE1KOUuiUZzU
	 RII22/aZxw5d+MnptxbBG8UrgleC7gH+qFjV51ePET9OqApqtM2h3OQrcwQ13hVJGLHYs
	 JK8E8a/mu29A7jLrAEtsncS1wuXDxbfd9Y1VkiPp82T1wleyRfK4dg0Eiq2aW75XurA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=HgAYqc9G;
	arc=none smtp.remote-ip=209.85.208.44
Received: from mail-ed1-f44.google.com (mail-ed1-f44.google.com [209.85.208.44])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 83FA5606A335
	for <lvs-devel@vger.kernel.org>; Mon, 16 Nov 2026 10:15:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 83FA5606A335
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=HgAYqc9G
Received: by mail-ed1-f44.google.com with SMTP id 4fb4d7f45d1cf-6b7efd3bc26so1628641a12.1
        for <lvs-devel@vger.kernel.org>; Mon, 16 Nov 2026 02:15:33 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794824132; x=1795428932; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=MmFHwFEuMpLfLRAKJJjBjIdikYWgskAg6Z40N1h66qk=;
        b=HgAYqc9G+r96o0aqLB0eD65XAGTpvqpGGt1tW8Ub7O/zlwjAXz1TJx3hFYyjVwyZ09
         ECxETVeCo06ckRHSN36lx41RzEpKa2tvpIimz2927tVhlZPmryHZF2EL7RoebI89/kfv
         fY4XMfG987AjFYznToDjdOG6cRZtFHqytosoCqFNm7pkBmCTuUTMhzaCvCKvZhw8BgSW
         nb2VijaUGgqbOlOrDlLogUZwZVHbdXT/2BY7o76L+vWqspXux2lQVg0LxzJbjnvzXpeQ
         b6+N6W7V2SaeT/vujdVrAi0PrvF14wgBNST8KCkL2miE0tnLXS+SXFukDhhwmIqG8Ry7
         0bqw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794824132; x=1795428932;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=MmFHwFEuMpLfLRAKJJjBjIdikYWgskAg6Z40N1h66qk=;
        b=utx51HmzAPqSMBg6QwmQVK1CL3LfdxI4i/Cv2sZm4/ttIoMXsK1Y83jd7BQDh+TSGC
         Gij5e4Rs5Vlqmj/z8MiURmAA1bEdnqn0w5hw4zNuR6KqoSyd7C2U8iUThaH2wDxc70og
         o87C5zIjK7u1J/Pf34hHr2F0nVDVBjRTvKTaUnpdPTGk/CCGC+qucv/ba2Hva8DAA/hC
         pn0o1ys7+DK4SGAgxJKi8Df1te7CawK1GsmkOlgFZ4bqjuYQcVaDhSlj5IkCsKpPcxcB
         mCovs57mu30eMdc79axxG4PgjDG/BhDwk2RbKE2XDcMr3KybrbI3pnh2nlwGUHW9M+sJ
         AAnA==
X-Forwarded-Encrypted: i=1; AL+hErFkfsB3qcfDqxS9dXRp0HLwkW3dvnE/KTTkKRvq/Q0Ac6lnsh7L6OOoiAFASQqIm2I7jdTFvtB+ugs=@vger.kernel.org
X-Gm-Message-State: APuU4Z9jAR1kwln9yMObRLO++vU3CejhLiOzmaVR1jqAPPqy61vHVJn2
	mLpV5ZIN2BcVsWSxt6O7EpLpiU9cS5Vj5aMHUwi4vw09N37T5KSZY/Ui
X-Gm-Gg: AYBFou0VZ3HjwY1X9HyPVTscu/HaVbyTOyoIAdMg/IUzNk/lWXowDmWnxAPVLvbWpW+
	d8Ls4LA71P6mYUv57LKbpyFUejUde9IsFOpfGm76Ji9y3H9CRYKNDlQEqrIMwfNCSYnb3mwjoAT
	WiavL2UDdDBImdzjQ/QBbu2smufa1H53gUyxE2uZm7Jjc/M1nuQmdzW3vVHdwYyktVHk1ceOn/B
	wNnexgzCIr69rVny3RBgaklqw4NlWhLWagtcZYKyKb+g/ZAZnFpJN6z+lnHwFPOS4yKv7p+J99B
	xKzDoOrO/IHQz+U3cUMQJ6CiAWzLpCAp5ZCmpukWSqwiafqDfo++CFsEHgi5ZNE2dfX1v0hWF4C
	eBCra5Ly/oX/8xH0yaljQCvCRn0TMTqW7a4qbhcnDM4k4N1s2hiTrQDZepY8g73T8nlEJ7wd8NI
	Wa+X7Wnfryt2Ex3LHmb4dvzEU0aKXfCeGU8dy8WtQJEQ3Wv29o4i1QC7OLHPd2v9CXr2GKunYkC
	pUgHxlg1o1JndoEAW0RjCjndHVIEpG4dGZzVAxnc7RWPCfNP7sMhApKHYhIirs9dowmBUwYjPCA
	QRTkJm5OMKHUAp18KkkfSNP0YV0kRp4boO5UMuTyG386dyrh45ogXxCi6rcu
X-Received: by 2002:a05:6402:210e:b0:6b6:8ed8:765a with SMTP id 4fb4d7f45d1cf-6b7c0d06184mr7571102a12.38.1794824131325;
        Mon, 16 Nov 2026 02:15:31 -0800 (PST)
Received: from theodors-laptop.. ([5.255.118.7])
        by smtp.gmail.com with ESMTPSA id 4fb4d7f45d1cf-6b7c24e7714sm4235699a12.28.2026.11.16.02.15.29
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 16 Nov 2026 02:15:30 -0800 (PST)
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
Subject: [PATCH nf v3] ipvs: ftp: do not link expectations to unconfirmed conntracks
Date: Mon, 16 Nov 2026 13:15:06 +0300
Message-Id: <20261116101506.98853-1-theodorlarionov@gmail.com>
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

Link the expectation only to a confirmed conntrack.

Fixes: b25adce16064 ("ipvs: correct usage/allocation of seqadj ext in ipvs")
Suggested-by: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: stable@vger.kernel.org
Signed-off-by: Theodor Arsenij Larionov Trichkine <theodorlarionov@gmail.com>
---
v3: skip unconfirmed conntracks, as suggested by Pablo; v2 did not
cover NAT.
v2: https://lore.kernel.org/netdev/20261113011447.2357709-8-pablo@netfilter.org/

 net/netfilter/ipvs/ip_vs_ftp.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 44de99f4d187..cb0cdc35a7c1 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -398,8 +398,10 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 						   end - start,
 						   buf, buf_len);
 		if (mangled) {
-			ip_vs_nfct_expect_related(skb, ct, n_cp,
-						  ipvsh->protocol, 0, 0);
+			if (nf_ct_is_confirmed(ct))
+				ip_vs_nfct_expect_related(skb, ct, n_cp,
+							  ipvsh->protocol,
+							  0, 0);
 			if (skb->ip_summed == CHECKSUM_COMPLETE)
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
 			/* csum is updated */
-- 
2.34.1

