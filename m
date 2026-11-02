Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793606880;
	b=2HipunWITw0soE356vA/Tu+PFlki7MMlilwReet8eF+hgSn5BQdjURJAAR+WUrG9cLvy
	 QdedqmUAi3s3xaDj4DxuKXXrP5Kj+TUp048lgduhtxrNI47VF+J085taIdeYF8eN6Sglu
	 ra+sOhdwJQ5K7V3lRIg8DSE8mzFo8s6QUuznXPsLKx8pU+nU2I5HvsSxuBVUkVaVPui56
	 Mngq/YXRVjLyf6pZFBnV/qf4vhGokdExaWQWm+IJDXfCwVWz5Orkwev4fEyLhEctorH/O
	 iuXerog2EqIbt+YGbN1N8kSQqG+A5lhyFRrsjMW2M7Eq29+ShxgI53v0FdeLm038P7Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793606880;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=OM9ITTFd4wToE5cGFTMESYfhLmg2h0KtTmYQ5F4QRvA=;
	b=1m2mWIiPRGVtnBh+EOFYGh3vxeBVAMjKIFwsuv7VWpwT67KwrGDRdpQ3vkDA3XveZYjJ
	 Cd1pHbIaLyEjnT46IAIuphLw3em7KB0hI4D/aTtwNsPa1rfqnmAuUhr3mA78KJQDflNUJ
	 CpR6EhnVgeD4STXEQMxfKwcw5+bbANwQ6pStxA6QM/7m6qjwZnbVVKjNJQwzsbvk4t9BX
	 s7UERlqoV2XqLe/Yv51132V7WHQx1x3I83X8NiUJECFIAQelX2BAOO45LbSVMChz/JZDg
	 M+/cSorGYC5/Z58LzgmehfPhEbPgQ/ttCBk9uyzlrfi4pkjyYyv7xJccogHVkaQ/qKg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=tqdS1SiD;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 69970606A329;
	Mon,  2 Nov 2026 08:07:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 69970606A329
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=tqdS1SiD
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 9E6DA21F8F;
	Mon, 02 Nov 2026 10:07:49 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=OM9ITTFd
	4wToE5cGFTMESYfhLmg2h0KtTmYQ5F4QRvA=; b=tqdS1SiDGsxx0Rr95CmPbQ3Z
	1+7eb/udDJ4BLiUKbGTLnJHi+k8vz7qTlvlZNWEeCnYByLIHOGchg81Rm22i3+p1
	d9bP9c4M3lJHw30Kt1NncMCLPtAZqerYeQ3cYCIZMlaowpuGi8QYNR4bCt4EXOdi
	cTo5JGXbDC+GW16ayA9TnXX9tkIxNlMacje3Nd9e52zxsK4tBqxf83AxdTSandcF
	cmsaRarhS3VbVt4uYuKLeiMPXgbaBSOntG4JCt4VhvKBkpHfPiYUF5i6Kdsws97m
	ttx0CxWb2Kaz7sLqemzorPW54E/mIhZURZssMvJyRxpoH+Kh7uSXCdLBbPRzRt3e
	4jXpcz3yNHNJR4iq5GSUYBIjYaK7WziL8aLQ+VkgTXBLq5E2sHjP/t7nEWMeQWNL
	xkFfz4TXwrA0Fl6FPNPvUnofytwH+zsy1bh6DIsdRyM7W7MfPlAiX7U7i6QIvAdr
	z0TPvHtsE1biz8GuAS8gIb7EWTlIjc7V69qG3Nh45RIizKtzHmNccYytie5WPMWK
	ePSjwv5v36JVCV3T1hsamcxksqSCq6Q1i4HJRKT8KVXGO57VQRashHx/169ldJ+w
	rf5oSwIhBpKDZLwmOjp84YHUC+ZXNWPPVZgVqS+rX4q2PNR8GvgohKwxDVj/bdsQ
	OYAUqgoYpBrxpjxbTys=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 02 Nov 2026 10:07:49 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 09B4960BAF;
	Mon,  2 Nov 2026 10:07:49 +0200 (EET)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6A287fJL022195;
	Mon, 2 Nov 2026 10:07:41 +0200
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 6A287bji022193;
	Mon, 2 Nov 2026 10:07:37 +0200
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf v3 0/2] ipvs: read conn fields during sync atomically
Date: Mon,  2 Nov 2026 10:07:26 +0200
Message-ID: <20261102080728.22178-1-ja@ssi.bg>
X-Mailer: git-send-email 2.56.0
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

        Hello,

        The following are two patches that ensure atomic access
for the connection fields in the backup and master servers.

        The first patch makes sure the connection fields such as
flags, sync_conn_opt (seqs), state, old_state and timeout are
updated atomically in the backup server.

        As for the master server, the second patch takes snapshot
of the flags and seqs under lock before sending. This is to
ensure we send valid seqs if their presence is marked in
the flags we send.

Changes in v2:
* add patch 1
* patch 2: read seqs with flags under lock

Changes in v3:
* as v1 of patch 2 is applied, make v3 relative to the
  applied commit and rename it

Link to v1:
https://lore.kernel.org/all/20260909155500.68273-1-ja@ssi.bg/

Link to v2:
https://lore.kernel.org/all/20260929113436.44306-1-ja@ssi.bg/

Julian Anastasov (2):
  ipvs: update flags and seqs in backup server under lock
  ipvs: read flags and seqs in master atomically

 net/netfilter/ipvs/ip_vs_sync.c | 32 ++++++++++++++++++++++++++------
 1 file changed, 26 insertions(+), 6 deletions(-)

-- 
2.56.0


