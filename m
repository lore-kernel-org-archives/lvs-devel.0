From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH -stable 0/3] ipvs: patches for stable
Date: Mon,  1 May 2017 16:45:34 +0300
Message-ID: <20170501134537.4715-1-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org

	Hello,

The following patches are rediffs for "ipvs: SNAT packet replies
only for NATed connections" for different stable kernels:

The official patch for the net tree (will come from Simon) works for:
4.9.25, 4.10.13, 4.11, net tree

Patch 1: 3.2.88, 3.4.113
Patch 2: 3.10.105, 3.12.73, 3.16.43, 4.1.39
Patch 3: 4.4.65
