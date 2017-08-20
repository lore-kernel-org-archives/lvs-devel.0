From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 1/2] netfilter: ipvs: fix the issue that sctp_conn_schedule drops non-INIT packet
Date: Sun, 20 Aug 2017 13:38:07 +0800
Message-ID: <9475ae3e6d80f0c6547371f5a910edfbbd4a9b2a.1503207076.git.lucien.xin@gmail.com>
References: <cover.1503207076.git.lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :in-reply-to:references;
        bh=Bx550/MqXNWxeNuj2hnoxiTE9gVummDyV6RskL3pEVA=;
        b=B6lTf/Tjk+Rsk/I0c6F1voCdwoV3lUMHGpZ+q2sy7Ko0UYlpfpKSGdJW22PpKj4HPy
         IBlrnoIOU0hlnCZU6DerG0T5ivwawQsCRyCzKyanVsiIkjWPGMDarbPKOm9w8n/S8ZAF
         vSZtcTNTmOxJlFKl6qoJvj57vPS7hs7d12bOpi8mUpNu/6l859KX/qezWDGv0ticr+Nm
         Urqhg8uzQann+EwwUY4Q0t3gJxYT8/gVBnpcryhLXjln254fFOXYihDjWFB+9JICnO3Y
         swKpXGKmiUdwO2CA5BNJ7X7L+vxcsW2BiVL3BOTgx+HErMSyqfC2hzZx/VUtJcUXrkv9
         Imkg==
In-Reply-To: <cover.1503207076.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1503207076.git.lucien.xin@gmail.com>
References: <cover.1503207076.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org
Cc: pablo@netfilter.org, Alex Gartrell <agartrell@fb.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org

Commit 5e26b1b3abce ("ipvs: support scheduling inverse and icmp SCTP
packets") changed to check packet type early. It introduced a side
effect: if it's not a INIT packet, ports will be set as  NULL, and
the packet will be dropped later.

It caused that sctp couldn't create connection when ipvs module is
loaded and any scheduler is registered on server.

Li Shuang reproduced it by running the cmds on sctp server:
  # ipvsadm -A -t 1.1.1.1:80 -s rr
  # ipvsadm -D -t 1.1.1.1:80
then the server could't work any more.

This patch is to return 1 when it's not an INIT packet. It means ipvs
will accept it without creating a conn for it, just like what it does
for tcp.

Fixes: 5e26b1b3abce ("ipvs: support scheduling inverse and icmp SCTP packets")
Reported-by: Li Shuang <shuali@redhat.com>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/netfilter/ipvs/ip_vs_proto_sctp.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 3ffad4a..e9b18ac 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -24,9 +24,12 @@ sctp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 		if (sh) {
 			sch = skb_header_pointer(skb, iph->len + sizeof(_sctph),
 						 sizeof(_schunkh), &_schunkh);
-			if (sch && (sch->type == SCTP_CID_INIT ||
-				    sysctl_sloppy_sctp(ipvs)))
+			if (sch) {
+				if (!(sysctl_sloppy_sctp(ipvs) ||
+				      sch->type == SCTP_CID_INIT))
+					return 1;
 				ports = &sh->source;
+			}
 		}
 	} else {
 		ports = skb_header_pointer(
-- 
2.1.0

