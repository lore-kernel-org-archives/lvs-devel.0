Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794590279;
	b=rW6f2fmIu07rha235OvHyDXUZy2Vepv/oubJITlCwSR0CYRt+fMTNK5cfuw/xQvxQDZa
	 +09VlKJZBAYiEqHRCM0Ky+YbsqRRJhyaVf//36S4WN1GhvcotaM62EM3qTUoW+tydRLgY
	 magmLkSqlBQraYSCsTH8g8wL/wFmq7ValiAI9DGxvZvfgNPw6MojIE9CM0d7hCT7OwGkS
	 OYuX29Raqkph42KJexJCfHE1A1tmZ7hsbs9TICYv3RfhYggVDm1ZgT7FxV2JghhukU22d
	 pnqIKFM3bha8x0CPE3DuqRFOw3juW0uHzjv70eUvsgT7jArnTEOikmJSamKHOuzbtng==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794590279;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=PVJtQ5hN7JNtRgrhw61SKODFQASqaxJzZHDO+EbyW4s=;
	b=Zo5yQjZTrUToRn4SK7wou2V6I80gBOrBMDXjjwSRJqKUyVhf9M1s7/QcdAjffLWZVwgB
	 uu7WJ1uFqOgnON622LuRzD9zsCJvaip10gPEicWZVUTMGcLM5DDxGkYtwp8JxBiL9xqd0
	 +5LRu2TeXD5kGqfoc0IIAuypCFOxQoZeBD8HHP3CLSBl2YdRT9oyXMS4PwhLbid1pJx1l
	 myXjvzbIDBTOrGrGxk/H7R3vTuH/DECLd3qcC8Lb6+trgTVn/7U+/D2yPvPCv4hMjVnng
	 +tVOEuinXTepPrMTmavtGR/9ax0ybFtY0xc5MvmyvJhnlT92VeXzeDkX8Y8LiOQpVjw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=jdvTKZdv;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C8BAF60776EA;
	Fri, 13 Nov 2026 17:17:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=jdvTKZdv
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7EF631F000C6;
	Fri, 13 Nov 2026 17:17:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794590279;
	bh=PVJtQ5hN7JNtRgrhw61SKODFQASqaxJzZHDO+EbyW4s=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=jdvTKZdvUR5C9oG+Ac1o8TpgGGUCH89hZc/ERVb2ZH395zAWhAg3+4MA+OyFbI9l+
	 1ukYPQtuJMvZtqrDTgVZeWzR1L0xq8gH2/jjK8Ome3aETZJwuxPcguU7SncchSQnk7
	 RFPwuDVJb7wGrCAABbIrEJLVmGePOLUNfwceh1tgtJisVL/m4KZH5pJCjbU2vUFDMc
	 1E38DLYPh8XjvJE2eoKpajP2gKn2SXkKehfdBGAG9tD219tLEeRKJY4ZioxzXeybCM
	 cVOGFJcTOF6cDSE9CM2t1bk+m1VB/jU80Okw5QJQboWrPjIJEqYKmWS2Vs8jmqMF9d
	 9uui4jLS8wqMQ==
Date: Fri, 13 Nov 2026 17:17:51 +0000
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
Subject: Re: [PATCH net-next 11/14] ipvs: annotate data-races around
 lblc_expiration and lblcr_expiration
Message-ID: <20261113171751.GU18859@horms.kernel.org>
References: <20261109025425.328445-1-jiayuan.chen@linux.dev>
 <20261109025425.328445-12-jiayuan.chen@linux.dev>
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
In-Reply-To: <20261109025425.328445-12-jiayuan.chen@linux.dev>

On Mon, Nov 09, 2026 at 10:52:10AM +0800, Jiayuan Chen wrote:
> sysctl_lblc_expiration and sysctl_lblcr_expiration are read without any
> lock while their sysctl handlers update them with WRITE_ONCE(). Add
> READ_ONCE() to the readers.
> 
> Signed-off-by: Jiayuan Chen <jiayuan.chen@linux.dev>

Acked-by: Simon Horman <horms@kernel.org>

