From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 3/5] ipvs: Document sysctl sync_qlen_max and sync_sock_size
Date: Thu, 16 Mar 2017 13:43:13 +0100
Message-ID: <1489668195-15240-4-git-send-email-horms@verge.net.au>
References: <1489668195-15240-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1489668205; bh=OmECVureu8xx0fbR5swuAgAgMPvpCgVKANaI9NNAOxU=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=sYr6KP0C3+Vp4GQf5PMqivGVDDt757cLfI8ou6+TREZAa8emTmK9nocv92B9AFKa9
         XHwQkRVPVLVdgfhHswjF3YLZiYtIKm0MlcVyPKNKXrwhhBIdJTXycqt/YE+NiU0ETn
         r7r6dAjS+jHaB2kYFe9uVSRoBJAiyWZ2wEyQumJM=
In-Reply-To: <1489668195-15240-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hangbin Liu <liuhangbin@gmail.com>, Simon Horman <horms@verge.net.au>

From: Hangbin Liu <liuhangbin@gmail.com>

Document sysctl sync_qlen_max and sync_sock_size based on
commit 1c003b1580e2 ("ipvs: wakeup master thread").

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 Documentation/networking/ipvs-sysctl.txt | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/Documentation/networking/ipvs-sysctl.txt b/Documentation/networking/ipvs-sysctl.txt
index 7acaaa65451e..159d70b6dff3 100644
--- a/Documentation/networking/ipvs-sysctl.txt
+++ b/Documentation/networking/ipvs-sysctl.txt
@@ -217,6 +217,20 @@ sync_retries - INTEGER
 	to protect against loss of sync messages. The range of the
 	sync_retries is from 0 to 3.
 
+sync_qlen_max - UNSIGNED LONG
+
+	Hard limit for queued sync messages that are not sent yet. It
+	defaults to 1/32 of the memory pages but actually represents
+	number of messages. It will protect us from allocating large
+	parts of memory when the sending rate is lower than the queuing
+	rate.
+
+sync_sock_size - INTEGER
+	default 0
+
+	Configuration of SNDBUF (master) or RCVBUF (slave) socket limit.
+	Default value is 0 (preserve system defaults).
+
 snat_reroute - BOOLEAN
 	0 - disabled
 	not 0 - enabled (default)
-- 
2.7.0.rc3.207.g0ac5344

