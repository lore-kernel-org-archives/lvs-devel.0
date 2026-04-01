Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C14CA3F1650
	for <lvs-devel@vger.kernel.org>; Wed,  1 Apr 2026 15:13:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775056416; cv=none; b=W42ta7w2qWC03LJPSCEE+UdBVCe+z24fpA6IV4L3MtYGTjqloQ04rmIP/pjMmowKHgWVVA+CAPDM9Rs+bH6CgdKNJpCRBoyEXhdH1A6JL72uKQ2JIxPQtuoXmeQRbeBX0IHFHmGG0Y2QlxZQmWT+NJd13y53B37RFgkQXxULY8s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775056416; c=relaxed/simple;
	bh=Vx31kPj8WzRhzbsHW7UHSZzpuFvTyhoJHSe1Ji0Xm8E=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=pXl27CBcK/oYGOt9ieciqsq3hJGvLlezg0mTQsoIFBF9MbVkQ3C21hgnkeKacJEAPIVUgZ7c8h/kKNht/dxyu1SoJP2PySP+Iy+oqyBxaWtZQf9//TtCRhOpOoSHhn79/SBHyD+F/F7dLA3My82jOZIRD4XFWCZOK30CQBVvHPY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=KohO9/f9; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="KohO9/f9"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1775056406;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=qxBR3iXengsp3kpZeNErIksVg/dBeXg0IjlLomymZ64=;
	b=KohO9/f9lvAzCqel1Hd/TQcidzFLxb02x1dgx67+q6yH65o9/8Rb9UTK1Nc+zSlozQXyGH
	sf5uGxNMpZgUj+EIP2zjWgDncp3Vjm2/2qOoskfNz8pk/t4RHtRf8+tq+gIZ3O4hbc6bEO
	UhsRUrCKfelNZCANSK89uB8hCv69eZI=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-110-A6DpxH2rOJarDmVSk27dNA-1; Wed,
 01 Apr 2026 11:13:19 -0400
X-MC-Unique: A6DpxH2rOJarDmVSk27dNA-1
X-Mimecast-MFC-AGG-ID: A6DpxH2rOJarDmVSk27dNA_1775056397
Received: from mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.12])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 77BD91955DB6;
	Wed,  1 Apr 2026 15:13:16 +0000 (UTC)
Received: from [10.22.81.104] (unknown [10.22.81.104])
	by mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 27BFF19560AB;
	Wed,  1 Apr 2026 15:13:12 +0000 (UTC)
Message-ID: <81fb8d07-01c2-4fde-930a-03ea72b30978@redhat.com>
Date: Wed, 1 Apr 2026 11:13:11 -0400
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH-next v2 2/2] ipvs: Guard access of HK_TYPE_KTHREAD cpumask
 with RCU
To: Frederic Weisbecker <frederic@kernel.org>
Cc: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>,
 "David S. Miller" <davem@davemloft.net>, David Ahern <dsahern@kernel.org>,
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
 Paolo Abeni <pabeni@redhat.com>, Pablo Neira Ayuso <pablo@netfilter.org>,
 Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
 Chen Ridong <chenridong@huawei.com>, Phil Auld <pauld@redhat.com>,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
 lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
 coreteam@netfilter.org, sheviks <sheviks@gmail.com>
References: <20260331165015.2777765-1-longman@redhat.com>
 <20260331165015.2777765-3-longman@redhat.com>
 <ac0VfO3XiD_F1gv-@localhost.localdomain>
Content-Language: en-US
From: Waiman Long <longman@redhat.com>
In-Reply-To: <ac0VfO3XiD_F1gv-@localhost.localdomain>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.12

On 4/1/26 8:54 AM, Frederic Weisbecker wrote:
> Le Tue, Mar 31, 2026 at 12:50:15PM -0400, Waiman Long a écrit :
>> The ip_vs_ctl.c file and the associated ip_vs.h file are the only places
>> in the kernel where HK_TYPE_KTHREAD cpumask is being retrieved and used.
>> Now that HK_TYPE_KTHREAD/HK_TYPE_DOMAIN cpumask can be changed at run
>> time. We need to use RCU to guard access to this cpumask to avoid a
>> potential UAF problem as the returned cpumask may be freed before it
>> is being used.
>>
>> We can replace HK_TYPE_KTHREAD by HK_TYPE_DOMAIN as they are aliases
>> of each other, but keeping the HK_TYPE_KTHREAD name can highlight the
>> fact that it is the kthread initiated by ipvs that is being controlled.
>>
>> Signed-off-by: Waiman Long <longman@redhat.com>
> Oh I see you're handling a few concerns here. But it's too late, the previous
> patch broke bisection.
Good point. So I have to either reverse the patch order, or just change 
HK_TYPE_KTHREAD to HK_TYPE_DOMAIN & drop the first one.
>
>> ---
>>   include/net/ip_vs.h            | 20 ++++++++++++++++----
>>   net/netfilter/ipvs/ip_vs_ctl.c | 13 ++++++++-----
>>   2 files changed, 24 insertions(+), 9 deletions(-)
>>
>> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
>> index 72d325c81313..7bda92fd3fe6 100644
>> --- a/include/net/ip_vs.h
>> +++ b/include/net/ip_vs.h
>> @@ -1411,7 +1411,7 @@ static inline int sysctl_run_estimation(struct netns_ipvs *ipvs)
>>   	return ipvs->sysctl_run_estimation;
>>   }
>>   
>> -static inline const struct cpumask *sysctl_est_cpulist(struct netns_ipvs *ipvs)
>> +static inline const struct cpumask *__sysctl_est_cpulist(struct netns_ipvs *ipvs)
>>   {
>>   	if (ipvs->est_cpulist_valid)
>>   		return ipvs->sysctl_est_cpulist;
>> @@ -1529,7 +1529,7 @@ static inline int sysctl_run_estimation(struct netns_ipvs *ipvs)
>>   	return 1;
>>   }
>>   
>> -static inline const struct cpumask *sysctl_est_cpulist(struct netns_ipvs *ipvs)
>> +static inline const struct cpumask *__sysctl_est_cpulist(struct netns_ipvs *ipvs)
>>   {
>>   	return housekeeping_cpumask(HK_TYPE_KTHREAD);
>>   }
>> @@ -1564,6 +1564,18 @@ static inline int sysctl_svc_lfactor(struct netns_ipvs *ipvs)
>>   	return READ_ONCE(ipvs->sysctl_svc_lfactor);
>>   }
>>   
>> +static inline bool sysctl_est_cpulist_empty(struct netns_ipvs *ipvs)
>> +{
>> +	guard(rcu)();
>> +	return cpumask_empty(__sysctl_est_cpulist(ipvs));
>> +}
>> +
>> +static inline unsigned int sysctl_est_cpulist_weight(struct netns_ipvs *ipvs)
>> +{
>> +	guard(rcu)();
>> +	return cpumask_weight(__sysctl_est_cpulist(ipvs));
>> +}
>> +
>>   /* IPVS core functions
>>    * (from ip_vs_core.c)
>>    */
>> @@ -1895,7 +1907,7 @@ static inline void ip_vs_est_stopped_recalc(struct netns_ipvs *ipvs)
>>   	/* Stop tasks while cpulist is empty or if disabled with flag */
>>   	ipvs->est_stopped = !sysctl_run_estimation(ipvs) ||
>>   			    (ipvs->est_cpulist_valid &&
>> -			     cpumask_empty(sysctl_est_cpulist(ipvs)));
>> +			     sysctl_est_cpulist_empty(ipvs));
> It's not needed, if ipvs->est_cpulist_valid, sysctl_est_cpulist() doesn't
> refer to housekeeping.
Right.
>>   #endif
>>   }
>>   
>> @@ -1911,7 +1923,7 @@ static inline bool ip_vs_est_stopped(struct netns_ipvs *ipvs)
>>   static inline int ip_vs_est_max_threads(struct netns_ipvs *ipvs)
>>   {
>>   	unsigned int limit = IPVS_EST_CPU_KTHREADS *
>> -			     cpumask_weight(sysctl_est_cpulist(ipvs));
>> +			     sysctl_est_cpulist_weight(ipvs);
> That probably works for callers ip_vs_start_estimator().
>
> But this is not handling the core issue that related kthreads should be updated,
> as is done in ipvs_proc_est_cpumask_set(), when HK_TYPE_DOMAIN mask changes.

If ipvs_proc_est_cpumask_set() has been called, the real affinity should 
be the intersection of the given cpumask and HK_TYPE_DOMAIN cpumask. Is 
that what you are referring to?

Cheers,
Longman

>
>>   
>>   	return max(1U, limit);
>>   }
>> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
>> index 032425025d88..e253a1ceef48 100644
>> --- a/net/netfilter/ipvs/ip_vs_ctl.c
>> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
>> @@ -2338,11 +2338,14 @@ static int ipvs_proc_est_cpumask_get(const struct ctl_table *table,
>>   
>>   	mutex_lock(&ipvs->est_mutex);
>>   
>> -	if (ipvs->est_cpulist_valid)
>> -		mask = *valp;
>> -	else
>> -		mask = (struct cpumask *)housekeeping_cpumask(HK_TYPE_KTHREAD);
>> -	ret = scnprintf(buffer, size, "%*pbl\n", cpumask_pr_args(mask));
>> +	/* HK_TYPE_KTHREAD cpumask needs RCU protection */
>> +	scoped_guard(rcu) {
>> +		if (ipvs->est_cpulist_valid)
>> +			mask = *valp;
>> +		else
>> +			mask = (struct cpumask *)housekeeping_cpumask(HK_TYPE_KTHREAD);
>> +		ret = scnprintf(buffer, size, "%*pbl\n", cpumask_pr_args(mask));
>> +	}
> And that works.
>
> Thanks.
>
>>   
>>   	mutex_unlock(&ipvs->est_mutex);
>>   
>> -- 
>> 2.53.0
>>

