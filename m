Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794589858;
	b=Ekg2tL9kmdIR9HtFB52f4wXqJYR3vBvBCDna+9Cpcf+AOCwUH1R60zCmWCvOnJsNZ0Az
	 IrOBqG9KBXgdxvJVzG0TzrEir7M6O7qnF+y4SIwDiTE+bCFQZY296oSzrUjypzohE+f9Y
	 JvT2PgfQlHDxsBME+JLSR+WIUchzW3w/gIp+pvrI2Pe2kjZnUfgizbkONmD3AJNHLbSiZ
	 tn5309PQ5Yipg78RjfEt44xPY1lBfWcwDW3y3gIp6FOYnF1J5GzVw/kMtWT7u7R6YC00O
	 8o73e8P76UivonkYc4po/FXNapbXGIVI5D0aNQRmBA8QjklAMPDS4M4iyPl/p1vaw/w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794589858;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=maofO7OzpRbXrucFNRCXLNY3Wo8C40MOHwmWctw+fM8=;
	b=mYC9XZ6hLdDHdteeYZvwv0RVEHdQKi9jf1tKqD0q3OmLBfSGcoykwZj3/kP8IzaMi0bk
	 2F6ABLyS8gjCofJwUxcGLTKSH9ymqX50SvGnSuSstLJDR+arr/Fo2TvewcrcicqMdpKfT
	 ftrLeL2Rh/qh4pxsybQQGELfPYF0dhXdUCOlJFM+YEyXkkzxAsjl62Zq5Pa+jIxazfLC0
	 2X5csoO0sKADUBLqm4Opgnfs8INcg9i9wTTX1vKH3bUGSCu9naB1Cb0W3E0oGR0neYFbp
	 erMT3cpMXzJ/YTgHzMMXEAEAeEQ9KlSEX5MetEZQO9bhJN+q2sh/Xb6rQHv0iPLWS3A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BpWp6k1S;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 815BE606A88E;
	Fri, 13 Nov 2026 17:10:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BpWp6k1S
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6FD401F000C7;
	Fri, 13 Nov 2026 17:10:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794589858;
	bh=maofO7OzpRbXrucFNRCXLNY3Wo8C40MOHwmWctw+fM8=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=BpWp6k1SdAfBuXCQXVprjvqV5tKMSYJz/sh75MYEal9fLvubId0RI2k0pXbaXPcqP
	 XW7W8QTY8Yp80bHb3bHbhJ2pmExjzJKvRTkysa/kB7Uk5kSQk48Ky/V6jYgRS2Ag/z
	 b0gc71kH7THrDydxHbgpA1u2Z+aPcUEz4iVI/oIZ8uDXPH+fZw+EOrLG8smPRlR81n
	 hUqtJAsa4dogw4cFSolmDv3RS80cZ9AdHNVyrReK6dyCERc/Tkn+CUP8WdJ70s/Tyd
	 WsDSoElNiJ/7Mr3PPR2dotagWAQqYJsoCXp8vaEKs5odiInmbGy+gNs4DhVXqgNBFb
	 z/PlpRnhV0X9Q==
Date: Fri, 13 Nov 2026 17:10:50 +0000
From: Simon Horman <horms@kernel.org>
To: Jiayuan Chen <jiayuan.chen@linux.dev>
Cc: netdev@vger.kernel.org, David Ahern <dsahern@kernel.org>,
	Ido Schimmel <idosch@nvidia.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@kernel.org>,
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	Paul Moore <paul@paul-moore.com>,
	Matthieu Baerts <matttbe@kernel.org>,
	Mat Martineau <martineau@kernel.org>,
	Geliang Tang <geliang@kernel.org>, Julian Anastasov <ja@ssi.bg>,
	Allison Henderson <achender@kernel.org>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Xin Long <lucien.xin@gmail.com>,
	"D. Wythe" <alibuda@linux.alibaba.com>,
	Dust Li <dust.li@linux.alibaba.com>,
	Sidraya Jayagond <sidraya@linux.ibm.com>,
	Mahanta Jambigi <mjambigi@linux.ibm.com>,
	Tony Lu <tonylu@linux.alibaba.com>,
	Wen Gu <guwen@linux.alibaba.com>, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	bridge@lists.linux.dev, linux-security-module@vger.kernel.org,
	mptcp@lists.linux.dev, lvs-devel@vger.kernel.org,
	linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
	linux-sctp@vger.kernel.org, linux-s390@vger.kernel.org
Subject: Re: [PATCH net-next 02/14] inet: frags: annotate data-races around
 fqdir->timeout and fqdir->max_dist
Message-ID: <20261113171050.GM18859@horms.kernel.org>
References: <20261109025425.328445-1-jiayuan.chen@linux.dev>
 <20261109025425.328445-3-jiayuan.chen@linux.dev>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261109025425.328445-3-jiayuan.chen@linux.dev>

On Mon, Nov 09, 2026 at 10:52:01AM +0800, Jiayuan Chen wrote:
> fqdir->timeout and fqdir->max_dist are read without any lock while their
> sysctl handlers update them with WRITE_ONCE(). Add READ_ONCE() to the
> readers.
> 
> Signed-off-by: Jiayuan Chen <jiayuan.chen@linux.dev>

Reviewed-by: Simon Horman <horms@kernel.org>
