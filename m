From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 00/12] ipvs: changes for local server and local client
Date: Sun, 17 Oct 2010 16:12:21 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1010171607550.20665@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; format="flowed"; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org


 	Hello,

 	The following patches fix some bugs (patch 1 and 2),
add support for NAT to local real server, add handlers in
LOCAL_OUT to properly schedule connections from local clients.
Currently, patch 9 and 10 add these handlers in LOCAL_OUT
without any configuration, i.e. we add code in OUTPUT hook
which is not good for the performance of non-IPVS traffic.
May be some config option that enables support for DNAT
to local servers and for local clients can help for this.

 	The patches are against recent nf-next and require
the "ipvs: IPv6 tunnel mode" patch. They are tested
and can be applied to nf-next after review/comments.

What works:

- NAT to local real server, even with different port, from local
or remote client

- local client:
 	- NAT, DR, TUN

 	- from LOCAL_OUT, needs client to bind socket
 	to non-VIP address before connecting if DR/TUN servers are
 	used because the output routing before OUTPUT hook
 	selects VIP as source address ignoring any preferred source
 	addresses, even if the local route is replaced.

Not tested: IPv6. I'll need help here from people with IPv6 setups.

Remaining problems:

- IPv6 defragmentation: still not implemented, we rely on netfilter defrag

Regards

--
Julian Anastasov <ja@ssi.bg>
