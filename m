From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH v3 2/2] netfilter: ipvs: use GFP_KERNEL allocation where possible
Date: Sat, 14 Apr 2012 12:37:47 -0400
Message-ID: <1334421467-30313-2-git-send-email-levinsasha928@gmail.com>
References: <1334421467-30313-1-git-send-email-levinsasha928@gmail.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=from:to:cc:subject:date:message-id:x-mailer:in-reply-to:references;
        bh=2efXASzzL05EExi8exoeLFHvQwo7vK8JvGbNpv4VGiY=;
        b=Hf8MyD0RXDzeAbj7zmn7QsrPH3ZYmPZggoOE9Ds++zh2uHE557VDvaQ352mDVLsrKc
         akW0uDmdGQJfOO1REhbEDvPHwCf8X2EaLhHCzOKzaWbLh/gaTQTsUceaPPHy820ZNQxR
         XzZP7qPUbcxNUN8vgYgwGgZWWcK0AegPkim36a5q3VRyCmfTYW0KWWHkLX/crzA+uVMM
         04W1DqPPJkhE2LBDtBLNHVJDM+OqgM2QwDwah6ylR2iD8cIzgzAcfa3BQ7ufyLxzjSPG
         D6QIg0aNVogK7x9CaanFMZ26eu7ar4r7uKJj9Os1tztQx22EUPH6h7aNo8EPTToNDOqP
         Gh+w==
In-Reply-To: <1334421467-30313-1-git-send-email-levinsasha928@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, kaber@trash.net, davem@davemloft.net
Cc: davej@redhat.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

Use GFP_KERNEL instead of GFP_ATOMIC when registering an ipvs protocol.

This is safe since it will always run from a process context.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 net/netfilter/ipvs/ip_vs_proto.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index a62360e..307dbbb 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -68,7 +68,7 @@ register_ip_vs_proto_netns(struct net *net, struct ip_vs_protocol *pp)
 	struct netns_ipvs *ipvs = net_ipvs(net);
 	unsigned hash = IP_VS_PROTO_HASH(pp->protocol);
 	struct ip_vs_proto_data *pd =
-			kzalloc(sizeof(struct ip_vs_proto_data), GFP_ATOMIC);
+			kzalloc(sizeof(struct ip_vs_proto_data), GFP_KERNEL);
 
 	if (!pd)
 		return -ENOMEM;
-- 
1.7.8.5

