Received: from mail-dy2-f41.google.com (mail-dy2-f41.google.com [74.125.229.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3C8A9383323
	for <lvs-devel@vger.kernel.org>; Sat, 26 Sep 2026 17:51:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.229.41
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790445101; cv=none; b=kNj+DEZtr2Vb34cOeujMj3WiLo8uQFNE5lpy3+vQesNChfYfYvPQVP8gWrqHFN61tyWbHwdAJYacahAEqGAds+Ds4sVtY1FNiEyI3/1CIUO3LQPJqOM2sd0+3BhyCheZAfBs5P7OJWAnMwWbPDDQ6CnT8894SjcQBie4MTayqug=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790445101; c=relaxed/simple;
	bh=EmUMS+ZRzCUeb0rndVpz/BHk6ngRvxk7aEnRstACYI0=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=NgTPOk27q8YtUr9v9ss/ZIW25KCEqR9Btbv5V1lIrciYX1cMogzww/XS+cxmw3kb79lOfX6tl++mnC3a73gWEkWBS6PeaY4yFW6i1CsXrZ+oiF6Mq3lXWFxlcrCcK8N4sHzJ/cTd9njS59eY6NRnRBBJwKl6odvK9DRFgKIOzc8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=jiCtCpt4; arc=none smtp.client-ip=74.125.229.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jiCtCpt4"
Received: by mail-dy2-f41.google.com with SMTP id 5a478bee46e88-344213c95bdso3073eec.2
        for <lvs-devel@vger.kernel.org>; Sat, 26 Sep 2026 10:51:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790445098; x=1791049898; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=kh+HhJ5EU4L73Wf3xyAcV+eWsVVzfBMuFzfcoxTkNvA=;
        b=jiCtCpt4vnJnOA8DpIpxUf0gq1glcMmuVGBKTFxetlmQ+0ybEnHVCNsN+BLRSLvx9q
         fYG8ZEy7pWci1/qQ3B1ofb22WapqefvEFIlkaO4jR9oHoUdV1JQxdyn5CEmbLIjG3o8M
         1k/W27mMNFIXm4l4lQrxNdNZ0IpaSozk4jP9PKZBFUiWEdeBjU2YVwa8PCFZfSoAoY6a
         /7VnqfZpwIWQLYxhHJ1A0uBIWF7nnBSdRpKzIEw//b3ot8KBQLSv2x1fFT/5sIpFBvjY
         cz4Q1txOOqmEWw449KGmcH6UG/wcDZdFlXfi4rXAdFUXsdnQkgpR1RNkO451zujkwP+E
         9WRQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790445098; x=1791049898;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=kh+HhJ5EU4L73Wf3xyAcV+eWsVVzfBMuFzfcoxTkNvA=;
        b=O7Gbu/Bu8AyFnsRei2LoUBlBFi2G9bOSod4HOpaxsWIYwspxm1e2O8ookzDx+wmwHG
         UzuzcL3ceVbnBmRw3KVJmToO9pSOnSIdpN1xx+LDBQlT8wopVUwVjx9QQV/kqWwd433u
         ur2HJfPYu1rF74JvnbAF3S6G14STxvQc+Cfl3gsCMBwkvu5ui09ax6aAyQD7skQaqrsd
         vh1sjAhidicw8fUy1qlAXtna3pBxYb3NC2Eh1dzELsT48yzCA5e9zVXf3kgsJcbc9Ywg
         ePMiy07nWMGFodUU17zyqx8fu7Ruz5P4ZZgjNTuDBn0GMQAdbnOFaKR0tO/qZiDKdsJ/
         wL5g==
X-Forwarded-Encrypted: i=1; AKwUvBwgkWgN3NqucT8kQpRRmDtbpyNzUIluEoVEvyUsLaxnYInytoWgBeJev6b86MwXFcQZpA1qHG4Y9Fc=@vger.kernel.org
X-Gm-Message-State: AFq9FYIANN7NbTnRk4LE5JbxpUt7kclJtF+pQtumDBbAttTbP2jRhIba
	8DDS6aYWG3QRu+nPx4x5Ry8+6Wu3v8/SuKWuIQYhPV3PeB9usGND25Oy
X-Gm-Gg: AYBFou1w1IsFK+lglRtbJiPpT3TtWQH7EdX5AjUPhsbzQErDtQjd+8hWaQtKfqxEgki
	JsJJPDJhNnk/x/8STBU47BSUT7utQjt9+/1pueRoTIBedpc2qGGpzzKPEfEukwMmD8GsVBgVMgg
	TVY3oTDZgCf2lCEoAFhxPJDmMP3qAy+U1y+B4Ax11FbkXImvNxbMZhoKpjVxkExprWyOgh1YIk2
	f3bDqAAEBB55UOMFLeSEpz552otI7EY3uYaPBfmg3FUFFePZQsCVgX11D/LJGG/ZMXYKbJTzBme
	v7cvM1CMnNn4c8T9zCpvOl0z8lTSxx3MW1aDwH0a2Kxgj/rOQE4twSLPIN8JLndGrAOQg/pKiQC
	RM/eDr5+0yHrqpRidvjnnCP+pithHZe6AdeGO/UTnFhG7HrzURYQR1ewwgqDoL7fCSx33ZXo1zJ
	bBW9VdSO6abbe11cCmOdgjQuU4LrFRzPDxe2bMpqznUuRDwWjS+0sNVTGq/+RRxVnm7cyV3zGu5
	YqmHpc/Od2g1adB2SuYanrhdxovaYuxfECk+SC3cYi1UjBr6UuXUhmkey1BSqoegcO2sA==
X-Received: by 2002:a05:7301:540e:b0:33c:1bd2:1db6 with SMTP id 5a478bee46e88-3426d0df371mr5641086eec.0.1790445096797;
        Sat, 26 Sep 2026 10:51:36 -0700 (PDT)
Received: from localhost.localdomain (95.169.12.199.16clouds.com. [95.169.12.199])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-341459234a1sm15872673eec.24.2026.09.26.10.51.32
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 26 Sep 2026 10:51:36 -0700 (PDT)
From: Chengfeng Ye <nicoyip.dev@gmail.com>
To: Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	Phil Sutter <phil@nwl.cc>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>
Cc: netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org,
	linux-kernel@vger.kernel.org,
	Chengfeng Ye <nicoyip.dev@gmail.com>,
	stable@vger.kernel.org
Subject: [PATCH net] ipvs: Defer application parent freeing until after RCU readers
Date: Sun, 27 Sep 2026 01:51:29 +0800
Message-ID: <20260926175129.2612644-1-nicoyip.dev@gmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

unregister_ip_vs_app() removes each incarnation from its protocol list and
uses call_rcu() to defer freeing it, but frees the parent application
immediately. An RCU reader that already found an incarnation can still
access the parent through inc->app in ip_vs_app_inc_get().

During FTP helper module unload, the following interleaving is possible:

  CPU 0 (RCU reader)                 CPU 1 (module unload)
  tcp_app_conn_bind()
    find inc in protocol list
                                     unregister_ip_vs_app()
                                       ip_vs_app_inc_release(inc)
                                         list_del_rcu(&inc->p_list)
                                         call_rcu(&inc->rcu_head, ...)
                                       kfree(a)
    ip_vs_app_inc_get(inc)
      try_module_get(inc->app->module)

The helper module is already going away, so try_module_get() would fail,
but evaluating its argument first reads the freed parent. The subsequent
rcu_barrier() in pernet unregistration cannot protect this earlier free.
KASAN reported:

  BUG: KASAN: slab-use-after-free in ip_vs_app_inc_get+0x7c/0x90
  Call Trace:
   ip_vs_app_inc_get+0x7c/0x90
   tcp_app_conn_bind+0x1bc/0x290
   ip_vs_conn_new+0x1915/0x20d0
   ip_vs_schedule+0x697/0xea0
   tcp_conn_schedule+0x489/0x820
   ip_vs_in_hook+0x7bf/0x1f40
  Allocated by task 88:
   kmemdup_noprof+0x20/0x50
   register_ip_vs_app+0x12d/0x2c0
   __ip_vs_ftp_init+0x56/0x160 [ip_vs_ftp]
  Freed by task 104:
   kfree+0x131/0x3c0
   unregister_ip_vs_app+0x2f4/0x5b0
   unregister_pernet_operations+0x232/0x490
   unregister_pernet_subsys+0x1c/0x30
   __do_sys_delete_module+0x346/0x510

Use kfree_rcu() with the existing rcu_head to keep the parent alive until
these readers finish. Successful helper references already prevent normal
module unload, and incarnation RCU callbacks do not access the parent.

Fixes: 363c97d7435e ("ipvs: convert app locks")
Cc: stable@vger.kernel.org
Signed-off-by: Chengfeng Ye <nicoyip.dev@gmail.com>
---
 net/netfilter/ipvs/ip_vs_app.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
index 11cbdbaf561d..2c1b47702da2 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
@@ -242,7 +242,7 @@ void unregister_ip_vs_app(struct netns_ipvs *ipvs, struct ip_vs_app *app)
 		}
 
 		list_del(&a->a_list);
-		kfree(a);
+		kfree_rcu(a, rcu_head);
 
 		/* decrease the module use count */
 		ip_vs_use_count_dec();
-- 
2.43.0

