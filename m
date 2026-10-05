Received: from mail-dy1-f173.google.com (mail-dy1-f173.google.com [74.125.82.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5808744AB8E
	for <lvs-devel@vger.kernel.org>; Mon,  5 Oct 2026 23:08:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.82.173
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791241709; cv=none; b=DJH189qwr+mB2fgUjJI8ukxetN/ktf4WejSG8yC0+Kc5okf+2NHtA2Pw2fld4L7KIDGyeAVOLatYyfOtqHs+Xg/Enr5d3+TYNYND0M0+Asw0spRmHIDwXVPfMu0gW1ZOAWVUmXv2M5haU85YUemHhpn855LA9OZsRldGTUr+YlM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791241709; c=relaxed/simple;
	bh=Ksghcm5X8LCN4vVxohqv4ljnWZLsedxMoepypuhBXFk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=A8dG4pm85eim1YfyBF6iuV1vma15RZ0UGgLXi1rgitiKzc316YHif8IU/O0cqB2SnYn4sLRpy3olQcTBlCMVenCyQZZoigRO3p7+6TFT2GgJw5JPFdhfjJyDJzqmKH+dUej73Ak+S1tr4rHqVjLTjVQrafMQaFQmCwDKxAX6az0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=OLEOErpD; arc=none smtp.client-ip=74.125.82.173
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OLEOErpD"
Received: by mail-dy1-f173.google.com with SMTP id 5a478bee46e88-3282db206d3so7128204eec.0
        for <lvs-devel@vger.kernel.org>; Mon, 05 Oct 2026 16:08:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1791241703; x=1791846503; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=/HtUfIuegfaNudBUjGk4ZRNwRDJb7i8lilIXKpQlSYQ=;
        b=OLEOErpD7QSHIPGML0k0s4yhOLQw6nGG2lsJvDCZ6cE6FNbXhvCjBZmjtffcNL9tjd
         dZhzoBzq3nQ2/n2fPQ2PseBM+PjneWllIB7Hgt+LjPFNfcHGBV3DlaIu0YUnYVsYk/VL
         bRpVKpho3Ji6mMyy7QTfFwqwjse02oMmHrjaefoO0LzsbRnaWsBuOFgcfrzqCVo30iPi
         DY+SbZh603nXWIBG1w/nVwpk/tSwD3zmC3z2+3pqQwJsCqbLRJnYOGj76UWYGXJhxufL
         5ZjQF5o5I5Sm/Bu/Xxg402aGxziu+uFy4jjMEagI/FZWBgiNV99oj6CXM9n5/f6eLTBf
         4NDQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791241703; x=1791846503;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=/HtUfIuegfaNudBUjGk4ZRNwRDJb7i8lilIXKpQlSYQ=;
        b=k2hD3zEd5qLfz4w+Ox/Q4e5nHHcK/rxQurjvujwomreuKkFqYbeD0G6W7N027dvorz
         W8AhWBVbB5FRZIB4J8UnwT3GkWlCkeqWKciPIa7lpOceXEmFq4nlncxbn3kyo2DV4GS+
         VnhbF0xhDO3vBHvY95iwhhFTp9LAr5bo6qB+eYgJcBhDCZZcLpOiYXcrb9pqXiazMJT9
         eZ4ZAQ/s8HoZq8O0ZecLeXDyLkUHMU2N5P++Yg+g1W0oHiqLWMxJR6xfyfg0i7uEhLtP
         e2vcvavydCiebjLkxHlPsv6k6ViSCA2NcuKjKf9quT/9IQE886MIm7/GMCMjXAL1KpQW
         PBxw==
X-Forwarded-Encrypted: i=1; AKwUvBz+SBxnc51y+b7MNSMemeW5Wj9wgxufZUdXfyQ4WWMF4Len1WhK0TxZpr1auzQ6fduJEECc6uYKoxI=@vger.kernel.org
X-Gm-Message-State: AFuF++k3lJ4uiTXbEVCJMd+K2HD/+lucOIhLg1g8qAhgy1yVSbh3+GOw
	SNZK7xPRyW47igAd0ot+PJOPOyOddq98uyulHNL1b6/XEy896uT4Jc2g
X-Gm-Gg: AYBFou2M/LDiMHutNEhRkWtZTzCLlhRAgVsbDka2svkMZmAmF2HqALcy7XpuiMHbCpH
	AmX10+fF280i5HYf4E7XSdTGmk3vyv3h7N83/XwXHzWpt2HRC45OSsqfllH9w+DmKG1a3tHWJVC
	HlRedFnfpI+rdC8SiEsc1ysydIDLv4joUoQem0h2fW0ApwVnkz6rt7ZVtw0OK4yDBCFcgGd4l/u
	a1+F7SVH9XtoZDeoE9ZE7BnYW3bIidVnkWqVJv2qKNUxH6cZfIKgCo8F0wRADrM6jflUduHzEmb
	NOkGD5pFmbgHeDTT1yBVnNLLKAuZ1SYreIhWx+S/E/fGomu+vDVHcDFhte4Op+M8HHQKH4721m5
	KYse5NL3inGHwFuflbw0mZSgK7wYOif0stEh9D3wNG0vWgFp9hgC31AAcE6rv9lbZgTWPRRXI/Q
	vFqkrEZNS9brTByw3OYvck2F1ncpX2A8txsifneb+XdC/f+z0jeuZ+eX+ELwPrUZc=
X-Received: by 2002:a05:7301:1c8f:b0:351:1cc6:995e with SMTP id 5a478bee46e88-3511cc6c880mr8388656eec.5.1791241702738;
        Mon, 05 Oct 2026 16:08:22 -0700 (PDT)
Received: from adriano ([190.215.95.120])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-35146a5b004sm1859493eec.18.2026.10.05.16.08.20
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 05 Oct 2026 16:08:22 -0700 (PDT)
From: Adriano Cordova <adrianox@gmail.com>
To: Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Florian Westphal <fw@strlen.de>,
	netfilter-devel@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v6 nf-next 3/3] selftests: netfilter: ipvs: add per-service secure_tcp test
Date: Mon,  5 Oct 2026 20:08:08 -0300
Message-ID: <20261005230808.148478-4-adrianox@gmail.com>
X-Mailer: git-send-email 2.51.0
In-Reply-To: <20261005230808.148478-1-adrianox@gmail.com>
References: <20261005230808.148478-1-adrianox@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Two services share a VIP, one carrying IP_VS_SVC_F_SECURE_TCP.
A bare SYN followed by a bare ACK suffices to test the state
machine: the normal service reaches ESTABLISHED, but the secure
one stays in SYN_RECV.

Assisted-by: opencode:deepseek-flash
Signed-off-by: Adriano Cordova <adrianox@gmail.com>
---
Changes in v2:
- send probes with TTL=1 instead of an nft drop, and fix
  Sashiko comments.

Changes in v4:
- Check the return value of setsockopt(IP_HDRINCL), sendto() and
  mnl_socket_bind(), and fail do_add() when IPVS does not reply.
- Check inet_pton(), initialize fam and the parsed addresses, and verify
  the flags attribute length before copying it (Sashiko).

Changes in v5:
- Reword the changelog: the probe sends a bare SYN followed by a bare
  ACK, not a single SYN+ACK.
- Skip the test when the ip_vs or ip_vs_rr module is unavailable.
- Check the probe exit status so a probe that dies after the SYN cannot
  leave the secure-side SYN_RECV assertion passing.

 .../testing/selftests/net/netfilter/Makefile  |   6 +
 .../selftests/net/netfilter/gen_tcp_probe.c   | 158 ++++++++
 .../net/netfilter/ipvs_secure_tcp.sh          | 169 +++++++++
 .../net/netfilter/ipvs_secure_tcp_mln.c       | 337 ++++++++++++++++++
 4 files changed, 670 insertions(+)
 create mode 100644 tools/testing/selftests/net/netfilter/gen_tcp_probe.c
 create mode 100755 tools/testing/selftests/net/netfilter/ipvs_secure_tcp.sh
 create mode 100644 tools/testing/selftests/net/netfilter/ipvs_secure_tcp_mln.c

diff --git a/tools/testing/selftests/net/netfilter/Makefile b/tools/testing/selftests/net/netfilter/Makefile
index df3c20c90f5d..f88bf69cc874 100644
--- a/tools/testing/selftests/net/netfilter/Makefile
+++ b/tools/testing/selftests/net/netfilter/Makefile
@@ -22,6 +22,7 @@ TEST_PROGS := \
 	conntrack_tcp_unreplied.sh \
 	conntrack_vrf.sh \
 	ipvs.sh \
+	ipvs_secure_tcp.sh \
 	nf_conntrack_packetdrill.sh \
 	nf_nat_edemux.sh \
 	nft_audit.sh \
@@ -52,6 +53,8 @@ TEST_GEN_FILES = \
 	connect_close \
 	conntrack_dump_flush \
 	conntrack_reverse_clash \
+	gen_tcp_probe \
+	ipvs_secure_tcp_mln \
 	nf_queue \
 	sctp_collision \
 	udpclash \
@@ -62,6 +65,9 @@ include ../../lib.mk
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
index 000000000000..185c3b1146dc
--- /dev/null
+++ b/tools/testing/selftests/net/netfilter/gen_tcp_probe.c
@@ -0,0 +1,158 @@
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
+ * A TTL of 1 keeps the packets from reaching the real server: IPVS updates
+ * the connection state before forwarding, then the packet expires and an
+ * ICMP time-exceeded is sent back to us.
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
+	const uint8_t *p = data;
+	uint32_t sum = 0;
+
+	while (len > 1) {
+		uint16_t w;
+
+		memcpy(&w, p, sizeof(w));
+		sum += w;
+		p += 2;
+		len -= 2;
+	}
+	if (len) {
+		uint16_t w = 0;
+
+		memcpy(&w, p, 1);
+		sum += w;
+	}
+	while (sum >> 16)
+		sum = (sum & 0xffff) + (sum >> 16);
+	return ~sum;
+}
+
+static int send_seg(int fd, const struct in_addr *sip, uint16_t sport,
+		    const struct in_addr *dip, uint16_t dport,
+		    uint32_t seq, int syn, int ack)
+{
+	struct {
+		struct iphdr ip;
+		struct tcphdr tcp;
+	} pkt = { };
+	struct iphdr *ip = &pkt.ip;
+	struct tcphdr *tcp = &pkt.tcp;
+	struct sockaddr_in dst;
+
+	ip->version = 4;
+	ip->ihl = 5;
+	ip->tot_len = htons(sizeof(pkt));
+	ip->id = htons((uint16_t)(seq & 0xffff));
+	ip->ttl = 1;
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
+		uint8_t tcpbuf[12 + sizeof(struct tcphdr)];
+
+		memcpy(ph, &ip->saddr, 4);
+		memcpy(ph + 4, &ip->daddr, 4);
+		ph[8] = 0;
+		ph[9] = IPPROTO_TCP;
+		ph[10] = (sizeof(struct tcphdr) >> 8) & 0xff;
+		ph[11] = sizeof(struct tcphdr) & 0xff;
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
+	if (sendto(fd, &pkt, sizeof(pkt), 0, (struct sockaddr *)&dst,
+		   sizeof(dst)) < 0) {
+		perror("sendto");
+		return -1;
+	}
+	return 0;
+}
+
+int main(int argc, char *argv[])
+{
+	struct in_addr sip = { }, dip = { };
+	uint16_t sport, dport;
+	int fd, one = 1;
+	uint32_t seq = 0x12345678;
+
+	if (argc != 5) {
+		fprintf(stderr, "usage: %s <src_ip> <src_port> <dst_ip> <dst_port>\n",
+			argv[0]);
+		return 2;
+	}
+	if (inet_pton(AF_INET, argv[1], &sip) != 1 ||
+	    inet_pton(AF_INET, argv[3], &dip) != 1) {
+		fprintf(stderr, "bad address\n");
+		return 2;
+	}
+	sport = htons((uint16_t)atoi(argv[2]));
+	dport = htons((uint16_t)atoi(argv[4]));
+
+	fd = socket(AF_INET, SOCK_RAW, IPPROTO_RAW);
+	if (fd < 0) {
+		perror("raw socket");
+		return 1;
+	}
+	if (setsockopt(fd, IPPROTO_IP, IP_HDRINCL, &one, sizeof(one)) < 0) {
+		perror("setsockopt");
+		close(fd);
+		return 1;
+	}
+
+	if (send_seg(fd, &sip, sport, &dip, dport, seq, 1, 0) < 0) {
+		close(fd);
+		return 1;
+	}
+	usleep(100000);
+	if (send_seg(fd, &sip, sport, &dip, dport, seq + 1, 0, 1) < 0) {
+		close(fd);
+		return 1;
+	}
+
+	close(fd);
+	return 0;
+}
diff --git a/tools/testing/selftests/net/netfilter/ipvs_secure_tcp.sh b/tools/testing/selftests/net/netfilter/ipvs_secure_tcp.sh
new file mode 100755
index 000000000000..c1fda5a5a8a7
--- /dev/null
+++ b/tools/testing/selftests/net/netfilter/ipvs_secure_tcp.sh
@@ -0,0 +1,169 @@
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
+# Requires root, netns, ipvsadm, and the built helpers
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
+
+if [ ! -d /proc/sys/net/ipv4/vs/ ]; then
+	if ! modprobe -q ip_vs; then
+		echo "skip: could not run test without ipvs module"
+		exit $ksft_skip
+	fi
+fi
+if ! modprobe -q ip_vs_rr; then
+	echo "skip: could not run test without ip_vs_rr module"
+	exit $ksft_skip
+fi
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
+	# The probes carry TTL=1, so IPVS updates the connection state and
+	# then the packet expires before reaching the real server (which
+	# stays silent, no RST to interfere with the observation).
+
+	# Push SYN then ACK to each service from the client.  Both segments
+	# must be sent: a bare SYN already leaves the connection in SYN_RECV,
+	# so a probe that died after the SYN would not be caught otherwise.
+	if ! ip netns exec "${ns0}" "$probe" "${cip}" 40000 \
+			"${vip}" "${port_secure}"; then
+		echo -e "${RED}FAIL${NC}: probe to ${vip}:${port_secure} failed"
+		ret=1
+	fi
+	if ! ip netns exec "${ns0}" "$probe" "${cip}" 40001 \
+			"${vip}" "${port_plain}"; then
+		echo -e "${RED}FAIL${NC}: probe to ${vip}:${port_plain} failed"
+		ret=1
+	fi
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
index 000000000000..54c6d860addf
--- /dev/null
+++ b/tools/testing/selftests/net/netfilter/ipvs_secure_tcp_mln.c
@@ -0,0 +1,337 @@
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
+#define IP_VS_SVC_F_SECURE_TCP	0x0100
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
+	*fam = 0;
+	nl = mnl_socket_open(NETLINK_GENERIC);
+	if (!nl)
+		return -errno;
+	if (mnl_socket_bind(nl, 0, 0) < 0) {
+		mnl_socket_close(nl);
+		return -errno;
+	}
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
+	if (tb[IPVS_SVC_ATTR_FLAGS] &&
+	    mnl_attr_get_payload_len(tb[IPVS_SVC_ATTR_FLAGS]) >= sizeof(fl)) {
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
+	if (!nl)
+		return -errno;
+	if (mnl_socket_bind(nl, 0, 0) < 0) {
+		mnl_socket_close(nl);
+		return -errno;
+	}
+	nlh = mnl_nlmsg_put_header(buf);
+	genl = mnl_nlmsg_put_extra_header(nlh, sizeof(struct genlmsghdr));
+	genl->cmd = IPVS_CMD_GET_SERVICE;
+	genl->version = IPVS_GENL_VERSION;
+	nlh->nlmsg_type = fam;
+	nlh->nlmsg_flags = NLM_F_REQUEST;
+	ret = fill_service(nlh, vip, port, 0, 0);
+	if (ret < 0) {
+		mnl_socket_close(nl);
+		return ret;
+	}
+	if (send_cmd(nl, nlh) < 0) {
+		mnl_socket_close(nl);
+		return -1;
+	}
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
+	ret = fill_service(nlh, vip, port, 1, secure);
+	if (ret < 0)
+		return 1;
+
+	nl = mnl_socket_open(NETLINK_GENERIC);
+	if (!nl)
+		return 1;
+	if (mnl_socket_bind(nl, 0, 0) < 0) {
+		mnl_socket_close(nl);
+		return 1;
+	}
+	if (send_cmd(nl, nlh) < 0) {
+		mnl_socket_close(nl);
+		return 1;
+	}
+
+	/* Read the reply so we can report why a command may have failed */
+	for (;;) {
+		ret = mnl_socket_recvfrom(nl, buf, sizeof(buf));
+		if (ret <= 0) {
+			fprintf(stderr, "no reply from IPVS\n");
+			mnl_socket_close(nl);
+			return 1;
+		}
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
+	uint16_t fam = 0;
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

