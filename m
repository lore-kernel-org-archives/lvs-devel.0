From: Chris Caputo <ccaputo@alt.net>
Subject: [PATCH 3/3] IPVS: add wlib & wlip schedulers
Date: Tue, 20 Jan 2015 23:21:30 +0000 (UTC)
Message-ID: <Pine.LNX.4.64.1501202320340.8217@nacho.alt.net>
References: <Pine.LNX.4.44.0501260832210.17893-100000@nacho.alt.net>
	<Pine.LNX.4.61.0502010007060.1148@penguin.linux-vs.org>
	<Pine.LNX.4.64.1501172217420.8217@nacho.alt.net>
	<alpine.LFD.2.11.1501192342190.2687@ja.home.ssi.bg>
Reply-To: Chris Caputo <ccaputo-dated-1432164091.579f17@alt.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alt.net;
	s=default; x=1422400891; h=Comment:DomainKey-Signature:Received:
	Received:Received:Date:To:cc:Subject:In-Reply-To:Message-ID:
	References:MIME-Version:Content-Type:From:Reply-To; bh=iIcvc/iyY
	2Ggqxfc0Jm580PgSHZQK1Dk+FmpXPa8+QU=; b=FM9bAHNZWkE8XD2RZlj5Mf7Zn
	y/BZ0/DO/SfltcxGRu8zJzfvm75/0dpESu+YcRLp5EWDka7E2Q1EY+9esivTNidi
	hGgrpQ+iCedN7QNj3UdEdozsAlg7DDm+YO0RLC1K+LJeDq7m9JCUQJtfxZw+mQ1f
	V2LE3F7InfVJZrG5bc=
In-Reply-To: <alpine.LFD.2.11.1501192342190.2687@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org

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
