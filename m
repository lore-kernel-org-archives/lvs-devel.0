Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9BF802EF64F;
	Wed,  8 Jul 2026 15:53:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783526018; cv=none; b=pbZ4bRdG/v28OFSp3j3Ij3QI9Zp47TxmDL1BpF2ulQz2mSN+qvCSrMAFGrdxoS0d0euG7msGMXsDTr7zv9v8wmiAm2ug8aJEmXY3T5iMYGskxe/3LbxS5PTrHj+ru+aK2Meywb1Cyc/BO/zzKR2v/QBQnkNw7XJE7k8aW7a/XEU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783526018; c=relaxed/simple;
	bh=0Mge3JAgIP+E0X+MesrXp8TixEJc4l6be13natFqp4w=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=Vz2cXP7C18vlqqBWxHH8mlE9JQuD1yv1UeLXYZXt0g90wwcAOi1936iVEEpWcgc6FlUlqZlbJ3D2/+iFNRewsgnXJDvfEdPGQPFDE5pnfd/4l21PcqFhq/j208XTpmIH4rdO2IbGcn/9gwNCMwzYJEhdwKlnhSR9CYQ0kBpaJbY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=rGhaM8I/; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="rGhaM8I/"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id C88EE20252;
	Wed, 08 Jul 2026 18:53:32 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=IrBFyo4X9p4vQcBuAXEscbyeWrGozHn+zcsBI+OqvLA=; b=rGhaM8I/EwgW
	HvSp6hduo21Rar8HkjRO+WuJ2VuHDC7d9dlomU8UF5YtzUV0ZLUBZ4BDZ08MF/w0
	QJ7eBHhkZ2e1NoYOCraLJ3pYyMxAKJ5BcMYPOQg806+fBw5l5XpfcrW5dwNDch6u
	1VC8zjSgewpLyAqLebPHaAlK+2c69PL+0FXofnBLcK5lSGeQl8I+47LGd2CywkeP
	rDOM3CO93CCJk8z73uWAATYexH7/Um7MV5KmHhEEk8buXJ5MwjYPByGVNGabhuVn
	bgs30xxlohn3+P/jo2HLU6Dvbk1OwD3Eqa8gfi4/UnCcY+EzsI5dsOfxXq3sa/B2
	5r2jTdci421Kgtas6DtmX3bXaiF2DHQ6HU4a26NBvB14ub+IFWzaNMweT0OBw2vs
	I4sQZRbDVyCcwa9HeDjmRxRxzn3b3ma31pVETQ2eSgL06lotDaEBUgVNwZGIlYNm
	M9qrrq1JHtZKbAUczLfVwQLqq2JvtYF8+pycZ82cZ50lHdYG0tyLJ2SP3c6+nN6B
	N0kVBOAgkgF4GL6Um+5+uQfBzTigZuKuiruGLTwj6BPVFoTAlxc3GVmjz1aEQD7N
	HzEXw0pyQQseqVouHpUp4bs4FYPm9GAlUxk/iF8BCDzA91VlGRBDOQYIDzOAVH6J
	uxDfS/k6eoCCalWOWvg+8UwnkSsj4Go=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 08 Jul 2026 18:53:32 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 5F34C6029E;
	Wed,  8 Jul 2026 18:53:25 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 668FrEwS064811;
	Wed, 8 Jul 2026 18:53:16 +0300
Date: Wed, 8 Jul 2026 18:53:14 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
cc: Simon Horman <horms@verge.net.au>, David Ahern <dsahern@kernel.org>,
        Ido Schimmel <idosch@nvidia.com>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        Alexander Frolkin <avf@eldamar.org.uk>, netdev@vger.kernel.org,
        lvs-devel@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        stable@vger.kernel.org, Yuxiang Yang <yangyx22@mails.tsinghua.edu.cn>,
        Ao Wang <wangao@seu.edu.cn>, Xuewei Feng <fengxw06@126.com>,
        Qi Li <qli01@tsinghua.edu.cn>, Ke Xu <xuke@tsinghua.edu.cn>
Subject: Re: [PATCH nf] ipvs: make destination flags atomic
In-Reply-To: <91509A0C-9E4A-4F0E-A45C-ABD29396067E@mails.tsinghua.edu.cn>
Message-ID: <afcdb34c-ec10-de8e-083c-624bcedca90e@ssi.bg>
References: <20260707085706.96322-1-zhaoyz24@mails.tsinghua.edu.cn> <41c3d792-af7d-5582-5057-ac3df5f7bfd6@ssi.bg> <91509A0C-9E4A-4F0E-A45C-ABD29396067E@mails.tsinghua.edu.cn>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Wed, 8 Jul 2026, Yizhou Zhao wrote:

> > On Jul 8, 2026, at 03:18, Julian Anastasov <ja@ssi.bg> wrote:
> > 
> > On Tue, 7 Jul 2026, Yizhou Zhao wrote:
> > 
> 
> We have posted a v2 patch at:
> https://lore.kernel.org/netfilter-devel/20260708060454.20534-1-zhaoyz24@mails.tsinghua.edu.cn/
> 
> The v2 patch updates the commit message with more conservative
> wording, and fixes the checkpatch logical-continuation warnings.

	After looking again at the code, I think we can
do it in different way:

- IP_VS_DEST_F_AVAILABLE and IP_VS_DEST_F_OVERLOAD are defined
in include/uapi/linux/ip_vs.h but we never export them to user
space. So, we are free to change them. We can move them to 
include/net/ip_vs.h, see below...

- IP_VS_DEST_F_AVAILABLE is changed only under service_mutex,
so we can keep its usage

- IP_VS_DEST_F_OVERLOAD needs different access methods.
We can add 'unsigned long flags2;', may be after l_threshold.
And to switch to such usage (F_OVERLOAD -> FL_OVERLOAD):

	- test_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2)
	- set_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2)

		Sometimes if (test_bit()) clear_bit() can avoid
		full memory barrier in ip_vs_dest_update_overload()

	- clear_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2)
		test_bit() guard can help here too

	As there are other races involved, something like
this can be a starting point for such change. It tries harder
to update the overload flag on dest edit/add but it does not
include the proposed bitops:

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 49297fec448a..b34631270e24 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1906,6 +1906,8 @@ static inline void ip_vs_dest_put_and_free(struct ip_vs_dest *dest)
 		kfree(dest);
 }
 
+void ip_vs_dest_update_overload(struct ip_vs_dest *dest);
+
 /* IPVS sync daemon data and function prototypes
  * (from ip_vs_sync.c)
  */
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index d19caf66afeb..3fd221996e6e 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1087,6 +1087,26 @@ static inline int ip_vs_dest_totalconns(struct ip_vs_dest *dest)
 		+ atomic_read(&dest->inactconns);
 }
 
+__always_inline void ip_vs_dest_update_overload(struct ip_vs_dest *dest)
+{
+	int conns, l, u;
+
+	u = READ_ONCE(dest->u_threshold);
+	if (!u)
+		goto unset;
+	conns = ip_vs_dest_totalconns(dest);
+	if (conns >= u) {
+		dest->flags |= IP_VS_DEST_F_OVERLOAD;
+		return;
+	}
+	l = READ_ONCE(dest->l_threshold) ? : (u * 3 / 4);
+	if (conns >= l && l)
+		return;
+
+unset:
+	dest->flags &= ~IP_VS_DEST_F_OVERLOAD;
+}
+
 /*
  *	Bind a connection entry with a virtual service destination
  *	Called just after a new connection entry is created.
@@ -1161,9 +1181,7 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
 		atomic_inc(&dest->persistconns);
 	}
 
-	if (dest->u_threshold != 0 &&
-	    ip_vs_dest_totalconns(dest) >= dest->u_threshold)
-		dest->flags |= IP_VS_DEST_F_OVERLOAD;
+	ip_vs_dest_update_overload(dest);
 }
 
 
@@ -1257,16 +1275,8 @@ static inline void ip_vs_unbind_dest(struct ip_vs_conn *cp)
 		atomic_dec(&dest->persistconns);
 	}
 
-	if (dest->l_threshold != 0) {
-		if (ip_vs_dest_totalconns(dest) < dest->l_threshold)
-			dest->flags &= ~IP_VS_DEST_F_OVERLOAD;
-	} else if (dest->u_threshold != 0) {
-		if (ip_vs_dest_totalconns(dest) * 4 < dest->u_threshold * 3)
-			dest->flags &= ~IP_VS_DEST_F_OVERLOAD;
-	} else {
-		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
-			dest->flags &= ~IP_VS_DEST_F_OVERLOAD;
-	}
+	if (dest->flags & IP_VS_DEST_F_OVERLOAD)
+		ip_vs_dest_update_overload(dest);
 
 	ip_vs_dest_put(dest);
 }
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index bcf40b8c41cf..2871116e46ec 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1315,6 +1315,7 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 	struct ip_vs_service *old_svc;
 	struct ip_vs_scheduler *sched;
 	int conn_flags;
+	bool upd_thresh;
 
 	/* We cannot modify an address and change the address family */
 	BUG_ON(!add && udest->af != dest->af);
@@ -1370,10 +1371,12 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 	/* set the dest status flags */
 	dest->flags |= IP_VS_DEST_F_AVAILABLE;
 
-	if (udest->u_threshold == 0 || udest->u_threshold > dest->u_threshold)
-		dest->flags &= ~IP_VS_DEST_F_OVERLOAD;
-	dest->u_threshold = udest->u_threshold;
-	dest->l_threshold = udest->l_threshold;
+	upd_thresh = READ_ONCE(dest->u_threshold) != udest->u_threshold ||
+		     READ_ONCE(dest->l_threshold) != udest->l_threshold;
+	WRITE_ONCE(dest->u_threshold, udest->u_threshold);
+	WRITE_ONCE(dest->l_threshold, udest->l_threshold);
+	if (upd_thresh)
+		ip_vs_dest_update_overload(dest);
 
 	dest->af = udest->af;
 
@@ -3667,8 +3670,8 @@ __ip_vs_get_dest_entries(struct netns_ipvs *ipvs, const struct ip_vs_get_dests *
 			entry.port = dest->port;
 			entry.conn_flags = atomic_read(&dest->conn_flags);
 			entry.weight = atomic_read(&dest->weight);
-			entry.u_threshold = dest->u_threshold;
-			entry.l_threshold = dest->l_threshold;
+			entry.u_threshold = READ_ONCE(dest->u_threshold);
+			entry.l_threshold = READ_ONCE(dest->l_threshold);
 			entry.activeconns = atomic_read(&dest->activeconns);
 			entry.inactconns = atomic_read(&dest->inactconns);
 			entry.persistconns = atomic_read(&dest->persistconns);
@@ -4277,8 +4280,10 @@ static int ip_vs_genl_fill_dest(struct sk_buff *skb, struct ip_vs_dest *dest)
 			 dest->tun_port) ||
 	    nla_put_u16(skb, IPVS_DEST_ATTR_TUN_FLAGS,
 			dest->tun_flags) ||
-	    nla_put_u32(skb, IPVS_DEST_ATTR_U_THRESH, dest->u_threshold) ||
-	    nla_put_u32(skb, IPVS_DEST_ATTR_L_THRESH, dest->l_threshold) ||
+	    nla_put_u32(skb, IPVS_DEST_ATTR_U_THRESH,
+			READ_ONCE(dest->u_threshold)) ||
+	    nla_put_u32(skb, IPVS_DEST_ATTR_L_THRESH,
+			READ_ONCE(dest->l_threshold)) ||
 	    nla_put_u32(skb, IPVS_DEST_ATTR_ACTIVE_CONNS,
 			atomic_read(&dest->activeconns)) ||
 	    nla_put_u32(skb, IPVS_DEST_ATTR_INACT_CONNS,

Regards

--
Julian Anastasov <ja@ssi.bg>

