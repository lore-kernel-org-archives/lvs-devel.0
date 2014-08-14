From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH ipvs] ipvs: Add selftests for ipvs
Date: Wed, 13 Aug 2014 19:12:29 -0700
Message-ID: <1407982349-9080-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : mime-version : content-type; s=facebook;
 bh=Q4wL2uBRt9H6HCuJa5IoYWECWhZhNLTGw5VyDOXiego=;
 b=RaJX2OZJZSsAuQSydDmJJR5+6Ybu/dxv7SA4QCORhlisVH03KUip45uMvYPSW8sdSJc/
 QvaX7aVMDyIt4tVp0QUxx9Vnf8zQc59jm0dGfZda9CaB39lJqZ4vbzja6PKHiaAxn10E
 r92WXeeadBj0MeNC8XdV4UZKZwroIdRW3D0= 
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: ja@ssi.bg, lvs-devel@vger.kernel.org, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

Here's a basic python framework for doing selftests on ipvs.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 tools/testing/selftests/ipvs/.gitignore            |   1 +
 tools/testing/selftests/ipvs/Makefile              |  14 +
 tools/testing/selftests/ipvs/general_ipvs_tests.py |  87 ++++++
 tools/testing/selftests/ipvs/network_headers.py    | 315 +++++++++++++++++++++
 tools/testing/selftests/ipvs/network_test_utils.py |  93 ++++++
 tools/testing/selftests/ipvs/test-ipvs.py          |  17 ++
 6 files changed, 527 insertions(+)
 create mode 100644 tools/testing/selftests/ipvs/.gitignore
 create mode 100644 tools/testing/selftests/ipvs/Makefile
 create mode 100644 tools/testing/selftests/ipvs/general_ipvs_tests.py
 create mode 100644 tools/testing/selftests/ipvs/network_headers.py
 create mode 100644 tools/testing/selftests/ipvs/network_test_utils.py
 create mode 100644 tools/testing/selftests/ipvs/test-ipvs.py

diff --git a/tools/testing/selftests/ipvs/.gitignore b/tools/testing/selftests/ipvs/.gitignore
new file mode 100644
index 0000000..0d20b64
--- /dev/null
+++ b/tools/testing/selftests/ipvs/.gitignore
@@ -0,0 +1 @@
+*.pyc
diff --git a/tools/testing/selftests/ipvs/Makefile b/tools/testing/selftests/ipvs/Makefile
new file mode 100644
index 0000000..be74db3
--- /dev/null
+++ b/tools/testing/selftests/ipvs/Makefile
@@ -0,0 +1,14 @@
+# Makefile for net selftests
+
+PYTHON ?= python
+TEST_MODULES += general_ipvs_tests
+
+all:
+
+run_tests:
+	@$(PYTHON) -c 'import sys ; assert sys.version_info[:2] >= (2, 7), \
+			"Depends on python version 2.7"' && \
+			$(PYTHON) ./test-ipvs.py $(TEST_MODULES)
+
+clean:
+	rm -f *.pyc
diff --git a/tools/testing/selftests/ipvs/general_ipvs_tests.py b/tools/testing/selftests/ipvs/general_ipvs_tests.py
new file mode 100644
index 0000000..dd7f6d4
--- /dev/null
+++ b/tools/testing/selftests/ipvs/general_ipvs_tests.py
@@ -0,0 +1,87 @@
+import collections
+import unittest
+
+from network_headers import *
+from network_test_utils import *
+
+class TestLocalRouting(IpvsTest):
+    def do_cross_boundary_test(self, src, vip, rs):
+        self.tun.add_route(rs)
+        add_ipvs_service(vip, 15213, [rs])
+        p = create_iph(src, vip, payload=TcpHeader(15220, 15213, syn=1))
+        send_raw_packet(p)
+        self.assertEqual(None, self.tun.read(tmo=.5))
+
+    def test_local_to_remote(self):
+        self.do_cross_boundary_test('127.0.0.1', '1.2.3.4', '1.2.3.5')
+
+class TestIpvsRoundRobin(IpvsTest):
+    def do_balance_test(self, vip, port, real_servers, src_ip):
+        self.tun.add_routes(real_servers)
+        add_ipvs_service(vip, port, real_servers)
+
+        buckets = collections.defaultdict(lambda: 0)
+        base_port = 15000
+        for i in xrange(10000):
+            src = base_port + i
+            p = create_iph(src_ip, vip, payload=TcpHeader(src, port, syn=1))
+            send_raw_packet(p)
+            buckets[self.tun.read().dst] += 1
+
+        avg = float(sum(buckets.values())) / len(buckets)
+        for k, v in buckets.iteritems():
+            self.assertTrue(abs(v - avg) <= 1.0)
+
+    def test_balance_v4(self):
+        real_servers = ['1.2.3.%d' % i for i in xrange(5, 32)]
+        self.do_balance_test(
+            '1.2.3.4', 15213, real_servers, '9.9.9.9')
+
+    def test_balance_v6(self):
+        real_servers = ['face::%x' % i for i in xrange(5, 32)]
+        self.do_balance_test(
+            'face::4', 15213, real_servers, 'b00c::1')
+
+    def do_stickiness_test(self, vip, port, real_servers, src_ip):
+        self.tun.add_routes(real_servers)
+        add_ipvs_service(vip, port, real_servers)
+
+        buckets = {}
+        base_port = 15000
+        for i in xrange(10000):
+            src = base_port + (i % 43)
+            p = create_iph(src_ip, vip, payload=TcpHeader(src, port, syn=1))
+            send_raw_packet(p)
+            dst_ip = self.tun.read().dst
+            if src not in buckets:
+                buckets[src] = dst_ip
+            else:
+                self.assertEqual(buckets[src], dst_ip)
+
+    def test_stickiness_v4(self):
+        real_servers = ['1.2.3.%d' % i for i in xrange(5, 32)]
+        self.do_stickiness_test(
+            '1.2.3.4', 15213, real_servers, '9.9.9.9')
+
+    def test_stickiness_v6(self):
+        real_servers = ['face::%x' % i for i in xrange(5, 32)]
+        self.do_stickiness_test(
+            'face::4', 15213, real_servers, 'b00c::1')
+
+class TestFragments(IpvsTest):
+    def test_ignore_dont_fragment_v4(self):
+        src, vip, rip = ['1.2.3.%d' % i for i in (5, 6, 7)]
+        self.tun.add_route(rip)
+        add_ipvs_service(vip, 15213, [rip])
+        pout = create_iph(src, vip, payload=TcpHeader(2000, 15213, syn=1))
+        pout.payload.payload = 'a' * 1460
+        pout.frag_off = 1 << 14
+        self.assertTrue(set_sysctl('net.ipv4.vs.pmtu_disc', 1, False))
+
+        send_raw_packet(pout)
+        self.assertEqual(None, self.tun.read())
+
+        self.assertTrue(set_sysctl('net.ipv4.vs.pmtu_disc', 0, False))
+        send_raw_packet(pout)
+        self.assertNotEqual(None, self.tun.read())
+        self.assertNotEqual(None, self.tun.read())
diff --git a/tools/testing/selftests/ipvs/network_headers.py b/tools/testing/selftests/ipvs/network_headers.py
new file mode 100644
index 0000000..c6e29d1
--- /dev/null
+++ b/tools/testing/selftests/ipvs/network_headers.py
@@ -0,0 +1,315 @@
+import socket
+import struct
+
+def parse_l3_packet(s):
+    if (ord(s[0]) >> 4) == 4:
+        return Ipv4Header.parse(s)
+    else:
+        return Ipv6Header.parse(s)
+
+def create_iph(src, *args, **kwargs):
+    if src.find('.') >= 1:
+        return Ipv4Header(src, *args, **kwargs)
+    else:
+        return Ipv6Header(src, *args, **kwargs)
+
+def parse_payload(proto, data):
+    if proto == socket.IPPROTO_IPIP:
+        return Ipv4Header.parse(data)
+    elif proto == socket.IPPROTO_IPV6:
+        return Ipv6Header.parse(data)
+    elif proto == socket.IPPROTO_TCP:
+        return TcpHeader.parse(data)
+    elif proto == socket.IPPROTO_UDP:
+        return UdpHeader.parse(data)
+    elif proto == socket.IPPROTO_ICMP:
+        return IcmpDestUnreachHeader.parse(data)
+    elif proto == socket.IPPROTO_ICMPV6:
+        return Icmpv6PacketTooBigHeader.parse(data)
+    else:
+        return None
+
+def internet_csum(data):
+    def carry_around_add(a, b):
+        c = a + b
+        return (c & 0xffff) + (c >> 16)
+
+    def checksum(msg):
+        s = 0
+        for i in range(0, len(msg), 2):
+            if i + 1 < len(msg):
+                w = ord(msg[i]) + (ord(msg[i+1]) << 8)
+            else:
+                w = ord(msg[i])
+            s = carry_around_add(s, w)
+        return ~s & 0xffff
+
+    return socket.htons(checksum(data))
+
+class Ipv4Header:
+    fmt = '!BBHHHBBH4s4s'
+    encaps_proto = socket.IPPROTO_IPIP
+    address_family = socket.AF_INET
+
+    def __init__(self, src, dst, proto=0, version=4, ihl=5, tos=0, tot_len=0,
+                 ident=0, frag_off=0, ttl=42, csum=0, payload=None):
+        self.src, self.dst, self.proto, self.version = src, dst, proto, version
+        self.ihl, self.tos, self.tot_len, self.ident = ihl, tos, tot_len, ident
+        self.frag_off, self.ttl, self.csum = frag_off, ttl, csum
+        self.payload = payload
+
+    @staticmethod
+    def parse(data):
+        fields = struct.unpack(Ipv4Header.fmt, data[:20])
+        ver_ihl, tos, tot_len, ident, frag_off = fields[:5]
+        ttl, proto, csum, src_raw, dst_raw = fields[5:]
+        version = ver_ihl >> 4
+        ihl = ver_ihl & 0xf
+        src = socket.inet_ntop(socket.AF_INET, src_raw)
+        dst = socket.inet_ntop(socket.AF_INET, dst_raw)
+        payload = parse_payload(proto, data[ihl * 4:tot_len])
+        return Ipv4Header(src=src, dst=dst, proto=proto, version=version,
+                          ihl=ihl, tos=tos, tot_len=tot_len, ident=ident,
+                          frag_off=frag_off, ttl=ttl, csum=csum,
+                          payload=payload)
+
+    def __pseudo_header_fn(self, length):
+        src_raw = socket.inet_pton(socket.AF_INET, self.src)
+        dst_raw = socket.inet_pton(socket.AF_INET, self.dst)
+        proto = self.payload.__class__.encaps_proto
+        return struct.pack('!4s4sBBH', src_raw, dst_raw, 0, proto, length)
+
+    def serialize(self, ph_fn=None):
+        ver_ihl = (self.version << 4) | self.ihl
+
+        ps = self.payload.serialize(ph_fn=self.__pseudo_header_fn)
+        if self.proto == 0:
+            self.proto = self.payload.__class__.encaps_proto
+        if self.tot_len == 0:
+            self.tot_len = 20 + len(ps)
+
+        if self.ident == 0:
+            self.ident = 0xf00f
+
+        src_raw = socket.inet_pton(socket.AF_INET, self.src)
+        dst_raw = socket.inet_pton(socket.AF_INET, self.dst)
+        csum = self.csum
+        if csum == 0:
+            fields = [ver_ihl, self.tos, self.tot_len, self.ident,
+                      self.frag_off, self.ttl, self.proto, 0, src_raw, dst_raw]
+            csum = internet_csum(struct.pack(self.__class__.fmt, *fields))
+
+        fields = [ver_ihl, self.tos, self.tot_len, self.ident, self.frag_off,
+                  self.ttl, self.proto, csum, src_raw, dst_raw]
+
+        return struct.pack(self.__class__.fmt, *fields) + ps
+
+    def __repr__(self):
+        return ('Ipv4Header(src="{s.src}", dst="{s.dst}", proto={s.proto}, ' +
+                'version={s.version}, ihl={s.ihl}, tos={s.tos}, ' +
+                'tot_len={s.tot_len}, ident={s.ident}, ' +
+                'frag_off={s.frag_off}, ttl={s.ttl}, csum=0x{s.csum:x}, ' +
+                'payload={s.payload})').format(s=self)
+
+class Ipv6Header:
+    fmt = '!IHBB16s16s'
+    encaps_proto = socket.IPPROTO_IPV6
+    address_family = socket.AF_INET6
+
+    def __init__(self, src, dst, proto=0, version=6, tclass=0, flow_label=0,
+                 payload_len=0, hop_limit=42, payload=None):
+        self.src, self.dst, self.proto, self.version = src, dst, proto, version
+        self.tclass, self.flow_label = tclass, flow_label
+        self.payload_len, self.hop_limit = payload_len, hop_limit
+        self.payload = payload
+
+    @staticmethod
+    def parse(data):
+        fields = struct.unpack(Ipv6Header.fmt, data[:40])
+        fw, payload_len, proto, hop_limit, src_raw, dst_raw = fields
+        version = (fw >> 28) & 0xf
+        tclass = (fw >> 20) & 0xff
+        flow_label = fw & 0xfffff
+        src = socket.inet_ntop(socket.AF_INET6, src_raw)
+        dst = socket.inet_ntop(socket.AF_INET6, dst_raw)
+        payload = parse_payload(proto, data[40:payload_len + 40])
+        return Ipv6Header(src=src, dst=dst, proto=proto, version=version,
+                          tclass=tclass, flow_label=flow_label,
+                          payload_len=payload_len, hop_limit=hop_limit,
+                          payload=payload)
+
+    def __pseudo_header_fn(self, length):
+        src_raw = socket.inet_pton(socket.AF_INET6, self.src)
+        dst_raw = socket.inet_pton(socket.AF_INET6, self.dst)
+        proto = self.payload.__class__.encaps_proto
+        return struct.pack('!16s16sIBBBB', src_raw, dst_raw, length, 0, 0, 0,
+                           proto)
+
+    def serialize(self, ph_fn=None):
+        fw = (self.version << 28) | (self.tclass << 20) | self.flow_label
+        ps = self.payload.serialize(ph_fn=self.__pseudo_header_fn)
+        if self.proto == 0:
+            self.proto = self.payload.__class__.encaps_proto
+        if self.payload_len == 0:
+            self.payload_len = len(ps)
+
+        src_raw = socket.inet_pton(socket.AF_INET6, self.src)
+        dst_raw = socket.inet_pton(socket.AF_INET6, self.dst)
+
+        fields = [fw, self.payload_len, self.proto, self.hop_limit, src_raw,
+                  dst_raw]
+
+        return struct.pack(self.__class__.fmt, *fields) + ps
+
+    def __repr__(self):
+        return ('Ipv6Header(src="{s.src}", dst="{s.dst}", proto="{s.proto}", ' +
+                'version={s.version}, tclass={s.tclass}, ' +
+                'flow_label={s.flow_label}, payload_len={s.payload_len}, ' +
+                'hop_limit={s.hop_limit}, payload={s.payload})').format(s=self)
+
+class TcpHeader:
+    fmt = '!HHIIHHHH'
+    encaps_proto = socket.IPPROTO_TCP
+    def __init__(self, src, dst, seq=0, ack_num=0, data_off=5, ns=0, cwr=0, ece=0,
+                 urg=0, ack=0, psh=0, rst=0, syn=0, fin=0, win_size=100, csum=0,
+                 urg_ptr=0, payload=''):
+        self.src, self.dst, self.seq, self.ack_num = src, dst, seq, ack_num
+        self.data_off, self.ns, self.cwr, self.ece = data_off, ns, cwr, ece
+        self.urg, self.ack, self.psh, self.rst = urg, ack, psh, rst
+        self.syn, self.fin, self.win_size, self.csum = syn, fin, win_size, csum
+        self.urg_ptr, self.payload = urg_ptr, payload
+
+    @staticmethod
+    def parse(data):
+        if len(data) == 8:  # ICMP?
+            src, dst, seq = struct.unpack('!HHI', data)
+            return TcpHeader(src=src, dst=dst, win_size=0, data_off=0, seq=seq)
+
+        fields = struct.unpack(TcpHeader.fmt, data[:20])
+        src, dst, seq, ack_num, flags, win_size, csum, urg_ptr = fields
+        data_off = (flags >> 12) & 0xf
+        fbits = [((flags >> i) & 0x1) for i in xrange(9)][::-1]
+        ns, cwr, ece, urg, ack, psh, rst, syn, fin = fbits
+        payload = data[(data_off * 4):]
+        return TcpHeader(src=src, dst=dst, seq=seq, ack_num=ack_num, ns=ns,
+                         cwr=cwr, ece=ece, urg=urg, ack=ack, psh=psh, rst=rst,
+                         syn=syn, fin=fin, win_size=win_size, csum=csum,
+                         urg_ptr=urg_ptr, payload=payload)
+
+    def serialize(self, ph_fn):
+        if self.data_off == 0:
+            self.data_off = 5
+
+        bits = [self.ns, self.cwr, self.ece, self.urg, self.ack, self.psh,
+                self.rst, self.syn, self.fin]
+        flags = reduce(lambda flags, bit: (flags << 1) | bit, bits, 0)
+        flags = flags | (self.data_off << 12)
+
+        csum = self.csum
+        if csum == 0:
+            fields = [self.src, self.dst, self.seq, self.ack_num, flags,
+                      self.win_size, csum, self.urg_ptr]
+            s = struct.pack(self.__class__.fmt, *fields) + self.payload
+            csum = internet_csum(ph_fn(20 + len(self.payload)) + s)
+
+        fields = [self.src, self.dst, self.seq, self.ack_num, flags,
+                  self.win_size, csum, self.urg_ptr]
+        return struct.pack(self.__class__.fmt, *fields) + self.payload
+
+    def __repr__(self):
+        return ('TcpHeader(src={s.src}, dst={s.dst}, seq={s.seq}, ' +
+                'ack_num={s.ack_num}, ns={s.ns}, cwr={s.cwr}, ece={s.ece}, ' +
+                'urg={s.urg}, ack={s.ack}, psh={s.psh}, rst={s.rst}, ' +
+                'syn={s.syn}, fin={s.fin}, win_size={s.win_size}, ' +
+                'csum=0x{s.csum:x}, urg_ptr={s.urg_ptr})').format(s=self)
+
+class UdpHeader:
+    fmt = '!HHHH'
+    encaps_proto = socket.IPPROTO_UDP
+    def __init__(self, src, dst, csum=0, payload=''):
+        self.src, self.dst, self.csum, self.payload = src, dst, csum, payload
+
+    @staticmethod
+    def parse(data):
+        fields = struct.unpack(UdpHeader.fmt, data[:8])
+        src, dst, csum, length = fields
+        payload = data[8:length]
+        return UdpHeader(src=src, dst=dst, csum=csum, payload=payload)
+
+    def serialize(self, ph_fn):
+        length = 8 + len(self.payload)
+        csum = self.csum
+        if csum == 0:
+            fields = [self.src, self.dst, csum, length]
+            s = struct.pack(self.__class__.fmt, *fields) + self.payload
+            csum = internet_csum(ph_fn(length) + s)
+        fields = [self.src, self.dst, csum, 8 + len(self.payload)]
+        return struct.pack(UdpHeader.fmt, *fields) + self.payload
+
+    def __repr__(self):
+        return ('UdpHeader(src={s.src}, dst={s.dst}, csum=0x{s.csum:x}, ' +
+                'payload={s.payload})').format(s=self)
+
+class IcmpDestUnreachHeader:
+    fmt = '!BBHHH'
+    encaps_proto = socket.IPPROTO_ICMP
+    def __init__(self, csum=0, next_mtu=1500, payload=None):
+        self.type, self.code, self.csum, self.next_mtu = 3, 4, csum, next_mtu
+        self.payload = payload
+
+    @staticmethod
+    def parse(data):
+        fields = struct.unpack(IcmpDestUnreachHeader.fmt, data[:8])
+        type, code, csum, _, next_mtu = fields
+        assert type == 3 and code == 4, "because supporting all icmp sucks"
+        payload = parse_payload(socket.IPPROTO_IPIP, data[8:])
+        return IcmpDestUnreachHeader(next_mtu=next_mtu, csum=csum,
+                                     payload=payload)
+
+    def serialize(self, ph_fn=None):
+        assert self.payload.__class__.encaps_proto == socket.IPPROTO_IPIP
+        ps = self.payload.serialize()[:28]
+        csum = self.csum
+        if csum == 0:
+            fields = [self.type, self.code, csum, 0, self.next_mtu]
+            s = struct.pack(self.__class__.fmt, *fields)
+            csum = internet_csum(s + ps)
+        fields = [self.type, self.code, csum, 0, self.next_mtu]
+        s = struct.pack(self.__class__.fmt, *fields)
+        return s + ps
+
+    def __repr__(self):
+        return ('IcmpDestUnreachHeader(csum=0x{s.csum:x}, ' + 
+                'next_mtu={s.next_mtu}, payload={s.payload})').format(s=self)
+
+class Icmpv6PacketTooBigHeader:
+    fmt = '!BBHI'
+    encaps_proto = socket.IPPROTO_ICMPV6
+    def __init__(self, csum=0, mtu=1500, payload=None):
+        self.type, self.code, self.csum, self.mtu = 2, 0, csum, mtu
+        self.payload = payload
+
+    @staticmethod
+    def parse(data):
+        fields = struct.unpack(Icmpv6PacketTooBigHeader.fmt, data[:8])
+        type, code, csum, mtu = fields
+        assert type == 2 and code == 0, "because supporting all icmpv6 sucks"
+        payload = parse_payload(socket.IPPROTO_IPV6, data[8:])
+        return Icmpv6PacketTooBigHeader(mtu=mtu, csum=csum,
+                                        payload=payload)
+
+    def serialize(self, ph_fn):
+        assert self.payload.__class__.encaps_proto == socket.IPPROTO_IPV6
+        ps = self.payload.serialize()
+        csum = self.csum
+        if csum == 0:
+            fields = [self.type, self.code, csum, self.mtu]
+            s = struct.pack(self.__class__.fmt, *fields)
+            csum = internet_csum(ph_fn(len(s + ps)) + s + ps)
+        fields = [self.type, self.code, csum, self.mtu]
+        s = struct.pack(self.__class__.fmt, *fields)
+        return s + ps
+
+    def __repr__(self):
+        return ('Icmpv6PacketTooBigHeader(csum=0x{s.csum:x}, ' + 
+                'mtu={s.mtu}, payload={s.payload})').format(s=self)
diff --git a/tools/testing/selftests/ipvs/network_test_utils.py b/tools/testing/selftests/ipvs/network_test_utils.py
new file mode 100644
index 0000000..f9ab162
--- /dev/null
+++ b/tools/testing/selftests/ipvs/network_test_utils.py
@@ -0,0 +1,93 @@
+import fcntl
+import os
+import re
+import select
+import socket
+import struct
+import subprocess
+import unittest
+
+import network_headers
+
+def set_sysctl(ctl, val, throw=False):
+    try:
+        with open(os.path.join('/proc/sys', ctl.replace('.', '/')), 'w') as f:
+            f.write(str(val))
+        return True
+    except:
+        if throw:
+            raise
+        return False
+
+def kernel_version():
+    regex = r"([0-9])*\.([0-9]*)\.([0-9]*)-.*"
+    return map(int, re.match(regex, os.uname()[2]).groups())
+
+def send_raw_packet(packet):
+    s = socket.socket(packet.__class__.address_family, socket.SOCK_RAW,
+                      socket.IPPROTO_RAW);
+    s.sendto(packet.serialize(), 0, (packet.dst, 0))
+    s.close()
+
+def add_ipvs_service(vip, port, real_servers, scheduler='rr', service_type='tcp'):
+    if vip.find(':') >= 0 and vip[0] != '[':
+        vip = '[' + vip + ']'
+    def c(*args):
+        assert subprocess.call(args) == 0
+    service = '%s:%d' % (vip, port)
+    sf = '--tcp-service' if service_type == 'tcp' else '--udp-service'
+    ef = '--ipip'
+    c('ipvsadm', '-A', sf, service, '--scheduler', scheduler)
+    for rs in real_servers[::-1]:
+        c('ipvsadm', '-a', sf, service, '--real-server', rs, ef)
+
+
+def reset_ipvs():
+    subprocess.call("""\
+        ipvsadm --clear &&
+        lsmod | grep '^ip_vs_' | cut -d' ' -f1 | xargs -r -n1 rmmod &&
+        rmmod ip_vs;
+    """, shell=True)
+
+    # TODO(agartrell@fb.com): Why do we need to have a v4 vip always?
+    add_ipvs_service('192.168.255.38', 999, [])
+
+class Tun:
+    def __init__(self):
+        TUNSETIFF = 0x400454ca
+        IFF_TUN = 0x0001
+        IFF_NO_PI = 0x1000
+        self.tun = open('/dev/net/tun', 'r')
+        ifr = struct.pack('16sH', 'tun%d', IFF_TUN | IFF_NO_PI)
+        ifr = fcntl.ioctl(self.tun, TUNSETIFF, ifr)
+        self.name = struct.unpack('16sH', ifr)[0].split('\0')[0]
+
+        subprocess.call(['ip', 'link', 'set', 'dev', self.name, 'up'])
+
+    def add_route(self, rt):
+        subprocess.call(['ip', 'route', 'add', 'dev', self.name, rt])
+
+    def add_routes(self, routes):
+        for rt in routes:
+            self.add_route(rt)
+
+    def read(self, tmo=1):
+        r, w, e = select.select([self.tun], [], [], tmo)
+        if len(r):
+            s = os.read(self.tun.fileno(), 1500)
+            return network_headers.parse_l3_packet(s)
+        else:
+            return None
+
+    def close(self):
+        self.tun.close()
+
+class IpvsTest(unittest.TestCase):
+    def setUp(self):
+        reset_ipvs()
+        self.tun = Tun()
+
+    def tearDown(self):
+        self.tun.close()
+        self.tun = None
+
diff --git a/tools/testing/selftests/ipvs/test-ipvs.py b/tools/testing/selftests/ipvs/test-ipvs.py
new file mode 100644
index 0000000..fb5f20e
--- /dev/null
+++ b/tools/testing/selftests/ipvs/test-ipvs.py
@@ -0,0 +1,17 @@
+import sys
+import os
+import unittest
+
+def main(argv):
+    if os.geteuid() != 0:
+        print >>sys.stderr, "Must be run as root"
+        sys.exit(2)
+
+    suite = unittest.TestSuite()
+    for modname in argv[1:]:
+        module = __import__(modname)
+        suite.addTest(unittest.TestLoader().loadTestsFromModule(module))
+    unittest.TextTestRunner(verbosity=2).run(suite)
+
+if __name__ == '__main__':
+    main(sys.argv)
-- 
1.8.1

