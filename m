Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 824A2377AB4;
	Thu, 20 Aug 2026 04:19:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787199575; cv=none; b=u4U15uQ1mTWSzwMe8QKjpsIjTCF3NrblHOZ5lfq2kHgEu4llrkBkUXrEKPN1KM33hApT3pe12GDf0IAyerTjh+YN/uHn3M7UMyF21CAyo8aVLflhZDVZxdsl05hrqFpAMFjmVLVe6F8KRAVKZXdqshPno+Zj8MctC+MFqjgojXk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787199575; c=relaxed/simple;
	bh=dAlLbjRkxBfIrm7DUCRIRbmO3MyWus330Bamjg0il5I=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=GFn9A5rtiNclRT/BGgeqB5gx/dJoYaXQXaisGugUMudH+uzAlvoE2RGxjBhgr7zfrI+373BobEh27G/hClK/t7RAlRgCLXAp9+J4+b/OaXopLQ69GnJ+OYZ3fQD1aI70GHrYZhzPeU47Lklyj4S30E0KjVagXXsd/LDtiHPuZKI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Ma6Q09KI; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Ma6Q09KI"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 452B31F00A3A;
	Thu, 20 Aug 2026 04:19:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787199574;
	bh=+R63TSIRcwTf8b7LANj525Ofhu06KmM2wt3KgdBq4cQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Ma6Q09KI8yYT9QxwA0OLAtazDNnEWcbwi+7OHKZMIP96Cel8kTuXQu+huKGMGtUgD
	 6ruuilVOFqho6a8VIEJo/aMQNlrlvaRMka5IIypLz/Ve+6SrjaG5F3bH7d9eniXbHU
	 DtA5rKpnz9pZi9Xi6zPVg6KWc5qyKI6ucOj1N5WV55ddh1MZBAUZYSs4XnKqIITo+8
	 bwVj6INLGoIMYLdXlqDceypC5qcY+Jqx1lr79Y89iCcZM3j5V1kfDZWWIY1sRvzEX6
	 BC6jv9ucYfCBQHd0ZCQ6H2DQ0tmE9OuKsYVgrQHzZ2O5HKqb0KiUPDa+1cYob+OrOT
	 vncRbkEtkQWHQ==
From: Sasha Levin <sashal@kernel.org>
To: stable@vger.kernel.org
Cc: Sasha Levin <sashal@kernel.org>,
	Simon Horman <horms@verge.net.au>,
	lvs-devel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	netfilter-devel@vger.kernel.org,
	Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH -stable 1/1] ipvs: separate destination availability state
Date: Thu, 20 Aug 2026 00:19:24 -0400
Message-ID: <20260820040907.3@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260818201638.121446-2-ja@ssi.bg>
References: <20260818201638.121446-2-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

On Tue, Aug 18, 2026 at 11:16:38PM +0300, Julian Anastasov wrote:
> [ Julian: Backport by removing the hunks from ip_vs_xmit.c ]

Queued for 6.18, 6.12, 6.6, 6.1, 5.15 and 5.10, thanks.

-- 
Thanks,
Sasha
