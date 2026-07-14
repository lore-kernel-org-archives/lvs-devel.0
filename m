Received: from ns1.suksangroup.com (ns1.suksangroup.com [103.13.31.55])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5AD863264F4
	for <lvs-devel@vger.kernel.org>; Tue, 14 Jul 2026 05:24:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.13.31.55
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784006691; cv=none; b=Y84N7ybssWQr7XRflk1+jS8cY5SQLaRDdy6ctoSSgivW4mH1xO/ZJ20dPWLxSLzNmb9C7CAICJi0xONu8tGzkm6tgWIlfxH+VuR2tcp8Vd4HxhnXUYPWojdRJKzfOKHSCiTzp62jMbTB2tVAyg0w6OlwRzgbNpaGj47a0JB1t9w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784006691; c=relaxed/simple;
	bh=UUlJYQgFVrGgt88xvpL/bxgmb8OKE8rknWzAvJ1bT+8=;
	h=From:To:Subject:Date:Message-ID:MIME-Version:Content-Type; b=WLJFoWimyQrIaQ9GIa2mBJGXPMc7maO+KV6NWJ3fmL1hGqUdL76mnW+JCjH5Bzs0cVltxryJStxSZQjArbppqKer+zfVU51LMEziEhdeedqpsV4H2VQpp46gR3WNg7ZpHb1hhQIv7e4KJrWzrwqDn849L68oqBalPxR3h5qKJOY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=inbox.org; spf=fail smtp.mailfrom=inbox.org; dkim=pass (2048-bit key) header.d=suksangroup.co.th header.i=@suksangroup.co.th header.b=ZVNylGWy; arc=none smtp.client-ip=103.13.31.55
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=inbox.org
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=inbox.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=suksangroup.co.th header.i=@suksangroup.co.th header.b="ZVNylGWy"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=suksangroup.co.th; s=default; h=Content-Transfer-Encoding:Content-Type:
	MIME-Version:Message-ID:Date:Subject:To:From:Reply-To:Sender:Cc:Content-ID:
	Content-Description:Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc
	:Resent-Message-ID:In-Reply-To:References:List-Id:List-Help:List-Unsubscribe:
	List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=UUlJYQgFVrGgt88xvpL/bxgmb8OKE8rknWzAvJ1bT+8=; b=ZVNylGWyyT9Q3UYhjLdcgF0lvJ
	/iVwe63GVnEGBsLPe6nxwvVKgJAizSvdSjFE4+jI4m/kRuYub1lRoylbkKkA8Xv34O6GZ1tT6Ybql
	NUQzVjAxSY9DInFza80mWow6W6FUhsHQk3DxTFVV5zFKISwyIUpFvjimE1jUBlb6tvrRK3ry8Y3cp
	PBHLjq9RFVb4ejtxlMl8XUw74K0nTVl8vEQvrOFshB0oeWAPelX5wKzkJUxIL1vtx5/wsWkqFoWCW
	kp8DhqIXBkOGVCDua2xp+oMN9prxMiQyGOna3v5vPpn2sU3CV9LoqfrxQEUpMSZnUS2F14fzW6TS+
	wbhhPD2g==;
Received: from [207.189.26.187] (port=63390)
	by ns1.suksangroup.com with esmtpsa  (TLS1.3) tls TLS_AES_256_GCM_SHA384
	(Exim 4.99.4)
	(envelope-from <info@inbox.org>)
	id 1wjVdQ-0000000FxQn-1YQk
	for lvs-devel@vger.kernel.org;
	Tue, 14 Jul 2026 12:24:47 +0700
Reply-To: hanns.schofield@lexcapitalgrowth.com
From: Harry Schofield ESQ <info@inbox.org>
To: lvs-devel@vger.kernel.org
Subject: Dear lvs-devel@vger.kernel.org, 
Date: 14 Jul 2026 00:24:44 -0500
Message-ID: <20260714002443.198C020A94DDB984@inbox.org>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: quoted-printable
X-AntiAbuse: This header was added to track abuse, please include it with any abuse report
X-AntiAbuse: Primary Hostname - ns1.suksangroup.com
X-AntiAbuse: Original Domain - vger.kernel.org
X-AntiAbuse: Originator/Caller UID/GID - [47 12] / [47 12]
X-AntiAbuse: Sender Address Domain - inbox.org
X-Get-Message-Sender-Via: ns1.suksangroup.com: authenticated_id: smtp@suksangroup.co.th
X-Authenticated-Sender: ns1.suksangroup.com: smtp@suksangroup.co.th
X-Source: 
X-Source-Args: 
X-Source-Dir: 


Re:Good day lvs-devel,

Please let me know if this is best email to send you the project=20
info.

Kind regards,

Harry Schofield, ceMBA


