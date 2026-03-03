Received: from Chamillionaire.breakpoint.cc (Chamillionaire.breakpoint.cc [91.216.245.30])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E99B0381AF4;
	Tue,  3 Mar 2026 20:27:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=91.216.245.30
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772569674; cv=none; b=orcDKIBWUjJcsrXtv8NBxhAC8+sbKpnKRziVuMUktvGL4um4iFkg6yHsscIbsSpbEVb/T3i+no51Ww0JsirDbd+dKxwiHay332IxWK31gNp+pIsUH1BhSWsTvw4aT0LwgEu0pIxTsn8N/cmSxQRXhNF5q1eWtUtpH59x7KGuybo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772569674; c=relaxed/simple;
	bh=7L+E4f69vZb/g837CP4QoSAiF36UmBJMqjMfpO8JWb8=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=pUQnDhP0ww3VjsLNNi0QQUp3ap9Pcjd+NsOQ74Cuzzc629gPwqGUzpVsoy5KIKl59EgvSR0YZF1A5V+07XBBVVSNPIdUUd9McXN8K6mX/wsNqyDIuDeqDnstwHTYQmJZq+gEP7BZPUoWzEVH4PEGl4zZFxjqJ75B0sDSsb0zy38=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=strlen.de; spf=pass smtp.mailfrom=strlen.de; arc=none smtp.client-ip=91.216.245.30
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=strlen.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=strlen.de
Received: by Chamillionaire.breakpoint.cc (Postfix, from userid 1003)
	id E5C7E6047A; Tue, 03 Mar 2026 21:27:44 +0100 (CET)
Date: Tue, 3 Mar 2026 21:27:42 +0100
From: Florian Westphal <fw@strlen.de>
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>,
	Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Dust Li <dust.li@linux.alibaba.com>,
	Jiejian Wu <jiejian@linux.alibaba.com>, rcu@vger.kernel.org
Subject: Re: [PATCH nf-next 2/5] ipvs: add resizable hash tables
Message-ID: <aadEPpg171LUn-dg@strlen.de>
References: <20260226195021.64943-1-ja@ssi.bg>
 <20260226195021.64943-3-ja@ssi.bg>
 <aaQ955aj9ONBe695@strlen.de>
 <8cb40028-50ed-b646-ecd7-9ab47e9ba38f@ssi.bg>
 <aaXiPAI5mcHAt385@strlen.de>
 <f1780ae2-5b62-d898-952a-3f779a91ad38@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f1780ae2-5b62-d898-952a-3f779a91ad38@ssi.bg>

Julian Anastasov <ja@ssi.bg> wrote:
> > There is some checkpatch noise in patch 1:
> > 
> > CHECK: Alignment should match open parenthesis
> > #42: FILE: include/linux/rculist_bl.h:24:
> > +       rcu_assign_pointer(hlist_bl_first_rcu(h),
> >                 (struct hlist_bl_node *)((unsigned long)n | LIST_BL_LOCKMASK));
> 
> 	I don't change here any alignment and I didn't fixed it
> because I'm not sure how to make it better :)

Thats fine, then just ignore it.
As I said, the checkpatch stuff isn't too imporant.

> > Why are you not re-using rhashtables and instead roll your own?
> > 
> > No requirement, but might make sense to mention the rationale
> > in the commit message.
> 
> 	I found the rhashtable_remove_fast operation slow by using 
> hashing+lookup. Also, IPVS needs to rehash (move) single entry when
> its key changes (cport in ip_vs_conn_fill_cport) and I don't see
> public method in rht for this. Things get complicated when we add double 
> conn hashing, it needs careful move operation from one/two chains. Also, 
> in part 4 of the changes we allow customizations for the load factor,
> in case the defaults are not suitable for the setup.
> 
> 	May be I can add more info in the commit message about this.

Yes, I think your explanation makes sense, a small note/copypaste of
the above into the commit message is enough.

Thanks!
