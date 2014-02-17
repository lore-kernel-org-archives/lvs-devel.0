From: Art -kwaak- van Breemen <ard@telegraafnet.nl>
Subject: Regression in pmtud lvs-nat with ipv6 since at least 3.10
Date: Mon, 17 Feb 2014 16:32:06 +0100
Message-ID: <20140217153206.GC18029@telegraafnet.nl>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org

Hi,
I just discovered a major regression in path-mtu-discovery with
lvs-nat-ipv6
It seems that at least since 3.10.27, verifiedn on 3.12.10, with
the latest known working at least 3.7.10.

The problem is this:
The ICMP6, packet too big gets "corrupted". In a sence the icmp
itself does not get corrupted, but the replacement of source and
destination address are plain wrong:

A correct dump (on 3.7.10):
16:16:55.351103 IP6 2a02:XXXX:0:XXX::2 > 2a02:310:0:2950::80:108: ICMP6, packet too big, mtu 1480, length 1240
        0x0000:  6000 0000 04d8 3a3d 2a02 XXXX 0000 XXXX  `.....:=*.......
        0x0010:  0000 0000 0000 0002 2a02 0310 0000 2950  ........*.....)P
        0x0020:  0000 0000 0080 0108 0200 6564 0000 05c8  ..........ed....
        0x0030:  6000 0000 05b4 063c 2a02 0310 0000 2950  `......<*.....)P
        0x0040:  0000 0000 0080 0108 2a02 XXXX XXXX XXXX  ........*....._.
        0x0050:  XXXX XXXX 996e 3404 01bb e128 a28b 89fd  eK0y.n4....(....
        0x0060:  45ac 7c39 8010 0078 6708 0000 0101 080a  E.|9...xg.......
        0x0070:  c8e9 759f 002b e18d a003 0201 0202 0302  ..u..+..........
        0x0080:  36d1 300d 0609 2a86 4886 f70d 0101 0505  6.0...*.H.......
        0x0090:  0030 4231 0b30 0906 0355 0406 1302 5553  .0B1.0...U....US
<snip>


A wrong dump (any since 3.10.27):
14:32:11.822345 IP6 2001:7b8:2ff:6f:2a02:310:0:2950 > ::80:104:0:0:80:104: ICMP6, packet too big, mtu 1472, length 1240
        0x0000:  6000 aa5f 04d8 3a3c 2001 07b8 02ff 006f  `.._..:<.......o
        0x0010:  2a02 0310 0000 2950 0000 0000 0080 0104  *.....)P........
        0x0020:  0000 0000 0080 0104 0200 0617 0000 05c0  ................
        0x0030:  6000 0000 05a8 063b 2a02 0310 0000 0100  `......;*.......
        0x0040:  0200 f8ff fe80 0004 2001 07b8 032d 0000  .............-..
        0x0050:  YYYY YYYY YYYY YYYY 0050 c723 7e6a 835c  .d....66.P.#~j.\
        0x0060:  ca00 19c5 8010 0078 f3b6 0000 0101 080a  .......x........
        0x0070:  c8df df1e 0945 23c2 4854 5450 2f31 2e31  .....E#.HTTP/1.1
<snip>

What we can clearly see in the wrong picture is this:
source higher 64 bits is correct (my home gw address)
source lower 64 bits is the higher 64 bits of the destination machine.
destination higher 64 bits is the lower 64 bits of the destination machine
destination lower 64 bits is the lower 64 bits of the destination machine.
That last part in question is this on the loadbalancer:
TCP  [2a02:310:0:100:200:f8ff:fe80:4]:http wrr
  -> [2a02:310:0:2950::80:104]:http Masq    4      0          0         
  -> [2a02:310:0:2950::80:204]:http Masq    4      0          0         

The addresses within the icmp6 packet itself are also not translated.


I've been browsing git but I cannot see any real differences in icmpv6
handling, so I think it might be that the core has some changes.

Regards,

Ard van Breemen

