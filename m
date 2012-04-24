From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH v2 2/2] ipvs: add check in ftp for initialized core
Date: Wed, 25 Apr 2012 00:29:59 +0300
Message-ID: <1335302999-10702-3-git-send-email-ja@ssi.bg>
References: <1335302999-10702-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1335302999-10702-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

	Avoid crash when registering ip_vs_ftp after
the IPVS core initialization for netns fails. Do this by
checking for present core (net->ipvs).

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_ftp.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 538d74e..e39f693 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -439,6 +439,8 @@ static int __net_init __ip_vs_ftp_init(struct net *net)
 	struct ip_vs_app *app;
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
+	if (!ipvs)
+		return -ENOENT;
 	app = kmemdup(&ip_vs_ftp, sizeof(struct ip_vs_app), GFP_KERNEL);
 	if (!app)
 		return -ENOMEM;
-- 
1.7.3.4

