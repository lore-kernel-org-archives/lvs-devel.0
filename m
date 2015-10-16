From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next 0/2] ipvs: drop packet during rescheduling
Date: Fri, 16 Oct 2015 11:07:47 +0300
Message-ID: <1444982869-9600-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Jiri Bohac <jbohac@suse.cz>

Jiri Bohac is reporting for a problem with the connection
rescheduling mechanism added in 3.10 when new SYNs in
connection to dead real server can be redirected to another
real server. His solution is to drop SYNs until the IPVS
connection and its conntrack are properly removed, so that
a new connection can be established later from client's
retransmissions. Alternative would be to redirect the
conntrack (its reply direction) to the new real server but
we do not see such solution.

The second patch addresses another scenario: client restarts
TCP connection by reusing the same IPVS connection:

- IPVS conn is established, eg. FTP without persistence
- restart client box
- start new TCP connection from same port to reuse IPVS conn
C: SYN with new SEQ
S: ACK with ACK_SEQ=old SEQ
C: RST SEQ=old SEQ, IPVS conn:EST->CLOSE
retransmit pause
C: SYN, still in CLOSE? => DROP, expire IPVS conn
Expire IPVS connection
retransmit pause
C: SYN, create connection

In this case we should allow rescheduling in CLOSE state.
In the worst case for this scenario with initial RTO=3 secs
the client can be delayed for 9 seconds.

Julian Anastasov (2):
  ipvs: drop first packet to redirect conntrack
  ipvs: allow rescheduling after RST

 include/net/ip_vs.h             | 17 +++++++++++++++++
 net/netfilter/ipvs/ip_vs_core.c | 38 +++++++++++++++++++++++++++++---------
 2 files changed, 46 insertions(+), 9 deletions(-)

-- 
1.9.3

