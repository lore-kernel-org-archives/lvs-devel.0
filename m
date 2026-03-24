Received: from Chamillionaire.breakpoint.cc (Chamillionaire.breakpoint.cc [91.216.245.30])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9BCFC23183F;
	Tue, 24 Mar 2026 13:02:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=91.216.245.30
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774357358; cv=none; b=c/kWy9fd0tClnfmmzNzV4xqAvkBur/rJ7I2PeGhkFMOAGCMBp3/hSmAV0WtqEH84/fBFr6JzdGOh6VBHKIXaeTEB6XB6Fq/aB46KQuebwHtwZuQS7//iePWCPJoEgZ6+7AGuvLuS5SXODtp4GCStXyvguCxQNzJ8Fub+XTXHtE8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774357358; c=relaxed/simple;
	bh=GmIUiLbuBnA3nAopsTDcD94SGgtpBgpFaWNqqszch44=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=JuNQBGV5xEF5ZeFAL9ypa9JTJXNsu4Cf5IhgnW6/XwF/ALvnwRVv2Fr3d1Z1o5fSmyMJhM2mSReFGCLDnPH0JBVFZhvbNSMNnRc4whObBgaXP6Vjl7CZzTs3oCBZ/jVv3f8ylvnOa7+9rutUG6laZwcMsK0ie2RCxGWJLcSeMMI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=strlen.de; spf=pass smtp.mailfrom=strlen.de; arc=none smtp.client-ip=91.216.245.30
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=strlen.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=strlen.de
Received: by Chamillionaire.breakpoint.cc (Postfix, from userid 1003)
	id 778C6605C3; Tue, 24 Mar 2026 14:02:24 +0100 (CET)
Date: Tue, 24 Mar 2026 14:02:03 +0100
From: Florian Westphal <fw@strlen.de>
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>,
	Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Dust Li <dust.li@linux.alibaba.com>,
	Jiejian Wu <jiejian@linux.alibaba.com>
Subject: Re: [PATCH nf-next 3/3] ipvs: add conn_lfactor and svc_lfactor
 sysctl vars
Message-ID: <acKLSxnxYWCPKDBR@strlen.de>
References: <20260323162523.44964-1-ja@ssi.bg>
 <20260323162523.44964-4-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260323162523.44964-4-ja@ssi.bg>

Julian Anastasov <ja@ssi.bg> wrote:
> +			*valp = val;
> +			if (rcu_dereference_protected(ipvs->conn_tab, 1))
> +				mod_delayed_work(system_unbound_wq,
> +						 &ipvs->conn_resize_work, 0);

Can I change this to rcu_access_pointer()?

rcu_dereference_protected( ... , 1)

... always looks like a bug to me, even though its fine here.
