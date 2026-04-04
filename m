Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 42F6C248891;
	Sat,  4 Apr 2026 14:58:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775314736; cv=none; b=jF9kmnG/kbB0116gBpiQi1emDkus29bcOyHlOVNBnuMaxHVlKmYcdeArxkJnXXbadayBFS4MmD1pnHJjUXOVgsodPC3TYWEht9hasOhWJgVYK7hfUOZvQGxPWZ/qyxh2WZvqcqyqsWKdPqQ5xgKYaNZrGr29X8VwnBT9YlZczWA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775314736; c=relaxed/simple;
	bh=83+KN641MOf2ZXp6EoHxWpKBgOXhkjpqI9qlN9/qu5E=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=q7vzmplIZHFGLJ8LA0Ie0DFfWeq8ow/Km+42H20NeQFFGU83Vpm3uOS2U1O6+ImcQOkxA70AI7OCfZjwpDz6Uo1XMaKcG6uOl0aTjpusp7SpcFUbvee5sDPZdLLJSvTbfiiourjDMGPO3Aov8HFTChvAq+vDhTh4hP+7Ep37aTc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=clB3bZ/Y; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="clB3bZ/Y"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 3AE2321C5D;
	Sat, 04 Apr 2026 17:58:44 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=3uHzP2CP40ZTuLXW5buuDvxnd6+9ysI1WLolHX3mKY4=; b=clB3bZ/YCzV8
	ys0ID4dR92yogt5wmn6JOWod/YANOnjX26BeRaRhLlkqea6m+JoguzYAlhRay6a2
	vMNWXvIBftA81ckPu44zIbBuJsvUhPK7dn5qX83fXn+Hw6JP5fUC/8PQklW7o74l
	Qsmsof3/0s1syJRmY4ura5KiZlyK5WU36F5cStu7/C/vD0ruOwa8wuAvqxmSzTKy
	qUlcKT7dc+WxP21uGvVM3mhNfedQmHeKOZLlLoOXA/FytqQLoo3ZZ8UhVAOhy+4V
	V5+KYNZ9T3/QQI6/oJbJEAyeRuSXsJdI1rweYZlhMgVG9NoWEeLM+lA57++OBuf1
	momozyyeIjiVKWlouNY+u0Rxkku51J+hlESm+Gvz8x5w+dXImRuAaY+ZaI9wdLdD
	kPG4qcU0xtClkhX64Lerj2YGIK9KvHufNhDDZO0LWd2/vVHM1aFdSPQkpP5DfChv
	wOIkhONupnEBCJNdBfaPFct0nMjadpd7qvOSeC68hVQF4MZPX0+wocC0ebMaIjPk
	ZZ++/iYI3iBOS8+LC2GEZDZ2fudEtzDC/yv5s0NYWF/uMtBr/0DGeYzIaiccUao4
	hqkxDxLclNwKgzPUpwCYcYbt1ETobU6NhgFyAphEzXrJ5PTohmW9q85EulEvKH+J
	Zy7c/Y/PDCcrfiNC5oqyaPZtHmi6d/I=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sat, 04 Apr 2026 17:58:42 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id A2DD560818;
	Sat,  4 Apr 2026 17:58:40 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 634EwQGD026021;
	Sat, 4 Apr 2026 17:58:26 +0300
Date: Sat, 4 Apr 2026 17:58:26 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Florian Westphal <fw@strlen.de>
cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>
Subject: Re: [PATCH nf-next 1/3] ipvs: show the current conn_tab size to
 users
In-Reply-To: <adDoUEwfuYpdGanf@strlen.de>
Message-ID: <ca884668-502a-bf6f-2122-95094883f3d4@ssi.bg>
References: <20260323162523.44964-1-ja@ssi.bg> <20260323162523.44964-2-ja@ssi.bg> <adDoUEwfuYpdGanf@strlen.de>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Sat, 4 Apr 2026, Florian Westphal wrote:

> Julian Anastasov <ja@ssi.bg> wrote:
> > As conn_tab is per-net, better to show the current hash table size
> > to users instead of the ip_vs_conn_tab_size (max).
> > 
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > ---
> >  net/netfilter/ipvs/ip_vs_ctl.c | 26 ++++++++++++++++++++++----
> >  1 file changed, 22 insertions(+), 4 deletions(-)
> > 
> > diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> > index b472e564b769..3129b15dadc2 100644
> > --- a/net/netfilter/ipvs/ip_vs_ctl.c
> > +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> > @@ -281,6 +281,13 @@ static void est_reload_work_handler(struct work_struct *work)
> >  	mutex_unlock(&ipvs->est_mutex);
> >  }
> >  
> > +static int get_conn_tab_size(struct netns_ipvs *ipvs)
> > +{
> > +	struct ip_vs_rht *t = rcu_dereference(ipvs->conn_tab);
> > +
> > +	return t? t->size : 0;
> > +}
> 
> Pablo suggest to make this self-contained so callers don't have to
> handle rcu read lock:

	I created it this way because ip_vs_info_seq_show()
and IPVS_CMD_GET_INFO case are already under RCU lock.
I'll report v2 soon...

> static int get_conn_tab_size(struct netns_ipvs *ipvs)
> {
> 	const struct ip_vs_rht *t;
> 	int size = 0;
> 
> 	rcu_read_lock();
> 	t = rcu_dereference(ipvs->conn_tab);
> 	if (t)
> 		size = t->size;
> 	rcu_read_unlock();
> 
> 	return size;
> }

Regards

--
Julian Anastasov <ja@ssi.bg>

