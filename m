Received: from Chamillionaire.breakpoint.cc (Chamillionaire.breakpoint.cc [91.216.245.30])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DDECE314D07;
	Mon,  2 Mar 2026 19:17:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=91.216.245.30
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772479055; cv=none; b=OWMMO9h0DcBXQ3Nbk962EStjWicIeco4pPaqxE5KC3jL9GmPKKDZLwcBYbt00tkZPegMTjB+nP3oe16IRqi70nGBJEdbUim1L8XWsc3rARJiOEeHsClTEosjP85tivYg3xOYnl3xSjZHGnAZ2m6AgxZjcVVznTJtiMPy4HHxfUw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772479055; c=relaxed/simple;
	bh=NHJX2nT1SxORHqZR/NfsKvFGYKZd69ATlV2B/7s46MY=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=uhr1vFAi3oS532xugFWh4I5PDy2IFYLJxAmNmrThNXkRW3x9uA72HnykFVFIV85jmODI5ls1cw3nXt9vkeZIbMcNDGFrS1BZ+Ho3BPLklJr4XwZF8KMb466MCU0fckTKBrVMmPTmZhnbPaCJ4y97c4q/HyPdCcRrJR8JrNhPl1g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=strlen.de; spf=pass smtp.mailfrom=strlen.de; arc=none smtp.client-ip=91.216.245.30
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=strlen.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=strlen.de
Received: by Chamillionaire.breakpoint.cc (Postfix, from userid 1003)
	id 82C8260492; Mon, 02 Mar 2026 20:17:25 +0100 (CET)
Date: Mon, 2 Mar 2026 20:17:25 +0100
From: Florian Westphal <fw@strlen.de>
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>,
	Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Dust Li <dust.li@linux.alibaba.com>,
	Jiejian Wu <jiejian@linux.alibaba.com>, rcu@vger.kernel.org
Subject: Re: [PATCH nf-next 2/5] ipvs: add resizable hash tables
Message-ID: <aaXiPAI5mcHAt385@strlen.de>
References: <20260226195021.64943-1-ja@ssi.bg>
 <20260226195021.64943-3-ja@ssi.bg>
 <aaQ955aj9ONBe695@strlen.de>
 <8cb40028-50ed-b646-ecd7-9ab47e9ba38f@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <8cb40028-50ed-b646-ecd7-9ab47e9ba38f@ssi.bg>

Julian Anastasov <ja@ssi.bg> wrote:
> > Julian Anastasov <ja@ssi.bg> wrote:
> > > +/**
> > > + * ip_vs_rht_for_bucket_retry() - Retry bucket if entries are moved
> > > + * @t:		current table, used as cursor, struct ip_vs_rht *var
> > > + * @bucket:	index of current bucket or hash key
> > > + * @sc:		temp seqcount_t *var
> > > + * @retry:	temp int var
> > > + */
> > > +#define ip_vs_rht_for_bucket_retry(t, bucket, sc, seq, retry)		\
> >=20
> > This triggers a small kdoc warning:
> >=20
> > Warning: include/net/ip_vs.h:554 function parameter 'seq' not described=
 in 'ip_vs_rht_for_bucket_retry'
>=20
> 	Will fix it, thanks! Just let me know if more comments
> are expected before sending next version...

There is some checkpatch noise in patch 1:

CHECK: Alignment should match open parenthesis
#42: FILE: include/linux/rculist_bl.h:24:
+       rcu_assign_pointer(hlist_bl_first_rcu(h),
                (struct hlist_bl_node *)((unsigned long)n | LIST_BL_LOCKMAS=
K));

CHECK: Macro argument 'member' may be better as '(member)' to avoid precede=
nce issues
#97: FILE: include/linux/rculist_bl.h:126:
+#define hlist_bl_for_each_entry_continue_rcu(tpos, pos, member)           =
     \
+       for (pos =3D rcu_dereference_raw(hlist_bl_next_rcu(&(tpos)->member)=
); \
+            pos &&                                                     \
+            ({ tpos =3D hlist_bl_entry(pos, typeof(*tpos), member); 1; });=
 \
+            pos =3D rcu_dereference_raw(hlist_bl_next_rcu(pos)))


And patch 2:
ERROR: Macros with complex values should be enclosed in parentheses
#147: FILE: include/net/ip_vs.h:583:
+#define ip_vs_rht_walk_buckets_rcu(table, head)                           =
     \
+       ip_vs_rht_for_each_table_rcu(table, _t, _p)                     \
+               ip_vs_rht_for_each_bucket(_t, _bucket, head)            \
+                       ip_vs_rht_for_bucket_retry(_t, _bucket, _sc,    \
+                                                  _seq, _retry)

BUT SEE:

   do {} while (0) advice is over-stated in a few situations:

   The more obvious case is macros, like MODULE_PARM_DESC, invoked at

[ there is more ]

=2E.. but I don't really care, you can handle/ignore it as you see fit.

I only have a question wrt. the hash table choice.

Why are you not re-using rhashtables and instead roll your own?

No requirement, but might make sense to mention the rationale
in the commit message.

Thanks.
