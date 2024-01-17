Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B60051426B;
	Wed, 17 Jan 2024 09:54:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1705485258; cv=none; b=rM2hSQJ1XbxK5JFkFbfefT78tCDBvcA5TXDnrziJTyTmke/WtGQZxHNx7KYq/XjlVxBuc3MXVLSEFq4mQ8T2SHfjdQjNdBmeZenb6Kyj+h0BE2C3D27UwEhlorwcTSL0UW+V/LTudEIS51kDNZ0xwUw5GY0/j4gw96PkNwYiiCU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1705485258; c=relaxed/simple;
	bh=eVYYekh0XZjfZpzzFiTcix+gfMEsLzIfQ978A4MhKOA=;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To; b=T3XUtNPgfK4k+y1EpJDRLFuMWHcqoOAHGlnJmWDIEIa2ygzSXdnHApb/Go9pCy4V7Pq0zhSKq682Temz23KxmO1x3hiaZVd2zQ9yrGGwVzbDomvtqc8J09N1W5w0RDbhmZVvPvmJN8SELQlZ/SO2uQ7+p+73ziKT0cp9/UlxCvw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=t90EU0ak; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="t90EU0ak"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A67E4C433C7;
	Wed, 17 Jan 2024 09:54:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1705485258;
	bh=eVYYekh0XZjfZpzzFiTcix+gfMEsLzIfQ978A4MhKOA=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=t90EU0akMJBXSMhXDkCcc9bBiFv9HSIhslNExMYWa0r0IlOOgIHsmUznSnpL90tiy
	 ZhncJ4JHNSy9KHKIjesXTsCUxW7Ud6MjIgIWU8jjScvbNtLQ6xszB4W/3no2D15xmP
	 yfe1sOl3Aj9m88kcLowqKt5dm3Oq6wofB5Kul8jvGVylXYL2PwfqnPX4OsaoOlMnIa
	 nZe+eeWrhT8fqwBJ4T965UIzFcgGqRlrjfcYphZtY8QCz8moUcdCISMhuG3L6gE1Nb
	 nCIUJPMRhTGkMedbbLb0W6T9+EDhbD1gSZdUtSVZR4rPA6mcEXZq8qw7tp7uoF++Pn
	 uf/gng9Z35KTw==
Date: Wed, 17 Jan 2024 09:54:14 +0000
From: Simon Horman <horms@kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, Dust Li <dust.li@linux.alibaba.com>,
	Jiejian Wu <jiejian@linux.alibaba.com>,
	Jiri Wiesner <jwiesner@suse.de>
Subject: Re: [PATCHv2 RFC net-next 08/14] ipvs: use resizable hash table for
 services
Message-ID: <20240117095414.GL588419@kernel.org>
References: <20231212162444.93801-1-ja@ssi.bg>
 <20231212162444.93801-9-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20231212162444.93801-9-ja@ssi.bg>

On Tue, Dec 12, 2023 at 06:24:38PM +0200, Julian Anastasov wrote:
> Make the hash table for services resizable in the bit range of 4-20.
> Table is attached only while services are present. Resizing is done
> by delayed work based on load (the number of hashed services).
> Table grows when load increases 2+ times (above 12.5% with factor=3)
> and shrinks 8+ times when load decreases 16+ times (below 0.78%).
> 
> Switch to jhash hashing to reduce the collisions for multiple
> services.
> 
> Add a hash_key field into the service that includes table ID and
> bucket ID. This helps the lookup and delete operations.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

...

> @@ -391,18 +440,29 @@ static inline struct ip_vs_service *
>  __ip_vs_service_find(struct netns_ipvs *ipvs, int af, __u16 protocol,
>  		     const union nf_inet_addr *vaddr, __be16 vport)
>  {
> -	unsigned int hash;
> +	DECLARE_IP_VS_RHT_WALK_BUCKET_RCU();
> +	struct hlist_bl_head *head;
>  	struct ip_vs_service *svc;
> -
> -	/* Check for "full" addressed entries */
> -	hash = ip_vs_svc_hashkey(ipvs, af, protocol, vaddr, vport);
> -
> -	hlist_for_each_entry_rcu(svc, &ipvs->svc_table[hash], s_list) {
> -		if (svc->af == af && ip_vs_addr_equal(af, &svc->addr, vaddr) &&
> -		    svc->port == vport && svc->protocol == protocol &&
> -		    !svc->fwmark) {
> -			/* HIT */
> -			return svc;
> +	struct ip_vs_rht *t, *p;
> +	struct hlist_bl_node *e;
> +	u32 hash, hash_key;
> +
> +	ip_vs_rht_for_each_table_rcu(ipvs->svc_table, t, p) {
> +		/* Check for "full" addressed entries */
> +		hash = ip_vs_svc_hashval(t, af, protocol, vaddr, vport);
> +
> +		hash_key = ip_vs_rht_build_hash_key(t, hash);
> +		ip_vs_rht_walk_bucket_rcu(t, hash_key, head) {
> +			hlist_bl_for_each_entry_rcu(svc, e, head, s_list) {

Hi Julian,

Smatch thinks that head is used uninitialised here.
This does seem to be the case to me too.

> +				if (READ_ONCE(svc->hash_key) == hash_key &&
> +				    svc->af == af &&
> +				    ip_vs_addr_equal(af, &svc->addr, vaddr) &&
> +				    svc->port == vport &&
> +				    svc->protocol == protocol && !svc->fwmark) {
> +					/* HIT */
> +					return svc;
> +				}
> +			}
>  		}
>  	}
>  
> @@ -416,16 +476,26 @@ __ip_vs_service_find(struct netns_ipvs *ipvs, int af, __u16 protocol,
>  static inline struct ip_vs_service *
>  __ip_vs_svc_fwm_find(struct netns_ipvs *ipvs, int af, __u32 fwmark)
>  {
> -	unsigned int hash;
> +	DECLARE_IP_VS_RHT_WALK_BUCKET_RCU();
> +	struct hlist_bl_head *head;
>  	struct ip_vs_service *svc;
> -
> -	/* Check for fwmark addressed entries */
> -	hash = ip_vs_svc_fwm_hashkey(ipvs, fwmark);
> -
> -	hlist_for_each_entry_rcu(svc, &ipvs->svc_table[hash], s_list) {
> -		if (svc->fwmark == fwmark && svc->af == af) {
> -			/* HIT */
> -			return svc;
> +	struct ip_vs_rht *t, *p;
> +	struct hlist_bl_node *e;
> +	u32 hash, hash_key;
> +
> +	ip_vs_rht_for_each_table_rcu(ipvs->svc_table, t, p) {
> +		/* Check for fwmark addressed entries */
> +		hash = ip_vs_svc_fwm_hashval(t, af, fwmark);
> +
> +		hash_key = ip_vs_rht_build_hash_key(t, hash);
> +		ip_vs_rht_walk_bucket_rcu(t, hash_key, head) {
> +			hlist_bl_for_each_entry_rcu(svc, e, head, s_list) {

Ditto.

> +				if (READ_ONCE(svc->hash_key) == hash_key &&
> +				    svc->fwmark == fwmark && svc->af == af) {
> +					/* HIT */
> +					return svc;
> +				}
> +			}
>  		}
>  	}
>  

...
