From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Slab corruption
Date: Thu, 7 Oct 2010 08:57:21 +0200
Message-ID: <201010070857.21822.hans.schillstrom@ericsson.com>
References: <20100926133313.GA30560@verge.net.au> <1285913303.5670.122.camel@seasc0214> <alpine.LFD.2.00.1010011018270.1615@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1010011018270.1615@ja.ssi.bg>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>
Cc: "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>

Hi
Have you seen Slab corruption before ?
I got it when deleting a service when there is real-servers left
It's not related to IPv6 or fwmarks any "-D" causes it if there is rs attached for that service
(and it's not bad RAM).

ex.
# ipvsadm -D -f 21 -6
Slab corruption: size-512 start=ffff880001760488, len=512
Redzone: 0x9f911029d74e35b/0x9f911029d74e35b.
Last user: [<ffffffffa004aa3a>](__ip_vs_del_service+0xfa/0x108 [ip_vs])
020: 6b 6b 6b 6b 6a 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
Single bit error detected. Probably bad RAM.
Run memtest86+ or a similar memory test tool.
Prev obj: start=ffff880001760270, len=512
Redzone: 0x9f911029d74e35b/0x9f911029d74e35b.
Last user: [<ffffffff812b7a48>](skb_release_data+0xc1/0xc6)
000: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
010: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
Next obj: start=ffff8800017606a0, len=512
Redzone: 0xd84156c5635688c0/0xd84156c5635688c0.
Last user: [<ffffffff812b3487>](sock_wmalloc+0x34/0x75)
000: 5a 5a 5a 5a 5a 5a 5a 5a 00 00 33 33 00 00 00 05
010: 00 00 02 01 01 01 86 dd 60 00 00 00 00 30 59 01

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
