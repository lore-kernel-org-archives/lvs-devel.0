Received: from mail.netfilter.org (mail.netfilter.org [217.70.190.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8E1C6192B96;
	Thu,  7 Aug 2025 13:00:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.190.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1754571658; cv=none; b=KzhzfDszEGMgicdctFg9cQjYKyKyCPPXFgRPLt2QE+mjk7KUe1Wn8a6n6oEL04OLnUdY/623ccOeZ6vYqSlocpeVDHbpGxuYbmDnXjM+iWNJXISIcpo16ePDBcKIOggwxkDXM5J7XAUdyXLl6rEwLJnNbyDTjmb8tW7AdNtGJfw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1754571658; c=relaxed/simple;
	bh=Ymy3aH92/UMMaqPqGAvDclTA499ExCXOs+ouQYAUbQ8=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=TCTDXR1fsOrlXtnlpj/oO9/p0qysDAsrRbLhbgzCVQbEqOC+tLI2SxRWJYOyeQR/AkwAuTVffDUNF5nenPX/EhKfUr8pcg8pW8jevYKuZLSxCdYgDxLH4WJcBxT22TBqTHwlWD4kp76bQm+hAct2592zu8tvcwU+ptSHt+ISnTw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org; spf=pass smtp.mailfrom=netfilter.org; dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b=QTCa88mv; dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b=GGwwIJdF; arc=none smtp.client-ip=217.70.190.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netfilter.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b="QTCa88mv";
	dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b="GGwwIJdF"
Received: by mail.netfilter.org (Postfix, from userid 109)
	id E38486087A; Thu,  7 Aug 2025 15:00:54 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netfilter.org;
	s=2025; t=1754571654;
	bh=V1adYHv6a9Rtg1FAVXgqVXSYV7SgqgG4/kwgku8xc10=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=QTCa88mv8PpuRLs5hIY7rKKnFT3aBxjqxMZOxM29b/d+XVwHF/kZKKqHuY+9aTLvc
	 do5MvhY0NelU3InVAwyJY9Ac+Yo+55TSL3lRK8jSeszisKQS5Vh1s2kMATHFDdUQbH
	 3jUNQF2eWXY7VDBui+JL6QRg6CsDcneZbpQOAfLJNVavV8uaE+Z1AQkgwIw/PN40Go
	 fgAtG7vi8ndpeSrJuqAxc6ftEv/6VsRZxWghyWJOuyCU3mFy9iIOcoBiU+74aLd6Fq
	 38L71+jkZ/eaNrFTtf5ygdL4TzufMn2y88HOh1x8HuWrSD+TQUmbjLq72Hjr3Le8CS
	 ZSeIFOIAU2+HA==
X-Spam-Level: 
Received: from netfilter.org (mail-agni [217.70.190.124])
	by mail.netfilter.org (Postfix) with ESMTPSA id 395EC6087A;
	Thu,  7 Aug 2025 15:00:52 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netfilter.org;
	s=2025; t=1754571652;
	bh=V1adYHv6a9Rtg1FAVXgqVXSYV7SgqgG4/kwgku8xc10=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=GGwwIJdFdcQgLkPJ8jyQSfT85q8EjGsDM8a831bsyzeHgDcQ4NIJL95VDd3gyMV/7
	 6lg+PmTnyIDTj/CNDFdC9i/GAGmcmoMOm5B6MiRmWZRt+QlCIvEcjIR9etwcr1uW6q
	 YBRRYwLMzQ4jowCuF9KUQfl0EeJu1UDww2mhs3xVUiwftlbmT9N19Nr7Tu0s4ioGmX
	 LHC9q+TBgDCVHBfmQ61oJBf45w9qb9adh5lHbwmfk0Ish7W73Rs/RPu8dp37aZUIRQ
	 bf9fI1P0sb97mQWCqGTfFjGq6K9iqguByYTlwOFAN3fnzOjIGaoaoyBR9JC3433B7P
	 i/rfHWYvFI1Sg==
Date: Thu, 7 Aug 2025 15:00:49 +0200
From: Pablo Neira Ayuso <pablo@netfilter.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: Frederic Weisbecker <frederic@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	David Ahern <dsahern@kernel.org>, Simon Horman <horms@verge.net.au>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
	Jozsef Kadlecsik <kadlec@netfilter.org>, netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org
Subject: Re: [PATCH v2 net] ipvs: Fix estimator kthreads preferred affinity
Message-ID: <aJSjgW9Ln-waN_oF@calendula>
References: <20250729122611.247368-1-frederic@kernel.org>
 <2d915ef6-46eb-7487-f235-6b6688e68c58@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <2d915ef6-46eb-7487-f235-6b6688e68c58@ssi.bg>

On Wed, Jul 30, 2025 at 01:28:16PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Tue, 29 Jul 2025, Frederic Weisbecker wrote:
> 
> > The estimator kthreads' affinity are defined by sysctl overwritten
> > preferences and applied through a plain call to the scheduler's affinity
> > API.
> > 
> > However since the introduction of managed kthreads preferred affinity,
> > such a practice shortcuts the kthreads core code which eventually
> > overwrites the target to the default unbound affinity.
> > 
> > Fix this with using the appropriate kthread's API.
> > 
> > Fixes: d1a89197589c ("kthread: Default affine kthread to its preferred NUMA node")
> > Signed-off-by: Frederic Weisbecker <frederic@kernel.org>
> 
> 	Looks good to me for the nf tree, thanks!
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

For the record: Apologies, I will include this patch in the next pull request.
