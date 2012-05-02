From: Simon Horman <horms@verge.net.au>
Subject: [ANNOUNCE] ipvs and ipvs-next trees rebased
Date: Wed, 2 May 2012 10:33:30 +0900
Message-ID: <20120502013329.GB20415@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: Julian Anastasov <ja@ssi.bg>

Hi,

I have rebased my ipvs tree on kernel.org to reflect that the patches
have been added to Pablo's net tree.

The current head of the master branch is now:

116a0fc netem: fix possible skb leak


I have also rebased my ipvs-net tree on kernel.org in order to provide a pull
request for Pablo based on his net-next tree.

The current head of the master branch is now:

f0cb1db IPVS: ip_vs_proto.c: local functions should not be exposed globally

