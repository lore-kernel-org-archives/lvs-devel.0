Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BA6032765D7;
	Sat,  4 Apr 2026 15:37:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775317045; cv=none; b=kDa6DdjUEEJ3t0O3XZfVavQztdgQiD6R1jADqqbxyP6h2xRMJQnidEaLwaObFBKLjDieW4q2dTkVLkV2nTL9x7Iy++bKBj8qziQQUFTYtK5bjo6g/2KT5fwjIFGPHPoycBVFIaNfW3pibz/z1EXnwITZLpWlPZO735vv8V7cdck=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775317045; c=relaxed/simple;
	bh=ZcXaXORmxtirKTUGaslTKH5sbfBLaMwgkxvki80CR6E=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=NS+HpA+eFU1mNwhfSGKX2/YVbvFhPSO1Y0glWbZXvZBv5hiowgqMabTYfrwYm4Fw5VGMEuOnmwFk+O02u5AYmRmGjC2b1ChLrgUCND3t9ZKyt1UgodZYj1t7XpwNLpocFJFLMq+te08r73K+VB/wHkJ20I/yDzBjcycmlubPpAg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=HCWo/3yR; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="HCWo/3yR"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id D2F8C21C63;
	Sat, 04 Apr 2026 18:37:20 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=MzHtgV0/e4YGyhfcr3shqQby3NCBMZ1kKCFQAr0/Ecg=; b=HCWo/3yREmrI
	DN3GYrs1eEG5LbdvRNcGDqyjp7vgCIFV81zjl+Yn1zrTNiWgyJzbVMiYbei3H3uL
	LpNFoLR0CCJyNkez6NPXqhNBkIWKXXs6+8Ip6T6NxYPTSV/5FGk/OMRf8+RlyocC
	AtAI3zyUuVHWDls0SvaSAc2bEZ6QDhm4Bln6dL0h44FhhsQQxBEvrnmLjeSEO2LJ
	lsjGeBQpsdJyy0uG6J+6jEDDJfHcMrOy83b5Ogb/sW39+/V4ouXYaOsuvnxdwNUv
	kdeAZVdAC/xyOnbTQT6kPQnWqZkRhStFPxe2R8gaHXjIts0DVwxan40mOYMHNLoN
	OZ8Zdg3gi73oV7cwY/+Zz+mkz+Yiq/p4/hhR1v7L8Nzs2aFfQK1f+9IX5kwRDTXw
	tNfZ+PmDmbBS2xMHufuIuE9mvisAPbXmVFa+t2+/JWIyqePaTCMGWuXdWGl0+VVg
	XsRxXft9xUhPTdJCQON1NUkbQGUSme3eLY4oXA3Atxq7LmAFoFqywXeFJZFxi4wG
	MiuALsRUSLSH2G1XbvcEdpfbBY74Sq3LyxQ+nb2/O5SBVl6pn2K6wrJ5oPZui4nc
	68Z2xKZeqf7dT73SVuNAoYorkBbhDLPt8wCXkrjrttrQ5yumpNzumbiWeRO5M+kt
	U/PJOD1yT3uHdHKXMrC6iZbGJIOAnEI=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sat, 04 Apr 2026 18:37:19 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 196926084A;
	Sat,  4 Apr 2026 18:37:20 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 634FZDLC030103;
	Sat, 4 Apr 2026 18:35:13 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 634FZDSd030102;
	Sat, 4 Apr 2026 18:35:13 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>
Subject: [PATCHv2 nf-next 1/3] ipvs: show the current conn_tab size to users
Date: Sat,  4 Apr 2026 18:34:37 +0300
Message-ID: <20260404153439.30077-2-ja@ssi.bg>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260404153439.30077-1-ja@ssi.bg>
References: <20260404153439.30077-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

As conn_tab is per-net, better to show the current hash table size
to users instead of the ip_vs_conn_tab_size (max).

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 26 ++++++++++++++++++++++----
 1 file changed, 22 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index b472e564b769..d06d710dac83 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -281,6 +281,20 @@ static void est_reload_work_handler(struct work_struct *work)
 	mutex_unlock(&ipvs->est_mutex);
 }
 
+static int get_conn_tab_size(struct netns_ipvs *ipvs)
+{
+	const struct ip_vs_rht *t;
+	int size = 0;
+
+	rcu_read_lock();
+	t = rcu_dereference(ipvs->conn_tab);
+	if (t)
+		size = t->size;
+	rcu_read_unlock();
+
+	return size;
+}
+
 int
 ip_vs_use_count_inc(void)
 {
@@ -2742,10 +2756,13 @@ static void ip_vs_info_seq_stop(struct seq_file *seq, void *v)
 
 static int ip_vs_info_seq_show(struct seq_file *seq, void *v)
 {
+	struct net *net = seq_file_net(seq);
+	struct netns_ipvs *ipvs = net_ipvs(net);
+
 	if (v == SEQ_START_TOKEN) {
 		seq_printf(seq,
 			"IP Virtual Server version %d.%d.%d (size=%d)\n",
-			NVERSION(IP_VS_VERSION_CODE), ip_vs_conn_tab_size);
+			NVERSION(IP_VS_VERSION_CODE), get_conn_tab_size(ipvs));
 		seq_puts(seq,
 			 "Prot LocalAddress:Port Scheduler Flags\n");
 		seq_puts(seq,
@@ -3426,7 +3443,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 		char buf[64];
 
 		sprintf(buf, "IP Virtual Server version %d.%d.%d (size=%d)",
-			NVERSION(IP_VS_VERSION_CODE), ip_vs_conn_tab_size);
+			NVERSION(IP_VS_VERSION_CODE), get_conn_tab_size(ipvs));
 		if (copy_to_user(user, buf, strlen(buf)+1) != 0) {
 			ret = -EFAULT;
 			goto out;
@@ -3438,8 +3455,9 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	case IP_VS_SO_GET_INFO:
 	{
 		struct ip_vs_getinfo info;
+
 		info.version = IP_VS_VERSION_CODE;
-		info.size = ip_vs_conn_tab_size;
+		info.size = get_conn_tab_size(ipvs);
 		info.num_services =
 			atomic_read(&ipvs->num_services[IP_VS_AF_INET]);
 		if (copy_to_user(user, &info, sizeof(info)) != 0)
@@ -4448,7 +4466,7 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
 		if (nla_put_u32(msg, IPVS_INFO_ATTR_VERSION,
 				IP_VS_VERSION_CODE) ||
 		    nla_put_u32(msg, IPVS_INFO_ATTR_CONN_TAB_SIZE,
-				ip_vs_conn_tab_size))
+				get_conn_tab_size(ipvs)))
 			goto nla_put_failure;
 		break;
 	}
-- 
2.53.0


