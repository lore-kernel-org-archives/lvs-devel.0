From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [*v3 PATCH 02/22] IPVS: netns to services part 1
Date: Sat, 1 Jan 2011 15:57:29 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1101011547040.9065@obet.zrqbmnf.qr>
References: <1293706266-27152-1-git-send-email-hans@schillstrom.com> <1293706266-27152-3-git-send-email-hans@schillstrom.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1293706266-27152-3-git-send-email-hans@schillstrom.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hans@schillstrom.com
Cc: horms@verge.net.au, ja@ssi.bg, daniel.lezcano@free.fr, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Hans Schillstrom <hans.schillstrom@ericsson.com>


On Thursday 2010-12-30 11:50, hans@schillstrom.com wrote:
>+/*
>+ * Get net ptr from skb in traffic cases
>+ * use skb_sknet when call is from userland (ioctl or netlink)
>+ */
>+static inline struct net *skb_net(struct sk_buff *skb) {
>+#ifdef CONFIG_NET_NS
>+#ifdef CONFIG_IP_VS_DEBUG
>+	/*
>+	 * This is used for debug only.
>+	 * Start with the most likely hit
>+	 * End with BUG
>+	 */
>+	if (likely(skb->dev && skb->dev->nd_net))
>+		return dev_net(skb->dev);
>+	if (skb_dst(skb)->dev)
>+		return dev_net(skb_dst(skb)->dev);
>+	WARN(skb->sk,"Maybe skb_sknet should be used instead in %s() line:%d\n",
>+		      __func__, __LINE__);
>+	if (likely(skb->sk && skb->sk->sk_net))
>+		return sock_net(skb->sk);
>+	pr_err("There is no net ptr to find in the skb in %s() line:%d\n",
>+		__func__, __LINE__);
>+	BUG();
>+#else
>+	return dev_net(skb->dev ? : skb_dst(skb)->dev);
>+#endif
>+#else
>+	return &init_net;
>+#endif
>+}

Whether NETNS is disabled or not, dev_net(skb->dev) can be used in either case,
so the extra return &init_net case is not really required AFAICS.

>@@ -3446,43 +3471,48 @@ static struct pernet_operations ipvs_control_ops = {
>-	smp_wmb();
>+
>+	smp_wmb();	/* Do wee really need it now ? */

not "whee" :)
