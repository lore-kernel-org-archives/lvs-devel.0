Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=115.124.30.100
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794459290;
	b=4iNhu42vX0R+msbksGQWM0qmDU1gaA/8tO46AICAc4mqlXKwYRm12SBBCFdW3Ydrtl28
	 JEUlRqcB/GkJ3BN74utxjOqZTxb9+aj9JIpHHrHWpwsAOJnndkkwWTCXFGyvJFffIeehI
	 gekOauXfJ7zV3Z7VRRzhwwXrmwGa+1mwHo8AQdBd7sZVZSyCHUMNB1AdNFxs484YlqpAH
	 qSDMMCD8A9dEY++iZkHqEnlTQi8MEDTaGrkp5EBCBhG3+q7K/hFgiOUd66lTHaUV7MAVH
	 6PAR1ZMA3+5sqO6cFOH+y5v0sLpZvZ0JUnE0G0yMOWQquCF+/8QXHU2pFu6w0slo6rQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794459290;
	h=DMARC-Filter:DKIM-Signature:X-Alimail-AntiSpam:Received:Date:From:To:
	 Cc:Subject:Message-ID:Reply-To:References:MIME-Version:Content-Type:
	 Content-Disposition:In-Reply-To;
	bh=/V28rCHXi3T9oO9LFCn5sfVOcz0zmvubCJbcVebXDxQ=;
	b=xEHiGJOb9wMcknM/xQqVA+uG6A8Dw1YzVX26qlYAbMjn4oioog3Mr3AAKT08BzbQoPlm
	 e4OxRa1wKaPDLNWamivJj3958wPNvpfHxAP5PxeVSkECNXrHj2oaV/4/lAcCdMRexkeTL
	 X0FThaqeWpQgmrzDoL3pFzhKNHmoVMUP5vmAd9pZxc8sa/B+aEOPL4ZrFGXYGhwHmntJs
	 X5hn1wYLE0pkULJeQ3gbW4FqosCURDlMCm0jKcWUUhUDbJTt+ULk7cXmLAc7lHINhDuGf
	 f8vZSxmm4Eiwpdkimfi00q9bVb/kT200z+62eU59VqS4jJXdgCjPqorqoo3DXRn/iZw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=linux.alibaba.com;
	spf=pass smtp.mailfrom=linux.alibaba.com;
	dkim=pass header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=MXltY6b0;
	arc=none smtp.remote-ip=115.124.30.100
Received: from out30-100.freemail.mail.aliyun.com (out30-100.freemail.mail.aliyun.com [115.124.30.100])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9FBCB606A32A;
	Thu, 12 Nov 2026 04:54:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 9FBCB606A32A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=MXltY6b0
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1794459284; h=Date:From:To:Subject:Message-ID:MIME-Version:Content-Type;
	bh=/V28rCHXi3T9oO9LFCn5sfVOcz0zmvubCJbcVebXDxQ=;
	b=MXltY6b02zxJBPSSJCcrFOFIVlsBPwa+MF+BOn7nVcYMoHG/lR/idyOofAtP+7o28bmnleqYQobOuF1X03XhPFzpBC/hqZgH8dTQlrXbc1lMAFQJxWEzyBHEg4X9w+v0wAMn3OjhU+vlgQS7hHIJLJYkmTvC3eWmg5pBomYYpaY=
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R151e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=maildocker-contentspam011083073210;MF=dust.li@linux.alibaba.com;NM=1;PH=DS;RN=37;SR=0;TI=SMTPD_---0XEaoXEq_1794459281;
Received: from localhost(mailfrom:dust.li@linux.alibaba.com fp:SMTPD_---0XEaoXEq_1794459281 cluster:ay36)
          by smtp.aliyun-inc.com;
          Thu, 12 Nov 2026 12:54:41 +0800
Date: Thu, 12 Nov 2026 12:54:41 +0800
From: Dust Li <dust.li@linux.alibaba.com>
To: Jiayuan Chen <jiayuan.chen@linux.dev>, netdev@vger.kernel.org
Cc: David Ahern <dsahern@kernel.org>, Ido Schimmel <idosch@nvidia.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@kernel.org>,
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
	Simon Horman <horms@kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	Paul Moore <paul@paul-moore.com>,
	Matthieu Baerts <matttbe@kernel.org>,
	Mat Martineau <martineau@kernel.org>,
	Geliang Tang <geliang@kernel.org>, Julian Anastasov <ja@ssi.bg>,
	Allison Henderson <achender@kernel.org>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Xin Long <lucien.xin@gmail.com>,
	"D. Wythe" <alibuda@linux.alibaba.com>,
	Sidraya Jayagond <sidraya@linux.ibm.com>,
	Mahanta Jambigi <mjambigi@linux.ibm.com>,
	Tony Lu <tonylu@linux.alibaba.com>,
	Wen Gu <guwen@linux.alibaba.com>, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	bridge@lists.linux.dev, linux-security-module@vger.kernel.org,
	mptcp@lists.linux.dev, lvs-devel@vger.kernel.org,
	linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
	linux-sctp@vger.kernel.org, linux-s390@vger.kernel.org
Subject: Re: [PATCH net-next 12/14] net/smc: annotate data-races around smc
 sysctls
Message-ID: <avVGkcI_j0hDPjQB@linux.alibaba.com>
Reply-To: dust.li@linux.alibaba.com
References: <20261109025425.328445-1-jiayuan.chen@linux.dev>
 <20261109025425.328445-13-jiayuan.chen@linux.dev>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261109025425.328445-13-jiayuan.chen@linux.dev>

On 2026-11-09 10:52:11, Jiayuan Chen wrote:
>autocorking_size, smcr_buf_type, smcr_max_links_per_lgr,
>smcr_max_conns_per_lgr and limit_smc_hs are read without any lock while
>their sysctl handlers update them with WRITE_ONCE(), and the SMC netlink
>handlers toggle limit_smc_hs with plain writes. Add READ_ONCE() to the
>readers and WRITE_ONCE() to those handlers.
>
>Signed-off-by: Jiayuan Chen <jiayuan.chen@linux.dev>
Acked-by: Dust Li <dust.li@linux.alibaba.com>

Best regards,
Dust

>---
> net/smc/af_smc.c   | 8 ++++----
> net/smc/smc_clc.c  | 8 ++++----
> net/smc/smc_core.c | 2 +-
> net/smc/smc_tx.c   | 2 +-
> 4 files changed, 10 insertions(+), 10 deletions(-)
>
>diff --git a/net/smc/af_smc.c b/net/smc/af_smc.c
>index d10244af5bd29..9a657172be8f9 100644
>--- a/net/smc/af_smc.c
>+++ b/net/smc/af_smc.c
>@@ -88,7 +88,7 @@ int smc_nl_dump_hs_limitation(struct sk_buff *skb, struct netlink_callback *cb)
> 		return -ENOMEM;
> 
> 	if (nla_put_u8(skb, SMC_NLA_HS_LIMITATION_ENABLED,
>-		       sock_net(skb->sk)->smc.limit_smc_hs))
>+		       READ_ONCE(sock_net(skb->sk)->smc.limit_smc_hs)))
> 		goto err;
> 
> 	genlmsg_end(skb, hdr);
>@@ -102,13 +102,13 @@ int smc_nl_dump_hs_limitation(struct sk_buff *skb, struct netlink_callback *cb)
> 
> int smc_nl_enable_hs_limitation(struct sk_buff *skb, struct genl_info *info)
> {
>-	sock_net(skb->sk)->smc.limit_smc_hs = true;
>+	WRITE_ONCE(sock_net(skb->sk)->smc.limit_smc_hs, true);
> 	return 0;
> }
> 
> int smc_nl_disable_hs_limitation(struct sk_buff *skb, struct genl_info *info)
> {
>-	sock_net(skb->sk)->smc.limit_smc_hs = false;
>+	WRITE_ONCE(sock_net(skb->sk)->smc.limit_smc_hs, false);
> 	return 0;
> }
> 
>@@ -411,7 +411,7 @@ void smc_sk_init(struct net *net, struct sock *sk, int protocol)
> 	spin_lock_init(&smc->conn.send_lock);
> 	mutex_init(&smc->clcsock_release_lock);
> 	smc_init_saved_callbacks(smc);
>-	smc->limit_smc_hs = net->smc.limit_smc_hs;
>+	smc->limit_smc_hs = READ_ONCE(net->smc.limit_smc_hs);
> 	smc->use_fallback = false; /* assume rdma capability first */
> 	smc->fallback_rsn = 0;
> 	smc_close_init(smc);
>diff --git a/net/smc/smc_clc.c b/net/smc/smc_clc.c
>index 014d527d5462d..df0afeef67cbd 100644
>--- a/net/smc/smc_clc.c
>+++ b/net/smc/smc_clc.c
>@@ -990,8 +990,8 @@ int smc_clc_send_proposal(struct smc_sock *smc, struct smc_init_info *ini)
> 	}
> 	if (smcr_indicated(ini->smc_type_v2)) {
> 		memcpy(v2_ext->roce, ini->smcrv2.ib_gid_v2, SMC_GID_SIZE);
>-		v2_ext->max_conns = net->smc.sysctl_max_conns_per_lgr;
>-		v2_ext->max_links = net->smc.sysctl_max_links_per_lgr;
>+		v2_ext->max_conns = READ_ONCE(net->smc.sysctl_max_conns_per_lgr);
>+		v2_ext->max_links = READ_ONCE(net->smc.sysctl_max_links_per_lgr);
> 	}
> 
> 	pclc_base->hdr.length = htons(plen);
>@@ -1272,12 +1272,12 @@ int smc_clc_srv_v2x_features_validate(struct smc_sock *smc,
> 
> 	if (ini->smcr_version & SMC_V2) {
> 		ini->max_conns = min_t(u8, pclc_v2_ext->max_conns,
>-				       net->smc.sysctl_max_conns_per_lgr);
>+				       READ_ONCE(net->smc.sysctl_max_conns_per_lgr));
> 		if (ini->max_conns < SMC_CONN_PER_LGR_MIN)
> 			return SMC_CLC_DECL_MAXCONNERR;
> 
> 		ini->max_links = min_t(u8, pclc_v2_ext->max_links,
>-				       net->smc.sysctl_max_links_per_lgr);
>+				       READ_ONCE(net->smc.sysctl_max_links_per_lgr));
> 		if (ini->max_links < SMC_LINKS_ADD_LNK_MIN)
> 			return SMC_CLC_DECL_MAXLINKERR;
> 	}
>diff --git a/net/smc/smc_core.c b/net/smc/smc_core.c
>index 6021322253e93..3d338019a1b8b 100644
>--- a/net/smc/smc_core.c
>+++ b/net/smc/smc_core.c
>@@ -990,7 +990,7 @@ static int smc_lgr_create(struct smc_sock *smc, struct smc_init_info *ini)
> 		lgr->net = smc_ib_net(lnk->smcibdev);
> 		lgr_list = &smc_lgr_list.list;
> 		lgr_lock = &smc_lgr_list.lock;
>-		lgr->buf_type = lgr->net->smc.sysctl_smcr_buf_type;
>+		lgr->buf_type = READ_ONCE(lgr->net->smc.sysctl_smcr_buf_type);
> 		atomic_inc(&lgr_cnt);
> 	}
> 	smc->conn.lgr = lgr;
>diff --git a/net/smc/smc_tx.c b/net/smc/smc_tx.c
>index 0f0c6df3bf2ce..30bffe79d06a3 100644
>--- a/net/smc/smc_tx.c
>+++ b/net/smc/smc_tx.c
>@@ -148,7 +148,7 @@ static bool smc_should_autocork(struct smc_sock *smc)
> 	int corking_size;
> 
> 	corking_size = min_t(unsigned int, conn->sndbuf_desc->len >> 1,
>-			     sock_net(&smc->sk)->smc.sysctl_autocorking_size);
>+			     READ_ONCE(sock_net(&smc->sk)->smc.sysctl_autocorking_size));
> 
> 	if (atomic_read(&conn->cdc_pend_tx_wr) == 0 ||
> 	    smc_tx_prepared_sends(conn) > corking_size)
>-- 
>2.43.0
