Received: from mail-vs2-f12.google.com (mail-vs2-f12.google.com [74.125.227.12])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3128333B6CC
	for <lvs-devel@vger.kernel.org>; Sat, 12 Sep 2026 01:32:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.12
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789176779; cv=none; b=dmnk0CYMgdcc/wBONDUnz+qbzxo3YeNGlbKAN62J4nA0zecKIU44thZC8G1vs3jMVuh6eSX/DOOE4hyklK+9ydvK3rdiHdjXMlzDF6AD1g6LeCwzFKpt6PjLxWSMshlxp2EESI2FwzQaCGs6fP9xGRTkJk4iElE7M2cw18ybz00=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789176779; c=relaxed/simple;
	bh=6g+cSL0eBdklucjqJhFyJhyJSxkvcSVMcXhtt6jEgBQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=fLYL2R4/Bpof7ngRcRH7DXY5yI5PGjByI3gOWuBDLOspqLARaTCzEsml3UydxliM1dzL5UHM7WsrFW/7tnUV/yo0PbzB40FgdHrKDyknj8EOlSYYaPEbDG5ot+ApA/K8UNOL8wwheBWv/XIFzmZAJkl0/8O20uqEEkkycVRorcE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=cC4n8DtK; arc=none smtp.client-ip=74.125.227.12
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cC4n8DtK"
Received: by mail-vs2-f12.google.com with SMTP id 71dfb90a1353d-5c67e5059f9so78271e0c.2
        for <lvs-devel@vger.kernel.org>; Fri, 11 Sep 2026 18:32:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1789176776; x=1789781576; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=6xHTJJRtR4916mrRZnOLh8f72NSc1e/a8/mS38X8f0w=;
        b=cC4n8DtKXeqnXyuJXJki2aR3OIiaO9VzjbQQmM7Q6SZ4sJWzaBt9eWNTFlHCRrUTsZ
         bTR2S0+g9F8SFwUXisCMJlJK8voIcwmsOmLe1l2WkShtXtabUExT5R4MsjnZe9uy3zSw
         MkKxHzxhKh4H0aM6LX2fMn0T7x5kr/nCO//q7IikAkUsTJfLFfcKisvInEvNsBLkh4yK
         8a3oKa6xtO//n4SEY0p9uNvH/vBE0vUADxKgYcvdGHuBsOisgM1l5khZitkhQytTiHDJ
         kNJpSOPB3hxM0SgUMfJlx9dOevCyvkffBsSimFsFadW/naX5Gm4s5A9lnfnTfQjFPRo7
         xJ0A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1789176776; x=1789781576;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=6xHTJJRtR4916mrRZnOLh8f72NSc1e/a8/mS38X8f0w=;
        b=jZbRuuJ86a24yXfvjvs45FtFMSCRldQykKt08m2licFjOzstNytCIERg/wHqPVKW83
         SWou5bkL8B4/kRgIpsjBbQdZfkZAPruyzGt4nd/VwB2hHbFNKjuAffZYuuJkFxCIv6Fo
         apzEZAR/W4tU6Wb2MM9DOWPDmZPIDnGblYoA7/rk7aCVDr4a/GD6rtzDwBl2xn1ZRVH9
         4GalZf3LvOv6K3DLMDiPG5kd9kkePOQZzMg9Ny+a+rw87wR2hLi2CDhvL1fuZ9Z6rNKj
         Wg2dvthx3GVTtKBaNRPV4SNVU9NcGJWQtdPersvCUs2TvSCduAqCjAEBfXdfNrEVFYva
         IJPQ==
X-Forwarded-Encrypted: i=1; AKwUvBwskzMUpMorzq4qa4PCaNym86EWB2Q9Y3hvqyjaXvZTrLWYpkwq3024VWOenrLyrCzGMjUzjzkCU3w=@vger.kernel.org
X-Gm-Message-State: AFuF++mG8oRi/r0nNVuH870J2FFapCNPw9pYX8sAXHLwYFQ2km7d1HFU
	QNmimJDzWqlv3ARVxXW1QS+KFh4HVomqpsqRQi7wvqeIWYC+K1XPbNF/
X-Gm-Gg: AYBFou3APaOirxRsxw3HrtzZ0vEw1DzvKpExYiMUb8ZRXH+stABDbOLzpFlZwt3pV/8
	hb0xrXjeYkP2Yqv+vwIXJNTAOp7Fqcpr7qK1mn+J2pw+R1/igN2Uu23RlRX76Xc+0qWITeuid3J
	vzebHsMmXh+EQvVh6FG7gwkAKr3/m9qEp65Jz1jjncyi34HNPzeI+1vndqKrvuPynf5JzlvMqkV
	rMET+haOzyzGhF4ouoPN8joFuRfL0pfyXwdXrNaToOGiftKt995jlJGYDQhJoudUIMbwwgaTZAN
	tkMRwl5D7jFYeeDgnotJcxQxb7DESTOxPKGRM9n9y7mJ2GMyAjh9ok/7TqgeB0Ge3WQGmRZO0tN
	nB3iYLhOzL+vyUSdfM6pID4x8AQED4KUVGyG/arYRu+iZxcEPRGdQ7GvY/7M/prWPu6dyBpWRSh
	5b8In4sQoESoZ118Ub8RqngVAtCJ4DIidgSfS2qq/w3VOJKqE9XxPjT9E4SMS3pqo3h+QXjYHMD
	g==
X-Received: by 2002:a05:6122:3a12:b0:5c8:46e3:ec57 with SMTP id 71dfb90a1353d-5c965d63416mr817017e0c.1.1789176776008;
        Fri, 11 Sep 2026 18:32:56 -0700 (PDT)
Received: from adriano ([190.215.95.120])
        by smtp.gmail.com with ESMTPSA id 71dfb90a1353d-5c84714c380sm4738262e0c.15.2026.09.11.18.32.52
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 11 Sep 2026 18:32:55 -0700 (PDT)
From: Adriano Cordova <adrianox@gmail.com>
To: Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	Phil Sutter <phil@nwl.cc>,
	"David S . Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Shuah Khan <shuah@kernel.org>,
	netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Adriano Cordova <adrianox@gmail.com>
Subject: [PATCH 4/4] selftests: netfilter: ipvs: add per-service secure_tcp test
Date: Fri, 11 Sep 2026 22:32:16 -0300
Message-ID: <20260912013216.588300-5-adrianox@gmail.com>
X-Mailer: git-send-email 2.51.0
In-Reply-To: <20260912013216.588300-1-adrianox@gmail.com>
References: <20260912013216.588300-1-adrianox@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Two services share a VIP, one carrying IP_VS_SVC_F_SECURE_TCP.
A bare SYN+ACK suffices to test the state machine: the normal
service reaches ESTABLISHED, but the secure one stays in SYN_RECV.

Assisted-by: opencode
Signed-off-by: Adriano Cordova <adrianox@gmail.com>
---
 .../testing/selftests/net/netfilter/Makefile  |   6 +
 .../selftests/net/netfilter/gen_tcp_probe.c   | 127 +++++++
 .../net/netfilter/ipvs_secure_tcp.sh          | 158 +++++++++
 .../net/netfilter/ipvs_secure_tcp_mln.c       | 310 ++++++++++++++++++
 4 files changed, 601 insertions(+)
 create mode 100644 tools/testing/selftests/net/netfilter/gen_tcp_probe.c
 create mode 100755 tools/testing/selftests/net/netfilter/ipvs_secure_tcp.sh
 create mode 100644 tools/testing/selftests/net/netfilter/ipvs_secure_tcp_mln.c

diff --git a/tools/testing/selftests/net/netfilter/Makefile b/tools/testing/selftests/net/netfilter/Makefile
index f88dd4ef8d26..fad05afadd41 100644
--- a/tools/testing/selftests/net/netfilter/Makefile
+++ b/tools/testing/selftests/net/netfilter/Makefile
@@ -20,6 +20,7 @@ TEST_PROGS := \
 	conntrack_tcp_unreplied.sh \
 	conntrack_vrf.sh \
 	ipvs.sh \
+	ipvs_secure_tcp.sh \
 	nf_conntrack_packetdrill.sh \
 	nf_nat_edemux.sh \
 	nft_audit.sh \
@@ -50,6 +51,8 @@ TEST_GEN_FILES = \
 	connect_close \
 	conntrack_dump_flush \
 	conntrack_reverse_clash \
+	gen_tcp_probe \
+	ipvs_secure_tcp_mln \
 	nf_queue \
 	sctp_collision \
 	udpclash \
@@ -60,6 +63,9 @@ include ../../lib.mk
 $(OUTPUT)/nf_queue: CFLAGS += $(MNL_CFLAGS)
 $(OUTPUT)/nf_queue: LDLIBS += $(MNL_LDLIBS)
 
+$(OUTPUT)/ipvs_secure_tcp_mln: CFLAGS += $(MNL_CFLAGS)
+$(OUTPUT)/ipvs_secure_tcp_mln: LDLIBS += $(MNL_LDLIBS)
+
 $(OUTPUT)/conntrack_dump_flush: CFLAGS += $(MNL_CFLAGS)
 $(OUTPUT)/conntrack_dump_flush: LDLIBS += $(MNL_LDLIBS)
 $(OUTPUT)/udpclash: LDLIBS += -lpthread
diff --git a/tools/testing/selftests/net/netfilter/gen_tcp_probe.c b/tools/testing/selftests/net/netfilter/gen_tcp_probe.c
new file mode 100644
index 000000000000..d62bfdce70c0
--- /dev/null
+++ b/tools/testing/selftests/net/netfilter/gen_tcp_probe.c
@@ -0,0 +1,127 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Send a TCP SYN then a TCP ACK (no SYN-ACK, no data) to the VIP.
+ * IPVS's TCP state machine only inspects SYN/FIN/ACK/RST bits, so this
+ * exercises the INPUT-direction state transition:
+ *
+ *   SYN:  NONE -> SYN_RECV
+ *   ACK:  SYN_RECV -> ESTABLISHED   (tcp_states, normal)
+ *         SYN_RECV -> SYN_RECV      (tcp_states_dos, secure_tcp)
+ *
+ * Requires CAP_NET_RAW.
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <unistd.h>
+#include <stdint.h>
+#include <arpa/inet.h>
+#include <sys/socket.h>
+#include <netinet/ip.h>
+#include <netinet/tcp.h>
+#include <linux/if_ether.h>
+
+static inline uint16_t csump(const void *data, size_t len)
+{
+	const uint16_t *p = data;
+	uint32_t sum = 0;
+
+	while (len > 1) {
+		sum += *p++;
+		len -= 2;
+	}
+	if (len)
+		sum += *(const uint8_t *)p;
+	while (sum >> 16)
+		sum = (sum & 0xffff) + (sum >> 16);
+	return ~sum;
+}
+
+static void send_seg(int fd, const struct in_addr *sip, uint16_t sport,
+		     const struct in_addr *dip, uint16_t dport,
+		     uint32_t seq, int syn, int ack)
+{
+	uint8_t pkt[sizeof(struct iphdr) + sizeof(struct tcphdr)] = { 0 };
+	struct iphdr *ip = (struct iphdr *)pkt;
+	struct tcphdr *tcp = (struct tcphdr *)(pkt + sizeof(struct iphdr));
+	struct sockaddr_in dst;
+
+	ip->version = 4;
+	ip->ihl = 5;
+	ip->tot_len = htons(sizeof(pkt));
+	ip->id = htons((uint16_t)(seq & 0xffff));
+	ip->ttl = 64;
+	ip->protocol = IPPROTO_TCP;
+	ip->saddr = sip->s_addr;
+	ip->daddr = dip->s_addr;
+
+	tcp->source = sport;
+	tcp->dest = dport;
+	tcp->seq = htonl(seq);
+	tcp->ack_seq = htonl(seq + 1);
+	tcp->doff = 5;
+	if (syn)
+		tcp->syn = 1;
+	if (ack)
+		tcp->ack = 1;
+	tcp->window = htons(1024);
+
+	ip->check = csump(ip, sizeof(struct iphdr));
+	/* pseudo header for TCP checksum */
+	{
+		uint8_t ph[12];
+
+		memcpy(ph, &ip->saddr, 4);
+		memcpy(ph + 4, &ip->daddr, 4);
+		ph[8] = 0;
+		ph[9] = IPPROTO_TCP;
+		ph[10] = (sizeof(struct tcphdr) >> 8) & 0xff;
+		ph[11] = sizeof(struct tcphdr) & 0xff;
+
+		uint8_t tcpbuf[12 + sizeof(struct tcphdr)];
+
+		memcpy(tcpbuf, ph, 12);
+		memcpy(tcpbuf + 12, tcp, sizeof(struct tcphdr));
+		tcp->check = csump(tcpbuf, sizeof(tcpbuf));
+	}
+
+	memset(&dst, 0, sizeof(dst));
+	dst.sin_family = AF_INET;
+	dst.sin_addr = *dip;
+	dst.sin_port = dport;
+	sendto(fd, pkt, sizeof(pkt), 0, (struct sockaddr *)&dst,
+	       sizeof(dst));
+}
+
+int main(int argc, char *argv[])
+{
+	struct in_addr sip, dip;
+	uint16_t sport, dport;
+	int fd, one = 1;
+	uint32_t seq = 0x12345678;
+
+	if (argc != 5) {
+		fprintf(stderr, "usage: %s <src_ip> <src_port> <dst_ip> <dst_port>\n",
+			argv[0]);
+		return 2;
+	}
+	inet_pton(AF_INET, argv[1], &sip);
+	sport = htons((uint16_t)atoi(argv[2]));
+	inet_pton(AF_INET, argv[3], &dip);
+	dport = htons((uint16_t)atoi(argv[4]));
+
+	fd = socket(AF_INET, SOCK_RAW, IPPROTO_RAW);
+	if (fd < 0) {
+		perror("raw socket");
+		return 1;
+	}
+	setsockopt(fd, IPPROTO_IP, IP_HDRINCL, &one, sizeof(one));
+
+	send_seg(fd, &sip, sport, &dip, dport, seq, 1, 0);
+	usleep(100000);
+	send_seg(fd, &sip, sport, &dip, dport, seq + 1, 0, 1);
+
+	close(fd);
+	return 0;
+}
diff --git a/tools/testing/selftests/net/netfilter/ipvs_secure_tcp.sh b/tools/testing/selftests/net/netfilter/ipvs_secure_tcp.sh
new file mode 100755
index 000000000000..b079c0fe6b79
--- /dev/null
+++ b/tools/testing/selftests/net/netfilter/ipvs_secure_tcp.sh
@@ -0,0 +1,158 @@
+#!/bin/bash
+# SPDX-License-Identifier: GPL-2.0
+#
+# Runtime test for per-service secure_tcp (IP_VS_SVC_F_SECURE_TCP).
+#
+# Sets up the same 3-namespace topology as ipvs.sh
+# but checks the TCP state machine, not data forwarding.  Two
+# identical TCP services are added on the same VIP on different ports,
+# one is marked secure_tcp, the other is not. For each a bare SYN is
+# followed by a bare ACK (no SYN-ACK / no data).  IPVS classifies the
+# connection from the flag bits:
+#   * normal service:  SYN -> SYN_RECV, ACK -> ESTABLISHED
+#   * secure_tcp service:  SYN -> SYN_RECV, ACK -> SYN_RECV
+# This test checks that this is the case via `ipvsadm -Lnc`.
+#
+# Requires root, netns, ipvsadm, nft, and the built helpers
+# ipvs_secure_tcp_mln and gen_tcp_probe.
+
+source lib.sh
+
+ret=0
+readonly vip="207.175.44.110"
+readonly gip="10.0.0.1"
+readonly dip="172.16.0.1"
+readonly rip="172.16.0.2"
+readonly cip="10.0.0.2"
+readonly sip="10.0.0.3"
+readonly port_secure=8081
+readonly port_plain=8080
+
+GREEN='\033[0;92m'
+RED='\033[0;31m'
+NC='\033[0m'
+
+checktool "ipvsadm -v" "run test without ipvsadm"
+checktool "nft --version" "run test without nft"
+
+setup() {
+	setup_ns ns0 ns1 ns2
+
+	ip link add veth01 netns "${ns0}" type veth peer name veth10 netns "${ns1}"
+	ip link add veth02 netns "${ns0}" type veth peer name veth20 netns "${ns2}"
+	ip link add veth12 netns "${ns1}" type veth peer name veth21 netns "${ns2}"
+
+	ip netns exec "${ns0}" ip link set veth01 up
+	ip netns exec "${ns0}" ip link set veth02 up
+	ip netns exec "${ns0}" ip link add br0 type bridge
+	ip netns exec "${ns0}" ip link set veth01 master br0
+	ip netns exec "${ns0}" ip link set veth02 master br0
+	ip netns exec "${ns0}" ip link set br0 up
+	ip netns exec "${ns0}" ip addr add "${cip}/24" dev br0
+
+	ip netns exec "${ns1}" ip link set veth10 up
+	ip netns exec "${ns1}" ip addr add "${gip}/24" dev veth10
+	ip netns exec "${ns1}" ip link set veth12 up
+	ip netns exec "${ns1}" ip addr add "${dip}/24" dev veth12
+	ip netns exec "${ns1}" ip link set lo up
+	ip netns exec "${ns1}" ip addr add "${vip}/32" dev lo:1
+	ip netns exec "${ns1}" sysctl -qw net.ipv4.ip_forward=1
+
+	ip netns exec "${ns2}" ip link set veth20 up
+	ip netns exec "${ns2}" ip addr add "${sip}/24" dev veth20
+	ip netns exec "${ns2}" ip link set veth21 up
+	ip netns exec "${ns2}" ip addr add "${rip}/24" dev veth21
+
+	ip netns exec "${ns2}" ip addr add "${vip}/32" dev lo:1
+
+	ip netns exec "${ns0}" ip route add "${vip}/32" via "${gip}" dev br0
+
+	# load ipvs, then the rr scheduler (separate calls: modprobe treats
+	# the second name as a module parameter, not a second module)
+	ip netns exec "${ns1}" modprobe ip_vs
+	ip netns exec "${ns1}" modprobe ip_vs_rr
+
+	sleep 1
+}
+
+cleanup() {
+	cleanup_all_ns
+}
+
+# State of the connection to the VIP:port, from `ipvsadm -Lnc`.
+# Fields: pro  expire  state  source  virtual  destination
+conn_state() {
+	local vport=$1
+	ip netns exec "${ns1}" ipvsadm -Lnc 2>/dev/null |
+		awk -v vt="${vip}:${vport}" '$5==vt { print $3; exit }'
+}
+
+assert_state() {
+	local port=$1 want=$2
+	local got
+	got="$(conn_state "$port")"
+	echo "  vip ${vip}:${port}: state=${got:-?}"
+	if [ "${got:-}" != "$want" ]; then
+		echo -e "${RED}FAIL${NC}: vip ${vip}:${port} expected state" \
+			"${want}, got ${got:-none}"
+		ret=1
+	fi
+}
+
+test_secure() {
+	local bin probe
+
+	# Register the two services (secure_tcp on the secure port)
+	bin="$(pwd)/ipvs_secure_tcp_mln"
+	probe="$(pwd)/gen_tcp_probe"
+	ip netns exec "${ns1}" "$bin" add "${vip}" "${port_secure}" secure
+	ip netns exec "${ns1}" "$bin" add "${vip}" "${port_plain}" plain
+
+	# Add a real server to both services.  Use NAT (-m): in DR the conn gets
+	# IP_VS_CONN_F_NOOUTPUT, which makes the client ACK an INPUT_ONLY event
+	# and even tcp_states_dos promotes to ESTABLISHED, hiding the difference.
+	ip netns exec "${ns1}" ipvsadm -a -m -t "${vip}:${port_secure}" -r "${rip}:${port_secure}"
+	ip netns exec "${ns1}" ipvsadm -a -m -t "${vip}:${port_plain}" -r "${rip}:${port_plain}"
+
+	# verify the flag was actually set
+	local got
+	got="$(ip netns exec "${ns1}" "$bin" get "${vip}" "${port_secure}")"
+	echo "  secured service reports: ${got}"
+	echo "${got}" | grep -q "secure_tcp=1" ||
+		{ echo -e "${RED}FAIL${NC}: flag not set"; ret=1; }
+	got="$(ip netns exec "${ns1}" "$bin" get "${vip}" "${port_plain}")"
+	echo "${got}" | grep -q "secure_tcp=0" ||
+		{ echo -e "${RED}FAIL${NC}: flag unexpectedly set"; ret=1; }
+
+	# Drop any SYN on the real server so it stays silent (no RST that
+	# would interfere with the state-machine observation).
+	ip netns exec "${ns2}" nft add table inet filter
+	ip netns exec "${ns2}" nft add chain inet filter probe \
+		'{ type filter hook input priority 0; }'
+	ip netns exec "${ns2}" nft add rule inet filter probe \
+		tcp dport '{ '"${port_secure}"', '"${port_plain}"' }' drop
+
+	# Push SYN then ACK to each service from the client
+	ip netns exec "${ns0}" "$probe" "${cip}" 40000 "${vip}" "${port_secure}"
+	ip netns exec "${ns0}" "$probe" "${cip}" 40001 "${vip}" "${port_plain}"
+	sleep 1
+
+	echo "Testing per-service secure_tcp..."
+	echo "  --- connection table (ipvsadm -Lnc) ---"
+	ip netns exec "${ns1}" ipvsadm -Lnc 2>/dev/null
+	echo "  --- end connection table ---"
+	assert_state "${port_plain}" ESTABLISHED
+	assert_state "${port_secure}" SYN_RECV
+}
+
+trap cleanup EXIT
+
+setup
+test_secure
+
+if [ "$ret" -ne 0 ]; then
+	echo -e "$(basename $0): ${RED}FAIL${NC}"
+	exit 1
+fi
+echo -e "$(basename $0): ${GREEN}PASS${NC}"
+exit 0
diff --git a/tools/testing/selftests/net/netfilter/ipvs_secure_tcp_mln.c b/tools/testing/selftests/net/netfilter/ipvs_secure_tcp_mln.c
new file mode 100644
index 000000000000..c15a3c28e6fe
--- /dev/null
+++ b/tools/testing/selftests/net/netfilter/ipvs_secure_tcp_mln.c
@@ -0,0 +1,310 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * libmnl helper to set/query the per-service secure_tcp flag
+ * (IP_VS_SVC_F_SECURE_TCP), which ipvsadm does not expose.
+ *
+ * Usage:
+ *   ipvs_secure_tcp_mln add <vip> <port> <secure|plain>
+ *       Create a TCP virtual service (scheduler "rr") with the flag either
+ *       set or not.  Add real servers afterwards with:
+ *           ipvsadm -a -t <vip>:<port> -r <rs>:<port>
+ *   ipvs_secure_tcp_mln get <vip> <port>
+ *       Print "secure_tcp=<0|1>" for the service.
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <errno.h>
+#include <arpa/inet.h>
+
+#include <linux/netlink.h>
+#include <linux/genetlink.h>
+#include <linux/ip_vs.h>
+
+#include <libmnl/libmnl.h>
+
+/* Fallback in case the kernel's installed uapi header is older */
+#ifndef IP_VS_SVC_F_SECURE_TCP
+#define IP_VS_SVC_F_SECURE_TCP	0x0040
+#endif
+
+/* 16-byte address storage, matching union nf_inet_addr for AF_INET */
+struct inet_addr16 {
+	uint8_t all[16];
+};
+
+/* ---------------- family resolver ---------------- */
+static int ctrl_attr_cb(const struct nlattr *attr, void *data)
+{
+	const struct nlattr **tb = data;
+	int type = mnl_attr_get_type(attr);
+
+	if (mnl_attr_type_valid(attr, CTRL_ATTR_MAX) < 0)
+		return MNL_CB_ERROR;
+	if (type == CTRL_ATTR_FAMILY_ID) {
+		if (mnl_attr_validate(attr, MNL_TYPE_U16) < 0)
+			return MNL_CB_ERROR;
+		tb[CTRL_ATTR_FAMILY_ID] = attr;
+	}
+	return MNL_CB_OK;
+}
+
+static int ctrl_data_cb(const struct nlmsghdr *nlh, void *data)
+{
+	const struct nlattr *tb[CTRL_ATTR_MAX + 1] = { 0 };
+	uint16_t *fam = data;
+
+	if (nlh->nlmsg_type != GENL_ID_CTRL)
+		return MNL_CB_OK;
+	mnl_attr_parse(nlh, sizeof(struct genlmsghdr),
+		       (mnl_attr_cb_t)ctrl_attr_cb, tb);
+	if (tb[CTRL_ATTR_FAMILY_ID]) {
+		*fam = mnl_attr_get_u16(tb[CTRL_ATTR_FAMILY_ID]);
+		return MNL_CB_STOP;
+	}
+	return MNL_CB_OK;
+}
+
+static int resolve_family(const char *name, uint16_t *fam)
+{
+	struct mnl_socket *nl;
+	char buf[MNL_SOCKET_BUFFER_SIZE];
+	struct nlmsghdr *nlh;
+	struct genlmsghdr *genl;
+	int ret;
+
+	nl = mnl_socket_open(NETLINK_GENERIC);
+	if (!nl)
+		return -errno;
+	mnl_socket_bind(nl, 0, 0);
+
+	nlh = mnl_nlmsg_put_header(buf);
+	genl = mnl_nlmsg_put_extra_header(nlh, sizeof(struct genlmsghdr));
+	genl->cmd = CTRL_CMD_GETFAMILY;
+	genl->version = 1;
+	nlh->nlmsg_type = GENL_ID_CTRL;
+	nlh->nlmsg_flags = NLM_F_REQUEST;
+	mnl_attr_put_strz(nlh, CTRL_ATTR_FAMILY_NAME, name);
+
+	if (mnl_socket_sendto(nl, nlh, nlh->nlmsg_len) < 0) {
+		mnl_socket_close(nl);
+		return -errno;
+	}
+	do {
+		ret = mnl_socket_recvfrom(nl, buf, sizeof(buf));
+		if (ret < 0) {
+			if (errno == EAGAIN)
+				continue;
+			mnl_socket_close(nl);
+			return -errno;
+		}
+		ret = mnl_cb_run(buf, ret, 0, mnl_socket_get_portid(nl),
+				 (mnl_cb_t)ctrl_data_cb, fam);
+	} while (ret > 0 && *fam == 0);
+
+	mnl_socket_close(nl);
+	return *fam ? 0 : -ENOENT;
+}
+
+/* ---------------- fill service identifying attrs ---------------- */
+static int fill_service(struct nlmsghdr *nlh, const char *vip,
+			uint16_t port, int full, int secure)
+{
+	struct inet_addr16 vaddr = { 0 };
+	struct nlattr *nest;
+	struct ip_vs_flags fl;
+	int af = AF_INET;
+
+	if (inet_pton(af, vip, vaddr.all) != 1) {
+		fprintf(stderr, "bad VIP %s\n", vip);
+		return -EINVAL;
+	}
+
+	nest = mnl_attr_nest_start(nlh, IPVS_CMD_ATTR_SERVICE);
+	mnl_attr_put_u16(nlh, IPVS_SVC_ATTR_AF, af);
+	mnl_attr_put_u16(nlh, IPVS_SVC_ATTR_PROTOCOL, IPPROTO_TCP);
+	mnl_attr_put(nlh, IPVS_SVC_ATTR_ADDR, sizeof(vaddr), &vaddr);
+	/* port/be16: port is passed in network order from main() */
+	mnl_attr_put_u16(nlh, IPVS_SVC_ATTR_PORT, port);
+
+	if (full) {
+		mnl_attr_put_strz(nlh, IPVS_SVC_ATTR_SCHED_NAME, "rr");
+		memset(&fl, 0, sizeof(fl));
+		fl.mask = IP_VS_SVC_F_SECURE_TCP;
+		if (secure)
+			fl.flags = IP_VS_SVC_F_SECURE_TCP;
+		mnl_attr_put(nlh, IPVS_SVC_ATTR_FLAGS, sizeof(fl), &fl);
+		mnl_attr_put_u32(nlh, IPVS_SVC_ATTR_TIMEOUT, 0);
+		mnl_attr_put_u32(nlh, IPVS_SVC_ATTR_NETMASK, 0xffffffff);
+	}
+	mnl_attr_nest_end(nlh, nest);
+	return 0;
+}
+
+static int send_cmd(struct mnl_socket *nl, struct nlmsghdr *nlh)
+{
+	if (mnl_socket_sendto(nl, nlh, nlh->nlmsg_len) < 0) {
+		perror("sendto");
+		return -1;
+	}
+	return 0;
+}
+
+/* ---------------- get secure flag ---------------- */
+static int svc_attr_cb(const struct nlattr *attr, void *data)
+{
+	const struct nlattr **tb = data;
+	int type = mnl_attr_get_type(attr);
+
+	if (mnl_attr_type_valid(attr, IPVS_SVC_ATTR_MAX) < 0)
+		return MNL_CB_ERROR;
+	tb[type] = attr;
+	return MNL_CB_OK;
+}
+
+static int get_cb(const struct nlmsghdr *nlh, void *data)
+{
+	const struct nlattr *tb[IPVS_SVC_ATTR_MAX + 1] = { 0 };
+	struct ip_vs_flags fl;
+	int *secure = data;
+	struct nlattr *nest;
+
+	mnl_attr_for_each(nest, nlh, sizeof(struct genlmsghdr)) {
+		if (mnl_attr_get_type(nest) == IPVS_CMD_ATTR_SERVICE)
+			mnl_attr_parse_nested(nest, (mnl_attr_cb_t)svc_attr_cb, tb);
+	}
+	if (tb[IPVS_SVC_ATTR_FLAGS]) {
+		memcpy(&fl, mnl_attr_get_payload(tb[IPVS_SVC_ATTR_FLAGS]),
+		       sizeof(fl));
+		*secure = !!(fl.flags & IP_VS_SVC_F_SECURE_TCP);
+	}
+	return MNL_CB_STOP;
+}
+
+static int do_get(uint16_t fam, const char *vip, uint16_t port)
+{
+	struct mnl_socket *nl;
+	char buf[MNL_SOCKET_BUFFER_SIZE];
+	struct nlmsghdr *nlh;
+	struct genlmsghdr *genl;
+	int ret, secure = -1;
+
+	nl = mnl_socket_open(NETLINK_GENERIC);
+	mnl_socket_bind(nl, 0, 0);
+	nlh = mnl_nlmsg_put_header(buf);
+	genl = mnl_nlmsg_put_extra_header(nlh, sizeof(struct genlmsghdr));
+	genl->cmd = IPVS_CMD_GET_SERVICE;
+	genl->version = IPVS_GENL_VERSION;
+	nlh->nlmsg_type = fam;
+	nlh->nlmsg_flags = NLM_F_REQUEST;
+	fill_service(nlh, vip, port, 0, 0);
+	send_cmd(nl, nlh);
+
+	ret = mnl_socket_recvfrom(nl, buf, sizeof(buf));
+	while (ret >= 0) {
+		ret = mnl_cb_run(buf, ret, 0, mnl_socket_get_portid(nl),
+				 (mnl_cb_t)get_cb, &secure);
+		if (ret <= MNL_CB_STOP || secure >= 0)
+			break;
+		ret = mnl_socket_recvfrom(nl, buf, sizeof(buf));
+	}
+	mnl_socket_close(nl);
+	if (secure < 0)
+		return -ENOENT;
+	printf("secure_tcp=%d\n", secure);
+	return 0;
+}
+
+/* ---------------- add service with flag ---------------- */
+static int do_add(uint16_t fam, const char *vip, uint16_t port, int secure)
+{
+	struct mnl_socket *nl;
+	char buf[MNL_SOCKET_BUFFER_SIZE];
+	struct nlmsghdr *nlh;
+	struct genlmsghdr *genl;
+	int ret;
+
+	/* NLM_F_EXCL: fail if the service already exists */
+	nlh = mnl_nlmsg_put_header(buf);
+	genl = mnl_nlmsg_put_extra_header(nlh, sizeof(struct genlmsghdr));
+	genl->cmd = IPVS_CMD_NEW_SERVICE;
+	genl->version = IPVS_GENL_VERSION;
+	nlh->nlmsg_type = fam;
+	nlh->nlmsg_flags = NLM_F_REQUEST | NLM_F_ACK | NLM_F_CREATE | NLM_F_EXCL;
+	fill_service(nlh, vip, port, 1, secure);
+
+	nl = mnl_socket_open(NETLINK_GENERIC);
+	mnl_socket_bind(nl, 0, 0);
+	if (send_cmd(nl, nlh) < 0) {
+		mnl_socket_close(nl);
+		return 1;
+	}
+
+	/* Read the reply so we can report why a command may have failed */
+	for (;;) {
+		ret = mnl_socket_recvfrom(nl, buf, sizeof(buf));
+		if (ret <= 0)
+			break;
+		ret = mnl_cb_run(buf, ret, 0, mnl_socket_get_portid(nl),
+				 NULL, NULL);
+		if (ret < 0) {
+			int e = errno;
+
+			fprintf(stderr, "IPVS netlink error: ret=%d errno=%d (%s)\n",
+				ret, e, strerror(e));
+			mnl_socket_close(nl);
+			return 1;
+		}
+		if (ret <= MNL_CB_STOP)
+			break;
+	}
+	mnl_socket_close(nl);
+	return 0;
+}
+
+int main(int argc, char *argv[])
+{
+	const char *cmd, *vip;
+	uint16_t fam;
+	uint16_t port;
+	int ret, secure = 0;
+
+	if (argc < 4) {
+		fprintf(stderr,
+			"usage: %s add <vip> <port> <secure|plain>\n"
+			"       %s get <vip> <port>\n", argv[0], argv[0]);
+		return 2;
+	}
+	cmd = argv[1];
+	vip = argv[2];
+	port = (uint16_t)atoi(argv[3]);
+	port = htons(port);
+
+	ret = resolve_family(IPVS_GENL_NAME, &fam);
+	if (ret) {
+		fprintf(stderr, "cannot resolve IPVS genl family: %s\n",
+			strerror(-ret));
+		return 1;
+	}
+
+	if (strcmp(cmd, "add") == 0) {
+		if (argc < 5) {
+			fprintf(stderr, "usage: %s add ... <secure|plain>\n",
+				argv[0]);
+			return 2;
+		}
+		if (strcmp(argv[4], "secure") == 0) {
+			secure = 1;
+		} else if (strcmp(argv[4], "plain") != 0) {
+			fprintf(stderr, "unknown mode %s\n", argv[4]);
+			return 2;
+		}
+		return do_add(fam, vip, port, secure);
+	} else if (strcmp(cmd, "get") == 0) {
+		return do_get(fam, vip, port);
+	}
+
+	fprintf(stderr, "unknown command %s\n", cmd);
+	return 2;
+}
-- 
2.51.0

