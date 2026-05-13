Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 963E73655E3
	for <lvs-devel@vger.kernel.org>; Wed, 13 May 2026 01:41:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1778636517; cv=none; b=G/Vji5bGOuVHUs9QFBm0OyNKFqFVrAtc+6W0wOBrf3A4HCTi1/sHM42yrqQrhwWzhEBNIEzclSZ/thQ7gOeyt2rmZbwWh2GtMV4XitfGXXN+49G9jVn+PgJ2dWwP5ibUk5KP7ZFMxEac448288+52eeKFexxfYZW24iW2LagnYg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1778636517; c=relaxed/simple;
	bh=QpP+nVlhexDDbFF/v/fM34uLgmfJGufnyksSM6QIH74=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=iQ9xUoqCs1vIBhELGhVe/NYP87pbFHm+JkjkIxP+mhs99jgE4UolC87c67S8sGmR8X/ymcTDDcgeGR6gSEMk+4GOASezhgnuCURroMiAfEHeYpHEa5qR3mIz1DT/sLXfCLIzmTBVpF8xeYHU8n3bhSD5j7HOywa5s7HxuXRKE6Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=en1Mmekp; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="en1Mmekp"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1778636511;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=UT5oGYZY32+rUjFuqBiLxCgevBNWLQoqsz5+vYhdrcg=;
	b=en1MmekpBATQD9DDTmg2+yytog0Cbzzc7lBVgQaUypONPh1SILbEFGOdT9/M2q8mOBf+Dh
	g4fitbFlWC4UpvU0cuhTTXrc+pSBqtXsHiIp7q90CsaWbNqqJUyJeGvaiBavJXaTSoa/5O
	yrjFt4z2bgxEPLRB5giUQBrQcdgmsws=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-571-oLkdP7p7MimPfm9qP2zTYg-1; Tue,
 12 May 2026 21:41:47 -0400
X-MC-Unique: oLkdP7p7MimPfm9qP2zTYg-1
X-Mimecast-MFC-AGG-ID: oLkdP7p7MimPfm9qP2zTYg_1778636505
Received: from mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.4])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 09B1319560A1;
	Wed, 13 May 2026 01:41:44 +0000 (UTC)
Received: from [10.2.16.241] (unknown [10.2.16.241])
	by mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 1B89930001BE;
	Wed, 13 May 2026 01:41:39 +0000 (UTC)
Message-ID: <5734ac41-af0f-4696-8af0-073d3f15537f@redhat.com>
Date: Tue, 12 May 2026 21:41:38 -0400
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH net 0/8] IPVS fixes for net
To: Pablo Neira Ayuso <pablo@netfilter.org>, Julian Anastasov <ja@ssi.bg>
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
 netdev@vger.kernel.org, kuba@kernel.org, pabeni@redhat.com,
 edumazet@google.com, fw@strlen.de, horms@kernel.org,
 lvs-devel@vger.kernel.org, Anna-Maria Behnsen <anna-maria@linutronix.de>,
 Frederic Weisbecker <frederic@kernel.org>, Ingo Molnar <mingo@kernel.org>,
 Thomas Gleixner <tglx@kernel.org>
References: <20260505001648.360569-1-pablo@netfilter.org>
 <bce80830-1e2d-43ad-ba7f-055cb352b348@ssi.bg> <aftbVlmSOAFegQgf@chamomile>
Content-Language: en-US
From: Waiman Long <longman@redhat.com>
In-Reply-To: <aftbVlmSOAFegQgf@chamomile>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.4

On 5/6/26 11:16 AM, Pablo Neira Ayuso wrote:
> Hi Julian,
>
> Cc'ing Waiman Long and NOHZ maintainers (apologies if this is dragging
> more people that I should into this issue).
>
> On Wed, May 06, 2026 at 11:56:05AM +0300, Julian Anastasov wrote:
> [...]
>> 	Here are some comments after the last review from
>> Sashiko:
>>
>> https://sashiko.dev/#/patchset/20260505001648.360569-1-pablo%40netfilter.org
>>
>> Patch 1:
>> - while ip_vs_dst_event() should loop and ensure all dev
>> references are released, single change of svc_table_changes
>> does not indicate the old references are dropped by ip_vs_flush() or
>> ip_vs_del_service(). I'll post new change to abort the loop
>> when we are sure the services are at least once released.
>>
>> Patch 5:
>> - after executing ip_vs_est_calc_phase(), data can
>> remain only for kt0 because all estimators are stopped,
>> unlinked and the kt data structures for kt > 0 are empty
>> and as result freed and the kthread tasks stopped (which
>> happens early). After this, kt 0 calls
>> ip_vs_est_drain_temp_list() as part of its loop,
>> so it will eventually call ip_vs_est_add_kthread()
>> and ip_vs_est_reload_start() to request kthread tasks
>> to be started if data for new kthreads are created.
>> So, I don't see problem here.
>>
>> Patch 6:
>> - we will add conn_max sysctl soon
> OK, just follow up on these for 1 and 6, thanks.
>
>> Patch 7 and 8:
>> - I can not decide how valid are the concerns in the review.
> Placing here links for convenience:
>
> https://sashiko.dev/#/message/20260505001648.360569-8-pablo%40netfilter.org
> https://sashiko.dev/#/message/20260505001648.360569-9-pablo%40netfilter.org
>
> This is away from my limited scope of knowledged.
>
Sorry for the late reply. The latest upstream kernel has already been 
updated to make kthreads follow HK_TYPE_DOMAIN in determining which 
non-housekeeping CPUs should be avoided. For full CPU isolation, users 
should set nohz_full, isolcpus=domain and isolcpus=managed_irq to 
specify CPUs to isolate. Just one of them isn't enough for CPU 
isolation. In fact, the current plan is to enable runtime modification 
to these CPU isolation features so that users can acquire additional 
isolated CPUs or release some of them on demand. This is still a work in 
progress. So the AI comment on patch 8 isn't a real concern.

Please let me know if you have additional question.

Cheers,
Longman

