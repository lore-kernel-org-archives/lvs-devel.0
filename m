Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ED26B390995;
	Mon,  2 Mar 2026 22:19:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772489946; cv=none; b=lN7Uy18fkKjXPY5CJ+5Y75KmMIse+22hvo4WsOdEPcqft1pNHy5QPZjC8wAy3y8+tVRO0Et6VjaCchE9mfotDltCzQxkhEDWwCIzfIeCnMSW9O+xB9386p5idIh4wW/toEGP4tnMsaq6i1d72ZeVkIuYyAXSNJd0r5A6Qn5xtmk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772489946; c=relaxed/simple;
	bh=wrl1B5CtaEn2yLVWSxGWi505RYTBrAT8skDredTeNic=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=WrZVq9KW7cjgHLz7eBGn9L6M2pHEdiXQ9WV9qrJuBxf0BMML3psaKhJTgbd+mgVE2Tpbrfy45dlGkl/XNnizhDQrStA2MMDzEMVtyNfdxFtahSnGHeHSWcTawMpXB/4yBa9j23uiVtSakdeWYFDybRb525+QRcsBpwSO9wRcFX4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=TrlFBhfu; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="TrlFBhfu"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 393DF21D41;
	Tue, 03 Mar 2026 00:18:59 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=K2BjrCkn+3/4tdZXjXw5Du9tfAcXbUOI6+MIG9XakAM=; b=TrlFBhfuYihB
	JHuo1QlOX0ZCeQnbu63mb+8VmDkct0q7QjGwT+Zo1L+WAWCfSdtq+6CvnjctNRCw
	zHyvQDjKqtgaqI8Qrabz3GWpupvyRR7gGRepTXgTSfr5XKjlbVyFMlh2bEQbJdOe
	EyD9VXI4jc/wjE3ncvOk9bMH2ANHaaOiPdnQxIVeEhAI5zROloGe6DkLRCnIg9vb
	/a3lX8bxOuxxdUuFFLgzB2PwxwkwVUqbYq65JaOiWfsW5mXdx+3AA52NTbU80eAl
	+W5gV2SEEeZc3UZDA3LJdHrN9+IhJQxI8DW36qrecCitoo+MvED460INEKXyHNQt
	XMJsCgwVtQ3KPkvxp3UDgdXOe32qp2I2q0+Q60zh9P9lkqnvs9diBZCag1Rf3jJd
	1tfLePheFixRm5Qrod+Q0V2N8Ll7++zVQvbWxoDGDzp1fBsISnu3H8XPy9Okqz0y
	ZRRk6heakXUqROMmuyhzwuHC0LiHm04q21YYWRmZLQmCGTEDKtaBHbHu0D4iPbC6
	Fji3MztASbajh1LhC6YSLKvYgpPjIk3UyKymcfWC9OMw6RvvlcMdnMajLx9nA/8g
	I7UGk8SBO3ERgs7X6XH0oPNk6gHA706/lLGjmKH6TRfDuIyoIvvXwjd1hHInQudZ
	t0dwkRaUMV3TjsBjvZG8tml9d3cDTJU=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 03 Mar 2026 00:18:57 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 7C092608AE;
	Tue,  3 Mar 2026 00:18:56 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 622MIq4E100229;
	Tue, 3 Mar 2026 00:18:52 +0200
Date: Tue, 3 Mar 2026 00:18:52 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Florian Westphal <fw@strlen.de>
cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>, rcu@vger.kernel.org
Subject: Re: [PATCH nf-next 2/5] ipvs: add resizable hash tables
In-Reply-To: <aaXiPAI5mcHAt385@strlen.de>
Message-ID: <f1780ae2-5b62-d898-952a-3f779a91ad38@ssi.bg>
References: <20260226195021.64943-1-ja@ssi.bg> <20260226195021.64943-3-ja@ssi.bg> <aaQ955aj9ONBe695@strlen.de> <8cb40028-50ed-b646-ecd7-9ab47e9ba38f@ssi.bg> <aaXiPAI5mcHAt385@strlen.de>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 2 Mar 2026, Florian Westphal wrote:

> Julian Anastasov <ja@ssi.bg> wrote:
> > > Julian Anastasov <ja@ssi.bg> wrote:
> > > > +/**
> > > > + * ip_vs_rht_for_bucket_retry() - Retry bucket if entries are moved
> > > > + * @t:		current table, used as cursor, struct ip_vs_rht *var
> > > > + * @bucket:	index of current bucket or hash key
> > > > + * @sc:		temp seqcount_t *var
> > > > + * @retry:	temp int var
> > > > + */
> > > > +#define ip_vs_rht_for_bucket_retry(t, bucket, sc, seq, retry)		\
> > > 
> > > This triggers a small kdoc warning:
> > > 
> > > Warning: include/net/ip_vs.h:554 function parameter 'seq' not described in 'ip_vs_rht_for_bucket_retry'
> > 
> > 	Will fix it, thanks! Just let me know if more comments
> > are expected before sending next version...
> 
> There is some checkpatch noise in patch 1:
> 
> CHECK: Alignment should match open parenthesis
> #42: FILE: include/linux/rculist_bl.h:24:
> +       rcu_assign_pointer(hlist_bl_first_rcu(h),
>                 (struct hlist_bl_node *)((unsigned long)n | LIST_BL_LOCKMASK));

	I don't change here any alignment and I didn't fixed it
because I'm not sure how to make it better :)

> CHECK: Macro argument 'member' may be better as '(member)' to avoid precedence issues
> #97: FILE: include/linux/rculist_bl.h:126:
> +#define hlist_bl_for_each_entry_continue_rcu(tpos, pos, member)                \
> +       for (pos = rcu_dereference_raw(hlist_bl_next_rcu(&(tpos)->member)); \
> +            pos &&                                                     \
> +            ({ tpos = hlist_bl_entry(pos, typeof(*tpos), member); 1; }); \
> +            pos = rcu_dereference_raw(hlist_bl_next_rcu(pos)))

	I think, this matches how all such macros use the member
field.

> And patch 2:
> ERROR: Macros with complex values should be enclosed in parentheses
> #147: FILE: include/net/ip_vs.h:583:
> +#define ip_vs_rht_walk_buckets_rcu(table, head)                                \
> +       ip_vs_rht_for_each_table_rcu(table, _t, _p)                     \
> +               ip_vs_rht_for_each_bucket(_t, _bucket, head)            \
> +                       ip_vs_rht_for_bucket_retry(_t, _bucket, _sc,    \
> +                                                  _seq, _retry)

	Yep, here we use complex macros to help the callers
use a loop with their statement/body. In the previous versions
I checked the checkpatch output and due to the advanced macro
usage I'm not sure what can be made better...

> 
> BUT SEE:
> 
>    do {} while (0) advice is over-stated in a few situations:
> 
>    The more obvious case is macros, like MODULE_PARM_DESC, invoked at
> 
> [ there is more ]
> 
> ... but I don't really care, you can handle/ignore it as you see fit.
> 
> I only have a question wrt. the hash table choice.
> 
> Why are you not re-using rhashtables and instead roll your own?
> 
> No requirement, but might make sense to mention the rationale
> in the commit message.

	I found the rhashtable_remove_fast operation slow by using 
hashing+lookup. Also, IPVS needs to rehash (move) single entry when
its key changes (cport in ip_vs_conn_fill_cport) and I don't see
public method in rht for this. Things get complicated when we add double 
conn hashing, it needs careful move operation from one/two chains. Also, 
in part 4 of the changes we allow customizations for the load factor,
in case the defaults are not suitable for the setup.

	May be I can add more info in the commit message about this.

Regards

--
Julian Anastasov <ja@ssi.bg>

