From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 5/5] ipvs: Document sysctl pmtu_disc
Date: Thu, 16 Mar 2017 13:43:15 +0100
Message-ID: <1489668195-15240-6-git-send-email-horms@verge.net.au>
References: <1489668195-15240-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1489668209; bh=ItkqBzhwaeRxO3+rsZsZngjRG5KOuoW6wKFqi+JIL7Y=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=Z3eCt2MmBFIILy8Rgdem3s5iaIqYbvYqsNwQacu2Bc27n1IJ1bG7C1mbPbvK9xL0x
         DExD4pH5Hr2nL1xRo5Q/WTzAqO6NNPlXotK4/MrBrfNdt9KH7/BMmYxEybCd5TWGqM
         rghsIxYqNVi8DjcTsbnYk7cIlqRrK9zogAelv2jA=
In-Reply-To: <1489668195-15240-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hangbin Liu <liuhangbin@gmail.com>, Simon Horman <horms@verge.net.au>

From: Hangbin Liu <liuhangbin@gmail.com>

Document sysctl pmtu_disc based on commit 3654e61137db ("ipvs: add
pmtu_disc option to disable IP DF for TUN packets").

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 Documentation/networking/ipvs-sysctl.txt | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/Documentation/networking/ipvs-sysctl.txt b/Documentation/networking/ipvs-sysctl.txt
index a6feecd467cd..056898685d40 100644
--- a/Documentation/networking/ipvs-sysctl.txt
+++ b/Documentation/networking/ipvs-sysctl.txt
@@ -175,6 +175,14 @@ nat_icmp_send - BOOLEAN
         for VS/NAT when the load balancer receives packets from real
         servers but the connection entries don't exist.
 
+pmtu_disc - BOOLEAN
+	0 - disabled
+	not 0 - enabled (default)
+
+	By default, reject with FRAG_NEEDED all DF packets that exceed
+	the PMTU, irrespective of the forwarding method. For TUN method
+	the flag can be disabled to fragment such packets.
+
 secure_tcp - INTEGER
         0  - disabled (default)
 
-- 
2.7.0.rc3.207.g0ac5344

