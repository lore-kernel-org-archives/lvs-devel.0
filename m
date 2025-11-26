Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ABDE2340A57;
	Wed, 26 Nov 2025 20:08:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1764187734; cv=none; b=WNCaHZ/4qxQDffORZllnLfMmZvLKs9z189XB/5lwQhl+oC9i9EC+Jl2l1IuwPZMLWDCUOuLPrt7O2ZAkIkaxmrvGsD0epHxId94R0IExyOhFDxLAsMy0KXF/aU5V1E+0KIfaNXSQVyBGjAJxW5ORo4ky/R6HgSZeh1Kfnk3AGnc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1764187734; c=relaxed/simple;
	bh=cQVjupZGvGFW5YVeSg1gDcToG/qKLA663JiVWjLoA2o=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=M0mokFxYUoQqCpmVv8bIcbPWHte+105KqRN60imo+MPq52r52r30P5cSQvn3BlwZvjllcGKvDU887G9Neic4c74bTJZYc4CDIADbGIcnILDc2SYqi2oaSBoxOEgya7X6beo4xD0n4llzyzqNLg/fOs6eMqo5fKP0CbJRBRmoy78=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=iOCMwvP5; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="iOCMwvP5"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 6D90E2119C;
	Wed, 26 Nov 2025 22:08:49 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=DaqN/Y1FS5/jkC7JJp+A5/3gusA4Ql7VEP1EvX8buqI=; b=iOCMwvP52YVv
	zL30vbAuheVc3utX7Ezmaq2m812OpDgRdTI7P+DETjexkoc/vpNK4YX2im8nzMaW
	xoB1oDLTuZ1w6Q9UxHN1s1ofeiHRTg5KI+Q5Xnvg8v28pu3vz9HcDRcSGhLD4JLI
	MIWpEco9echhO+qhEXaTnnxqKAMvCJRhjy23jTuzwixOIEQWS/cV8j9QslovZlsf
	x3uBGRzGafCbGlXKBpu/0RYLM7GKzQP3x2roJw9AsBKz3EpD8wI2Rn+QwI91nhmJ
	hgarlrnYyvOOhJTEMkfWhkGZlHLNQUpUos3VdMksOPFTFHkEZWWb4SjG5EmOEJXk
	DPQiveMj66x8Oz63d7l3gZVi25adhBi6GlFDrfRr0j5X5rmGLLnATyHMsRyAYwbh
	5OE+ow8qPj9Tx8WdYxOff3BradV5QvYWkrwkljSOIfk6u7Eomjd91XDTwKuWSieD
	0Mv/ShehOeYq9uvY5ZNtSdpDzO19hJAWR6C/OuHIdBe3xGRmsfMPdVfBz6nYXjrj
	09+z2SD+HduZPCuQ8rQjV0MMST9WuilRREImEspH0RVx3AOR0hQ3Out8QaPl59Jn
	qt8zzWaunyloAKan9vnlLEzqARo+OYmQS29DGSa3tYYI/pN69lFfiw54pReTUzFZ
	bqPlsez1wvyli6eRzFRa00nt1CIsw0k=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 26 Nov 2025 22:08:48 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 2EF29603CB;
	Wed, 26 Nov 2025 22:08:47 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 5AQK8jMW043570;
	Wed, 26 Nov 2025 22:08:45 +0200
Date: Wed, 26 Nov 2025 22:08:45 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Pablo Neira Ayuso <pablo@netfilter.org>
cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>, rcu@vger.kernel.org
Subject: Re: [PATCHv6 net-next 11/14] ipvs: no_cport and dropentry counters
 can be per-net
In-Reply-To: <aSTOOez-GDzaG0LT@calendula>
Message-ID: <ccd51681-f39c-9d4b-9ef3-9d33b51a49ae@ssi.bg>
References: <20251019155711.67609-1-ja@ssi.bg> <20251019155711.67609-12-ja@ssi.bg> <aSTOOez-GDzaG0LT@calendula>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 24 Nov 2025, Pablo Neira Ayuso wrote:

> On Sun, Oct 19, 2025 at 06:57:08PM +0300, Julian Anastasov wrote:
> > With using per-net conn_tab these counters do not need to be
> > global anymore.
> > 
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > ---
> >  include/net/ip_vs.h             |  2 ++
> >  net/netfilter/ipvs/ip_vs_conn.c | 62 ++++++++++++++++++++-------------
> >  2 files changed, 39 insertions(+), 25 deletions(-)
> > 
> > diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> > index ce77800853ab..1b64c5ee2ac2 100644
> > --- a/include/net/ip_vs.h
> > +++ b/include/net/ip_vs.h

> > +	s8			dropentry_counters[8];

> > diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> > index bbce5b45b622..55000252c72c 100644
> > --- a/net/netfilter/ipvs/ip_vs_conn.c
> > +++ b/net/netfilter/ipvs/ip_vs_conn.c

> >  static inline int todrop_entry(struct ip_vs_conn *cp)
> >  {
> > -	/*
> > -	 * The drop rate array needs tuning for real environments.
> > -	 * Called from timer bh only => no locking
> > -	 */
> > -	static const signed char todrop_rate[9] = {0, 1, 2, 3, 4, 5, 6, 7, 8};
> > -	static signed char todrop_counter[9] = {0};

	We go from 9 to 8, see below.

> > +	struct netns_ipvs *ipvs = cp->ipvs;
> >  	int i;
> >  
> >  	/* if the conn entry hasn't lasted for 60 seconds, don't drop it.
> > @@ -1579,15 +1585,17 @@ static inline int todrop_entry(struct ip_vs_conn *cp)
> >  	if (time_before(cp->timeout + jiffies, cp->timer.expires + 60*HZ))
> >  		return 0;
> >  
> > -	/* Don't drop the entry if its number of incoming packets is not
> > -	   located in [0, 8] */
> > +	/* Drop only conns with number of incoming packets in [1..8] range */
> >  	i = atomic_read(&cp->in_pkts);
> > -	if (i > 8 || i < 0) return 0;
> > +	if (i > 8 || i < 1)
> 
> Why did this change? How is this related to the per-netns update?

	Using global state in todrop_counter[] is not good,
so we move it to the ipvs struct. We do not want
floods in one netns to lead to drops in another netns.

	The funny part is that todrop_rate[0] is 0,
so 'if (!todrop_rate[i]) return 0;' will do nothing
for i = 0. And I simply converted it to array [8] and
translate the packet count 1..8 to index 0..7. So,
there is no change in functionality.

> > +		return 0;
> >  
> > -	if (!todrop_rate[i]) return 0;
> > -	if (--todrop_counter[i] > 0) return 0;
> > +	i--;
> > +	if (--ipvs->dropentry_counters[i] > 0)
> > +		return 0;
> >  
> > -	todrop_counter[i] = todrop_rate[i];
> > +	/* Prefer to drop conns with less number of incoming packets */
> > +	ipvs->dropentry_counters[i] = i + 1;
> >  	return 1;
> >  }

Regards

--
Julian Anastasov <ja@ssi.bg>

