From: Alex Gartrell <agartrell@fb.com>
Subject: RFC: IPVS Unit Tests
Date: Wed, 6 Aug 2014 01:19:53 -0700
Message-ID: <53E1E529.1030407@fb.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="------------090407010700070600030301"
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=message-id : date : from :
 mime-version : to : cc : subject : content-type; s=facebook;
 bh=5nBEb72DR/e103lcQUiqS3q4AYcSQr63Y9vdeFJ61bQ=;
 b=j/3A+MNtnEp9DMJ0tcwlzwRR+MonLvCXJ6gkkxEm1iuKyHWgqGu7k1YUfH9Pmi6Ou7Y4
 wOKOTXSYj032Nb0Lh8WsjBdZARibKYkmZ9CrR/xSN1WG/tui0RVN2Irp/SxlfNmBbfop
 aStIz0SKjraiEUIqRmd+2cM7BNz4gLdvLGw= 
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: lvs-devel@vger.kernel.org
Cc: kernel-team <Kernel-team@fb.com>

--------------090407010700070600030301
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit

tl;dr; I've attached the outline of basic unit tests (v4 and v6 tests 
for round robin, but the sky's the limit) and want feedback

As previously mentioned, we use ipvs /a lot/ at Facebook.  We have a 
bunch of diffs that are pretty hacky to extend it to do stuff we need 
(mostly the ability to schedule flows at any point, because we ICMP to 
various ipvs instances and that can shift).  Eventually my aim is for 
that functionality to reach you guys in a more acceptable form, but at 
the moment that's the state of the world.

Anyway, in the process of forward porting stuff, I wrote a ton of unit 
tests for the custom functionality, but it's kind of a drag to extend 
and I don't think any of you are going to be super thrilled about unit 
tests that require our open source libraries (folly) and c++11.  So I 
started over in python to see how far I could get this afternoon.

These tests transmit over a raw socket and receive over a tun device.  I 
was running it on a 3.2 host, but it should work all the way forward to 
*-next (the C++ version does).  It's pretty easy to extend and mess with.

I've attached the entire script, but here's a simple test

     def do_stickiness_test(self, vip, port, real_servers, src_ip, iph_fn):
         self.tun.add_routes(real_servers)

         # For some reason this is necessary to not break ipv6?
         add_service('192.168.255.38', 999, [])
         add_service(vip, port, real_servers)

         buckets = {}
         base_port = 15000
         for i in xrange(10000):
             src = base_port + (i % 43)
             p = iph_fn(src_ip, vip, payload=TcpHeader(src, port, syn=1))
             send_raw_packet(p)
             dst_ip = parse_packet(self.tun.read()).dst
             if src not in buckets:
                 buckets[src] = dst_ip
             else:
                 self.assertEqual(buckets[src], dst_ip)

     def test_stickiness_v4(self):
         real_servers = ['1.2.3.%d' % i for i in xrange(5, 32)]
         self.do_stickiness_test(
             '1.2.3.4', 15213, real_servers, '9.9.9.9', Ipv4Header)

The raw socket stuff is just generally useful for other stuff too, if 
you're into that kind of thing.

Anyway, please let me know what you think

Thanks,

Alex

--------------090407010700070600030301
Content-Type: text/x-python-script; name="test-ipvs.py"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="test-ipvs.py"

import sys
import collections
import fcntl
import os
import select
import socket
import struct
import subprocess
import unittest

def parse_payload(proto, data):
    if proto == socket.IPPROTO_IPIP:
        return Ipv4Header.parse(data)
    elif proto == socket.IPPROTO_IPV6:
        return Ipv6Header.parse(data)
    elif proto == socket.IPPROTO_TCP:
        return TcpHeader.parse(data)
    elif proto == socket.IPPROTO_UDP:
        return UdpHeader.parse(data)
    else:
        return None

def internet_csum(data):
    def carry_around_add(a, b):
        c = a + b
        return (c & 0xffff) + (c >> 16)

    def checksum(msg):
        s = 0
        for i in range(0, len(msg), 2):
            if i + 1 < len(msg):
                w = ord(msg[i]) + (ord(msg[i+1]) << 8)
            else:
                w = ord(msg[i])
            s = carry_around_add(s, w)
        return ~s & 0xffff

    return socket.htons(checksum(data))

def send_raw_packet(packet):
    s = socket.socket(packet.__class__.address_family, socket.SOCK_RAW,
                      socket.IPPROTO_RAW);
    s.sendto(packet.serialize(), 0, (packet.dst, 0))
    s.close()

def parse_packet(s):
    if s == None:
        return None

    if (ord(s[0]) >> 4) == 4:
        return Ipv4Header.parse(s)
    else:
        return Ipv6Header.parse(s)

class Tun:
    def __init__(self):
        TUNSETIFF = 0x400454ca
        IFF_TUN = 0x0001
        IFF_NO_PI = 0x1000
        self.tun = open('/dev/net/tun', 'r')
        ifr = struct.pack('16sH', 'tun%d', IFF_TUN | IFF_NO_PI)
        ifr = fcntl.ioctl(self.tun, TUNSETIFF, ifr)
        self.name = struct.unpack('16sH', ifr)[0].split('\0')[0]

        subprocess.call(['ip', 'link', 'set', 'dev', self.name, 'up'])

    def add_route(self, rt):
        subprocess.call(['ip', 'route', 'add', 'dev', self.name, rt])

    def add_routes(self, routes):
        for rt in routes:
            self.add_route(rt)

    def read(self, tmo=1):
        r, w, e = select.select([self.tun], [], [], tmo)
        if len(r):
            return os.read(self.tun.fileno(), 1500)
        else:
            return None

    def close(self):
        self.tun.close()

class Ipv4Header:
    fmt = '!BBHHHBBH4s4s'
    encaps_proto = socket.IPPROTO_IPIP
    address_family = socket.AF_INET

    def __init__(self, src, dst, proto=0, version=4, ihl=5, tos=0, tot_len=0,
                 ident=0, frag_off=0, ttl=42, csum=0, payload=None):
        self.src, self.dst, self.proto, self.version = src, dst, proto, version
        self.ihl, self.tos, self.tot_len, self.ident = ihl, tos, tot_len, ident
        self.frag_off, self.ttl, self.csum = frag_off, ttl, csum
        self.payload = payload

    @staticmethod
    def parse(data):
        fields = struct.unpack(Ipv4Header.fmt, data[:20])
        ver_ihl, tos, tot_len, ident, frag_off = fields[:5]
        ttl, proto, csum, src_raw, dst_raw = fields[5:]
        version = ver_ihl >> 4
        ihl = ver_ihl & 0xf
        src = socket.inet_ntop(socket.AF_INET, src_raw)
        dst = socket.inet_ntop(socket.AF_INET, dst_raw)
        payload = parse_payload(proto, data[ihl * 4:tot_len])
        return Ipv4Header(src=src, dst=dst, proto=proto, version=version,
                          ihl=ihl, tos=tos, tot_len=tot_len, ident=ident,
                          frag_off=frag_off, ttl=ttl, csum=csum,
                          payload=payload)

    def __pseudo_header_fn(self, length):
        src_raw = socket.inet_pton(socket.AF_INET, self.src)
        dst_raw = socket.inet_pton(socket.AF_INET, self.dst)
        proto = self.payload.__class__.encaps_proto
        return struct.pack('!4s4sBBH', src_raw, dst_raw, 0, proto, length)

    def serialize(self, ph_fn=None):
        ver_ihl = (self.version << 4) | self.ihl

        ps = self.payload.serialize(ph_fn=self.__pseudo_header_fn)
        if self.proto == 0:
            self.proto = self.payload.__class__.encaps_proto
        if self.tot_len == 0:
            self.tot_len = 20 + len(ps)

        if self.ident == 0:
            self.ident = 0xf00f

        src_raw = socket.inet_pton(socket.AF_INET, self.src)
        dst_raw = socket.inet_pton(socket.AF_INET, self.dst)
        if self.csum == 0:
            fields = [ver_ihl, self.tos, self.tot_len, self.ident,
                      self.frag_off, self.ttl, self.proto, 0, src_raw, dst_raw]
            self.csum = internet_csum(struct.pack(self.__class__.fmt, *fields))

        fields = [ver_ihl, self.tos, self.tot_len, self.ident, self.frag_off,
                  self.ttl, self.proto, self.csum, src_raw, dst_raw]

        return struct.pack(self.__class__.fmt, *fields) + ps

    def __repr__(self):
        return ('Ipv4Header(src="{s.src}", dst="{s.dst}", proto="{s.proto}", ' +
                'version={s.version}, ihl={s.ihl}, tos={s.tos}, ' +
                'tot_len={s.tot_len}, ident={s.ident}, ' +
                'frag_off={s.frag_off}, ttl={s.ttl}, csum=0x{s.csum:x}, ' +
                'payload={s.payload})').format(s=self)

class Ipv6Header:
    fmt = '!IHBB16s16s'
    encaps_proto = socket.IPPROTO_IPV6
    address_family = socket.AF_INET6

    def __init__(self, src, dst, proto=0, version=6, tclass=0, flow_label=0,
                 payload_len=0, hop_limit=42, payload=None):
        self.src, self.dst, self.proto, self.version = src, dst, proto, version
        self.tclass, self.flow_label = tclass, flow_label
        self.payload_len, self.hop_limit = payload_len, hop_limit
        self.payload = payload

    @staticmethod
    def parse(data):
        fields = struct.unpack(Ipv6Header.fmt, data[:40])
        fw, payload_len, proto, hop_limit, src_raw, dst_raw = fields
        version = (fw >> 28) & 0xf
        tclass = (fw >> 20) & 0xff
        flow_label = fw & 0xfffff
        src = socket.inet_ntop(socket.AF_INET6, src_raw)
        dst = socket.inet_ntop(socket.AF_INET6, dst_raw)
        payload = parse_payload(proto, data[40:payload_len + 40])
        return Ipv6Header(src=src, dst=dst, proto=proto, version=version,
                          tclass=tclass, flow_label=flow_label,
                          payload_len=payload_len, hop_limit=hop_limit,
                          payload=payload)

    def __pseudo_header_fn(self, length):
        src_raw = socket.inet_pton(socket.AF_INET6, self.src)
        dst_raw = socket.inet_pton(socket.AF_INET6, self.dst)
        proto = self.payload.__class__.encaps_proto
        return struct.pack('!16s16sIBBBB', src_raw, dst_raw, length, 0, 0, 0,
                           proto)

    def serialize(self, ph_fn=None):
        fw = (self.version << 28) | (self.tclass << 20) | self.flow_label
        ps = self.payload.serialize(ph_fn=self.__pseudo_header_fn)
        if self.proto == 0:
            self.proto = self.payload.__class__.encaps_proto
        if self.payload_len == 0:
            self.payload_len = len(ps)

        src_raw = socket.inet_pton(socket.AF_INET6, self.src)
        dst_raw = socket.inet_pton(socket.AF_INET6, self.dst)

        fields = [fw, self.payload_len, self.proto, self.hop_limit, src_raw,
                  dst_raw]

        return struct.pack(self.__class__.fmt, *fields) + ps

    def __repr__(self):
        return ('Ipv6Header(src="{s.src}", dst="{s.dst}", proto="{s.proto}", ' +
                'version={s.version}, tclass={s.tclass}, ' +
                'flow_label={s.flow_label}, payload_len={s.payload_len}, ' +
                'hop_limit={s.hop_limit}, payload={s.payload})').format(s=self)

class TcpHeader:
    fmt = '!HHIIHHHH'
    encaps_proto = socket.IPPROTO_TCP
    def __init__(self, src, dst, seq=0, ack_num=0, data_off=5, ns=0, cwr=0, ece=0,
                 urg=0, ack=0, psh=0, rst=0, syn=0, fin=0, win_size=100, csum=0,
                 urg_ptr=0, payload=''):
        self.src, self.dst, self.seq, self.ack_num = src, dst, seq, ack_num
        self.data_off, self.ns, self.cwr, self.ece = data_off, ns, cwr, ece
        self.urg, self.ack, self.psh, self.rst = urg, ack, psh, rst
        self.syn, self.fin, self.win_size, self.csum = syn, fin, win_size, csum
        self.urg_ptr, self.payload = urg_ptr, payload

    @staticmethod
    def parse(data):
        fields = struct.unpack(TcpHeader.fmt, data[:20])
        src, dst, seq, ack_num, flags, win_size, csum, urg_ptr = fields
        data_off = (flags >> 12) & 0xf
        fbits = [((flags >> i) & 0x1) for i in xrange(9)][::-1]
        ns, cwr, ece, urg, ack, psh, rst, syn, fin = fbits
        payload = data[(data_off * 4):]
        return TcpHeader(src=src, dst=dst, seq=seq, ack_num=ack_num, ns=ns,
                         cwr=cwr, ece=ece, urg=urg, ack=ack, psh=psh, rst=rst,
                         syn=syn, fin=fin, win_size=win_size, csum=csum,
                         urg_ptr=urg_ptr, payload=payload)

    def serialize(self, ph_fn):
        if self.data_off == 0:
            self.data_off = 5

        bits = [self.ns, self.cwr, self.ece, self.urg, self.ack, self.psh,
                self.rst, self.syn, self.fin]
        flags = reduce(lambda flags, bit: (flags << 1) | bit, bits, 0)
        flags = flags | (self.data_off << 12)

        if self.csum == 0:
            fields = [self.src, self.dst, self.seq, self.ack_num, flags,
                      self.win_size, self.csum, self.urg_ptr]
            s = struct.pack(self.__class__.fmt, *fields) + self.payload
            self.csum = internet_csum(ph_fn(20 + len(self.payload)) + s)

        fields = [self.src, self.dst, self.seq, self.ack_num, flags,
                  self.win_size, self.csum, self.urg_ptr]
        return struct.pack(self.__class__.fmt, *fields) + self.payload

    def __repr__(self):
        return ('TcpHeader(src={s.src}, dst={s.dst}, seq={s.seq}, ' +
                'ack_num={s.ack_num}, ns={s.ns}, cwr={s.cwr}, ece={s.ece}, ' +
                'urg={s.urg}, ack={s.ack}, psh={s.psh}, rst={s.rst}, ' +
                'syn={s.syn}, fin={s.fin}, win_size={s.win_size}, ' +
                'csum=0x{s.csum:x}, urg_ptr={s.urg_ptr})').format(s=self)

class UdpHeader:
    fmt = '!HHHH'
    encaps_proto = socket.IPPROTO_UDP
    def __init__(self, src, dst, csum=0, payload=''):
        self.src, self.dst, self.csum, self.payload = src, dst, csum, payload

    @staticmethod
    def parse(data):
        fields = struct.unpack(UdpHeader.fmt, data[:8])
        src, dst, csum, length = fields
        payload = data[8:length]
        return UdpHeader(src=src, dst=dst, csum=csum, payload=payload)

    def serialize(self, ph_fn):
        length = 8 + len(self.payload)
        if self.csum == 0:
            fields = [self.src, self.dst, self.csum, length]
            s = struct.pack(self.__class__.fmt, *fields) + self.payload
            self.csum = internet_csum(ph_fn(length) + s)
        fields = [self.src, self.dst, self.csum, 8 + len(self.payload)]
        return struct.pack(UdpHeader.fmt, *fields) + self.payload

    def __repr__(self):
        return ('UdpHeader(src={s.src}, dst={s.dst}, csum=0x{s.csum:x}, ' +
                'payload={s.payload})').format(s=self)

RESET_IPVS = """\
ipvsadm --clear &&
lsmod | grep '^ip_vs_' | cut -d' ' -f1 | xargs -r -n1 rmmod &&
rmmod ip_vs;
"""

def add_service(vip, port, real_servers, scheduler='rr', service_type='tcp'):
    if vip.find(':') >= 0 and vip[0] != '[':
        vip = '[' + vip + ']'
    def c(*args):
        assert subprocess.call(args) == 0
    service = '%s:%d' % (vip, port)
    sf = '--tcp-service' if service_type == 'tcp' else '--udp-service'
    ef = '--ipip'
    c('ipvsadm', '-A', sf, service, '--scheduler', scheduler)
    for rs in real_servers[::-1]:
        c('ipvsadm', '-a', sf, service, '--real-server', rs, ef)

class TestIpvsRoundRobin(unittest.TestCase):
    def setUp(self):
        subprocess.call(RESET_IPVS, shell=True)
        self.tun = Tun()

    def tearDown(self):
        self.tun.close()
        self.tun = None

    def do_balance_test(self, vip, port, real_servers, src_ip, iph_fn):
        self.tun.add_routes(real_servers)

        # For some reason this is necessary to not break ipv6?
        add_service('192.168.255.38', 999, [])
        add_service(vip, port, real_servers)

        buckets = collections.defaultdict(lambda: 0)
        base_port = 15000
        for i in xrange(10000):
            src = base_port + i
            p = iph_fn(src_ip, vip, payload=TcpHeader(src, port, syn=1))
            send_raw_packet(p)
            buckets[parse_packet(self.tun.read()).dst] += 1

        avg = float(sum(buckets.values())) / len(buckets)
        for k, v in buckets.iteritems():
            self.assertTrue(abs(v - avg) <= 1.0)

    def test_balance_v4(self):
        real_servers = ['1.2.3.%d' % i for i in xrange(5, 32)]
        self.do_balance_test(
            '1.2.3.4', 15213, real_servers, '9.9.9.9', Ipv4Header)

    def test_balance_v6(self):
        real_servers = ['face::%x' % i for i in xrange(5, 32)]
        self.do_balance_test(
            'face::4', 15213, real_servers, 'b00c::1', Ipv6Header)

    def do_stickiness_test(self, vip, port, real_servers, src_ip, iph_fn):
        self.tun.add_routes(real_servers)

        # For some reason this is necessary to not break ipv6?
        add_service('192.168.255.38', 999, [])
        add_service(vip, port, real_servers)

        buckets = {}
        base_port = 15000
        for i in xrange(10000):
            src = base_port + (i % 43)
            p = iph_fn(src_ip, vip, payload=TcpHeader(src, port, syn=1))
            send_raw_packet(p)
            dst_ip = parse_packet(self.tun.read()).dst
            if src not in buckets:
                buckets[src] = dst_ip
            else:
                self.assertEqual(buckets[src], dst_ip)

    def test_stickiness_v4(self):
        real_servers = ['1.2.3.%d' % i for i in xrange(5, 32)]
        self.do_stickiness_test(
            '1.2.3.4', 15213, real_servers, '9.9.9.9', Ipv4Header)

    def test_stickiness_v6(self):
        real_servers = ['face::%x' % i for i in xrange(5, 32)]
        self.do_stickiness_test(
            'face::4', 15213, real_servers, 'b00c::1', Ipv6Header)


if __name__ == '__main__':
    unittest.main()

--------------090407010700070600030301--
