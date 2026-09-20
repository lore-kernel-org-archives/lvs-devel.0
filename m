Received: from mail-pj2-f12.google.com (mail-pj2-f12.google.com [74.125.227.140])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 30176348453
	for <lvs-devel@vger.kernel.org>; Sun, 20 Sep 2026 02:59:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.140
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789873155; cv=none; b=fTOpvRbZPk1Ek3BNATAGLPW+lAKcwYSQgccm8RjYr9l43JMSEnY43wavFHirmwbqC0PP8YMVizFDHgmYc5KyuUhD5ZlHT9VVsIj/p0JEw1coWMMrlmxPDo/hzd/fZRr/Q1KQqNwmC7jQ/UoG3pM6xtPMgv1kA2EpKoW+lKQpDUE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789873155; c=relaxed/simple;
	bh=gPJ0XQGgfNv1d3Ho/V654aeCBOUzDDXWMXBmKBXO/J8=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=CgfjEyrLI4/bj0V47ewK6rkcEotHeRzk/XHt8aIUnDpsY0bbpx47Ixi0babSqVI+ZOWX5cl/94jHPixKRzfPERYLlY0MCaGE7a8MQw1d52nOEZqXWgdapG3wJSr43Q4JDFx9ryFEClAlbwXWUVPRVRdO34AfssYFaxgZ9axWkDM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai; spf=pass smtp.mailfrom=nebusec.ai; dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b=suf0m9If; arc=none smtp.client-ip=74.125.227.140
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b="suf0m9If"
Received: by mail-pj2-f12.google.com with SMTP id d9443c01a7336-2db18fe433fso16784535ad.2
        for <lvs-devel@vger.kernel.org>; Sat, 19 Sep 2026 19:59:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=nebusec.ai; s=google; t=1789873151; x=1790477951; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=I4n3ZHXB3rBtaB7q7bj1Sr9MkUuUjSFhFDvZLmTYYbo=;
        b=suf0m9Ifs4QFSjxd8VCAAbRBaJrxKPMWgLOov+stmJd41vEOhbsu+amzY7tJE7OxCD
         hzCmkFkKMKrnoiTEy5BmHTQ5uSgqUTu93BQRBIRvhdOC1CwMli3qv+tWOhAPDCKKJmBw
         alRGTsQGFGOi26nmahUg6b/AiLSr1skFhNPq9YaA6rjLmuay2Dy1WJvIadmwBvaQeheg
         bq8Y7by0vyLL+Sipyy9fjwDjlKVuV903mudCO8M7rs2kwxpoVVj76HitNXiSVTnP8t2c
         /TmdICJ+NAjU8A2h8ALz+dh7gvhWVVT9YEYmcmZ9hOfB2C1/MQV4QHD1JBqXfABhmBwR
         zb5g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789873151; x=1790477951;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=I4n3ZHXB3rBtaB7q7bj1Sr9MkUuUjSFhFDvZLmTYYbo=;
        b=FBpLOJcvXt8v52InGMkgTdi3RfXfnhZQIDT2tendYFw7sMWtr6q2SeXVndqUS49h7T
         jY3grLaahNFhw6q79vrXRRcFqar0N5qRPMO0L4nJila1sizite66fy6Qs0sHLcwa96cm
         yCpjsrLa/OxYAvdFIeISLNujl0otV1mttOe+ULnalWB7Pgqog1icYIogkrMhbCoHYb+9
         LRk38NnJaK5+1xOO6YIojFMnEpH5Y36+lgGX/m8jnU0plN7YqCcDYO4JdndmI7LsBFbI
         peEVvh9blAbNfOmGbj4BcAaZ7dASw80tK2425djG2WghXPLnVMnMxs+gzOM91iiKA5Ku
         PqPQ==
X-Gm-Message-State: AFuF++lBUy/dQ7Zfpbc4Up32uadDTX3s64ozh9kQ+d5ZvM3uzcyvkIl9
	W1rQkQ25/AZ6Q++kNJvsrfHqZhzmVJh3ASWm4JyEkYnUGGvocrQVGRR5y1XLssOPVCMZgZLb6wZ
	Bo3mFwYvpfu8=
X-Gm-Gg: AYBFou2TX1xj7/z0gcJjemRhcT9Brg7FvAddWrvcVp3n5s6Dj2XGuMdLWt9GTJKmdgk
	sIaWQUPbbS/zJ90zw0V0FMdxJDzOrycTmnNcC+FLQo//cy653LCm30fwxxFiqZqwakokvqxOfv0
	xiI3AgOu8E1o52+hHR294OXvSe44UXknMIRhcACsVGPN1sW7XkZq1kwQYtTIkK/u3iqiEZInbV7
	92anoFufE3fVKVEldCP4Wicb4q9oG9pm3BEOtqvzmGlqGotNvVtIamWkQ5Jd8jYLtUDHoivw9XC
	HTp1CRpUVnyycjiDycgDeo8JgOhjJXCHW2t0AdYya0ynt6TEU3QWQ207x6AbQsa95/apG47vAAI
	vtdeTxIQjVjkz7+Q3YUpkRqKJ0rX/1rO07zANskDt5efMesoxqKNBrPk7HrDjEmEYFZzbb0sHKx
	1XBrG3roGDpCNy9d15wSLDB1rEwt75oZ7lRomhzUmK1wmIiGJxwFzKrC0GJZlq/u2qvdGBS624/
	FcGvuSyChoNj7KQOk0VV+zxoC17/3Hl8Qp96acxjuXHjJhlB0eR
X-Received: by 2002:a17:903:94c:b0:2d9:464f:d45f with SMTP id d9443c01a7336-2ddb1ab3b88mr119790415ad.5.1789873151458;
        Sat, 19 Sep 2026 19:59:11 -0700 (PDT)
Received: from [192.168.4.59] (c-73-93-246-205.hsd1.ca.comcast.net. [73.93.246.205])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-33c331d55cfsm11582358eec.30.2026.09.19.19.59.09
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sat, 19 Sep 2026 19:59:11 -0700 (PDT)
Message-ID: <f04216a2-263a-4e2d-9641-5be0fe4c766f@nebusec.ai>
Date: Sat, 19 Sep 2026 19:59:08 -0700
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH net 0/1] ipvs: bound twos scheduler destination walks
To: Julian Anastasov <ja@ssi.bg>, Jiayuan Chen <jiayuan.chen@linux.dev>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
 Simon Horman <horms@verge.net.au>, pablo@netfilter.org, fw@strlen.de,
 phil@nwl.cc, darby.payne@gmail.com, zzyy19904204639@163.com,
 Ren Wei <weir@nebusec.ai>
References: <cover.1789117690.git.zzyy19904204639@163.com>
 <861399d8-c71f-6589-d4cd-3549d9c5bc00@ssi.bg>
 <d8aab597-62b5-444a-a6cf-efd2642d9a81@linux.dev>
 <bfdbe9ba-f213-64e9-668d-e951aa0c2863@ssi.bg>
Content-Language: en-US
From: Yuan Tan <yuant@nebusec.ai>
In-Reply-To: <bfdbe9ba-f213-64e9-668d-e951aa0c2863@ssi.bg>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit


On 9/17/26 13:06, Julian Anastasov wrote:
> 	Hello,
>
> On Thu, 17 Sep 2026, Jiayuan Chen wrote:
>
>> On 9/15/26 2:01 AM, Julian Anastasov wrote:
>>> 	I assume the problem is caused by the dest_trash.
>>> It seems, we need a general solution to this problem.
>>> One option is to penalize with synchronize_rcu() if we detect
>>> dest that is reused too soon. But even that looks complex to
>>> implement.
>>
>> I think we can use pair(get_state_synchronize_rcu, cond_synchronize_rcu)
>> instead.
>> For 'ipvsadm -C && ipvsadm -R', synchronize_rcu is only called once.
>>
>>
>> From ccbb304ab17e00849ea0bf31582d384e6b2768ba Mon Sep 10 00:00:00 2001
>> From: Jiayuan Chen <jiayuan.chen@linux.dev>
>> Date: Thu, 10 Sep 2026 19:36:57 +0800
>> Subject: [PATCH] ipvs: wait for readers before reusing dest from trash
>>
>> __ip_vs_unlink_dest() and ip_vs_rs_unhash() remove the dest with
>> list_del_rcu()/hlist_del_rcu(), so readers can still be on it. If
>> ip_vs_add_dest() picks the same dest from trash right away,
>> __ip_vs_update_dest() links it into another service and rs_table,
>> and those readers follow the new next pointers into a different
>> list.
>>
>> A synchronize_rcu() on the delete side costs one grace period per
>> dest, which makes 'ipvsadm -C' with many real servers very slow.
>> Doing it on the reuse side has the same problem with 'ipvsadm -R'.
>> So record a grace period cookie when the dest goes to trash and use
>> cond_synchronize_rcu() on reuse. The first wait covers every dest
>> trashed before it, so a full restore waits at most once.
>>
>> Fixes: bcbde4c0a755 ("ipvs: make the service replacement more robust")
>> Signed-off-by: Jiayuan Chen <jiayuan.chen@linux.dev>
>> ---
>>  include/net/ip_vs.h            | 1 +
>>  net/netfilter/ipvs/ip_vs_ctl.c | 6 ++++++
>>  2 files changed, 7 insertions(+)
>>
>> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
>> index 32fde731bceb..81b7600ac959 100644
>> --- a/include/net/ip_vs.h
>> +++ b/include/net/ip_vs.h
>> @@ -1013,6 +1013,7 @@ struct ip_vs_dest {
>>
>>      struct rcu_head        rcu_head;
>>      struct list_head    t_list;        /* in dest_trash */
>> +    unsigned long        rcu_state;    /* GP cookie when trashed */
>>      unsigned int        in_rs_table:1;    /* we are in rs_table */
>>  };
>>
>> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
>> index 4c1c739446b7..99da7b74500f 100644
>> --- a/net/netfilter/ipvs/ip_vs_ctl.c
>> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
>> @@ -1159,6 +1159,7 @@ static void ip_vs_trash_put_dest(struct netns_ipvs
>> *ipvs,
>>      /* dest lives in trash with reference */
>>      list_add(&dest->t_list, &ipvs->dest_trash);
>>      dest->idle_start = istart;
>> +    dest->rcu_state = get_state_synchronize_rcu();
>>      spin_unlock_bh(&ipvs->dest_trash_lock);
>>  }
>>
>> @@ -1566,6 +1567,11 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct
>> ip_vs_dest_user_kern *udest)
>>                    IP_VS_DBG_ADDR(svc->af, &dest->vaddr),
>>                    ntohs(dest->vport));
>>
>> +        /* Readers may still follow n_list/d_list of the unlinked
>> +         * dest, wait before linking it again.
>> +         */
>> +        cond_synchronize_rcu(dest->rcu_state);
>> +
>>          ret = ip_vs_start_estimator(svc->ipvs, &dest->stats);
>>          /* On error put back dest into the trash */
>>          if (ret < 0)
>> --
>> 2.43.0
> 	Very good solution, indeed. But it needed some tuning
> and some other problems need to be solved:
>
> - if dest is edited and the dest tunnel parameters changed
> this leads to rehashing and a forced synchronize_rcu(). If
> many dests are changed in this way - we got a coffee time...
>
> - dest can be put back into dest_trash, so we do not need to
> update the rcu_state for this case
>
> - use single temp list dest_trash to speedup the deleting of
> service (with many dests) and the service flush (many services with
> many dests) by using single get_state_synchronize_rcu (which has
> full memory barrier) and by splicing the temp list with all
> deleted dests into the public dest_trash list by using single
> spin lock (ip_vs_trash_put_dests call).
>
> 	This is only compile-tested and I hope it can survive
> the flood tests that break the "two" scheduler lookups...


Hi Julian and Jiayuan,

Vega team here. I am wondering what would be the best way to move this
fix forward?

Would you prefer Darong to test Julian's version and send a v2,
crediting both of you with Suggested-by or Co-developed-by tags?

Alternatively, if either of you would prefer to submit the patch, please
include:

Reported-by: Vega vega@nebusec.ai <mailto:vega@nebusec.ai>
Reported-by: Darong Lu zzyy19904204639@163.com
<mailto:zzyy19904204639@163.com>

Thanks for your review and advice!


>
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index e09b9598a476..2ed6fe86fa73 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -1021,6 +1021,7 @@ struct ip_vs_dest {
>  
>  	struct rcu_head		rcu_head;
>  	struct list_head	t_list;		/* in dest_trash */
> +	unsigned long		rcu_state;	/* GP cookie when trashed */
>  	unsigned int		in_rs_table:1;	/* we are in rs_table */
>  };
>  
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 5de69404a5e0..d29dde6a61fd 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -64,7 +64,8 @@ int ip_vs_get_debug_level(void)
>  
>  
>  /*  Protos */
> -static void __ip_vs_del_service(struct ip_vs_service *svc, bool cleanup);
> +static void __ip_vs_del_service(struct ip_vs_service *svc,
> +				struct list_head *dest_trash, bool cleanup);
>  
>  
>  #ifdef CONFIG_IP_VS_IPV6
> @@ -883,7 +884,8 @@ static inline unsigned int ip_vs_rs_hashkey(int af,
>  }
>  
>  /* Hash ip_vs_dest in rs_table by <proto,addr,port>. */
> -static void ip_vs_rs_hash(struct netns_ipvs *ipvs, struct ip_vs_dest *dest)
> +static void ip_vs_rs_hash(struct netns_ipvs *ipvs, struct ip_vs_dest *dest,
> +			  bool need_gp)
>  {
>  	unsigned int hash;
>  	__be16 port;
> @@ -918,6 +920,9 @@ static void ip_vs_rs_hash(struct netns_ipvs *ipvs, struct ip_vs_dest *dest)
>  	 */
>  	hash = ip_vs_rs_hashkey(dest->af, &dest->addr, port);
>  
> +	/* Need RCU grace period when rehashing */
> +	if (need_gp)
> +		synchronize_rcu();
>  	hlist_add_head_rcu(&dest->d_list, &ipvs->rs_table[hash]);
>  	dest->in_rs_table = 1;
>  }
> @@ -1144,24 +1149,59 @@ ip_vs_trash_get_dest(struct ip_vs_service *svc, int dest_af,
>  	return dest;
>  }
>  
> -/* Put destination in trash */
> -static void ip_vs_trash_put_dest(struct netns_ipvs *ipvs,
> +/* Add destination in temp list for trash */
> +static void ip_vs_trash_add_dest(struct netns_ipvs *ipvs,
>  				 struct ip_vs_dest *dest, unsigned long istart,
> -				 bool cleanup)
> +				 struct list_head *dest_trash)
>  {
> -	spin_lock_bh(&ipvs->dest_trash_lock);
>  	IP_VS_DBG_BUF(3, "Moving dest %s:%u into trash, dest->refcnt=%d\n",
>  		      IP_VS_DBG_ADDR(dest->af, &dest->addr), ntohs(dest->port),
>  		      refcount_read(&dest->refcnt));
> +	/* dest lives in trash with reference */
> +	list_add(&dest->t_list, dest_trash);
> +	dest->idle_start = istart;
> +}
> +
> +/* Put destinations in trash */
> +static void ip_vs_trash_put_dests(struct netns_ipvs *ipvs,
> +				  struct list_head *dest_trash, bool cleanup)
> +{
> +	spin_lock_bh(&ipvs->dest_trash_lock);
>  	if (list_empty(&ipvs->dest_trash) && !cleanup)
>  		mod_timer(&ipvs->dest_trash_timer,
>  			  jiffies + (IP_VS_DEST_TRASH_PERIOD >> 1));
> -	/* dest lives in trash with reference */
> -	list_add(&dest->t_list, &ipvs->dest_trash);
> -	dest->idle_start = istart;
> +	list_splice(dest_trash, &ipvs->dest_trash);
>  	spin_unlock_bh(&ipvs->dest_trash_lock);
>  }
>  
> +/* Put destination back in trash */
> +static void ip_vs_trash_put_back(struct netns_ipvs *ipvs,
> +				 struct ip_vs_dest *dest)
> +{
> +	LIST_HEAD(dest_trash);
> +
> +	list_add(&dest->t_list, &dest_trash);
> +	ip_vs_trash_add_dest(ipvs, dest, dest->idle_start, &dest_trash);
> +	ip_vs_trash_put_dests(ipvs, &dest_trash, false);
> +}
> +
> +/* Put destinations in trash and save the RCU state */
> +static void ip_vs_trash_save_dests(struct netns_ipvs *ipvs,
> +				   struct list_head *dest_trash, bool cleanup)
> +{
> +	struct ip_vs_dest *dest;
> +	unsigned long rcu_state;
> +
> +	if (!list_empty(dest_trash)) {
> +		/* Remember when dests were removed and added to dest_trash */
> +		rcu_state = get_state_synchronize_rcu();
> +		list_for_each_entry(dest, dest_trash, t_list) {
> +			dest->rcu_state = rcu_state;
> +		}
> +		ip_vs_trash_put_dests(ipvs, dest_trash, cleanup);
> +	}
> +}
> +
>  static void ip_vs_dest_rcu_free(struct rcu_head *head)
>  {
>  	struct ip_vs_dest *dest;
> @@ -1348,6 +1388,7 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
>  	struct netns_ipvs *ipvs = svc->ipvs;
>  	struct ip_vs_service *old_svc;
>  	struct ip_vs_scheduler *sched;
> +	bool need_gp = false;
>  	int conn_flags;
>  
>  	/* We cannot modify an address and change the address family */
> @@ -1369,8 +1410,10 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
>  	if ((udest->conn_flags & IP_VS_CONN_F_FWD_MASK) !=
>  	    IP_VS_DFWD_METHOD(dest) ||
>  	    udest->tun_type != dest->tun_type ||
> -	    udest->tun_port != dest->tun_port)
> +	    udest->tun_port != dest->tun_port) {
> +		need_gp = dest->in_rs_table;
>  		ip_vs_rs_unhash(dest);
> +	}
>  
>  	/* set the tunnel info */
>  	dest->tun_type = udest->tun_type;
> @@ -1387,7 +1430,7 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
>  	}
>  	atomic_set(&dest->conn_flags, conn_flags);
>  	/* Put the real service in rs_table if not present. */
> -	ip_vs_rs_hash(ipvs, dest);
> +	ip_vs_rs_hash(ipvs, dest, need_gp);
>  
>  	/* bind the service */
>  	old_svc = rcu_dereference_protected(dest->svc, 1);
> @@ -1566,11 +1609,16 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
>  
>  		ret = ip_vs_start_estimator(svc->ipvs, &dest->stats);
>  		/* On error put back dest into the trash */
> -		if (ret < 0)
> -			ip_vs_trash_put_dest(svc->ipvs, dest, dest->idle_start,
> -					     false);
> -		else
> +		if (ret < 0) {
> +			ip_vs_trash_put_back(svc->ipvs, dest);
> +		} else {
> +			/* Readers may still follow n_list/d_list of the
> +			 * unlinked dest, wait before linking it again.
> +			 */
> +			cond_synchronize_rcu(dest->rcu_state);
> +
>  			__ip_vs_update_dest(svc, dest, udest, 1);
> +		}
>  	} else {
>  		/*
>  		 * Allocate and initialize the dest structure
> @@ -1634,7 +1682,7 @@ ip_vs_edit_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
>   *	Delete a destination (must be already unlinked from the service)
>   */
>  static void __ip_vs_del_dest(struct netns_ipvs *ipvs, struct ip_vs_dest *dest,
> -			     bool cleanup)
> +			     struct list_head *dest_trash, bool cleanup)
>  {
>  	ip_vs_stop_estimator(ipvs, &dest->stats);
>  
> @@ -1643,7 +1691,7 @@ static void __ip_vs_del_dest(struct netns_ipvs *ipvs, struct ip_vs_dest *dest,
>  	 */
>  	ip_vs_rs_unhash(dest);
>  
> -	ip_vs_trash_put_dest(ipvs, dest, 0, cleanup);
> +	ip_vs_trash_add_dest(ipvs, dest, 0, dest_trash);
>  
>  	/* Queue up delayed work to expire all no destination connections.
>  	 * No-op when CONFIG_SYSCTL is disabled.
> @@ -1693,6 +1741,7 @@ ip_vs_del_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
>  {
>  	struct ip_vs_dest *dest;
>  	__be16 dport = udest->port;
> +	LIST_HEAD(dest_trash);
>  
>  	/* We use function that requires RCU lock */
>  	rcu_read_lock();
> @@ -1712,8 +1761,9 @@ ip_vs_del_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
>  	/*
>  	 *	Delete the destination
>  	 */
> -	__ip_vs_del_dest(svc->ipvs, dest, false);
> +	__ip_vs_del_dest(svc->ipvs, dest, &dest_trash, false);
>  
> +	ip_vs_trash_save_dests(svc->ipvs, &dest_trash, false);
>  	return 0;
>  }
>  
> @@ -2057,7 +2107,8 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
>   *	- The service must be unlinked, unlocked and not referenced!
>   *	- We are called under _bh lock
>   */
> -static void __ip_vs_del_service(struct ip_vs_service *svc, bool cleanup)
> +static void __ip_vs_del_service(struct ip_vs_service *svc,
> +				struct list_head *dest_trash, bool cleanup)
>  {
>  	struct ip_vs_dest *dest, *nxt;
>  	struct ip_vs_scheduler *old_sched;
> @@ -2091,7 +2142,7 @@ static void __ip_vs_del_service(struct ip_vs_service *svc, bool cleanup)
>  	 */
>  	list_for_each_entry_safe(dest, nxt, &svc->destinations, n_list) {
>  		__ip_vs_unlink_dest(svc, dest, 0);
> -		__ip_vs_del_dest(svc->ipvs, dest, cleanup);
> +		__ip_vs_del_dest(svc->ipvs, dest, dest_trash, cleanup);
>  	}
>  
>  	/*
> @@ -2114,7 +2165,8 @@ static void __ip_vs_del_service(struct ip_vs_service *svc, bool cleanup)
>  /*
>   * Unlink a service from list and try to delete it if its refcnt reached 0
>   */
> -static void ip_vs_unlink_service(struct ip_vs_service *svc, bool cleanup)
> +static void ip_vs_unlink_service(struct ip_vs_service *svc,
> +				 struct list_head *dest_trash, bool cleanup)
>  {
>  	ip_vs_unregister_conntrack(svc);
>  	/* Hold svc to avoid double release from dest_trash */
> @@ -2124,7 +2176,7 @@ static void ip_vs_unlink_service(struct ip_vs_service *svc, bool cleanup)
>  	 */
>  	ip_vs_svc_unhash(svc);
>  
> -	__ip_vs_del_service(svc, cleanup);
> +	__ip_vs_del_service(svc, dest_trash, cleanup);
>  }
>  
>  /*
> @@ -2134,12 +2186,14 @@ static int ip_vs_del_service(struct ip_vs_service *svc)
>  {
>  	struct netns_ipvs *ipvs;
>  	struct ip_vs_rht *t, *p;
> +	LIST_HEAD(dest_trash);
>  	int ns;
>  
>  	if (svc == NULL)
>  		return -EEXIST;
>  	ipvs = svc->ipvs;
> -	ip_vs_unlink_service(svc, false);
> +	ip_vs_unlink_service(svc, &dest_trash, false);
> +	ip_vs_trash_save_dests(ipvs, &dest_trash, false);
>  
>  	/* Drop the table if no more services */
>  	ns = ip_vs_get_num_services(ipvs);
> @@ -2190,6 +2244,7 @@ static int ip_vs_flush(struct netns_ipvs *ipvs, bool cleanup)
>  	struct hlist_bl_node *ne;
>  	struct hlist_bl_node *e;
>  	struct ip_vs_rht *t, *p;
> +	LIST_HEAD(dest_trash);
>  
>  	/* Stop the resizer and drop the tables */
>  	if (!test_and_set_bit(IP_VS_WORK_SVC_NORESIZE, &ipvs->work_flags))
> @@ -2199,8 +2254,9 @@ static int ip_vs_flush(struct netns_ipvs *ipvs, bool cleanup)
>  	if (ip_vs_get_num_services(ipvs)) {
>  		ip_vs_rht_walk_buckets(ipvs->svc_table, head) {
>  			hlist_bl_for_each_entry_safe(svc, e, ne, head, s_list)
> -				ip_vs_unlink_service(svc, cleanup);
> +				ip_vs_unlink_service(svc, &dest_trash, cleanup);
>  		}
> +		ip_vs_trash_save_dests(ipvs, &dest_trash, cleanup);
>  	}
>  
>  	/* Unregister the hash table and release it after RCU grace period */
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
