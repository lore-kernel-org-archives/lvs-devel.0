Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=207.46.229.174
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794929945;
	b=RkjpV2Nkpq1bok1CQYEdtqmgPTp1CbZK5WfemUxME3zDQFS9ehBxZPz73PdsQVVpR46L
	 amEZYpSo5SxyEFEjmxRdwyaDwTbPiSMepAaN3t2qqA8FnX2mQX5VrwTI6P1HnbQSj+qWK
	 Zf925KWJmni5ai5SMM1ItmVQ1BcTqaDc9dUwOTaFro/AGuX6HEAQvS3qGtdyLwjrAN7PS
	 R/Tatkexshxkz/ZwlscBZ/p4qQbwV8EMFw0qUuBovzTFCcIp0HmUiWKmexw7uKfBa7DiQ
	 FFrDnGyXi0f7Mi8BcW6Sfi9EqDGLBPnOcSEHenJ93RJ5FlSGcgVBZS+t7kTaLJPkb+A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794929945;
	h=DMARC-Filter:Received:Date:From:To:Cc:Subject:Message-ID:
	 MIME-Version:Content-Type:Content-Disposition:X-CM-TRANSID:
	 X-Coremail-Antispam:X-CM-SenderInfo;
	bh=EM8suqZCPP76p1pmInbm5tIvzVVIlZjaW7WfFwnROgQ=;
	b=W84AQdL+7857PMjXOscgeGiDNI3IGOAR/JU9Gs7NkpNl0WBtMlMHjP/wgELtvvbrnwc7
	 KtnlArLv1n51ybutz5xDh7zngbz8E76qSnk9O5hJoRJGx0UaqqWtklBWO6Th2LnZNqoHo
	 UgIwmMBJGkLCrWZ8p0ayKe8Y7UN0tzJrF5ICMvhwxIJif9WkKSAaDwbWJ4emJHxI/F4Ad
	 iQl84HVkmsjRPa38bZMmAr1wUUwqfbJgKDbyoiSv3ZWFR7G1J8hrJ48FcjUs/bh6Gizwo
	 8NDp4oneTpf0HEl3+CtnvsDs3jOoRqVZqgNdNhMGNAd1eCNqehLVEMOa1QERDcxnvUQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=stu.xjtu.edu.cn;
	spf=pass smtp.mailfrom=stu.xjtu.edu.cn;
	arc=none smtp.remote-ip=207.46.229.174
Received: from azure-sdnproxy.icoremail.net (azure-sdnproxy.icoremail.net [207.46.229.174])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id E8C7D606A31C;
	Tue, 17 Nov 2026 15:39:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E8C7D606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=stu.xjtu.edu.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=stu.xjtu.edu.cn
Received: from fxxowodeMacBook-Pro.local (unknown [10.181.177.214])
	by app2 (Coremail) with SMTP id NAGowABH95MGdfxqPnxGAA--.2576S2;
	Tue, 17 Nov 2026 23:38:53 +0800 (CST)
Date: Tue, 17 Nov 2026 10:38:39 -0500
From: "Zhenrong (Daniel) Gu" <zrgu@stu.xjtu.edu.cn>
To: ja@ssi.bg, horms@verge.net.au
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	Xing Feng <xingfeng@stu.xjtu.edu.cn>,
	Peng Zhang <p-zhang@xjtu.edu.cn>
Subject: [BUG] ipvs: new connection on a reused port goes to the previous
 real server during conn_tab resize
Message-ID: <avx0_13w3xGNdZP8@fxxowodeMacBook-Pro.local>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
X-CM-TRANSID:NAGowABH95MGdfxqPnxGAA--.2576S2
X-Coremail-Antispam: 1UD129KBjvJXoW3ury5tFyrZrW8CrW7Ww4fAFb_yoWkWr4UpF
	W3KF9xKrn8Ga45Gw4kC3W8Gr15Ar4kJrW7Xr9YgF10kwn8CrnIqF4Iy34v9ayUArZ5A3Wj
	qF4jqw4xZa1DZ3DanT9S1TB71UUUUU7qnTZGkaVYY2UrUUUUjbIjqfuFe4nvWSU5nxnvy2
	9KBjDU0xBIdaVrnRJUUUvl1xkIjI8I6I8E6xAIw20EY4v20xvaj40_Wr0E3s1l1IIY67AE
	w4v_Jr0_Jr4l8cAvFVAK0II2c7xJM28CjxkF64kEwVA0rcxSw2x7M28EF7xvwVC0I7IYx2
	IY67AKxVW8JVW5JwA2z4x0Y4vE2Ix0cI8IcVCY1x0267AKxVW8JVWxJwA2z4x0Y4vEx4A2
	jsIE14v26rxl6s0DM28EF7xvwVC2z280aVCY1x0267AKxVW0oVCq3wAS0I0E0xvYzxvE52
	x082IY62kv0487Mc02F40EFcxC0VAKzVAqx4xG6I80ewAv7VC0I7IYx2IY67AKxVWUJVWU
	GwAv7VC2z280aVAFwI0_Jr0_Gr1lOx8S6xCaFVCjc4AY6r1j6r4UM4x0Y48IcVAKI48JM4
	x0x7Aq67IIx4CEVc8vx2IErcIFxwCY1x0262kKe7AKxVWUAVWUtwCY02Avz4vE-syl42xK
	82IYc2Ij64vIr41l42xK82IY6x8ErcxFaVAv8VW8Cr1UJr1l4I8I3I0E4IkC6x0Yz7v_Jr
	0_Gr1lx2IqxVAqx4xG67AKxVWUJVWUGwC20s026x8GjcxK67AKxVWUGVWUWwC2zVAF1VAY
	17CE14v26r126r1DMIIYrxkI7VAKI48JMIIF0xvE2Ix0cI8IcVAFwI0_Jr0_JF4lIxAIcV
	C0I7IYx2IY6xkF7I0E14v26r1j6r4UMIIF0xvE42xK8VAvwI8IcIk0rVWUJVWUCwCI42IY
	6I8E87Iv67AKxVWUJVW8JwCI42IY6I8E87Iv6xkF7I0E14v26r1j6r4UYxBIdaVFxhVjvj
	DU0xZFpf9x0JUBVbkUUUUU=
X-CM-SenderInfo: 5hqgt5hwuh2iqrsqq2dwxo5ylwxovvfxof0/

Hello Julian, Simon,

Since the connection table became resizable (v7.1), a new TCP connection
that reuses the client port of a connection in TIME_WAIT can have its
first packets after the SYN sent to the real server of the previous
connection, when the SYN arrives while conn_tab is being resized. The
SYN goes to the newly scheduled real server and the handshake completes
with it; the final ACK and the request then go to the old real server.

Seen on 7.3.3 (Fedora 7.3.3-300.fc45.x86_64, CONFIG_HZ=1000). The code
involved is unchanged in current mainline. All sysctls at their defaults
(conn_reuse_mode=1, expire_nodest_conn=0, conntrack=0); NAT forwarding,
rr scheduler.

We have not run 7.0; going by the code, the window does not exist
before the resizable table (see below), so this looks like a regression
from:

#regzbot introduced: 2fa7cc9c7025

Example (capture on the director, packets from client port 43002 leaving
towards the real servers):

    +0.0 ms   [S]   -> 10.2.3.2   (scheduled; SYN-ACK from 10.2.3.2)
    +0.0 ms   [.]   -> 10.2.4.2   <- real server of the previous
    +0.1 ms   [P.]  -> 10.2.4.2      connection on this port
  +201.3 ms   [P.]  -> 10.2.4.2   (client retransmission)
  +409.3 ms   [P.]  -> 10.2.4.2   (client retransmission)
  +818.2 ms   [P.]  -> 10.2.3.2
  +818.6 ms   [.]   -> 10.2.3.2
  +818.7 ms   [F.]  -> 10.2.3.2

The old real server still has the 4-tuple in TIME_WAIT and answers with
an ACK of the old connection; the new one never gets the request until
the misrouting stops. The client sees a delay of one or more RTOs, and
some connections are reset or time out.


Analysis (v7.3)
---------------

1. ip_vs_in(): a SYN that finds a connection in TIME_WAIT
   (is_new_conn_expected()) calls ip_vs_conn_expire_now() on it and
   schedules a new connection. The old entry stays hashed until its
   timer runs.

2. Before 7.1 there was one table and ip_vs_conn_hash() added at the
   bucket head, so lookups always found the new entry before the old
   one. With the resizable table:
   - while a resize is in progress, ip_vs_conn_hash() adds new entries
     to t->new_tbl, but __ip_vs_conn_in_get() walks the tables with
     ip_vs_rht_for_each_table_rcu(), the current (old) table first;
   - conn_resize_work_handler() moves each entry of the old table to
     the head of its bucket in the new table, so an old entry moved
     after the new entry was added ends up before it.
   In both cases the lookup for the packets that follow the SYN returns
   the old connection, and ip_vs_in() transmits them to its real server.

3. ip_vs_conn_put() on that path re-arms the old entry's timer with
   cp->timeout (TIME_WAIT: 2 minutes), cancelling the effect of
   ip_vs_conn_expire_now(), so the old entry stays in the table. In
   the runs below the misrouting of a connection stopped after 200 to
   800 ms; we have not established what ends it in each case.

The window is the time between the SYN and the moment the old entry no
longer comes first in the lookup, and it only exists around a resize.
Resizes happen whenever the connection count crosses a threshold, in
either direction (the resize work checks every 2 s).


Reproduction
------------

The script below (network namespaces and veth, needs ip, ipvsadm,
tcpdump, python3) runs a client that reuses 8 source ports in a loop
against a 4-server service, plus background connections from ephemeral
ports. Each real server answers one request and closes. A capture on
the director checks that every packet after a connection's SYN goes to
the real server that got the SYN. Three modes:

  force     write conn_lfactor every 100 ms, alternating between two
            values: each write starts a resize
  grow      no change: the table grows with the connection count
  noresize  conn_lfactor=8: no resize under this load (control)

Results, 60 s each, 7.3.3, i7-13700:

  mode      reused-port   misrouted     client: answered     client:
            connections   connections   after > 100 ms       failed
  force        11909          566            519             21 reset
  grow         13697            9              8             1 timeout
  noresize     15745            0              0                  0

(In grow mode the port of the timed-out connection stayed unusable for
a while, hence fewer connections than in noresize. The numbers vary
between runs; grow mode had between 4 and 12 misrouted connections in
the runs we did.)

To relate the misrouting to resizes, we recorded each resize with
kprobes on ip_vs_conn_tab_alloc() and on the return of
conn_resize_work_handler(), sampling the hit counts every 2 ms (same
setup, separate script). In two 60 s runs of the grow mode (4 resizes
each, about 25 ms of resizing per run), all 13 misrouted connections
started inside a resize or less than 1 ms before its sampled start.
With forced resizes, 409 of 422 started within 2 ms of one.

---8<--- repro.sh ---8<---
#!/bin/bash
# IPVS: packets of a new connection on a reused client port go to the real
# server of the previous connection when the SYN arrives during a conn_tab
# resize (Linux >= 7.1).
#
# Topology (network namespaces, veth): client 10.1.0.2 -> director
# (VIP 10.96.0.10:80, rr, masquerading) -> real servers 10.2.{1..4}.2:8080.
# The client reuses 8 source ports in a loop; each real server answers one
# request and closes, so the director keeps the previous connection of the
# port in TIME_WAIT when the next SYN arrives (conn_reuse_mode=1 path).
# A capture on the director checks that every packet after the SYN of a
# connection goes to the real server that got the SYN.
#
# usage: sudo ./repro.sh [force|grow|noresize] [seconds]
#   force     switch conn_lfactor every 100 ms: one resize each time (default)
#   grow      kernel defaults; the table grows with the connection count
#   noresize  conn_lfactor=8: no resize under this load (control)
# needs: ip, ipvsadm, tcpdump, python3. All sysctls keep their defaults
# except conn_lfactor.
set -euo pipefail
MODE=${1:-force}
SECS=${2:-60}
VIP=10.96.0.10
NS="rr-cli rr-lb rr-rs1 rr-rs2 rr-rs3 rr-rs4"
DIR=$(mktemp -d)
PIDS=()

cleanup() {
	for p in "${PIDS[@]}"; do kill "$p" 2>/dev/null || true; done
	wait 2>/dev/null || true
	for n in $NS; do ip netns del "$n" 2>/dev/null || true; done
}
trap cleanup EXIT
lb() { ip netns exec rr-lb "$@"; }

for n in $NS; do ip netns add "$n"; ip -n "$n" link set lo up; done
link() { # link NS1 IF1 ADDR1 NS2 IF2 ADDR2
	ip link add "$2" netns "$1" type veth peer name "$5" netns "$4"
	ip -n "$1" addr add "$3/24" dev "$2"; ip -n "$1" link set "$2" up
	ip -n "$4" addr add "$6/24" dev "$5"; ip -n "$4" link set "$5" up
}
link rr-lb cli 10.1.0.1 rr-cli eth0 10.1.0.2
ip -n rr-cli route add default via 10.1.0.1
for i in 1 2 3 4; do
	link rr-lb rs$i 10.2.$i.1 rr-rs$i eth0 10.2.$i.2
	ip -n rr-rs$i route add default via 10.2.$i.1
	ip netns exec rr-rs$i python3 -c '
import socket, sys, threading
s = socket.socket(); s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind((sys.argv[1], 8080)); s.listen(512)
def serve(c):
    try:
        c.settimeout(10)
        if c.recv(64):
            c.sendall(sys.argv[1].encode())
    except OSError:
        pass
    c.close()   # the real server closes first
while True:
    threading.Thread(target=serve, args=(s.accept()[0],), daemon=True).start()
' 10.2.$i.2 &
	PIDS+=($!)
done
lb sysctl -qw net.ipv4.ip_forward=1
ip -n rr-lb link add ipvs0 type dummy
ip -n rr-lb addr add $VIP/32 dev ipvs0
lb ipvsadm -A -t $VIP:80 -s rr
for i in 1 2 3 4; do
	lb ipvsadm -a -t $VIP:80 -r 10.2.$i.2:8080 -m
done
LF=$(lb sysctl -n net.ipv4.vs.conn_lfactor)
if [ "$MODE" = noresize ]; then
	LF=8
	lb sysctl -qw net.ipv4.vs.conn_lfactor=8
fi
sleep 3

lb tcpdump -i any -nn -s 96 -U -w "$DIR/lb.pcap" \
	'tcp and src host 10.1.0.2 and src portrange 43000-43007' 2>/dev/null &
PIDS+=($!)
sleep 1

if [ "$MODE" = force ]; then
	( v=$LF; while :; do
		v=$(( v == LF ? LF + 1 : LF ))
		lb sysctl -qw net.ipv4.vs.conn_lfactor=$v
		sleep 0.1
	done ) &
	PIDS+=($!)
fi

# Client: 8 threads reuse ports 43000-43007; 4 threads open connections
# from ephemeral ports so that the table holds a few thousand entries.
ip netns exec rr-cli python3 -c '
import errno, socket, sys, threading, time
vip, stop = sys.argv[1], time.monotonic() + float(sys.argv[2])
ok, fail, slow = 0, {}, 0
lock = threading.Lock()
def one(port):
    """None: the local port is still in use;
    else (answered, error, seconds)."""
    s = socket.socket()
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.settimeout(2)
    t = time.monotonic()
    try:
        if port:
            try:
                s.bind(("0.0.0.0", port))
            except OSError:
                return None
        s.connect((vip, 80)); s.sendall(b"x")
        if not s.recv(64):
            return False, "closed", 0
        return True, None, time.monotonic() - t
    except OSError as e:
        if e.errno == errno.EADDRNOTAVAIL:
            return None  # the last connection on the port is not closed
        return False, errno.errorcode.get(e.errno, type(e).__name__), 0
    finally:
        s.close()
def reuse(port):
    global ok, slow
    while time.monotonic() < stop:
        r = one(port)
        if r is None:
            time.sleep(0.05)
            continue
        with lock:
            if r[0]:
                ok += 1
                slow += r[2] > 0.1
            else:
                fail[r[1]] = fail.get(r[1], 0) + 1
        time.sleep(0.03)
def background():
    while time.monotonic() < stop:
        one(0); time.sleep(0.02)
th = [threading.Thread(target=reuse, args=(43000 + i,)) for i in range(8)]
th += [threading.Thread(target=background) for _ in range(4)]
[t.start() for t in th]; [t.join() for t in th]
print(f"client (reused ports): {ok} answered, {slow} of them after "
      f"more than 100 ms; failed: {fail or 0}")
' $VIP "$SECS"

sleep 1
kill "${PIDS[@]}" 2>/dev/null || true
wait 2>/dev/null || true
echo "mode $MODE, conn_lfactor $LF, $(uname -r)"
tcpdump -nn -tt -r "$DIR/lb.pcap" 2>/dev/null | python3 -c '
import sys
conns, cur = [], {}
for line in sys.stdin:
    f = line.split()
    # TIME IFACE Out IP 10.1.0.2.PORT > 10.2.X.2.8080: Flags [..], ...
    if len(f) < 9 or f[2] != "Out" or not f[6].endswith(".8080:"):
        continue
    port, rs = f[4].rsplit(".", 1)[1], f[6][:-6]
    flags, t = f[8].strip("[],"), float(f[0])
    if flags == "S":
        seq = f[10].rstrip(",")
        if port in cur and cur[port]["seq"] == seq:
            continue  # SYN retransmission
        cur[port] = c = {"port": port, "rs": rs, "t": t, "seq": seq, "pkts": []}
        conns.append(c)
    elif port in cur:
        cur[port]["pkts"].append((t, rs, flags))
bad = [c for c in conns if any(rs != c["rs"] for _, rs, _ in c["pkts"])]
print(f"connections on reused ports: {len(conns)}; with packets sent "
      f"to another real server than their SYN: {len(bad)}")
for c in bad[:2]:
    port, syn_rs, t0 = c["port"], c["rs"], c["t"]
    print(f"  port {port}: SYN -> {syn_rs}")
    for t, rs, flags in c["pkts"][:8]:
        mark = "" if rs == syn_rs else "   <-- other real server"
        print(f"    {(t - t0) * 1e3:+9.1f} ms  [{flags:3}] -> {rs}{mark}")
'
rm -rf "$DIR"
---8<--- end of repro.sh ---8<---


Possible directions (untested)
------------------------------

- Do not let lookups return a connection that a SYN has just expired
  for reuse, e.g. unhash it immediately in the conn_reuse_mode path
  when it has no other users, or mark it so that __ip_vs_conn_in_get()
  skips it.
- Or keep the "new entries first" order across a resize: look up
  t->new_tbl before the current table, and add moved entries at the
  tail of the new bucket.

The first seems more robust since it does not depend on how entries
are ordered.

Xing Feng, Peng Zhang (Cc'd) and I found this while testing a passive
runtime checker for L4 load balancers, which reports a TCP connection
whose packets leave towards a different backend than its SYN.

Thanks,
Zhenrong (Daniel) Gu

