From: pr-tracker-bot@kernel.org
Subject: Re: [GIT PULL] sysctl changes for v6.6-rc1
Date: Wed, 30 Aug 2023 03:58:07 +0000
Message-ID: <169336788741.6268.886734446514047714.pr-tracker-bot@kernel.org>
References: <ZO5Yx5JFogGi/cBo@bombadil.infradead.org>
Return-path: <netdev+bounces-31325-gl-netdev-2=m.gmane-mx.org@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1693367887;
	bh=mPKk2+swFtGFWy8pTYH1vfYUh7/3u0eFDl38x3vBbbc=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc:From;
	b=ADgZbQkup9SM4uuEjVXPl0kZb5qU5cRxcBUYIV68ssaOHHCZrS2+ntwfLz0HT21Ih
	 e386cEZAZNnNJznyld2KJf/v8fe7MjFSYHeqn2jCi/au5X8+GFJAJs2UqaMkjl13Pt
	 tBWufYtEAuzWRPX8V1l2CtngKltT6f7/s0ANkfkNNyVfix0L9B91QYMTHLJdOVoFVq
	 IlamCyGNhuWsTR9+yFkPDS5wrnr9z9xFHderl/6D+AsGosodrxgWcJDG1GU30wgN9F
	 bxisMSAemfMVycuM7wn1I11u7D6rtj9+5B2G88KHjzTBzjQzbN1UyndsBWNsRv7wH+
	 v1R8ONmU6MaSg==
In-Reply-To: <ZO5Yx5JFogGi/cBo@bombadil.infradead.org>
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:netdev+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:netdev+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Luis Chamberlain <mcgrof@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Joel Granados <joel.granados@gmail.com>, linux-fsdevel@vger.kernel.org, rds-devel@oss.oracle.com, "David S. Miller" <davem@davemloft.net>, Florian Westphal <fw@strlen.de>, willy@infradead.org, Jan Karcher <jaka@linux.ibm.com>, Wen Gu <guwen@linux.alibaba.com>, Simon Horman <horms@verge.net.au>, Tony Lu <tonylu@linux.alibaba.com>, linux-wpan@vger.kernel.org, Matthieu Baerts <matthieu.baerts@tessares.net>, Christian Borntraeger <borntraeger@linux.ibm.com>, mptcp@lists.linux.dev, Heiko Carstens <hca@linux.ibm.com>, Stefan Schmidt <stefan@datenfreihafen.org>, Will Deacon <will@kernel.org>, Julian Anastasov <ja@ssi.bg>, netfilter-devel@vger.kernel.org, Joerg Reuter <jreuter@yaina.de>, linux-kernel@vger.kernel.org, Alexander Gordeev <agordeev@linux.ibm.com>, linux-sctp@vger.kernel.org, Xin Long <lucien.xin@gmail.com>, Herbert

The pull request you sent on Tue, 29 Aug 2023 13:44:55 -0700:

> git://git.kernel.org/pub/scm/linux/kernel/git/mcgrof/linux.git/ tags/sysctl-6.6-rc1

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/adfd671676c922bada16477eb68b5eb5f065addc

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html

