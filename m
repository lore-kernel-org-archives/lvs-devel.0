From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [*v2 PATCH 01/22] IPVS: netns, add basic init per netns.
Date: Mon, 13 Dec 2010 16:12:08 +0100
Message-ID: <1292253128.4983.53.camel@seasc0214>
References: <1292247510-753-1-git-send-email-hans.schillstrom@ericsson.com>
	 <1292247510-753-2-git-send-email-hans.schillstrom@ericsson.com>
	 <alpine.LNX.2.01.1012131503190.18216@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1012131503190.18216@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Jan Engelhardt <jengelh@medozas.de>
Cc: "horms@verge.net.au" <horms@verge.net.au>, "ja@ssi.bg" <ja@ssi.bg>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "hans@schillstrom.com" <hans@schillstrom.com>

On Mon, 2010-12-13 at 15:08 +0100, Jan Engelhardt wrote:
> On Monday 2010-12-13 14:38, Hans Schillstrom wrote:
> >@@ -28,6 +28,18 @@
> > #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
> > #include <net/netfilter/nf_conntrack.h>
> > #endif
> >+#include <net/net_namespace.h>		/* Netw namespace */
> >+
> >+/*
> >+ * Generic access of ipvs struct
> >+ */
> >+static inline struct netns_ipvs * net_ipvs(struct net* net) {
> >+#ifdef CONFIG_NET_NS
> >+	return net->ipvs;
> >+#else
> >+	return init_net.ipvs;
> >+#endif
> >+}
> 
> This looks redundant, because even in the !CONFIG_NET_NS case,
> 'net' is valid and already points to &init_net.

Yes, that's right I'll remove it.

Thanks
Hans
> 
> >+static void __net_exit __ip_vs_cleanup(struct net *net)
> >+{
> >+	struct netns_ipvs *ipvs = net_ipvs(net);
> >+
> >+	IP_VS_DBG(10, "ipvs netns %d released\n", ipvs->inc);
> >+}
> >+


