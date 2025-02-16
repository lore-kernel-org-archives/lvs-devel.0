Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 20A91748F;
	Sun, 16 Feb 2025 09:27:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1739698084; cv=none; b=okva5vJ+UcBsHDl2LFaTF+AUAVVAznBP5c22UvroUdXIryKIvoj2Yl1qDhRD5SOC3Ou+++iuvTpIyUyKLLDEgsaW8xkuPJFR+49eiXOIrj7jWRcfG4Vl5Z0bKy8ZNlvw1HP6gOfucoxTNrW6KDuecXHV5FU2bGMPZuvnA4y3clg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1739698084; c=relaxed/simple;
	bh=PabaHSObL1FHhwTpo7FlmVS6XbdvGYluRSmJbaHlc+Q=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=pF+Y5B31tUyVvfhbGVHAQg90+sJ0qLeVXF56tjg4CPQ+4eFEUfdp5KVXzQZWV0DksjARiBXNHbAE0+kpTQkWY9fO91XIb5bNucN2fNaEPis2UlSkZ6bE430EyNDgV1YPjevzVyc88814cIPcHSL4Dtjtyvlw2xWZ3e0IKxE76dY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=64OM+z5G; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="64OM+z5G"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 15BD223505;
	Sun, 16 Feb 2025 11:27:51 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=tkY2r1upoRmrq85sW3Yt/r7d38HQ8mRdKHIEVeDaaWY=; b=64OM+z5Gfdie
	kpW/jfIev5f349JJm/1tMt/oGDIsepAEW1ycZltuRLwSawAHzG8U31m8cPjZ7LYg
	Uuzm1iovMkPHXpJnu7na5oe5A3oS6d0MyMcxKiDDgJH3/TYHYTN1kHZiMiDRgxRe
	TRs7u/dT2rDr6HVEXiqc7CCWW9ORcCHy/IblPCpOnOP/EJiLVSOuq4U7bs/JGhMz
	A8ypy1L+m5HcVDkkPY26KKEFHFN0dMJHKL6Ld6u5pE/ZMKI4FWWmH/W9szlnLq5P
	jX58LZpKRXv1+f3+Ledq6RG9iE19N1YfWInuo/nCdACdaExMsCTdzU4VFdV/RD1D
	s7qRberqtScQBPexHOPbYvNtFfVSpYp2+Njfc7jBuhsv8IC9CxUXnZ6wI0Zv6Q9k
	iEAuI8MiaiBrOm+wZNErwbCjSPIPNQxcvJClp8box4ZyL7Dy4ygew3Cm8xuMEjru
	Yi4snyY35nuFdDrTUt5MZ2s2wxZkLyCStnpjm0CFBEdGf5MefRu2C/bgMU94+9vq
	CU8yMnl+bQXHL0tYZjTWVk0pglgVFvSxOar8+0xbMpjfnSj3UUc93S7W+fCal+ES
	FhDMa5WRU6lom29jinwys+8SfSxozmbVWCSgmV5sGZbjhyXN9oF4hbP5iwsbmb94
	C7bA7YuEaZn3OU53PzeDkKKvIpmrztU=
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sun, 16 Feb 2025 11:27:49 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id 07C7615EA8;
	Sun, 16 Feb 2025 11:27:41 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.17.1) with ESMTP id 51G9RdLN011172;
	Sun, 16 Feb 2025 11:27:41 +0200
Date: Sun, 16 Feb 2025 11:27:39 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: m30030393 <mengkanglai2@huawei.com>
cc: pablo@netfilter.org, kadlec@netfilter.org, davem@davemloft.net,
        edumazet@google.com, kuba@kernel.org, pabeni@redhat.com,
        horms@kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, yanan@huawei.com, fengtao40@huawei.com,
        gaoxingwang1@huawei.com, lvs-devel@vger.kernel.org
Subject: Re: ftp ipvs connect failed in ipv6
In-Reply-To: <20250215110959.2557589-1-mengkanglai2@huawei.com>
Message-ID: <30ba0c1c-593c-f10b-4caf-a262d8ba1247@ssi.bg>
References: <7a1903c5-f7e3-4480-2a07-ae94e4d6a895@ssi.bg> <20250215110959.2557589-1-mengkanglai2@huawei.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="-1463811672-331892563-1739698061=:3370"

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-331892563-1739698061=:3370
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Sat, 15 Feb 2025, m30030393 wrote:

> Tue, 11 Feb 2025, Julian Anastasov wrote:
> >>
> >>On Mon, 10 Feb 2025, mengkanglai wrote:
> >>
> >>> Hello:
> >>> I found a problem with ftp ipvs.
> >>> I create 3 virtual machine in one host. One is the FTP client, the other is the ipvs transition host, and the other is the FTP server.
> >>> The ftp connection is successful in ipv4 address,but failed in ipv6 address.
> >>> The failure is tcp6 checksum error in 
> >>> tcp_dnat_handler(tcp_dnat_handler-> tcp_csum_check->csum_ipv6_magic), I trace back where skb->csum is assigned and found skb->csum is assigned in nf_ip6_checksum in case CHECKSUM_NONE(ipv6_conntrack_in=> nf_conntrack_in => nf_conntrack_tcp_packet => nf_ip6_checksum).
> >>> I don't know much about ipv6 checksums,why ipv6 nf_conntrack assign skb->csum but check error in ipvs tcp_dnat_handler?
> >>
> >>	Looks like the checksum validation does not use correct offset for the protocol header in the case with IPv6. Do you see extension headers before the final IPv6 header that points to TCP header? If that is the case, the following patch can help. If you prefer, you can apply just the TCP part for the FTP test. Let me know if this solves the problem, thanks!
> 
>     Thanks for your help, but the following patch can't help. see extension headers before the IPv6 header, it’s just the common first SYN packet of the IPv6 three-way handshake but csum check failed in tcp_csum_check. 
> 	I tried different offsets for the protocol header but doesn't work.

	The previous patch needs more changes, see below
v2 where we also provide correct protocol value. If this patch
does not help, send me more info, if you prefer privately:

- packet capture file containing such packet
- does it happen for other service (port), eg. 80/443 or just on 21
- the skb->ip_summed, tcphoff and skb->csum values in tcp_csum_check

[PATCHv2] ipvs: skip ipv6 extension headers for csum checks

Protocol checksum validation fails for IPv6 if there are extension
headers before the protocol header. iph->len already contains its
offset, so use it to fix the problem.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_proto_sctp.c | 18 ++++++------------
 net/netfilter/ipvs/ip_vs_proto_tcp.c  | 21 +++++++--------------
 net/netfilter/ipvs/ip_vs_proto_udp.c  | 20 +++++++-------------
 3 files changed, 20 insertions(+), 39 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 83e452916403..63c78a1f3918 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -10,7 +10,8 @@
 #include <net/ip_vs.h>
 
 static int
-sctp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp);
+sctp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
+		unsigned int sctphoff);
 
 static int
 sctp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
@@ -108,7 +109,7 @@ sctp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		int ret;
 
 		/* Some checks before mangling */
-		if (!sctp_csum_check(cp->af, skb, pp))
+		if (!sctp_csum_check(cp->af, skb, pp, sctphoff))
 			return 0;
 
 		/* Call application helper if needed */
@@ -156,7 +157,7 @@ sctp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		int ret;
 
 		/* Some checks before mangling */
-		if (!sctp_csum_check(cp->af, skb, pp))
+		if (!sctp_csum_check(cp->af, skb, pp, sctphoff))
 			return 0;
 
 		/* Call application helper if needed */
@@ -185,19 +186,12 @@ sctp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 }
 
 static int
-sctp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp)
+sctp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
+		unsigned int sctphoff)
 {
-	unsigned int sctphoff;
 	struct sctphdr *sh;
 	__le32 cmp, val;
 
-#ifdef CONFIG_IP_VS_IPV6
-	if (af == AF_INET6)
-		sctphoff = sizeof(struct ipv6hdr);
-	else
-#endif
-		sctphoff = ip_hdrlen(skb);
-
 	sh = (struct sctphdr *)(skb->data + sctphoff);
 	cmp = sh->checksum;
 	val = sctp_compute_cksum(skb, sctphoff);
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 7da51390cea6..ede4fa3b63f5 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -29,7 +29,8 @@
 #include <net/ip_vs.h>
 
 static int
-tcp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp);
+tcp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
+	       unsigned int tcphoff);
 
 static int
 tcp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
@@ -166,7 +167,7 @@ tcp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		int ret;
 
 		/* Some checks before mangling */
-		if (!tcp_csum_check(cp->af, skb, pp))
+		if (!tcp_csum_check(cp->af, skb, pp, tcphoff))
 			return 0;
 
 		/* Call application helper if needed */
@@ -244,7 +245,7 @@ tcp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		int ret;
 
 		/* Some checks before mangling */
-		if (!tcp_csum_check(cp->af, skb, pp))
+		if (!tcp_csum_check(cp->af, skb, pp, tcphoff))
 			return 0;
 
 		/*
@@ -301,17 +302,9 @@ tcp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 
 
 static int
-tcp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp)
+tcp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
+	       unsigned int tcphoff)
 {
-	unsigned int tcphoff;
-
-#ifdef CONFIG_IP_VS_IPV6
-	if (af == AF_INET6)
-		tcphoff = sizeof(struct ipv6hdr);
-	else
-#endif
-		tcphoff = ip_hdrlen(skb);
-
 	switch (skb->ip_summed) {
 	case CHECKSUM_NONE:
 		skb->csum = skb_checksum(skb, tcphoff, skb->len - tcphoff, 0);
@@ -322,7 +315,7 @@ tcp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp)
 			if (csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
 					    &ipv6_hdr(skb)->daddr,
 					    skb->len - tcphoff,
-					    ipv6_hdr(skb)->nexthdr,
+					    IPPROTO_TCP,
 					    skb->csum)) {
 				IP_VS_DBG_RL_PKT(0, af, pp, skb, 0,
 						 "Failed checksum for");
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index 68260d91c988..ffbebda547fc 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -25,7 +25,8 @@
 #include <net/ip6_checksum.h>
 
 static int
-udp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp);
+udp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
+	       unsigned int udphoff);
 
 static int
 udp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
@@ -155,7 +156,7 @@ udp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		int ret;
 
 		/* Some checks before mangling */
-		if (!udp_csum_check(cp->af, skb, pp))
+		if (!udp_csum_check(cp->af, skb, pp, udphoff))
 			return 0;
 
 		/*
@@ -238,7 +239,7 @@ udp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		int ret;
 
 		/* Some checks before mangling */
-		if (!udp_csum_check(cp->af, skb, pp))
+		if (!udp_csum_check(cp->af, skb, pp, udphoff))
 			return 0;
 
 		/*
@@ -297,17 +298,10 @@ udp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 
 
 static int
-udp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp)
+udp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
+	       unsigned int udphoff)
 {
 	struct udphdr _udph, *uh;
-	unsigned int udphoff;
-
-#ifdef CONFIG_IP_VS_IPV6
-	if (af == AF_INET6)
-		udphoff = sizeof(struct ipv6hdr);
-	else
-#endif
-		udphoff = ip_hdrlen(skb);
 
 	uh = skb_header_pointer(skb, udphoff, sizeof(_udph), &_udph);
 	if (uh == NULL)
@@ -325,7 +319,7 @@ udp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp)
 				if (csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
 						    &ipv6_hdr(skb)->daddr,
 						    skb->len - udphoff,
-						    ipv6_hdr(skb)->nexthdr,
+						    IPPROTO_UDP,
 						    skb->csum)) {
 					IP_VS_DBG_RL_PKT(0, af, pp, skb, 0,
 							 "Failed checksum for");
-- 
2.48.1

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-331892563-1739698061=:3370--

