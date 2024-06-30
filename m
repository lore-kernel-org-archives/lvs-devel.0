Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3616C200C1;
	Sun, 30 Jun 2024 13:16:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1719753386; cv=none; b=MiBvV2bY2N8gCfG9x5vVVP9MsCbttZwaLO942zuTGU7M5iLr3iG/FKCq7RUU6t8PBB1WpkSJyXwmidKPL+1CBrYDs0RvBMenZCNLmNEvZvDcM2guw5RdxZN+QfvGasfEqEMg4MLGzVOBz3FFerquD03TcSTSWbSmvPMp/wJbCcg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1719753386; c=relaxed/simple;
	bh=262UgeLynu8qYG6MZIXW3paH4jn28M/vPA9axxXZ2uY=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=t2PUitkhUG2CuAnafDR9OAW1mE+BYvw8RQAlecKLU4V+R0cEPTTymR5Av2GpmDvndnfQGKWu0IQFqhAoZQ9QLbreh4ygerswwXIrkzIhw+oyBPHnWeZKGZ0l5aPVjNsMPPbz6ld33/qZQYQLb/S0c6LeHT2LGZ9QkqQFwVTm6eQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=KBM+gCQA; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="KBM+gCQA"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 508EFC2BD10;
	Sun, 30 Jun 2024 13:16:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1719753385;
	bh=262UgeLynu8qYG6MZIXW3paH4jn28M/vPA9axxXZ2uY=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=KBM+gCQAEpYIUEU6nXr+TBWqsk88sgO8ALOHAd9X+nqwPFfPYHG56KblvcNSa1dfH
	 m86WyIPwzmInW5blbFz6ZwE3H8lWmd2RBNcyOvthsMBvXKBDWbzEYO/A27ofE6bg4q
	 wJpVfhAfU5Qt5RJvJe3bZvHjUm8IpVgenRDA+IzPj6mISi5l/mHmuYZK7x2RQKHXo/
	 EF97Nr0MV226zDg6zfCKkGWa0JXJ8mQlaWN3WNWc9jmsiYFY3at9x3Owd5PSkyWQNi
	 p2WDL3iPrGz5+nZU5qWWpLPm+VFSof5HsssKdXbelmZrI/b/2N3skqVr2PeZnhg7g0
	 nBJ1bVi1G/ukw==
Date: Sun, 30 Jun 2024 14:16:20 +0100
From: Simon Horman <horms@kernel.org>
To: Chen Hanxiao <chenhx.fnst@fujitsu.com>
Cc: Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@netfilter.org>,
	"David S . Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
	netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org
Subject: Re: [PATCH net-next v2] ipvs: properly dereference pe in
 ip_vs_add_service
Message-ID: <20240630131620.GA17134@kernel.org>
References: <20240627061515.1477-1-chenhx.fnst@fujitsu.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20240627061515.1477-1-chenhx.fnst@fujitsu.com>

On Thu, Jun 27, 2024 at 02:15:15PM +0800, Chen Hanxiao wrote:
> Use pe directly to resolve sparse warning:
> 
>   net/netfilter/ipvs/ip_vs_ctl.c:1471:27: warning: dereference of noderef expression
> 
> Fixes: 39b972231536 ("ipvs: handle connections started by real-servers")
> Signed-off-by: Chen Hanxiao <chenhx.fnst@fujitsu.com>

Acked-by: Simon Horman <horms@kernel.org>

