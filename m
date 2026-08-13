Received: from mail-pl1-f172.google.com (mail-pl1-f172.google.com [209.85.214.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A7D3349482A
	for <lvs-devel@vger.kernel.org>; Thu, 13 Aug 2026 16:59:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.214.172
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786640383; cv=pass; b=KN24Cj2mlRaYQ/lajfeFhqJTyO1Nl1J6JdhOWYnrmctJ5uTJd7t0tD9Y04FS68YG0yfxl8APQgV9Tb7bD3KJWlX7+iJO20v3YEG1rkGUeqSofwWxNwY1zwnu/7ohBCKeYMuuJZuGbRbmuqkyVGH/Bgz2rOOWhjhfIQgN9x8qcrU=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786640383; c=relaxed/simple;
	bh=xoBdWEtJTPlDLVyNbMab7t+/J7TUwi1z7zZtLQ6klVM=;
	h=MIME-Version:From:Date:Message-ID:Subject:To:Cc:Content-Type; b=TQIHGXSF0Xu9KIlu3q3OQUMoTUZcz6DxAwhfSMhY28Xp6xN8QCFSWUVtBpE1p//2QTxAVdstkpgKVyYZC42pP+Qcv/TLVRwzHVMVyUG5+WzzDMp9SDgjoj6Tr9LjqCMOJfD+R+dO3DNihzBuZDj+LgMOqp0F7oiA3yW8uGNKcQo=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Eoe0mBVp; arc=pass smtp.client-ip=209.85.214.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Eoe0mBVp"
Received: by mail-pl1-f172.google.com with SMTP id d9443c01a7336-2ce87c7e3bbso2053465ad.1
        for <lvs-devel@vger.kernel.org>; Thu, 13 Aug 2026 09:59:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1786640382; cv=none;
        d=google.com; s=arc-20260327;
        b=CzHYtsJtj/YQxuD6Qj0sVd/1JQAm6VNGSeYMVndj8ck6GJBByo0NsdMDJZ3shL2PjD
         ux/AuCkV2Qea+nrpAkWAudgjYZMyI+Xp67BySc9cZgh/DiVXVW6d3BPgUhuFEWZ2kVTb
         mo6SKrLah1wddvV869Xh7eB6D2V86qCvY1Qj9egkMQ8fTAwMrc3yCZcOvDbHck2y2tlW
         92KeDZnKbqBU02QCbZfaAYMDL4OtdNDnlP2Jy+zPcxtxzgkb1OugDBdQV7+uo04d+81K
         OAxF/SsvPij871KI/3pxdR+6IY6GBd+iz9gV1n3i34L3OA82w3tSkRx7u1WQNf+boths
         D4Qg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=5PCXtpD2RlzIqld0EEK6YS2HyVzJj+XySKEtASyVQ20=;
        fh=m0ObQt6ECWwEO3sk/WRhfVInkBtMny55ZQdRZo7w48s=;
        b=VN5VcSZ5GvJxXwg0NfKuzpV4WTU83koDCrGmsa3TlxB+w74dkuyirG+TpN86ds5UFN
         VdcrEMkfmZnAAnoDkmd5K2WgH8yw7/VWXb/yK1I6ZPW+6G/EmcpjLwNDMdWPm3HWOiFR
         MOLArZS/p8qM+Sr6rG8QQFob0Uel+/5py5z6m7bKXONiG5PLe60Q0s+NMZKvWTnEgjdQ
         QSANsDY25111kmQkFlSIksCUxoS2A3L1jYOrnRz2GYNzjbmixhh2J3JG9SyifUYs8AWf
         ZD7b2a6PVJKbjsdsvzHFsk6jcSDKoZs2jf9BzEUHI8DPDWoUUR2FznGMgER4TZo1VFcG
         2fkw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1786640382; x=1787245182; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:mime-version:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=5PCXtpD2RlzIqld0EEK6YS2HyVzJj+XySKEtASyVQ20=;
        b=Eoe0mBVpeSDdi7T3XLAxzyHYM/od6gilK0FfqVVaQnZJYb6FAffj76MwK44CEVzxo2
         lXpLCcfWLZ8F4f6y7n9iprcEXpf/LB/QinAUhfqR85T/QRXVJw1zfPbfA213B4qaLDYp
         atlsAA3O4a09qU+CdwO0K84bocjkDq/yaCphvjK/i9Lm2miLaRe3Ms3JgWyx3fyTMYZY
         G8l+iTgvoJcNCBROZuHQp6E+SHjZpCP37JK8UdS4tVmvPl3nhciAGcSLLMV3Em4vNSGf
         gsekNTEOAczWdL16NLWztGmQ4GbXSqn9UvXhmLELIa905JDObZu1vX4pO6TOTFFZLVKN
         66iw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786640382; x=1787245182;
        h=content-type:cc:to:subject:message-id:date:from:mime-version
         :x-gm-gg:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=5PCXtpD2RlzIqld0EEK6YS2HyVzJj+XySKEtASyVQ20=;
        b=hIrR2K+SwPatgBqQyA4FVDNYnkPg8wz0CpkRhR3zwWTAbY2Kc5K4Dg/4TIThFJ1SWN
         khnDMkxEvXFKN/JDmGCyovyl7CxUe3Yp9Tgo/ljGmjUgJl/oDsy6DnFTk96WRTxeAKcJ
         cCDEj1hdsF6ZvuuKwwXsPsXuoYenYsRpCSUb5Kv/q0t2n8b8AH4SxdsjwDsekDzrANxF
         VeydWuGr6gJfLl4VS8quknJL+VU0mNcnp7BbCq8AgsKaT8ugS11Tfe6GSlgNP/oCvd4X
         MVYFBMe9UaNsyGQaW3Kc85jgiHiII5Ot1iYDKWseosABH1lSrKcSyMSw0HEYrgurexZ0
         T55A==
X-Forwarded-Encrypted: i=1; AHgh+RoxbsFS2gL4I8chRvsXVh+P5DmdMvI2dpSJUsoZA91UZ3kYUOpDYeOEY1vj9VD4DepLT5vqoJ8LaQw=@vger.kernel.org
X-Gm-Message-State: AOJu0YzsywIhIbybbwLDrXzd3MX7DMFgu0LJ2s5rMEUZXeD0pYNxFb77
	uHpxc6lULNItHHjZh+ed64TctwfGNXHbpDObr/0UJqtW5vbL2wpES9Wz6FUeP1l0DX0ex+dUQb8
	sDlJnBGS+hyllSPDyWzKJT2++Lf98l5GBeW/xJEyJgjTX1Jo=
X-Gm-Gg: AR+sD13CSzCf9h2s35NhC7zD+kMnl4X/PgLocy/EcVeXdHcCxgm9eVXyJ2pWmAVlmyR
	Vc3Dru8IS3o/AVi9w/Opz1sYFtRjrVwGfcCnS7IrImmKlXSHjKv7PZs5gHfbwUJUbyx4yOohfZC
	RhREpneGOMLKwqbfPPdfpZflk3mst1koaUsU1PKpx+eidvmubywx7Kk/w6yjWmHh5bpO9b9lGZZ
	X7ZItcDQ99XX2/G3WIYLxVgsd6zXJCUkuDY4pUs5GmPCpGI6Ia9qW11Oskect8sfOrvtXiE2YDK
	+O6H6A2zjmXidUtj3Dt3nclnVd0OpqB0O19z9Q6ucKzo+ooEKSBbAU1lYiFtdl7u2lM3lxyB81Y
	pOp9HnsAF4846ozjZL6/LAMavnRgVlGkO2g==
X-Received: by 2002:a17:903:40d1:b0:2ca:304:f93e with SMTP id
 d9443c01a7336-2d37ebc2df5mr97346755ad.22.1786640381605; Thu, 13 Aug 2026
 09:59:41 -0700 (PDT)
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: Joas Antonio <joasantonio108@gmail.com>
Date: Thu, 13 Aug 2026 13:59:30 -0300
X-Gm-Features: AUfX_mwucnYyIHD3IqRl-RHeVt6sDZhmNV6nBBs18XEE_p_RDm2X2qFPzlzle-s
Message-ID: <CAOCBhwHbcnuzP1fz=JLqeRA0xNU=QdqppeRy2y=wqhJR6k_VRQ@mail.gmail.com>
Subject: [PATCH] ipvs: fix integer overflow in ftp helper port/address parsing
To: horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, fw@strlen.de
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, 
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

ip_vs_ftp_get_addrport() accumulates decimal digits into a __u16
(hport) and into unsigned char (p[]) without checking for overflow.
A crafted FTP PASV/EPSV response with an over-long port or address
octet wraps the value, so the helper configures the data connection
with a truncated port/address.

The netfilter conntrack FTP helper had the same defect, fixed in
commit 2b413fc689ba ("netfilter: nf_conntrack_ftp: avoid u16
overflows"). Apply the equivalent fix here: widen the port accumulator
to u32 and reject values above 65535, and reject address octets above
255.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Signed-off-by: CyberSecurityUP <joasantonio108@gmail.com>
---
 net/netfilter/ipvs/ip_vs_ftp.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index b315c608f..9e3e005a8 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -102,7 +102,7 @@ static int ip_vs_ftp_get_addrport(char *data, char
*data_limit,
  char *s, c;
  unsigned char p[6];
  char edelim;
- __u16 hport;
+ __u32 hport;
  int i = 0;

  if (data_limit - data < plen) {
@@ -144,7 +144,11 @@ static int ip_vs_ftp_get_addrport(char *data,
char *data_limit,
  return -1;
  c = *data;
  if (isdigit(c)) {
- p[i] = p[i]*10 + c - '0';
+ unsigned int val = p[i] * 10 + c - '0';
+
+ if (val > 255)
+ return -1;
+ p[i] = val;
  } else if (c == ',' && i < 5) {
  i++;
  p[i] = 0;
@@ -222,6 +226,8 @@ static int ip_vs_ftp_get_addrport(char *data, char
*data_limit,
  if (!isdigit(*s))
  break;
  hport = hport * 10 + *s - '0';
+ if (hport > 65535)
+ return -1;
  }
  if (s == data_limit || !hport || *s != edelim)
  return -1;
--
2.39.5 (Apple Git-154)
