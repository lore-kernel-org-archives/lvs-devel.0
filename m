Received: from mail.commetrax.com (mail.commetrax.com [141.95.18.165])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C36A21EBFE0
	for <lvs-devel@vger.kernel.org>; Thu, 16 Oct 2025 07:57:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=141.95.18.165
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1760601424; cv=none; b=iDLVh5v8NNZi1JvZZ1Nn7+0R/AI6gevYu6BYBzIseu7Pv49dVZc0IoIxf4aqEh1kDtQ7PyPM/RorsaBWigSgyVOvptCNXIvxUqjahcTN1f/UzxXX86BcZhytj507yChY3J/WCAQezDOZ1uUrtPF59uNNlrR8i03QDX7pVeZM/lY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1760601424; c=relaxed/simple;
	bh=M2z+nFeXqIRcbI6rcgrOtIQjqLLid9ZQ1XheJsIeFLM=;
	h=Message-ID:Date:From:To:Subject:MIME-Version:Content-Type; b=cUMSe/7cWNSeN4ITN7Y51uXNvGCFP6YhziLguRtad8K+RlSMsNMsF85hQmDx1Qg5uzbpuQo/vASQekATR6JgSI7LPU0kmO3lHW5J2rcAAdU1rxS+ZtV32ZSdSW4Ja/CnaO8pnWnJzkcG5RpzUBX14MU7J/xMu3jDpXgC6bwOa30=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=commetrax.com; spf=pass smtp.mailfrom=commetrax.com; dkim=pass (2048-bit key) header.d=commetrax.com header.i=@commetrax.com header.b=HfnadXmW; arc=none smtp.client-ip=141.95.18.165
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=commetrax.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=commetrax.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=commetrax.com header.i=@commetrax.com header.b="HfnadXmW"
Received: by mail.commetrax.com (Postfix, from userid 1002)
	id 20BD724D65; Thu, 16 Oct 2025 09:56:42 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=commetrax.com;
	s=mail; t=1760601421;
	bh=M2z+nFeXqIRcbI6rcgrOtIQjqLLid9ZQ1XheJsIeFLM=;
	h=Date:From:To:Subject:From;
	b=HfnadXmWTYqIRKlqkhfzqgfiFApa3OD3DjW9NhgH16IuL2PrSEGz5rnXSl7tSnbEl
	 /xDKm9BKK+IhKoTTNqYEOu59GcCTxfZbHqSa52CjS/sUiX6rXvsyj0VIDKWZSVXiUd
	 QkL7WtwqLs/oajjZbQsX3tHcu1rZ04SzcwgU2ut+wbGEP/AQGUo5dndgeIZc7vLvUC
	 MaS3IzbH+dMvnmt2y2GbUcIMqEI3XOBQrFZgLfXpYS2i0j+8KA26P00n9OH+A3fj39
	 apXEMZa1ybI0bThwZFy5LT5mRfpHfW6m7n3TIiOP6lrLy5k3aIUQamCHZYdNr27jd7
	 RU2mf4d7tEopw==
Received: by mail.commetrax.com for <lvs-devel@vger.kernel.org>; Thu, 16 Oct 2025 07:55:56 GMT
Message-ID: <20251016084500-0.1.cb.17760.0.iinq5zbr8d@commetrax.com>
Date: Thu, 16 Oct 2025 07:55:56 GMT
From: "Luke Walsh" <luke.walsh@commetrax.com>
To: <lvs-devel@vger.kernel.org>
Subject: Welders ready to work
X-Mailer: mail.commetrax.com
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hello,

we support companies in carrying out industrial projects by providing wel=
ding and assembly of steel structures =E2=80=93 both on-site and in-house=
=2E

In practice, this means we enter with a ready team of welders and fitters=
, take responsibility for preparing the components, their installation an=
d quality control.=20

The client receives a complete, safe and timely delivered structure.

If you have projects that require steel solutions, we would be happy to t=
alk about how we can take over this part of the work and relieve your tea=
m.

Would you be open to a short conversation?


Best regards
Luke Walsh
