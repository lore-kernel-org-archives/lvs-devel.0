From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [*v2 PATCH 01/22] IPVS: netns, add basic init per netns.
Date: Mon, 13 Dec 2010 15:08:54 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1012131503190.18216@obet.zrqbmnf.qr>
References: <1292247510-753-1-git-send-email-hans.schillstrom@ericsson.com> <1292247510-753-2-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1292247510-753-2-git-send-email-hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: horms@verge.net.au, ja@ssi.bg, daniel.lezcano@free.fr, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans@schillstrom.com


On Monday 2010-12-13 14:38, Hans Schillstrom wrote:
>@@ -28,6 +28,18 @@
> #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
> #include <net/netfilter/nf_conntrack.h>
> #endif
>+#include <net/net_namespace.h>		/* Netw namespace */
>+
>+/*
>+ * Generic access of ipvs struct
>+ */
>+static inline struct netns_ipvs * net_ipvs(struct net* net) {
>+#ifdef CONFIG_NET_NS
>+	return net->ipvs;
>+#else
>+	return init_net.ipvs;
>+#endif
>+}

This looks redundant, because even in the !CONFIG_NET_NS case,
'net' is valid and already points to &init_net.

>+static void __net_exit __ip_vs_cleanup(struct net *net)
>+{
>+	struct netns_ipvs *ipvs = net_ipvs(net);
>+
>+	IP_VS_DBG(10, "ipvs netns %d released\n", ipvs->inc);
>+}
>+
