Received: from mta1.migadu.com (out-1.mta1.migadu.com [95.215.58.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8DC562DF13B
	for <lvs-devel@vger.kernel.org>; Sun, 20 Sep 2026 13:35:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=95.215.58.1
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789911347; cv=none; b=RM1Zl7pW/9blcwOqV989/A2cNvA/n04B2qqtwTBFXejdrsS6FZ200WS4ZSFJqnSkNGA3f6QSApPJi843fUT5CnTR+bj0AFwYpDGRtLb/Y3h1dQoqNYLBYMbE3HZqDV54SOrTnZE0mbkELEEYsE7CyzfFJzW7ibSsbxYbAeP4yfo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789911347; c=relaxed/simple;
	bh=g9e/2IEJIPYCeLdiO80dbyVvZLVMyX1DLQvRmaTotn0=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=hB7ak6nUFYxZL5dyf7W5JK6xv08MqTCXEl2YeIihgAwW2/7Iiz1eaim3NZkrgGiRsnwCo/KvXVwtCNACAq6KtQyyIlv3GFbN8uvdXQ9zaK2Aa4Zcg+SaM8MsKnBzYo6r0OHiwSZlDUe+wEPJz4lKp2RksXkcCTw8KVPggwboxYQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev; spf=pass smtp.mailfrom=linux.dev; dkim=pass (1024-bit key) header.d=linux.dev header.i=@linux.dev header.b=tcdda1E5; arc=none smtp.client-ip=95.215.58.1
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.dev
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.dev header.i=@linux.dev header.b="tcdda1E5"
X-Envelope-To: lvs-devel@vger.kernel.org
DKIM-Signature: a=rsa-sha256; bh=g9e/2IEJIPYCeLdiO80dbyVvZLVMyX1DLQvRmaTotn0=;
 c=simple/simple; d=linux.dev;
 h=from:to:subject:date:message-id:mime-version:content-type; s=key1;
 t=1789911340; v=1; x=1790516140;
 b=tcdda1E5uMkw70YLiiXXWV64xj9d2qaLpcVXGMQYRrBpMmMxX2pFfMaHtWR7ifqZlGvXw5/8
 Y9d+xWOEK8kXXIco7e+zlDU5RHrWY3Y8MICKmnCBCEsUdIyd7fSu2OEhSZYByqE6feMzRKwEbdh
 pJOHOJNyFhDpC57VreYh/ROg=
X-Envelope-To: lvs-devel@vger.kernel.org
Received: by smtp.migadu.com with ESMTPS id 9a763997ddf6773c;
	Sun, 20 Sep 2026 13:35:40 +0000
X-Mizu-Trace-ID: 9a763997ddf6773c
X-Migadu-Flow: FLOW_OUT
Message-ID: <b2a1cc29-74ef-48e4-bd41-283279f2f670@linux.dev>
Date: Sun, 20 Sep 2026 21:35:30 +0800
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH net 0/1] ipvs: bound twos scheduler destination walks
To: Julian Anastasov <ja@ssi.bg>, Yuan Tan <yuant@nebusec.ai>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
 Simon Horman <horms@verge.net.au>, pablo@netfilter.org, fw@strlen.de,
 phil@nwl.cc, darby.payne@gmail.com, zzyy19904204639@163.com,
 Ren Wei <weir@nebusec.ai>
References: <cover.1789117690.git.zzyy19904204639@163.com>
 <861399d8-c71f-6589-d4cd-3549d9c5bc00@ssi.bg>
 <d8aab597-62b5-444a-a6cf-efd2642d9a81@linux.dev>
 <bfdbe9ba-f213-64e9-668d-e951aa0c2863@ssi.bg>
 <f04216a2-263a-4e2d-9641-5be0fe4c766f@nebusec.ai>
 <d000dd3a-0e8e-5b04-4642-fc1be0ffedaf@ssi.bg>
From: Jiayuan Chen <jiayuan.chen@linux.dev>
In-Reply-To: <d000dd3a-0e8e-5b04-4642-fc1be0ffedaf@ssi.bg>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit


On 9/20/26 9:19 PM, Julian Anastasov wrote:
> 	Hello,
>
> On Sat, 19 Sep 2026, Yuan Tan wrote:
>
>> On 9/17/26 13:06, Julian Anastasov wrote:
>>> On Thu, 17 Sep 2026, Jiayuan Chen wrote:
>>>
>>>> On 9/15/26 2:01 AM, Julian Anastasov wrote:
>>>>> 	I assume the problem is caused by the dest_trash.
>>>>> It seems, we need a general solution to this problem.
>>>>> One option is to penalize with synchronize_rcu() if we detect
>>>>> dest that is reused too soon. But even that looks complex to
>>>>> implement.
>>>> I think we can use pair(get_state_synchronize_rcu, cond_synchronize_rcu)
>>>> instead.
>>>> For 'ipvsadm -C && ipvsadm -R', synchronize_rcu is only called once.
>>>>
>>>>
>>>>  From ccbb304ab17e00849ea0bf31582d384e6b2768ba Mon Sep 10 00:00:00 2001
>>>> From: Jiayuan Chen <jiayuan.chen@linux.dev>
>>>> Date: Thu, 10 Sep 2026 19:36:57 +0800
>>>> Subject: [PATCH] ipvs: wait for readers before reusing dest from trash
>>>>
>>>> __ip_vs_unlink_dest() and ip_vs_rs_unhash() remove the dest with
>>>> list_del_rcu()/hlist_del_rcu(), so readers can still be on it. If
>>>> ip_vs_add_dest() picks the same dest from trash right away,
>>>> __ip_vs_update_dest() links it into another service and rs_table,
>>>> and those readers follow the new next pointers into a different
>>>> list.
>>>>
>>>> A synchronize_rcu() on the delete side costs one grace period per
>>>> dest, which makes 'ipvsadm -C' with many real servers very slow.
>>>> Doing it on the reuse side has the same problem with 'ipvsadm -R'.
>>>> So record a grace period cookie when the dest goes to trash and use
>>>> cond_synchronize_rcu() on reuse. The first wait covers every dest
>>>> trashed before it, so a full restore waits at most once.
>>>>
>>>> Fixes: bcbde4c0a755 ("ipvs: make the service replacement more robust")
>>>> Signed-off-by: Jiayuan Chen <jiayuan.chen@linux.dev>
>>>> ---
>>>>   include/net/ip_vs.h            | 1 +
>>>>   net/netfilter/ipvs/ip_vs_ctl.c | 6 ++++++
>>>>   2 files changed, 7 insertions(+)
>>>>
>>>> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
>>>> index 32fde731bceb..81b7600ac959 100644
>>>> --- a/include/net/ip_vs.h
>>>> +++ b/include/net/ip_vs.h
>>>> @@ -1013,6 +1013,7 @@ struct ip_vs_dest {
>>>>
>>>>       struct rcu_head        rcu_head;
>>>>       struct list_head    t_list;        /* in dest_trash */
>>>> +    unsigned long        rcu_state;    /* GP cookie when trashed */
>>>>       unsigned int        in_rs_table:1;    /* we are in rs_table */
>>>>   };
>>>>
>>>> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
>>>> index 4c1c739446b7..99da7b74500f 100644
>>>> --- a/net/netfilter/ipvs/ip_vs_ctl.c
>>>> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
>>>> @@ -1159,6 +1159,7 @@ static void ip_vs_trash_put_dest(struct netns_ipvs
>>>> *ipvs,
>>>>       /* dest lives in trash with reference */
>>>>       list_add(&dest->t_list, &ipvs->dest_trash);
>>>>       dest->idle_start = istart;
>>>> +    dest->rcu_state = get_state_synchronize_rcu();
>>>>       spin_unlock_bh(&ipvs->dest_trash_lock);
>>>>   }
>>>>
>>>> @@ -1566,6 +1567,11 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct
>>>> ip_vs_dest_user_kern *udest)
>>>>                     IP_VS_DBG_ADDR(svc->af, &dest->vaddr),
>>>>                     ntohs(dest->vport));
>>>>
>>>> +        /* Readers may still follow n_list/d_list of the unlinked
>>>> +         * dest, wait before linking it again.
>>>> +         */
>>>> +        cond_synchronize_rcu(dest->rcu_state);
>>>> +
>>>>           ret = ip_vs_start_estimator(svc->ipvs, &dest->stats);
>>>>           /* On error put back dest into the trash */
>>>>           if (ret < 0)
>>>> --
>>>> 2.43.0
>>> 	Very good solution, indeed. But it needed some tuning
>>> and some other problems need to be solved:
>>>
>>> - if dest is edited and the dest tunnel parameters changed
>>> this leads to rehashing and a forced synchronize_rcu(). If
>>> many dests are changed in this way - we got a coffee time...
>>>
>>> - dest can be put back into dest_trash, so we do not need to
>>> update the rcu_state for this case
>>>
>>> - use single temp list dest_trash to speedup the deleting of
>>> service (with many dests) and the service flush (many services with
>>> many dests) by using single get_state_synchronize_rcu (which has
>>> full memory barrier) and by splicing the temp list with all
>>> deleted dests into the public dest_trash list by using single
>>> spin lock (ip_vs_trash_put_dests call).
>>>
>>> 	This is only compile-tested and I hope it can survive
>>> the flood tests that break the "two" scheduler lookups...
>>
>> Hi Julian and Jiayuan,
>>
>> Vega team here. I am wondering what would be the best way to move this
>> fix forward?
> 	We have 2 options:
>
> 1. Jiayuan to modify his patch at least to cover the problem
> with returned dest back in trash:
>
> - get_state_synchronize_rcu() can not be in ip_vs_trash_put_dest()
> but only after the 2nd call
>
> - cond_synchronize_rcu() should be moved before __ip_vs_update_dest()
> as in my patch
>
> - then my v2 patch will be on top of his patch
>
> 	We should present them for AI reviews together,
> in same patchset, I guess.
>
> 2. I can post my change after adding a proper commit
> message (Co-developed-by, etc), then it can be attached as
> 1/1 to your modified 0/1 problem report
>
> 	I'll wait Jiayuan's decision.


Feel free to take any further action  :)

I just gave my idea and hope anyone can be inspired by this.


>> Would you prefer Darong to test Julian's version and send a v2,
> 	Yes, I rely on your very good test tools :) You can test
> the already posted version or the next one we are discussing to
> submit.
>
>> crediting both of you with Suggested-by or Co-developed-by tags?
>>
>> Alternatively, if either of you would prefer to submit the patch, please
>> include:
>>
>> Reported-by: Vega vega@nebusec.ai <mailto:vega@nebusec.ai>
>> Reported-by: Darong Lu zzyy19904204639@163.com
>> <mailto:zzyy19904204639@163.com>
> 	Sure
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
