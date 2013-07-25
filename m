From: Joe Stringer <joe@wand.net.nz>
Subject: [PATCH v2 net-next] net/sctp: Refactor SCTP skb checksum computation
Date: Thu, 25 Jul 2013 10:52:05 +0900
Message-ID: <1374717125-28969-1-git-send-email-joe@wand.net.nz>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=sender:from:to:cc:subject:date:message-id:x-mailer;
        bh=ZZwFNhnA1WxN6pmyD9r6Zyg5P4jURQEueb2WEoGfk7s=;
        b=CK/j8uY9vqop9voRs9b8vojODG/hMk6ghtfXHqyJUeUQIqg+XIDJrkog/T30fNmNqE
         EOp+t1MDDCt29+9RzlKhcnfodyqBi1m3D9DFjdzC2WMCesBS7FLhfTwizhMMiSx1SoYQ
         DQnt0m1nzQeRO3KOGSE3PHYaKNkBYxgRqJf5FssS3yGRBw7d71SVGi1o6QJRLhSE2mhN
         T01dGYNI2xn/nmsGXJWc8RQ6xTQmqt10+DsDT0VgFheJLw5o++irDGtTgrc68DxxdJ6a
         Wx2socFHNLH5699km69DBJwzLM5wFMmLoodQMxQBLJst7CHSkj4AYJVPnzqHcTtspI+y
         29sw==
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, pablo@netfilter.org, ja@ssi.bg, horms@verge.net.au, jesse@nicira.com, Joe Stringer <joe@wand.net.nz>

This patch consolidates the SCTP checksum calculation code from various
places to a single new function, sctp_compute_cksum(skb, offset).

Signed-off-by: Joe Stringer <joe@wand.net.nz>
---
v2:
* Use skb->data + offset for start position of checksum calculation
* Fix existing bug in sctp_csum_check() where the incorrect offset was used
* Remove redundant variable in sctp_nat_csum()
---
 include/net/sctp/checksum.h           |   15 +++++++++++++++
 net/netfilter/ipvs/ip_vs_proto_sctp.c |   23 +++--------------------
 net/netfilter/nf_nat_proto_sctp.c     |    8 +-------
 net/sctp/input.c                      |   10 +---------
 4 files changed, 20 insertions(+), 36 deletions(-)

diff --git a/include/net/sctp/checksum.h b/include/net/sctp/checksum.h
index 0cb08e6..5d55082 100644
--- a/include/net/sctp/checksum.h
+++ b/include/net/sctp/checksum.h
@@ -85,4 +85,19 @@ static inline __le32 sctp_end_cksum(__u32 crc32)
 	return cpu_to_le32(~crc32);
 }
 
+/* Calculate the CRC32C checksum of an SCTP packet.  */
+static inline __le32 sctp_compute_cksum(const struct sk_buff *skb,
+					unsigned int offset)
+{
+	const struct sk_buff *iter;
+
+	__u32 crc32 = sctp_start_cksum(skb->data + offset,
+				       skb_headlen(skb) - offset);
+	skb_walk_frags(skb, iter)
+		crc32 = sctp_update_cksum((__u8 *) iter->data,
+					  skb_headlen(iter), crc32);
+
+	return sctp_end_cksum(crc32);
+}
+
 #endif /* __sctp_checksum_h__ */
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 3c0da87..23e596e 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -66,15 +66,7 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 static void sctp_nat_csum(struct sk_buff *skb, sctp_sctphdr_t *sctph,
 			  unsigned int sctphoff)
 {
-	__u32 crc32;
-	struct sk_buff *iter;
-
-	crc32 = sctp_start_cksum((__u8 *)sctph, skb_headlen(skb) - sctphoff);
-	skb_walk_frags(skb, iter)
-		crc32 = sctp_update_cksum((u8 *) iter->data,
-					  skb_headlen(iter), crc32);
-	sctph->checksum = sctp_end_cksum(crc32);
-
+	sctph->checksum = sctp_compute_cksum(skb, sctphoff);
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 }
 
@@ -151,10 +143,7 @@ sctp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp)
 {
 	unsigned int sctphoff;
 	struct sctphdr *sh, _sctph;
-	struct sk_buff *iter;
-	__le32 cmp;
-	__le32 val;
-	__u32 tmp;
+	__le32 cmp, val;
 
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6)
@@ -168,13 +157,7 @@ sctp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp)
 		return 0;
 
 	cmp = sh->checksum;
-
-	tmp = sctp_start_cksum((__u8 *) sh, skb_headlen(skb));
-	skb_walk_frags(skb, iter)
-		tmp = sctp_update_cksum((__u8 *) iter->data,
-					skb_headlen(iter), tmp);
-
-	val = sctp_end_cksum(tmp);
+	val = sctp_compute_cksum(skb, sctphoff);
 
 	if (val != cmp) {
 		/* CRC failure, dump it. */
diff --git a/net/netfilter/nf_nat_proto_sctp.c b/net/netfilter/nf_nat_proto_sctp.c
index 396e55d..754536f 100644
--- a/net/netfilter/nf_nat_proto_sctp.c
+++ b/net/netfilter/nf_nat_proto_sctp.c
@@ -34,9 +34,7 @@ sctp_manip_pkt(struct sk_buff *skb,
 	       const struct nf_conntrack_tuple *tuple,
 	       enum nf_nat_manip_type maniptype)
 {
-	struct sk_buff *frag;
 	sctp_sctphdr_t *hdr;
-	__u32 crc32;
 
 	if (!skb_make_writable(skb, hdroff + sizeof(*hdr)))
 		return false;
@@ -51,11 +49,7 @@ sctp_manip_pkt(struct sk_buff *skb,
 		hdr->dest = tuple->dst.u.sctp.port;
 	}
 
-	crc32 = sctp_start_cksum((u8 *)hdr, skb_headlen(skb) - hdroff);
-	skb_walk_frags(skb, frag)
-		crc32 = sctp_update_cksum((u8 *)frag->data, skb_headlen(frag),
-					  crc32);
-	hdr->checksum = sctp_end_cksum(crc32);
+	hdr->checksum = sctp_compute_cksum(skb, hdroff);
 
 	return true;
 }
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 3fa4d85..944f70e 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -87,15 +87,7 @@ static inline int sctp_rcv_checksum(struct net *net, struct sk_buff *skb)
 {
 	struct sctphdr *sh = sctp_hdr(skb);
 	__le32 cmp = sh->checksum;
-	struct sk_buff *list;
-	__le32 val;
-	__u32 tmp = sctp_start_cksum((__u8 *)sh, skb_headlen(skb));
-
-	skb_walk_frags(skb, list)
-		tmp = sctp_update_cksum((__u8 *)list->data, skb_headlen(list),
-					tmp);
