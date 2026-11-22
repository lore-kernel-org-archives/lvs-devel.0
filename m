Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795356172;
	b=3A67U3qf9W/nq5JwTEHpDieCoNI3rZvLepfQ8iAfCDyQIlcar15FsNrR5ykGOBxa8Sia
	 47X56ojeH+vUY+qQ2VP+CPV9PqHIhLjTO3YRp4EMCS6BU8RGeNxyxqRWVaOavRgf1rCwg
	 hFGFzd7GEuM2WR2bt4Rz2t15dctPRrse+3oA2dz+c8VtRQlASCHxQzl7ocmg/v+mq4528
	 ljBY/tzG+iMA5v/wutf/c1Q0XTVAs+WrZ9sGrAPah5ov1+TduJXUOzgrnx9x9dz4RfLbe
	 W/Hr+o2fLrN3gQbkYKmgDQmh+LZChptahksZ9TcO+l4OG9w45kyY3uRj/0j+nNPGPLg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795356172;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:X-B4-Tracking:X-Change-ID:To:Cc:
	 X-Mailer;
	bh=onl/poboZkNxS7sIah0bvOjq6ruOD15HwZb7C8yumw8=;
	b=M1ZpgG2AX3t4/dlvuQKU90qnNTeWbplo0419IXDKgdjBhHnsH0Lf+PGGOwreOtvx+zlL
	 qwAOkthWXDpY01gBKUVNQH+Htie5mzLpJpfgVnJcAx7Z/CqYqxHarnnle/xlGvjJLzEWn
	 80YFqTMgVUrWH4+9loX5Qpmm+zZb86RHgUfqgjwP8Rq5h6hw+d9byo49OUTEWfB43O7MV
	 XzMIMVUdsflDBVB3xOnH6XYmm3sf5ysWnMab0I3U7X5P28mbPNb+t/HTOD1QouRgFMN2q
	 CfW46ok1I1EE3boMb0Ugr6b3ZsSUT1/O77POyNjjoeIjpvl+u9YkCXJxubhNgVQVljA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="lI/5Yk22";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 80FB4606A320;
	Sun, 22 Nov 2026 14:02:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lI/5Yk22
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6A68D1F000C0;
	Sun, 22 Nov 2026 14:02:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795356171;
	bh=onl/poboZkNxS7sIah0bvOjq6ruOD15HwZb7C8yumw8=;
	h=From:Date:Subject:To:Cc;
	b=lI/5Yk22pphQIKmQiI0IUKh7l61RDgEj69WTtHSsTMVkiSuFPtRkCZZ+wqQ4mTCW4
	 z45o5DnnsXZRrsvhNQzbycAWd9fdHLngn4bJWWsoWz4itEP7lrLvr+HSO1WxFKKoDG
	 xgldgOIpNynD25pAEpoUGJaAdOjhZ7PdVaRxWfGl2fwQ6NlU4ECZjr2nQPdATMubsR
	 sVeV1/XShUCWpZniy8NTXPGaL5P9MTfyvAKBDqtLB/w0jUQDO9scXWeNu8MtEqA8V/
	 dnqFK4eOJ3VgqQSz23GjuKalFYOVBlCGqYCMNMosrULsQBTE/MK0G2ZaZ09zBxh375
	 ACsX2NiCG5ruA==
From: Simon Horman <horms@kernel.org>
Date: Sun, 22 Nov 2026 14:02:42 +0000
Subject: [PATCH nf] MAINTAINERS: Retire as IPVS maintainer
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261122-ipvs-retire-v1-1-af35c7a4e2b8@kernel.org>
X-B4-Tracking: v=1; b=H4sIAAL2AmsC/x3MTQqAIBBA4avErBNS+rGuEi1Mx5qNyRgSSHdPW
 n6L9wokZMIES1OAMVOiK1TItgF7mnCgIFcNqlOjlEoJijkJxpsYhTRe73aatesHqEVk9PT8txW
 Ch+19P32LOU9hAAAA
X-Change-ID: 20261122-ipvs-retire-1af8bc798d45
To: Julian Anastasov <ja@ssi.bg>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, 
 Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>, 
 "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@kernel.org>, 
 Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, 
 Simon Horman <horms@kernel.org>, netdev@vger.kernel.org, 
 lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, 
 coreteam@netfilter.org
X-Mailer: b4 0.14.2

In practice it has been some time since I've been actively working on IPVS.
And likewise, IPVS is maintained in nf/nf-next rather than ipvs/ipvs-next
for some time now. So this is somewhat overdue.

- Remove myself as IPVS maintainer
- Romeve ipvs and ipvs-net tree

As verge.net.au has, unfortunately, expired with little prospect of
recovery, also:

- Add mailmap entry for horms@verge.net.au

Signed-off-by: Simon Horman <horms@kernel.org>
---
 .mailmap    | 1 +
 MAINTAINERS | 3 ---
 2 files changed, 1 insertion(+), 3 deletions(-)

diff --git a/.mailmap b/.mailmap
index d73ec73e5ba9dd4ca678493346e250c016a036c8..56485c0b6779ef550c286de808995438856abb09 100644
--- a/.mailmap
+++ b/.mailmap
@@ -863,6 +863,7 @@ Simona Vetter <simona.vetter@ffwll.ch> <daniel.vetter@ffwll.ch>
 Simona Vetter <simona.vetter@ffwll.ch> <daniel.vetter@intel.com>
 Simona Vetter <simona.vetter@ffwll.ch> <daniel@ffwll.ch>
 Simona Vetter <simona.vetter@ffwll.ch> <daniel@biene.ffwll.ch>
+Simon Horman <horms@kernel.org> <horms@verge.net.au>
 Simon Horman <horms@kernel.org> <simon.horman@corigine.com>
 Simon Horman <horms@kernel.org> <simon.horman@netronome.com>
 Simon Kelley <simon@thekelleys.org.uk>
diff --git a/MAINTAINERS b/MAINTAINERS
index 7336600952c8e48dd24f7a61fd45a202268d947c..e1cdfcfeb30235b0686a7c3c0c54dd5e43d48daa 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -13852,13 +13852,10 @@ W:	http://www.adaptec.com/
 F:	drivers/scsi/ips*
 
 IPVS
-M:	Simon Horman <horms@verge.net.au>
 M:	Julian Anastasov <ja@ssi.bg>
 L:	netdev@vger.kernel.org
 L:	lvs-devel@vger.kernel.org
 S:	Maintained
-T:	git git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git
-T:	git git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git
 F:	Documentation/networking/ipvs-sysctl.rst
 F:	include/net/ip_vs.h
 F:	include/uapi/linux/ip_vs.h



