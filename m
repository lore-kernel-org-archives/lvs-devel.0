From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [RFC PATCH] IPVS: Backup, Adding IPv6 address packing
Date: Fri, 29 Oct 2010 14:22:00 +0200
Message-ID: <1288354920-10994-1-git-send-email-hans.schillstrom@ericsson.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org, daniel.lezcano@free.fr
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>

Add pack/unpack of IPv6 address in sync message
in binary form similar to the ASCII ::

A packed IPv6 address constists of -
first byte
  high nibble first segment leng in bytes
  low nibble  possition of last segment.
then
  First segemnt i.e. left side of ::
  Last segment right side of ::

Examle  FC00::2
unpacked FC00 0000 0000 0000 0000 0000 0000 0002
packed   1F FC02
Example 2 2003::2:100
unpacked 2003 0000 0000 0000 0000 0000 0002 0100
packed   2D 20 03 02 01 00

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 net/netfilter/ipvs/ip_vs_sync.c |  128 +++++++++++++++++++++++++++++++++++---
 1 files changed, 117 insertions(+), 11 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 00f0fd3..6b4976c 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -363,6 +363,65 @@ get_curr_sync_buff(unsigned long time)
 	return sb;
 }
 
+/*
+ * Try to pack an IPv6 address
+ * Note that buffer must be at least 17 bytes
+ *
+ * Packing adds a byte before packed address
+ * m.s.nibble first segment size in bytes
+ * l.s.nibble last segment start offset in bytes (size = 16 - lastSeg)
+ *
+ * Return packed size, 0=no reduction
+ *        buffer contains first/lastSegemnt + (un)packed address
+ *
+ */
+static int ipv6addr_pack(struct in6_addr *in6, char *buffer)
+{
+	int i, pos=0, score=0;
+	int lmatch=0, firstSeg=0,lastSeg=0;
+	char *addr = in6->s6_addr;
+	char *buff = buffer;
+
+	/* Check for more than 3 bytes of zeroes */
+	for( i=0; i<16; i++) {
+		if ( *(addr++) ) {
+			score = 0;
+			continue;
+		}
+		if ( !score )
+			pos = i;
+		score++;
+		if (score > lmatch) {
+			lmatch = score;
+			firstSeg = pos;	/* Start of longest match */
+		}
+	}
+	lastSeg = firstSeg + lmatch;
+	addr = in6->s6_addr;
+	/* Store length of first seg then size of last seg */
+	*(buff++) = (firstSeg<<4 & 0xf0) | (lastSeg & 0xf);
+	memcpy(buff, addr, firstSeg);	/* Copy first segment */
+	buff += firstSeg;
+	memcpy(buff, addr+lastSeg, 16-lastSeg);
+	return 16 - lmatch;
+}
+/*
+ * unpack IPv6 address packed by above func.
+ */
+static int ipv6addr_unpack(char *buff, struct in6_addr *addr)
+{
+	int firstSeg, lastSeg;
+
+	firstSeg = (*buff >> 4) & 0xf;
+	lastSeg = *(buff++) & 0xf;
+	addr->s6_addr32[0] = 0;
+	addr->s6_addr32[1] = 0;
+	addr->s6_addr32[2] = 0;
+	addr->s6_addr32[3] = 0;
+	memcpy(addr->s6_addr, buff, firstSeg);
+	memcpy(addr->s6_addr+lastSeg, buff+firstSeg, 16-lastSeg);
+	return 0;
+}
 
 /*
  *      Add an ip_vs_conn information into the current sync_buff.
@@ -406,8 +465,8 @@ void ip_vs_sync_conn(struct ip_vs_conn *cp)
 		len += pe_name_len + 2;
 	len = (len+3) & 0xffc;		/* Final 32 bit alignment */
 
-	/* check if there is a space for this one */
-	if (curr_sb && (curr_sb->head+len > curr_sb->end) ) {
+	/* check if there is a space for this one and offest for ipv6 pack*/
+	if (curr_sb && (curr_sb->head+len+4 > curr_sb->end) ) {
 		sb_queue_tail(curr_sb);
 		curr_sb = NULL;
 	}
@@ -441,10 +500,26 @@ void ip_vs_sync_conn(struct ip_vs_conn *cp)
 
 #ifdef CONFIG_IP_VS_IPV6
 	if (cp->af == AF_INET6 ) {
-		p += sizeof(struct ip_vs_sync_v6);
-		ipv6_addr_copy(&s->v6.caddr, &cp->caddr.in6);
-		ipv6_addr_copy(&s->v6.vaddr, &cp->vaddr.in6);
-		ipv6_addr_copy(&s->v6.daddr, &cp->daddr.in6);
+		int psz;
+		p = (char *)&s->v6.caddr;
+		psz = ipv6addr_pack(&cp->caddr.in6, p);
+		psz += ipv6addr_pack(&cp->vaddr.in6, p+psz+1);
+		psz += ipv6addr_pack(&cp->vaddr.in6, p+psz+2);
+		if( psz >= 6 ) {
+			psz += 3;
+			p += psz;
+			s->v6.type |= STYPE_INET6_PACK;
+			len -= ((sizeof(struct in6_addr) * 3) - psz);
+			psz = sizeof(struct ip_vs_sync_v6)
+			      - (sizeof(struct in6_addr) * 3) + psz;
+			s->v6.ver_size = htons(psz & SVER_MASK);
+		}
+		else {
+			p += sizeof(struct ip_vs_sync_v6);
+			ipv6_addr_copy(&s->v6.caddr, &cp->caddr.in6);
+			ipv6_addr_copy(&s->v6.vaddr, &cp->vaddr.in6);
+			ipv6_addr_copy(&s->v6.daddr, &cp->daddr.in6);
+		}
 	} else
 #endif
 	{
@@ -508,13 +583,14 @@ ip_vs_conn_fill_param_sync(int af, union ip_vs_sync_conn *sc,
 			   int pe_data_len, char *pe_name, int pe_name_len )
 {
 #ifdef CONFIG_IP_VS_IPV6
-	if ( af == AF_INET6 )
-		ip_vs_conn_fill_param(af, sc->v6.protocol,
+	if ( af == AF_INET6 ) {
+		if (!(sc->v6.type & STYPE_INET6_PACK))
+			ip_vs_conn_fill_param(af, sc->v6.protocol,
 				   (const union nf_inet_addr *)&sc->v6.caddr,
 				   sc->v6.cport,
 				   (const union nf_inet_addr *)&sc->v6.vaddr,
 				   sc->v6.vport, p);
-	else
+	} else
 #endif
 		ip_vs_conn_fill_param(af, sc->v4.protocol,
 				   (const union nf_inet_addr *)&sc->v4.caddr,
@@ -780,7 +856,16 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
 		if (s->v6.type & STYPE_INET6  ) {
 #ifdef CONFIG_IP_VS_IPV6
 			af = AF_INET6;
-			p += sizeof(struct ip_vs_sync_v6);
+			if (s->v6.type & STYPE_INET6_PACK  ) {
+				p = (char*) &s->v6.caddr;
+				p += 1 + ((*p >> 4) & 0xf) /* len + First seg */
+				   + (16 - (*p & 0xf ));   /* + Last seg */
+				p += 1 + ((*p >> 4) & 0xf) /* len + First seg */
+				   + (16 - (*p & 0xf ));   /* + Last seg */
+				p += 1 + ((*p >> 4) & 0xf) /* len + First seg */
+				   + (16 - (*p & 0xf ));   /* + Last seg */
+			} else
+				p += sizeof(struct ip_vs_sync_v6);
 #else
 			IP_VS_DBG(2,"IPv6 sync message received, and IPVS is not compiled for IPv6\n");
 			p = (char *)s + size;		
@@ -891,7 +976,27 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
 				         ? &opt : NULL),
 				        pp);
 #ifdef CONFIG_IP_VS_IPV6
-		else
+		else {
+			/* Check if packed IPv6 */
+			if (s->v6.type & STYPE_INET6_PACK  ) {
+				union nf_inet_addr vaddr, daddr, caddr;
+				int ret;
+				p = (char*) &s->v6.caddr;
+				ret = ipv6addr_unpack(p, &caddr.in6);
+				p += 1 + ((*p >> 4) & 0xf) + (16 - (*p & 0xf ));
+				ret |= ipv6addr_unpack(p, &vaddr.in6);
+				p += 1 + ((*p >> 4) & 0xf) + (16 - (*p & 0xf ));
+				ret |= ipv6addr_unpack(p, &daddr.in6);
+				if (ret) {
+					IP_VS_ERR_RL("Invalid packed IPv6 add in sync msg\n");
+					return;
+				}
+				ip_vs_conn_fill_param(af, s->v6.protocol,
+						      &caddr, s->v6.cport,
+						      &vaddr, s->v6.vport,
+						      &param);
+
+			}
 			ip_vs_proc_conn(&param, flags, state, s->v6.protocol,
 					af,
 					(union nf_inet_addr *)&s->v6.daddr,
@@ -900,6 +1005,7 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
 				        (opt_flags & IPVS_OPT_F_SEQ_DATA
 				          ? &opt : NULL),
 				        pp);
+		}
 #endif
 		p = (char *)s + size;
 	} /* End of for(...) */
-- 
1.7.0.1

