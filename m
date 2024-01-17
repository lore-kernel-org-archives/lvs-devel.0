Received: from mg.ssi.bg (mg.ssi.bg [193.238.174.37])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6920C1EB36
	for <lvs-devel@vger.kernel.org>; Wed, 17 Jan 2024 13:10:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.37
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1705497017; cv=none; b=YRUTs6m236QRj45wWn7doorGIPPAJGOC0hIvvyykxwZjLfIs7V4QRvJRNOi+hyn4F3mi+uwqDKn5kj91jATdzaYT+rjV7VKZ2qERDeGEAua4Dk4EWSI7zFkg2rPK+F4s6cvBpHo4PX/nmoTU2q1Nf+JuK7jJmKBUbawN2Sy/kZs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1705497017; c=relaxed/simple;
	bh=8P3sdX8zEukcO5RPDL7AQWykI6njoWUvywMnDkNIGRo=;
	h=Received:Received:Received:DKIM-Signature:Received:Date:From:To:
	 cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:
	 Content-Type; b=MPT1h2++jweFYD6E6s6uqg72F0iEWLrITF2SDV32gVJp5CqNamZbwSwEmOvyDL9T2oQHx72wh58NLd1tbNW/kjqaMD0+AQ+THyjmbv1sQo+ihDxxpn2ooszAEpiCmtw2BF/ke33nQgN+ZazRcTNjh9D1fFN2lQOsVBlMMvWLZjI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=rmNjp1+J; arc=none smtp.client-ip=193.238.174.37
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="rmNjp1+J"
Received: from mg.bb.i.ssi.bg (localhost [127.0.0.1])
	by mg.bb.i.ssi.bg (Proxmox) with ESMTP id E16F52D1AD;
	Wed, 17 Jan 2024 15:10:04 +0200 (EET)
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mg.bb.i.ssi.bg (Proxmox) with ESMTPS id C65CB2D1A8;
	Wed, 17 Jan 2024 15:10:04 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id C8FFF3C043A;
	Wed, 17 Jan 2024 15:10:03 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
	t=1705497004; bh=8P3sdX8zEukcO5RPDL7AQWykI6njoWUvywMnDkNIGRo=;
	h=Date:From:To:cc:Subject:In-Reply-To:References;
	b=rmNjp1+JMszlht1Uc8re+VRCtM+Ke29vqn4vYM5Pw1AGQaNGMZVacm7JSliZKeUZh
	 lBhiaYUd4Npp8H7HeQBmRQ3/duUHl2UbN7wxPBdLgm2rEw/vNzjnDA7HG5Xki8Lbn+
	 8yFuMFc3zAlUmSTm+IBOlyUMshJEGdTGLz9z7N7g=
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.17.1/8.17.1) with ESMTP id 40HD9t74033355;
	Wed, 17 Jan 2024 15:09:56 +0200
Date: Wed, 17 Jan 2024 15:09:55 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@kernel.org>
cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        netdev@vger.kernel.org, Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>,
        Jiri Wiesner <jwiesner@suse.de>
Subject: Re: [PATCHv2 RFC net-next 08/14] ipvs: use resizable hash table for
 services
In-Reply-To: <20240117095414.GL588419@kernel.org>
Message-ID: <31a84455-86e7-c99f-7011-5385bbe0179d@ssi.bg>
References: <20231212162444.93801-1-ja@ssi.bg> <20231212162444.93801-9-ja@ssi.bg> <20240117095414.GL588419@kernel.org>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Wed, 17 Jan 2024, Simon Horman wrote:

> On Tue, Dec 12, 2023 at 06:24:38PM +0200, Julian Anastasov wrote:
> > Make the hash table for services resizable in the bit range of 4-20.
> > Table is attached only while services are present. Resizing is done
> > by delayed work based on load (the number of hashed services).
> > Table grows when load increases 2+ times (above 12.5% with factor=3)
> > and shrinks 8+ times when load decreases 16+ times (below 0.78%).
> > 
> > Switch to jhash hashing to reduce the collisions for multiple
> > services.
> > 
> > Add a hash_key field into the service that includes table ID and
> > bucket ID. This helps the lookup and delete operations.
> > 
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> 
> ...
> 
> > @@ -391,18 +440,29 @@ static inline struct ip_vs_service *
> >  __ip_vs_service_find(struct netns_ipvs *ipvs, int af, __u16 protocol,
> >  		     const union nf_inet_addr *vaddr, __be16 vport)
> >  {
> > -	unsigned int hash;
> > +	DECLARE_IP_VS_RHT_WALK_BUCKET_RCU();
> > +	struct hlist_bl_head *head;
> >  	struct ip_vs_service *svc;
> > -
> > -	/* Check for "full" addressed entries */
> > -	hash = ip_vs_svc_hashkey(ipvs, af, protocol, vaddr, vport);
> > -
> > -	hlist_for_each_entry_rcu(svc, &ipvs->svc_table[hash], s_list) {
> > -		if (svc->af == af && ip_vs_addr_equal(af, &svc->addr, vaddr) &&
> > -		    svc->port == vport && svc->protocol == protocol &&
> > -		    !svc->fwmark) {
> > -			/* HIT */
> > -			return svc;
> > +	struct ip_vs_rht *t, *p;
> > +	struct hlist_bl_node *e;
> > +	u32 hash, hash_key;
> > +
> > +	ip_vs_rht_for_each_table_rcu(ipvs->svc_table, t, p) {
> > +		/* Check for "full" addressed entries */
> > +		hash = ip_vs_svc_hashval(t, af, protocol, vaddr, vport);
> > +
> > +		hash_key = ip_vs_rht_build_hash_key(t, hash);
> > +		ip_vs_rht_walk_bucket_rcu(t, hash_key, head) {
> > +			hlist_bl_for_each_entry_rcu(svc, e, head, s_list) {
> 
> Hi Julian,
> 
> Smatch thinks that head is used uninitialised here.
> This does seem to be the case to me too.

	It would crash and not find svc if that was true. May be it is 
caused by the complex 'if (INIT then FAIL) {} else ANYTHING' 
construct used in ip_vs_rht_walk_bucket_rcu() which allows
'if () {} else for () for () for () ...'.

Regards

--
Julian Anastasov <ja@ssi.bg>

