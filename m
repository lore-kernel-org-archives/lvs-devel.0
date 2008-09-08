From: Simon Horman <horms@verge.net.au>
Subject: [rfc 0/3] IPVS: checksum updates
Date: Mon, 08 Sep 2008 12:04:20 +1000
Message-ID: <20080908020420.313463898@vergenet.net>
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: =?ISO-8859-15?q?Siim=20P=C3=B5der?= <siim@p6drad-teel.net>, Julian Anastasov <ja@ssi.bg>, Malcolm Turnbull <malcolm@loadbalancer.org>, Julius Volz <juliusv@google.com>, Vince Busam <vbusam@google.com>, Herbert Xu <herbert@gondor.apana.org.au>

Hi,

The impetus for this series of patches is Julian Anastasov noting
that "load balance IPv4 connections from a local process" checks
for 0 TCP checksums. Herbert Xu confirmed that this is not legal,
even on loopback traffic, but that rather partial checksums are
possible.

The first patch in this series is a proposed solution to handle
partial checksums for both TCP and UDP.

The other two patches clean things up a bit.

I have not tested this code beyond compilation yet.
