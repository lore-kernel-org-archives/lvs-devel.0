From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 0/2] netfilter: ipvs: some fixes in sctp_conn_schedule
Date: Sun, 20 Aug 2017 13:38:06 +0800
Message-ID: <cover.1503207076.git.lucien.xin@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=Z/ULjR4vd5Y3m8DDb5j4z2mmHqo72ZhLI2ChtBNVkcY=;
        b=g/pi5fwvwaCEKH7CsXB40rOBG2173oIRNqRtKAJ+TifqrYCNTD23BGtiMWsu07bjNd
         YS/cDcsd6ExE9/JmuwVNrCd0gfct4XjlUyNoCrqZWWi7b+qXwAT++uLC89yDozaakri9
         +DynKYiaiHlLA6zlX5N//9atnWsHw3qDvmzajegxVqTn3w0NRFAhj0JCAdc3w8dYK0UH
         Zbkmme6FaMLmXt51N1eyPGEbupGeBLzTBJl7Msc0ToaDJxxFLBYDdttpjdVB3hdiKOvf
         f58csND9aMIhQHhU9WVqPXMytujs2xliVHPmmwUTYgRBRKFq/xrlpbdBqnESH3yZmdEt
         65Gw==
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org
Cc: pablo@netfilter.org, Alex Gartrell <agartrell@fb.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org

Patch 1/2 fixes the regression introduced by commit 5e26b1b3abce.
Patch 2/2 makes ipvs not create conn for sctp ABORT packet.

Xin Long (2):
  netfilter: ipvs: fix the issue that sctp_conn_schedule drops non-INIT
    packet
  netfilter: ipvs: do not create conn for ABORT packet in
    sctp_conn_schedule

 net/netfilter/ipvs/ip_vs_proto_sctp.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

-- 
2.1.0

