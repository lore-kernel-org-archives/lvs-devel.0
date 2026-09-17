Received: from mta0.migadu.com (out-212.mta0.migadu.com [91.218.175.212])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C4EA04FB9D1
	for <lvs-devel@vger.kernel.org>; Thu, 17 Sep 2026 12:42:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=91.218.175.212
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789648939; cv=none; b=FAcmzaMp2+JRjZT2OtOxzmNHYr38dclORN+5+o9HxEjngABTx/5rVg6CXL4Snt+lQNsHP3K2dDs8/PSLRvE2YMWx4xy2M9xqHdi8rYfXbXNXNi2kCaFe5Yro2bGH0yhEJBP0wAPw2wIqMeurmZKwMXmVeOfyhmQ3BdQWNjVDgdk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789648939; c=relaxed/simple;
	bh=X8Rwlaxr4CS6AlKne4l5YvG9acTFvMARS52buVLDJkc=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=RKyNYmlpBxgBLt+JI9p08GqOhlu03/wRwaaQQNt+21NtDR5Hv3CZykDC/7HflozIzwKZ0tJzL5wZ4L8yWfNJVcrDIJxlda0FA2h2Wcwm6Q+TusyFF8hvxZTmsWtr4UyWUAx988fhAmr7OKMaFfgeaRaXM+bNNoQKui3kdamRGjY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev; spf=pass smtp.mailfrom=linux.dev; dkim=pass (1024-bit key) header.d=linux.dev header.i=@linux.dev header.b=EW81XCCg; arc=none smtp.client-ip=91.218.175.212
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.dev
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.dev header.i=@linux.dev header.b="EW81XCCg"
X-Envelope-To: lvs-devel@vger.kernel.org
DKIM-Signature: a=rsa-sha256; bh=X8Rwlaxr4CS6AlKne4l5YvG9acTFvMARS52buVLDJkc=;
 c=simple/simple; d=linux.dev;
 h=from:to:subject:date:message-id:mime-version:content-type; s=key1;
 t=1789648925; v=1; x=1790253725;
 b=EW81XCCgZztRTCOltDEWCw8Cc0KxcSLE4MyIP4IIP8iiv2Lym1NoEx5IRN+PfVEcfL9fgSka
 KkFMY/QLtPFW0Gm89+CE0ugrKa09an79zPMdshPs6rYBNgnezo+xSaP6yi1wUG/3mY4RAAPPI1n
 nPBDQYKaqy8+7CiTixihgH30=
X-Envelope-To: lvs-devel@vger.kernel.org
Received: by smtp.migadu.com with ESMTPS id 7678bcde10ec6b73;
	Thu, 17 Sep 2026 12:42:05 +0000
X-Mizu-Trace-ID: 7678bcde10ec6b73
X-Migadu-Flow: FLOW_OUT
Message-ID: <d8aab597-62b5-444a-a6cf-efd2642d9a81@linux.dev>
Date: Thu, 17 Sep 2026 20:42:00 +0800
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH net 0/1] ipvs: bound twos scheduler destination walks
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
 Simon Horman <horms@verge.net.au>, pablo@netfilter.org, fw@strlen.de,
 phil@nwl.cc, darby.payne@gmail.com, vega@nebusec.ai, zzyy19904204639@163.com
References: <cover.1789117690.git.zzyy19904204639@163.com>
 <861399d8-c71f-6589-d4cd-3549d9c5bc00@ssi.bg>
From: Jiayuan Chen <jiayuan.chen@linux.dev>
In-Reply-To: <861399d8-c71f-6589-d4cd-3549d9c5bc00@ssi.bg>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit


On 9/15/26 2:01 AM, Julian Anastasov wrote:
> 	Hello,
>
> On Sun, 13 Sep 2026, Ren Wei wrote:
>
>> From: Darong Lu <zzyy19904204639@163.com>


[...]

>> The root cause is that both walks are unbounded. If the iterator follows a
>> reused list entry, it can continue walking indefinitely and prevent the
>> scheduler from returning. The fix reads the service destination count before
>> each walk and stops after that many entries, while preserving the existing
>> scheduler algorithm and RCU list traversal.
> 	I'm trying to understand how the iterator can be
> tricked to loop forever: to loop, it should never reach
> &svc->destinations, so it must walk unlinked nodes which
> create some loop between them. But READ_ONCE soon or later
> will read actual ptr from memory, so it should reach to
> &svc->destinations. We know that entries end up in reverse
> order in the list after they are added but how looks the
> list that causes the loop?
>
> 	OTOH, I don't understand why we need two full lookups to
> trigger the problem, can it happen with one list_for? Other
> schedulers also walk the list twice, for example, RR remembers
> previous position.
>
> 	I assume the problem is caused by the dest_trash.
> It seems, we need a general solution to this problem.
> One option is to penalize with synchronize_rcu() if we detect
> dest that is reused too soon. But even that looks complex to
> implement.


I think we can use pair(get_state_synchronize_rcu, cond_synchronize_rcu) 
instead.
For 'ipvsadm -C && ipvsadm -R', synchronize_rcu is only called once.


 From ccbb304ab17e00849ea0bf31582d384e6b2768ba Mon Sep 10 00:00:00 2001
From: Jiayuan Chen <jiayuan.chen@linux.dev>
Date: Thu, 10 Sep 2026 19:36:57 +0800
Subject: [PATCH] ipvs: wait for readers before reusing dest from trash

__ip_vs_unlink_dest() and ip_vs_rs_unhash() remove the dest with
list_del_rcu()/hlist_del_rcu(), so readers can still be on it. If
ip_vs_add_dest() picks the same dest from trash right away,
__ip_vs_update_dest() links it into another service and rs_table,
and those readers follow the new next pointers into a different
list.

A synchronize_rcu() on the delete side costs one grace period per
dest, which makes 'ipvsadm -C' with many real servers very slow.
Doing it on the reuse side has the same problem with 'ipvsadm -R'.
So record a grace period cookie when the dest goes to trash and use
cond_synchronize_rcu() on reuse. The first wait covers every dest
trashed before it, so a full restore waits at most once.

Fixes: bcbde4c0a755 ("ipvs: make the service replacement more robust")
Signed-off-by: Jiayuan Chen <jiayuan.chen@linux.dev>
---
  include/net/ip_vs.h            | 1 +
  net/netfilter/ipvs/ip_vs_ctl.c | 6 ++++++
  2 files changed, 7 insertions(+)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 32fde731bceb..81b7600ac959 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1013,6 +1013,7 @@ struct ip_vs_dest {

      struct rcu_head        rcu_head;
      struct list_head    t_list;        /* in dest_trash */
+    unsigned long        rcu_state;    /* GP cookie when trashed */
      unsigned int        in_rs_table:1;    /* we are in rs_table */
  };

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 4c1c739446b7..99da7b74500f 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1159,6 +1159,7 @@ static void ip_vs_trash_put_dest(struct netns_ipvs 
*ipvs,
      /* dest lives in trash with reference */
      list_add(&dest->t_list, &ipvs->dest_trash);
      dest->idle_start = istart;
+    dest->rcu_state = get_state_synchronize_rcu();
      spin_unlock_bh(&ipvs->dest_trash_lock);
  }

@@ -1566,6 +1567,11 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct 
ip_vs_dest_user_kern *udest)
                    IP_VS_DBG_ADDR(svc->af, &dest->vaddr),
                    ntohs(dest->vport));

+        /* Readers may still follow n_list/d_list of the unlinked
+         * dest, wait before linking it again.
+         */
+        cond_synchronize_rcu(dest->rcu_state);
+
          ret = ip_vs_start_estimator(svc->ipvs, &dest->stats);
          /* On error put back dest into the trash */
          if (ret < 0)
--
2.43.0

