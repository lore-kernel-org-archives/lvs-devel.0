From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: [*v3 PATCH 01/22] IPVS: netns, add basic init per netns.
Date: Fri, 31 Dec 2010 16:36:46 +0100
Message-ID: <201012311636.46744.hans@schillstrom.com>
References: <1293706266-27152-1-git-send-email-hans@schillstrom.com> <1293706266-27152-2-git-send-email-hans@schillstrom.com> <alpine.LNX.2.01.1012310055050.15397@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1012310055050.15397@obet.zrqbmnf.qr>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: Jan Engelhardt <jengelh@medozas.de>
Cc: horms@verge.net.au, ja@ssi.bg, daniel.lezcano@free.fr, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Hans Schillstrom <hans.schillstrom@ericsson.com>


On Friday, December 31, 2010 00:58:35 Jan Engelhardt wrote:
> 
> On Thursday 2010-12-30 11:50, hans@schillstrom.com wrote:
> >+++ b/include/net/ip_vs.h
> >@@ -28,6 +28,15 @@
> > #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
> > #include <net/netfilter/nf_conntrack.h>
> > #endif
> >+#include <net/net_namespace.h>		/* Netw namespace */
> >+
> >+/*
> >+ * Generic access of ipvs struct
> >+ */
> >+static inline struct netns_ipvs * net_ipvs(struct net* net)
> 
> Balancing the '*' between the ' ' would be nice... I know it's hard at this
> time of the year ;-)
> 
I'll send a new patch set and run checkpatch,
but that will be after new years eve :-)

> >diff --git a/include/net/netns/ip_vs.h b/include/net/netns/ip_vs.h
> >new file mode 100644
> >index 0000000..9068d95
> >--- /dev/null
> >+++ b/include/net/netns/ip_vs.h
> >@@ -0,0 +1,26 @@
> >+/*
> >+ * ip_vs.h
> >+ *
> >+ *  Created on: Nov 23, 2010
> >+ *  Author: hans
> >+ */
> 
> Filenames, creation dates, author names (when they don't serve a copyright
> notice), CVS $Id$ tags, etc. don't belong into files. The git log exists for
> that very purpose.
> 
Oops that's an eclipse feature, that should be removed.

> >+struct netns_ipvs {
> >+	int			inc;		/* Incarnation */
> >+};
> 
> Just my thoughts: Incarnation - haven't heard that in a while. ("inc"
> is also used as an abbreviation for increment, so ~ ~). Other places
> use "generation" as a term (such as the VFS on inode generation). [I
> also get the feeling that (re)"incarnation" may require a death, so
> it is different from "generation" after all -]

:-))

> 
> >+++ b/net/netfilter/ipvs/ip_vs_core.c
> >@@ -1813,6 +1820,44 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
> > #endif
> > };
> >
> >+/*
> >+ *	Initialize IP Virtual Server netns mem.
> >+ */
> >+static int __net_init  __ip_vs_init(struct net *net)
> >+{
> >+	struct netns_ipvs *ipvs;
> >+
> >+	if (!net_eq(net, &init_net)) {
> >+		pr_err("The final patch for enabling netns is missing\n");
> >+		return -EPERM;
> >+	}
> >+	ipvs = (struct netns_ipvs *)net_generic(net, ip_vs_net_id);
> 
> Pointless cast is pointless.

Well, that is a reminder from a backport...

> 
> >index c1c167a..ea390f8 100644
> >--- a/net/netfilter/ipvs/ip_vs_sync.c
> >+++ b/net/netfilter/ipvs/ip_vs_sync.c
> >@@ -1639,3 +1639,31 @@ int stop_sync_thread(int state)
> >
> > 	return 0;
> > }
> >+
> >+/*
> >+ * Initialize data struct for each netns
> >+ */
> >+static int __net_init __ip_vs_sync_init(struct net *net)
> >+{
> >+	return 0;
> >+}
> >+
> >+static void __ip_vs_sync_cleanup(struct net *net)
> >+{
> >+	return;
> >+}
> 
> The trailing return; in functions returning nothing can be (and
> generally, is) omitted.
> 
Oops

Thanks alot 

/Hans

