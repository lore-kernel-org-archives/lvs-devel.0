Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 819E81C5496;
	Wed, 27 Aug 2025 10:48:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1756291705; cv=none; b=QHkkj9TV8ZdYGTVxSs2GB3/KXF0qFT/5rLrQju2UdfRfxEIxfyN4GN44eBVml08PuULbDAbxfARaFce2HXyAVn7DApR/5LLBzJrnqtLUSeXUUWJZgCt/NfzsY+PD7dbIobEi30KjtFXg66sWogBmIfTQnMZ+GdGXX3x3TQjOUVQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1756291705; c=relaxed/simple;
	bh=DMYmWN61KVuMj6xHJA0q9m7MIXo+ETDqqJfxsWK/v8Y=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Ci1WY3uqfcOGrGcFVh+4sI4S0BFm341SVCJN+f9dcnw5gPe2CDHqUEpweai/fxmoyfJPG3R9jSzGdfcRSrhxpwPUqdNHFJp2YRUYwmT1wtRwge9I1vvjEUywUVrZldZGIr1QHbohbNLZ4GcirXc5DUDwZd/xDnqncM89OH7L/Wc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=eIN265ez; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="eIN265ez"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 25E99C4CEEB;
	Wed, 27 Aug 2025 10:48:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1756291705;
	bh=DMYmWN61KVuMj6xHJA0q9m7MIXo+ETDqqJfxsWK/v8Y=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=eIN265ezV7OiJZQP/8z192KwoDESRoFkVRGNGA9a/STF00PtCzS/5OHXgbs8/YI4k
	 1j2bJeEK2rotLlJMMzkgAggFhG0pkNrctucTijjgb/mRZER84h5oI2upOK/LuVQhjB
	 ypFdsAEMranyGAlnpm3nkx193EoYlhjViFh1nbgAtQlni2Jb6BgT6bT1dPQuPspNZd
	 rG6NmjxasuowJzzKr6QNndOyGsQM4DKTHt4JzwyKU50Nlieb2Ii1X9GVETzxB2zZEM
	 rncuCk3QASYaan4UHD6pvL+Y41xzTdOWCzEKDzIUdwi+GmBkf1uAPPlG3gdeleKEJP
	 8HwDep3xAjQzg==
Date: Wed, 27 Aug 2025 11:48:19 +0100
From: Simon Horman <horms@kernel.org>
To: Frederic Weisbecker <frederic@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	David Ahern <dsahern@kernel.org>, Julian Anastasov <ja@ssi.bg>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@netfilter.org>, netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org
Subject: Re: [PATCH net] ipvs: Fix estimator kthreads preferred affinity
Message-ID: <20250827104819.GA26074@horms.kernel.org>
References: <20250729120659.201095-1-frederic@kernel.org>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20250729120659.201095-1-frederic@kernel.org>

On Tue, Jul 29, 2025 at 02:06:59PM +0200, Frederic Weisbecker wrote:
> The estimator kthreads' affinity are defined by sysctl overwritten
> preferences and applied through a plain call to the scheduler's affinity
> API.
> 
> However since the introduction of managed kthreads preferred affinity,
> such a practice shortcuts the kthreads core code which eventually
> overwrites the target to the default unbound affinity.
> 
> Fix this with using the appropriate kthread's API which will carry the
> desired affinity and maintain it across CPU hotplug events and CPU
> isolation constraints.
> 
> Fixes: d1a89197589c ("kthread: Default affine kthread to its preferred NUMA node")
> Signed-off-by: Frederic Weisbecker <frederic@kernel.org>

Acked-by: Simon Horman <horms@kernel.org>

