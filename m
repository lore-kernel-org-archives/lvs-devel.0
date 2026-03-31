Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B45E23ED5A9
	for <lvs-devel@vger.kernel.org>; Tue, 31 Mar 2026 14:24:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774967098; cv=none; b=NSrEPbE8EnU6KUW+beLCEH3zFdibtNSOKoyS/NP9xQRQl8xNMvDQGJPrdCM7jmvvXFzwNMcS2VDvlWxxWkC+VhzfTRC+4zknV3jBY1iGb4TOWX7krowcGOaQ5OLGTf/aARk1XdjEuvsT5XyvILi20RbdaS41T7O9GQpbS2XegzY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774967098; c=relaxed/simple;
	bh=qq8PLy0+8DA4C0FTyjzMTsfyH4GsvOGNzncTx4/Waq4=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=Y3Vc7c3yRQGsHtXfDxQ6O+JxGDCukgiYooR12sDtyNbMPCvBm44DfLarONrAXJqJPvEKT+yDIs/I7aLndfOnoeBP0AFVr5/+WgIpD167dgMDut4CI4xhAeoju2mDEa7g+z5yHxK8r6iGe4p8rT++fHtXc4bswOuKkTWaqFm4XG0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=IgsyScfU; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="IgsyScfU"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1774967094;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=xGbExH2WyJPhqEH/I3Ex4mJo86JJcu+eMS2b1MQ0hyc=;
	b=IgsyScfUgebUIfVjrlK5RLploV83GV6DxiYVPnywHBG+8iNwNbEyIV6uybIlB4tC/Vrbxz
	GSjz/3m+2sGKk0Mc8g7I6mPD1ukkGM3mAt1pkagVdyaO8I5AcaPZcVzE4xdiQFYIKzDBe4
	Ip/UumL5W2mglY/YxQotnE3jlnen+bw=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-84-JphZul2mPUKkspbNxYcMHQ-1; Tue,
 31 Mar 2026 10:24:45 -0400
X-MC-Unique: JphZul2mPUKkspbNxYcMHQ-1
X-Mimecast-MFC-AGG-ID: JphZul2mPUKkspbNxYcMHQ_1774967082
Received: from mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.12])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 937301886BE2;
	Tue, 31 Mar 2026 14:23:49 +0000 (UTC)
Received: from [10.22.80.26] (unknown [10.22.80.26])
	by mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 921FD19560AB;
	Tue, 31 Mar 2026 14:23:45 +0000 (UTC)
Message-ID: <b2fea411-de12-4e1a-bfc5-fdc14b2e29d5@redhat.com>
Date: Tue, 31 Mar 2026 10:23:44 -0400
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 2/2] ipvs: Guard access of HK_TYPE_KTHREAD cpumask with
 RCU
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, "David S. Miller"
 <davem@davemloft.net>, David Ahern <dsahern@kernel.org>,
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
 Paolo Abeni <pabeni@redhat.com>, Pablo Neira Ayuso <pablo@netfilter.org>,
 Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
 Frederic Weisbecker <frederic@kernel.org>,
 Chen Ridong <chenridong@huawei.com>, Phil Auld <pauld@redhat.com>,
 linux-kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
 lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
 coreteam@netfilter.org, sheviks <sheviks@gmail.com>
References: <20260324151827.2006656-1-longman@redhat.com>
 <20260324151827.2006656-3-longman@redhat.com>
 <6b8f1536-444c-e75a-c4b3-d5cbe7c1786e@ssi.bg>
Content-Language: en-US
From: Waiman Long <longman@redhat.com>
In-Reply-To: <6b8f1536-444c-e75a-c4b3-d5cbe7c1786e@ssi.bg>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.12

On 3/26/26 4:32 AM, Julian Anastasov wrote:
> 	Hello,
>
> On Tue, 24 Mar 2026, Waiman Long wrote:
>
>> The ip_vs_ctl.c file and the associated ip_vs.h file are the only places
>> in the kernel where HK_TYPE_KTHREAD cpumask is being retrieved and used.
>> Now that HK_TYPE_KTHREAD/HK_TYPE_DOMAIN cpumask can be changed at run
>> time. We need to use RCU to guard access to this cpumask to avoid a
>> potential UAF problem as the returned cpumask may be freed before it
>> is being used.
>>
>> Signed-off-by: Waiman Long <longman@redhat.com>
>> ---
>>   include/net/ip_vs.h            | 20 ++++++++++++++++----
>>   net/netfilter/ipvs/ip_vs_ctl.c | 13 ++++++++-----
>>   2 files changed, 24 insertions(+), 9 deletions(-)
>>
>> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
>> index 29a36709e7f3..17c85a575ef4 100644
>> --- a/include/net/ip_vs.h
>> +++ b/include/net/ip_vs.h
>> @@ -1155,7 +1155,7 @@ static inline int sysctl_run_estimation(struct netns_ipvs *ipvs)
>>   	return ipvs->sysctl_run_estimation;
>>   }
>>   
>> -static inline const struct cpumask *sysctl_est_cpulist(struct netns_ipvs *ipvs)
>> +static inline const struct cpumask *__sysctl_est_cpulist(struct netns_ipvs *ipvs)
>>   {
>>   	if (ipvs->est_cpulist_valid)
>>   		return ipvs->sysctl_est_cpulist;
>> @@ -1273,7 +1273,7 @@ static inline int sysctl_run_estimation(struct netns_ipvs *ipvs)
>>   	return 1;
>>   }
>>   
>> -static inline const struct cpumask *sysctl_est_cpulist(struct netns_ipvs *ipvs)
>> +static inline const struct cpumask *__sysctl_est_cpulist(struct netns_ipvs *ipvs)
>>   {
>>   	return housekeeping_cpumask(HK_TYPE_KTHREAD);
>>   }
>> @@ -1290,6 +1290,18 @@ static inline int sysctl_est_nice(struct netns_ipvs *ipvs)
>>   
>>   #endif
>>   
> 	May be there is little fuzz here, due to the recent
> changes in the nf-next tree. If this is a bugfix due to the
> missing RCU protection, may be you should add Fixes line too
> and use the nf tree. Probably, there will be fuzz/collisions with
> the changes in the nf-next tree...
Thanks for the suggestion, I will rebase the patches on top of the 
nf-next tree.
>
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
>> @@ -1604,7 +1616,7 @@ static inline void ip_vs_est_stopped_recalc(struct netns_ipvs *ipvs)
>>   	/* Stop tasks while cpulist is empty or if disabled with flag */
>>   	ipvs->est_stopped = !sysctl_run_estimation(ipvs) ||
>>   			    (ipvs->est_cpulist_valid &&
>> -			     cpumask_empty(sysctl_est_cpulist(ipvs)));
>> +			     sysctl_est_cpulist_empty(ipvs));
>>   #endif
>>   }
>>   
>> @@ -1620,7 +1632,7 @@ static inline bool ip_vs_est_stopped(struct netns_ipvs *ipvs)
>>   static inline int ip_vs_est_max_threads(struct netns_ipvs *ipvs)
>>   {
>>   	unsigned int limit = IPVS_EST_CPU_KTHREADS *
>> -			     cpumask_weight(sysctl_est_cpulist(ipvs));
>> +			     sysctl_est_cpulist_weight(ipvs);
>>   
>>   	return max(1U, limit);
>>   }
>> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
>> index 35642de2a0fe..f38a2e2a9dc5 100644
>> --- a/net/netfilter/ipvs/ip_vs_ctl.c
>> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
>> @@ -1973,11 +1973,14 @@ static int ipvs_proc_est_cpumask_get(const struct ctl_table *table,
>>   
>>   	mutex_lock(&ipvs->est_mutex);
>>   
>> -	if (ipvs->est_cpulist_valid)
>> -		mask = *valp;
>> -	else
>> -		mask = (struct cpumask *)housekeeping_cpumask(HK_TYPE_KTHREAD);
>> -	ret = scnprintf(buffer, size, "%*pbl\n", cpumask_pr_args(mask));
>> +	/* HK_TYPE_KTHREAD cpumask needs RCU protection */
> 	Can we switch IPVS to use HK_TYPE_DOMAIN? The initial
> intention was to follow the code in kthread.c. Then you can
> reconsider if HK_TYPE_KTHREAD should be alias to HK_TYPE_DOMAIN,
> may be not if there are no other users...

Yes, I can certainly switch to use HK_TYPE_DOMAIN instead. The reason I 
keep HK_TYPE_KTHREAD is that it may not be obvious to others that 
kthread is now following the HK_TYPE_DOMAIN cpumask, 
keeping  HK_TYPE_KTHREAD but making it an alias can make that clear.


>> +	scoped_guard(rcu) {
>> +		if (ipvs->est_cpulist_valid)
>> +			mask = *valp;
>> +		else
>> +			mask = (struct cpumask *)housekeeping_cpumask(HK_TYPE_KTHREAD);
>> +		ret = scnprintf(buffer, size, "%*pbl\n", cpumask_pr_args(mask));
>> +	}
>>   
>>   	mutex_unlock(&ipvs->est_mutex);
>>   
>> -- 
>> 2.53.0
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
>

