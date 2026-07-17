Received: from orbyte.nwl.cc (orbyte.nwl.cc [151.80.46.58])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D7C5E346E44;
	Fri, 17 Jul 2026 10:39:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=151.80.46.58
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784284763; cv=none; b=RM8a6nYvdMn3XVDo8sy+Uzdv4gptnJXF7681OxLUKjIxRCyXHiqdIsFTsqCkV+BpxG7fxpJGOf6Vb7YDTMkWJYZ0O2TgQiKlBatkAoxRFhSwDZTNE4czYpaxq5uHDNERp6H0UomN4bgpfP9IC/L3luYyMoCIuUsz6j0elmJatRs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784284763; c=relaxed/simple;
	bh=SEOEZpN6CmpyPTr68+7LPlfB/QG/D1uXuKPcAUV3DqM=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=NFU/layCNrI7zQMLH6j36C03LwIPfUu9ZBi6CNrN1cyRmKnzjNLvY1UfmJnMIiXHTgdVxBM069RWVFVXgTFAdg+KII8A0R35FYVxcJRGSl9I77W7kYahJfSeIp6nImnuhAsEyFJoQqTdRK3GssOmzviLcdOo/5Da4VUaNbRsmvM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nwl.cc; spf=pass smtp.mailfrom=nwl.cc; dkim=pass (2048-bit key) header.d=nwl.cc header.i=@nwl.cc header.b=odFgcNs1; arc=none smtp.client-ip=151.80.46.58
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nwl.cc
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nwl.cc
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nwl.cc header.i=@nwl.cc header.b="odFgcNs1"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=nwl.cc;
	s=mail2022; h=In-Reply-To:Content-Type:MIME-Version:References:Message-ID:
	Subject:Cc:To:From:Date:Sender:Reply-To:Content-Transfer-Encoding:Content-ID:
	Content-Description:Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc
	:Resent-Message-ID:List-Id:List-Help:List-Unsubscribe:List-Subscribe:
	List-Post:List-Owner:List-Archive;
	bh=HCW9RzhvR9xsH6bJb1z530rgfji4u54DDv1LEeoE200=; b=odFgcNs1P/tpcxDgvoeloi4eK7
	CzptOeWmTgXSnMdv7xSAKDxYhcXJk8SGLckTVLHo0bmNscvkKiNRnzUKNOVBY7eVXZ9cGcbB5PPSO
	Bt4Wr7ToUeSxrMWvFh8yqWy8ToW6lt+W4RXepNla0khLcGvs5NW8p2YVYJ+0d+x/+kjEAxvQjFVO8
	vn51Gaj/JziAvvg6ENJD9IfGW/l5MA86Xb+ssfeZCB9SWZUnUYpzP8ARJKiC44W9XM6jS+f2qK0h5
	BZkZ5vkNVK4MWlyUc6yNWv9HOJV+z3aJv4EYJ4RCgDfdBvnhRHpfKjUoZkQSt8zCxIjqafZWRE6tp
	ylaBwCXw==;
Received: from n0-1 by orbyte.nwl.cc with local (Exim 4.98.2)
	(envelope-from <phil@nwl.cc>)
	id 1wkfyF-000000003Er-0rVn;
	Fri, 17 Jul 2026 12:39:07 +0200
Date: Fri, 17 Jul 2026 12:39:07 +0200
From: Phil Sutter <phil@nwl.cc>
To: Subasri S <subasris1210@gmail.com>
Cc: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
	Simon Horman <horms@kernel.org>, netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH nf-next] ipvs: use type-safe allocation helpers in
 ip_vs_rht_alloc
Message-ID: <aloGSzc4UMJVveCQ@orbyte.nwl.cc>
References: <20260716-nf-next-ipvs-deprecated-v1-1-4aad24f87cb8@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260716-nf-next-ipvs-deprecated-v1-1-4aad24f87cb8@gmail.com>

On Thu, Jul 16, 2026 at 07:37:10PM +0530, Subasri S wrote:
> As per Documentation/process/deprecated.rst, open-coded kmalloc
> assignments for struct objects are deprecated. Replace
> kzalloc(sizeof(*ptr), GFP_KERNEL) with kzalloc_obj() and
> kvmalloc_array(n, sizeof(*ptr), GFP_KERNEL) with kvmalloc_objs()
> in ip_vs_rht_alloc().
> 
> Compile tested with CONFIG_IP_VS=y and runtime tested using
> tools/testing/selftests/net/netfilter/ipvs.sh on x86_64/QEMU.
> 
> Signed-off-by: Subasri S <subasris1210@gmail.com>

Reviewed-by: Phil Sutter <phil@nwl.cc>
