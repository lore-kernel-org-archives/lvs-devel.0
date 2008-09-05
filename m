From: Sven Wegener <sven.wegener@stealer.net>
Subject: [PATCH] ipvs: Use pointer to address from sync message
Date: Fri, 5 Sep 2008 13:46:00 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.0809051342360.18192@titan.stealer.net>
References: <1220363755-9854-1-git-send-email-juliusv@google.com> <1220363755-9854-13-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1220363755-9854-13-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

We want a pointer to it, not the value casted to a pointer.

Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
---
 net/ipv4/ipvs/ip_vs_sync.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

I've been too late with having a look at these patches. I'm going to
send follow-up patches for the issues I find.

Simon, please apply onto lvs-next-2.6.

diff --git a/net/ipv4/ipvs/ip_vs_sync.c b/net/ipv4/ipvs/ip_vs_sync.c
index 40647ed..28237a5 100644
--- a/net/ipv4/ipvs/ip_vs_sync.c
+++ b/net/ipv4/ipvs/ip_vs_sync.c
@@ -397,11 +397,11 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
 					flags &= ~IP_VS_CONN_F_INACTIVE;
 			}
 			cp = ip_vs_conn_new(AF_INET, s->protocol,
-					    (union nf_inet_addr *)s->caddr,
+					    (union nf_inet_addr *)&s->caddr,
 					    s->cport,
-					    (union nf_inet_addr *)s->vaddr,
+					    (union nf_inet_addr *)&s->vaddr,
 					    s->vport,
-					    (union nf_inet_addr *)s->daddr,
+					    (union nf_inet_addr *)&s->daddr,
 					    s->dport,
 					    flags, dest);
 			if (dest)
