From: Chris Caputo <ccaputo@alt.net>
Subject: [PATCH 2/2] IPVS: add wlib & wlip schedulers
Date: Sat, 17 Jan 2015 23:16:09 +0000 (UTC)
Message-ID: <Pine.LNX.4.64.1501172310300.8217@nacho.alt.net>
Reply-To: Chris Caputo <ccaputo-dated-1431904570.dcd98e@alt.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alt.net;
	s=default; x=1422141771; h=Comment:DomainKey-Signature:Received:
	Received:Received:Date:To:cc:Subject:Message-ID:MIME-Version:
	Content-Type:From:Reply-To; bh=iIcvc/iyY2Ggqxfc0Jm580PgSHZQK1Dk+
	FmpXPa8+QU=; b=L/ZOxTj4wJ10gZ9dt4HOjKf5FNUfIRQLUZFTvxgS82fCmhJRe
	S/95db3WblSkptDvCzlNjwRdUCAmJIFDuD27GLw18gKZ8gNe147kkuP0hT5ZWqUN
	VUi6jXCplB/QC4IChliG3rDOi/fO0fUEqP1NjM1q1ukqHeO9rKmgYeV8GU=
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org

From: Chris Caputo <ccaputo@alt.net> 

IPVS wlib (Weighted Least Incoming Byterate) and wlip (Weighted Least Incoming 
Packetrate) scheduler docs for ipvsadm-1.27.

Signed-off-by: Chris Caputo <ccaputo@alt.net>
---
diff -upr ipvsadm-1.27-stock/SCHEDULERS ipvsadm-1.27/SCHEDULERS
--- ipvsadm-1.27-stock/SCHEDULERS	2013-09-06 08:37:27.000000000 +0000
+++ ipvsadm-1.27/SCHEDULERS	2015-01-17 22:14:32.812597191 +0000
@@ -1 +1 @@
-rr|wrr|lc|wlc|lblc|lblcr|dh|sh|sed|nq
+rr|wrr|lc|wlc|lblc|lblcr|dh|sh|sed|nq|wlib|wlip
diff -upr ipvsadm-1.27-stock/ipvsadm.8 ipvsadm-1.27/ipvsadm.8
--- ipvsadm-1.27-stock/ipvsadm.8	2013-09-06 08:37:27.000000000 +0000
+++ ipvsadm-1.27/ipvsadm.8	2015-01-17 22:14:32.812597191 +0000
@@ -261,6 +261,14 @@ fixed service rate (weight) of the ith s
 \fBnq\fR - Never Queue: assigns an incoming job to an idle server if
 there is, instead of waiting for a fast one; if all the servers are
 busy, it adopts the Shortest Expected Delay policy to assign the job.
+.sp
+\fBwlib\fR - Weighted Least Incoming Byterate: directs network
+connections to the real server with the least incoming byterate
+normalized by the server weight.
+.sp
+\fBwlip\fR - Weighted Least Incoming Packetrate: directs network
+connections to the real server with the least incoming packetrate
+normalized by the server weight.
 .TP
 .B -p, --persistent [\fItimeout\fP]
 Specify that a virtual service is persistent. If this option is
