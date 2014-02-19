From: Art -kwaak- van Breemen <ard@telegraafnet.nl>
Subject: Re: [PATCH] ipvs: fix ipv6 icmp forwarding in natted services
Date: Wed, 19 Feb 2014 19:21:04 +0100
Message-ID: <20140219182103.GL20771@telegraafnet.nl>
References: <20140217161601.GD18029@telegraafnet.nl>
 <alpine.LFD.2.11.1402172321200.2420@ja.home.ssi.bg>
 <20140218100533.GE18029@telegraafnet.nl>
 <20140218133725.GA20771@telegraafnet.nl>
 <20140218135439.GB20771@telegraafnet.nl>
 <alpine.LFD.2.11.1402182225560.2011@ja.home.ssi.bg>
 <20140219102751.GD20771@telegraafnet.nl>
 <1392825857.5821.422.camel@hawk.mlab.se>
 <20140219175335.GJ20771@telegraafnet.nl>
 <20140219180232.GK20771@telegraafnet.nl>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140219180232.GK20771@telegraafnet.nl>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Ansis Atteka <aatteka@nicira.com>, Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>


Hans,
I want to keep the patch as is, but change the description:

====
[PATCH] ipvs: fix wrong icmp_offset in ip_vs_nat_icmp_v6
From: Ard van Breemen <ard@telegraafnet.nl>


Fix regression introduced in 3.8 with commit 9195bb8e381d81
("ipv6: improve ipv6_find_hdr() to skip empty routing headers")
which broke commit 63dca2c0b0e7a9
("ipvs: Fix faulty IPv6 extension header handling in IPVS").
by a small change in ipv6_find_hdr: finding specific protocols is not
supported anymore, use -1 instead. Solves (pmtud) problems caused by
damaged IPv6 headers in NAT-ed ICMP packets.

Signed-off-by: Ard van Breemen <ard@telegraafnet.nl>
CC: Jesper Dangaard Brouer <brouer@redhat.com>
CC: Hans Schillstrom <hans@schillstrom.com>

---

Do you and Ansis agree with me?

Regards,

Ard van Breemen
