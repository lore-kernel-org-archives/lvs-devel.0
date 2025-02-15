Received: from szxga01-in.huawei.com (szxga01-in.huawei.com [45.249.212.187])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E334418F2DF;
	Sat, 15 Feb 2025 11:10:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=45.249.212.187
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1739617863; cv=none; b=IwIiH4TqNlczlSJed7nfxSY4A4GtPPN5SMmRQWRa3ZEifcBt+x537Yle/PkA/Acc4BPUtrnvQG/rOhvr0OdTTwWMvZ2iqvX4N4/CNYDST+0iKuEmrEWnz05iRz53CWsSz0BnLjnQ7RQ0oKinpkFYcZfwnTXOAbsdgy5PcbW38tk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1739617863; c=relaxed/simple;
	bh=sPpAxcr8OEPeF6nDrBH1XyqrEsoo2vFroxJiGi2FJUc=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=ScDvp8Ceu4LVSZLtAoLi5pWTqeFBdvW8RbtfmP3IWat0Rb1G4N8NqSgDbuRnn/Ip0iyVdzTlNnbnttsVcd++HuF3i5moE14NIYwEdQv06qe8QBw08QnhOonqfsi+/LItycxkET5j9kt4tpw83UOh5a/P3Ml2QYBa6ZJE5KvHjus=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; arc=none smtp.client-ip=45.249.212.187
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Received: from mail.maildlp.com (unknown [172.19.163.252])
	by szxga01-in.huawei.com (SkyGuard) with ESMTP id 4Yw5hC54Fnz11Q89;
	Sat, 15 Feb 2025 19:06:19 +0800 (CST)
Received: from kwepemo500008.china.huawei.com (unknown [7.202.195.163])
	by mail.maildlp.com (Postfix) with ESMTPS id D92901800D9;
	Sat, 15 Feb 2025 19:10:50 +0800 (CST)
Received: from localhost.localdomain (10.175.124.27) by
 kwepemo500008.china.huawei.com (7.202.195.163) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.1544.11; Sat, 15 Feb 2025 19:10:49 +0800
From: m30030393 <mengkanglai2@huawei.com>
To: <ja@ssi.bg>
CC: <pablo@netfilter.org>, <kadlec@netfilter.org>, <davem@davemloft.net>,
	<edumazet@google.com>, <kuba@kernel.org>, <pabeni@redhat.com>,
	<horms@kernel.org>, <netfilter-devel@vger.kernel.org>,
	<coreteam@netfilter.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <yanan@huawei.com>, <fengtao40@huawei.com>,
	<gaoxingwang1@huawei.com>, <lvs-devel@vger.kernel.org>
Subject: Re: ftp ipvs connect failed in ipv6
Date: Sat, 15 Feb 2025 19:09:59 +0800
Message-ID: <20250215110959.2557589-1-mengkanglai2@huawei.com>
X-Mailer: git-send-email 2.33.0
In-Reply-To: <7a1903c5-f7e3-4480-2a07-ae94e4d6a895@ssi.bg>
References: <7a1903c5-f7e3-4480-2a07-ae94e4d6a895@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
X-ClientProxiedBy: dggems706-chm.china.huawei.com (10.3.19.183) To
 kwepemo500008.china.huawei.com (7.202.195.163)

Tue, 11 Feb 2025, Julian Anastasov wrote:
>>
>>
>>	Hello,
>>
>>On Mon, 10 Feb 2025, mengkanglai wrote:
>>
>>> Hello:
>>> I found a problem with ftp ipvs.
>>> I create 3 virtual machine in one host. One is the FTP client, the other is the ipvs transition host, and the other is the FTP server.
>>> The ftp connection is successful in ipv4 address,but failed in ipv6 address.
>>> The failure is tcp6 checksum error in 
>>> tcp_dnat_handler(tcp_dnat_handler-> tcp_csum_check->csum_ipv6_magic), I trace back where skb->csum is assigned and found skb->csum is assigned in nf_ip6_checksum in case CHECKSUM_NONE(ipv6_conntrack_in=> nf_conntrack_in => nf_conntrack_tcp_packet => nf_ip6_checksum).
>>> I don't know much about ipv6 checksums,why ipv6 nf_conntrack assign skb->csum but check error in ipvs tcp_dnat_handler?
>>
>>	Looks like the checksum validation does not use correct offset for the protocol header in the case with IPv6. Do you see extension headers before the final IPv6 header that points to TCP header? If that is the case, the following patch can help. If you prefer, you can apply just the TCP part for the FTP test. Let me know if this solves the problem, thanks!

    Thanks for your help, but the following patch can't help. see extension headers before the IPv6 header, it’s just the common first SYN packet of the IPv6 three-way handshake but csum check failed in tcp_csum_check. 
	I tried different offsets for the protocol header but doesn't work.

>>[PATCH] ipvs: provide correct ipv6 proto offset for csum checks
>>
>>Protocol checksum validation fails if there are multiple IPv6 headers before the protocol header. iph->len already contains its offset, so use it to fix the problem.
>>
>>Signed-off-by: Julian Anastasov <ja@ssi.bg>
>>---
>> net/netfilter/ipvs/ip_vs_proto_sctp.c | 18 ++++++------------  net/netfilter/ipvs/ip_vs_proto_tcp.c  | 19 ++++++-------------  net/netfilter/ipvs/ip_vs_proto_udp.c  | 18 ++++++------------
>> 3 files changed, 18 insertions(+), 37 deletions(-)
>>
>>diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
>>index 83e452916403..63c78a1f3918 100644
>>--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
>>+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
>>@@ -10,7 +10,8 @@
>> #include <net/ip_vs.h>
>> 
>> static int
>>-sctp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp);
>>+sctp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
>>+		unsigned int sctphoff);
>> 
>> static int
>> sctp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb, @@ -108,7 +109,7 @@ sctp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
>> 		int ret;
>> 
>> 		/* Some checks before mangling */
>>-		if (!sctp_csum_check(cp->af, skb, pp))
>>+		if (!sctp_csum_check(cp->af, skb, pp, sctphoff))
>> 			return 0;
>> 
>> 		/* Call application helper if needed */ @@ -156,7 +157,7 @@ sctp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
>> 		int ret;
>> 
>> 		/* Some checks before mangling */
>>-		if (!sctp_csum_check(cp->af, skb, pp))
>>+		if (!sctp_csum_check(cp->af, skb, pp, sctphoff))
>> 			return 0;
>> 
>> 		/* Call application helper if needed */ @@ -185,19 +186,12 @@ sctp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,  }
>> 
>> static int
>>-sctp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp)
>>+sctp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
>>+		unsigned int sctphoff)
>> {
>>-	unsigned int sctphoff;
>> 	struct sctphdr *sh;
>> 	__le32 cmp, val;
>> 
>>-#ifdef CONFIG_IP_VS_IPV6
>>-	if (af == AF_INET6)
>>-		sctphoff = sizeof(struct ipv6hdr);
>>-	else
>>-#endif
>>-		sctphoff = ip_hdrlen(skb);
>>-
>> 	sh = (struct sctphdr *)(skb->data + sctphoff);
>> 	cmp = sh->checksum;
>> 	val = sctp_compute_cksum(skb, sctphoff); diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
>>index 7da51390cea6..dabdb9d3b479 100644
>>--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
>>+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
>>@@ -29,7 +29,8 @@
>> #include <net/ip_vs.h>
>> 
>> static int
>>-tcp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp);
>>+tcp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
>>+	       unsigned int tcphoff);
>> 
>> static int
>> tcp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb, @@ -166,7 +167,7 @@ tcp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
>> 		int ret;
>> 
>> 		/* Some checks before mangling */
>>-		if (!tcp_csum_check(cp->af, skb, pp))
>>+		if (!tcp_csum_check(cp->af, skb, pp, tcphoff))
>> 			return 0;
>> 
>> 		/* Call application helper if needed */ @@ -244,7 +245,7 @@ tcp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
>> 		int ret;
>> 
>> 		/* Some checks before mangling */
>>-		if (!tcp_csum_check(cp->af, skb, pp))
>>+		if (!tcp_csum_check(cp->af, skb, pp, tcphoff))
>> 			return 0;
>> 
>> 		/*
>>@@ -301,17 +302,9 @@ tcp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
>> 
>> 
>> static int
>>-tcp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp)
>>+tcp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
>>+	       unsigned int tcphoff)
>> {
>>-	unsigned int tcphoff;
>>-
>>-#ifdef CONFIG_IP_VS_IPV6
>>-	if (af == AF_INET6)
>>-		tcphoff = sizeof(struct ipv6hdr);
>>-	else
>>-#endif
>>-		tcphoff = ip_hdrlen(skb);
>>-
>> 	switch (skb->ip_summed) {
>> 	case CHECKSUM_NONE:
>> 		skb->csum = skb_checksum(skb, tcphoff, skb->len - tcphoff, 0); diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
>>index 68260d91c988..e99e7c5df869 100644
>>--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
>>+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
>>@@ -25,7 +25,8 @@
>> #include <net/ip6_checksum.h>
>> 
>> static int
>>-udp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp);
>>+udp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
>>+	       unsigned int udphoff);
>> 
>> static int
>> udp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb, @@ -155,7 +156,7 @@ udp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
>> 		int ret;
>> 
>> 		/* Some checks before mangling */
>>-		if (!udp_csum_check(cp->af, skb, pp))
>>+		if (!udp_csum_check(cp->af, skb, pp, udphoff))
>> 			return 0;
>> 
>> 		/*
>>@@ -238,7 +239,7 @@ udp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
>> 		int ret;
>> 
>> 		/* Some checks before mangling */
>>-		if (!udp_csum_check(cp->af, skb, pp))
>>+		if (!udp_csum_check(cp->af, skb, pp, udphoff))
>> 			return 0;
>> 
>> 		/*
>>@@ -297,17 +298,10 @@ udp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
>> 
>> 
>> static int
>>-udp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp)
>>+udp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
>>+	       unsigned int udphoff)
>> {
>> 	struct udphdr _udph, *uh;
>>-	unsigned int udphoff;
>>-
>>-#ifdef CONFIG_IP_VS_IPV6
>>-	if (af == AF_INET6)
>>-		udphoff = sizeof(struct ipv6hdr);
>>-	else
>>-#endif
>>-		udphoff = ip_hdrlen(skb);
>> 
>> 	uh = skb_header_pointer(skb, udphoff, sizeof(_udph), &_udph);
>> 	if (uh == NULL)
>>--
>>2.48.1
>>
>>
>>Regards
>>
>>--
>>Julian Anastasov <ja@ssi.bg>

