From: Sven Wegener <sven.wegener@stealer.net>
Subject: [PATCH] ipvs: Mark tcp/udp v4 and v6 debug functions static
Date: Fri, 5 Sep 2008 14:43:00 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.0809051441070.18192@titan.stealer.net>
References: <1220363755-9854-1-git-send-email-juliusv@google.com> <1220363755-9854-11-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1220363755-9854-11-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

They are only used in this file, so they should be static

Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
---
 net/ipv4/ipvs/ip_vs_proto.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

Simon, please apply onto lvs-next-2.6.

diff --git a/net/ipv4/ipvs/ip_vs_proto.c b/net/ipv4/ipvs/ip_vs_proto.c
index 50f6215..b06da1c 100644
--- a/net/ipv4/ipvs/ip_vs_proto.c
+++ b/net/ipv4/ipvs/ip_vs_proto.c
@@ -151,7 +151,7 @@ const char * ip_vs_state_name(__u16 proto, int state)
 }
 
 
-void
+static void
 ip_vs_tcpudp_debug_packet_v4(struct ip_vs_protocol *pp,
 			     const struct sk_buff *skb,
 			     int offset,
@@ -190,7 +190,7 @@ ip_vs_tcpudp_debug_packet_v4(struct ip_vs_protocol *pp,
 }
 
 #ifdef CONFIG_IP_VS_IPV6
-void
+static void
 ip_vs_tcpudp_debug_packet_v6(struct ip_vs_protocol *pp,
 			     const struct sk_buff *skb,
 			     int offset,
