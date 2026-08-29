Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DF56E22E3F0;
	Sat, 29 Aug 2026 03:34:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787974494; cv=none; b=j2F5cPKEYBZOT7QcvU5cucAfGzAgdm6kOx6zr51eAzcJ43WCKTIZ77jerOSGWr3i7lCdfJOYENNWrHJjEBFZHR68qrx/bKECmb4GXZU6Q2OhypoxWI0rMCYELJ8Iit0eX8YAbL53FLyXzcn4klynIq7PbbtXbEfF9m5kD1jxdgI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787974494; c=relaxed/simple;
	bh=G6YnDC3Bd8h6Mtz4c2METMXpJ1rzqwFdpsYXgmmrLEA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Xfaz7ZIYqxA6rE8avY10oWWwRYPkYXDUk6xqKaZAOEcovTrp8KdgQFHMgAK7J9Dv87Lz9s2gCxE+rrauVAgHT9mhsbzE7MmxvCpkteWup4HknClXiYnLRJwjqT8bsXPsyZTag72k+gIGOKNDaWC5QswZsXl4myu4B31K1V7kUVQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=EVKB7qwO; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="EVKB7qwO"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D58581F00A3F;
	Sat, 29 Aug 2026 03:34:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787974493;
	bh=E6siB1YvZalUIraySCKgtvZ+KGOogw5b479lEh9bn/0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=EVKB7qwOUh8sEmcXsJJyF0knMqvxQoKDszQorTifOvxGlTpewwdxPsR84bz2cqaR0
	 QAvx6xDoKLWdWdU3ilQEQWdL7Qh9aHhWYWBuT/MAbMBm/OWcZLM5XCVdF08hnJLXN4
	 REDWdePV0kNK30xzVYpQJLLMMzLWQ0OOLeOn9bwIf7Xovs/I0/k80VhKU0kANQRplR
	 /kkOnTJpu6+rHTdm6EgU6cKNGbWkgatHot0O0GtcGDI2WT2t6T3trQTAJL9e3YK19k
	 LwXH0fzkzAg04vCZIPwm29sPZPkTU5yGX4EumsdK0zvzx27ZLO0RBCJvcEuI5epa0f
	 KY0yP5ApVg8Sg==
From: Sasha Levin <sashal@kernel.org>
To: stable@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Sasha Levin <sashal@kernel.org>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	"David S. Miller" <davem@davemloft.net>,
	Jakub Kicinski <kuba@kernel.org>,
	Dwip Banerjee <dwip@linux.vnet.ibm.com>,
	netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org,
	linux-kernel@vger.kernel.org,
	Denis Arefev <arefev@swemel.ru>
Subject: Re: [PATCH 5.10/6.1] ipvs: reload ip header after head reallocation
Date: Fri, 28 Aug 2026 23:34:38 -0400
Message-ID: <20260828-stable-daily-0007-ipvs-reload-iph@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260828085522.31015-1-arefev@swemel.ru>
References: <20260828085522.31015-1-arefev@swemel.ru>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

> commit a2f57827bf7c695b8c72dc4511cae8e86582369d upstream.
>
> __ip_vs_get_out_rt() calls skb_ensure_writable() which may
> reallocate skb->head.

Queued for 6.1, 5.15 and 5.10, thanks.  5.15 has the same dangling iph in
ip_vs_bypass_xmit(), so I applied the same patch there as well.

-- 
Thanks,
Sasha
