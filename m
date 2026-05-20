Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0BA82299937;
	Wed, 20 May 2026 01:22:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779240141; cv=none; b=muBQawC/KWpyC3lk30WAZ/6ebuYf/fzoQx5dLlRiawqg8J0tLOjJQM9FKTIlLkS0UP3GI5eWck7o+D/XNDIA9nr163TcngZvTP1n+gnhgw+jaV8593cJmd2DYQqYl9fxeyOKenWNHKwKYgP7e/s5aJN0T4aQRnZ6Hh2YQ7YO9ZE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779240141; c=relaxed/simple;
	bh=Jlxxfz2coa8Zxo883jNw4XVwpwOJ5iRS+2VhN9tAP98=;
	h=Date:From:To:Cc:Subject:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=NGkJzSSXIqPvfUAspWWi6Lj6vAHGbFAzMgarhhuF87UdKbotzPnWMsJ/4yaAU6erNeQD/8KEgGUS9jaVw6N7sau9JzRBhmReZijiCEBLKLFZX9HwhtKSEfF4LBzx3bAK3C7rYVxZxE20gduIS1yf8qCQMeN3N3rAq9keBv0hx20=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=mtXVoJyx; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="mtXVoJyx"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CE4091F000E9;
	Wed, 20 May 2026 01:22:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1779240140;
	bh=Jlxxfz2coa8Zxo883jNw4XVwpwOJ5iRS+2VhN9tAP98=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References;
	b=mtXVoJyxmnjQY/v+iiRX8XrlLB9MdsSx3OD7Nnd91Z7+G90rSpl64A6rf+47DN2oB
	 iJCHRmr/ZtUwGKAkmlFtpnrC81kCR1gwdz4rX7EfW4tY0BgxmHGB96MfZlQ+PpNE32
	 9R0PnXz6s7CisfhyvvaU0a5rSZ++vSZcT3jMsajre+yKe9Ax2OK7xXRF+tswIR7ZSx
	 KX3gEwLXGyvotdb8/fO/2p9I3/FdaeyreHY5DxSxHok6hj/wyxrUprKWRz/cHrYaUq
	 nP7CZQQabjAKoeMkOm7tOPvTOcEe9vE8GRHs4Ffk0ZDqw6hLtwUE7TZt/DCYTFgpsx
	 5XeBQR90wDGjA==
Date: Tue, 19 May 2026 18:22:19 -0700
From: Jakub Kicinski <kuba@kernel.org>
To: Marco Crivellari <marco.crivellari@suse.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Tejun Heo
 <tj@kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Frederic
 Weisbecker <frederic@kernel.org>, Sebastian Andrzej Siewior
 <bigeasy@linutronix.de>, Michal Hocko <mhocko@suse.com>, Simon Horman
 <horms@verge.net.au>, Eric Dumazet <edumazet@google.com>, "David S .
 Miller" <davem@davemloft.net>, Paolo Abeni <pabeni@redhat.com>, Julian
 Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Florian
 Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
 lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
 coreteam@netfilter.org
Subject: Re: [PATCH v2 net-next 2/2] ipvs: Replace use of system_unbound_wq
 with system_dfl_long_wq
Message-ID: <20260519182219.0d685a27@kernel.org>
In-Reply-To: <20260515135143.259669-3-marco.crivellari@suse.com>
References: <20260515135143.259669-1-marco.crivellari@suse.com>
	<20260515135143.259669-3-marco.crivellari@suse.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Fri, 15 May 2026 15:51:37 +0200 Marco Crivellari wrote:
> Subject: [PATCH v2 net-next 2/2] ipvs: Replace use of system_unbound_wq with system_dfl_long_wq

FTR leaving this one to netfilter folks
