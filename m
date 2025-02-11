Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 36B9F1E376E;
	Tue, 11 Feb 2025 14:01:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1739282499; cv=none; b=ItmiBaXQkWZKsRFJm5ag/sz7HpsTkHwg+DEr80aWTmJBUaoUeqqh/NstcZ0QeiYBUaEoACtTn1n+UvB/yHXazQUU+cyqQ3xB/TupM7gzPLERsOr/eKpnDnSoqt01d9d34c4Kn+pzbVRoRLnYfIfuvoZkzipzjMwQY7BUvvru6A8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1739282499; c=relaxed/simple;
	bh=tL9O+uEh0ILH739lliOo8AMi2wqhWQL+dKG8bMas4mc=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=RR60Rk3pEWGb2313y3sbyiMsrE0ev0Io7unCXQIZbw5fgA6AH5XMq3g/rRHzWuUxpsM+6RQ2nakk0OfcW5LwIglQoC6wRt2+vUdExXHjBoQbWWIz5JIM6VZz1w6EDhsw8mS15LldOPsH8AsEO1/XuYlSbOdrvN5dvyX3h8liyY4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=RUhRtJvE; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="RUhRtJvE"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id CF773234F0;
	Tue, 11 Feb 2025 15:55:26 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=g2Omdx+gC2VgWT+qBhjHWyxng8Qdk36CSx5aBDN/WYc=; b=RUhRtJvEltA0
	kGC14MNbugq34P1kIz+l/q108own4UKmGAlom7ntH9q2ahzzp9+mQypRjEcAaBs3
	YrKlYgdmsLbpQDSW2x8kI5RiqJR1cLj5nflAvEmTVVMiPHMXm5xpAm7ZGwvFlGnB
	Fn88I6JA/vvrv2YAZ3SqgxDR7NVtn50mTn22UDKp9bYL3+e8Tf0VzlDsRFI0i7oe
	YMVv4JfQfnaiE7hR4KFMPupN0R0wfSRRBPECJJm5m2OvHaCktUZkT38uWNtRuDK2
	PTqan5qRWA5IRSlLYfi+9UpR7TJemmxooYhs+6wvsCTLrw9Vs7Ef9bkazr25hTB/
	IeCcdpeBla5F+lO8u72kd2WSOSFc4e8jvumN1/aQeo6tUQfVStIjE1k9LEiUYVq1
	r2WSqUbvdR2G27ND5tIPsmZhaxY9lV4z2f+nbnT7eR0EoM+ZCgyBkG5IrRlh0Cak
	zuYUopMoaYxM8toiWFoZYL/kyrckHPE7jWWXVRtq1LL5KA6fdTAt62orESJNvEp6
	n+e++iXeeDlnbAYbbmVph9ZbBtCAFFcSVJ02J1TAJKei+Z4zcUF5kLGl7hFaK1jU
	h9ZqvlztB5lx3ct7qaEGfrAfbr2S6KVGakgpWjAcmA6DwF+Ei/rIWN9R9tJ4Ihyi
	CCphLm3TDUPW1uobQ6YBX0unICHq5O4=
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 11 Feb 2025 15:55:25 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id 615C117093;
	Tue, 11 Feb 2025 15:55:18 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.17.1) with ESMTP id 51BDt7l9025873;
	Tue, 11 Feb 2025 15:55:10 +0200
Date: Tue, 11 Feb 2025 15:55:07 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: mengkanglai <mengkanglai2@huawei.com>
cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@netfilter.org>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>,
        "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
        "coreteam@netfilter.org" <coreteam@netfilter.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Yanan (Euler)" <yanan@huawei.com>,
        "Fengtao (fengtao, Euler)" <fengtao40@huawei.com>,
        "gaoxingwang (A)" <gaoxingwang1@huawei.com>, lvs-devel@vger.kernel.org
Subject: Re: ftp ipvs connect failed in ipv6
In-Reply-To: <e1527ca5f8f84be09022859f5e33b584@huawei.com>
Message-ID: <7a1903c5-f7e3-4480-2a07-ae94e4d6a895@ssi.bg>
References: <e1527ca5f8f84be09022859f5e33b584@huawei.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 10 Feb 2025, mengkanglai wrote:

> Hello:
> I found a problem with ftp ipvs.
> I create 3 virtual machine in one host. One is the FTP client, the other is the ipvs transition host, and the other is the FTP server.
> The ftp connection is successful in ipv4 address,but failed in ipv6 address.
> The failure is tcp6 checksum error in tcp_dnat_handler(tcp_dnat_handler-> tcp_csum_check->csum_ipv6_magic),
> I trace back where skb->csum is assigned and found skb->csum is assigned in nf_ip6_checksum in case CHECKSUM_NONE(ipv6_conntrack_in=> nf_conntrack_in => nf_conntrack_tcp_packet => nf_ip6_checksum).
> I don't know much about ipv6 checksums,why ipv6 nf_conntrack assign skb->csum but check error in ipvs tcp_dnat_handler?

	Looks like the checksum validation does not use correct
offset for the protocol header in the case with IPv6. Do you
see extension headers before the final IPv6 header that
points to TCP header? If that is the case, the following patch
can help. If you prefer, you can apply just the TCP part for
the FTP test. Let me know if this solves the problem, thanks!

[PATCH] ipvs: provide correct ipv6 proto offset for csum checks

Protocol checksum validation fails if there are multiple IPv6 headers
before the protocol header. iph->len already contains its offset, so
use it to fix the problem.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_proto_sctp.c | 18 ++++++------------
 net/netfilter/ipvs/ip_vs_proto_tcp.c  | 19 ++++++-------------
 net/netfilter/ipvs/ip_vs_proto_udp.c  | 18 ++++++------------
 3 files changed, 18 insertions(+), 37 deletions(-)

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
index 7da51390cea6..dabdb9d3b479 100644
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
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index 68260d91c988..e99e7c5df869 100644
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
-- 
2.48.1


Regards

--
Julian Anastasov <ja@ssi.bg>

