From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [*v3 PATCH 02/22] IPVS: netns to services part 1
Date: Mon, 3 Jan 2011 10:14:00 +0100
Message-ID: <1294046040.4983.60423.camel@seasc0214>
References: <1293706266-27152-1-git-send-email-hans@schillstrom.com>
	 <1293706266-27152-3-git-send-email-hans@schillstrom.com>
	 <alpine.LNX.2.01.1101011547040.9065@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1101011547040.9065@obet.zrqbmnf.qr>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Jan Engelhardt <jengelh@medozas.de>
Cc: "hans@schillstrom.com" <hans@schillstrom.com>, "horms@verge.net.au" <horms@verge.net.au>, "ja@ssi.bg" <ja@ssi.bg>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>

On Sat, 2011-01-01 at 15:57 +0100, Jan Engelhardt wrote:
> On Thursday 2010-12-30 11:50, hans@schillstrom.com wrote:
> >+/*
> >+ * Get net ptr from skb in traffic cases
> >+ * use skb_sknet when call is from userland (ioctl or netlink)
> >+ */
> >+static inline struct net *skb_net(struct sk_buff *skb) {
> >+#ifdef CONFIG_NET_NS
> >+#ifdef CONFIG_IP_VS_DEBUG
> >+	/*
> >+	 * This is used for debug only.
> >+	 * Start with the most likely hit
> >+	 * End with BUG
> >+	 */
> >+	if (likely(skb->dev && skb->dev->nd_net))
> >+		return dev_net(skb->dev);
> >+	if (skb_dst(skb)->dev)
> >+		return dev_net(skb_dst(skb)->dev);
> >+	WARN(skb->sk,"Maybe skb_sknet should be used instead in %s() line:%d\n",
> >+		      __func__, __LINE__);
> >+	if (likely(skb->sk && skb->sk->sk_net))
> >+		return sock_net(skb->sk);
> >+	pr_err("There is no net ptr to find in the skb in %s() line:%d\n",
> >+		__func__, __LINE__);
> >+	BUG();
> >+#else
> >+	return dev_net(skb->dev ? : skb_dst(skb)->dev);
> >+#endif
> >+#else
> >+	return &init_net;
> >+#endif
> >+}
> 
> Whether NETNS is disabled or not, dev_net(skb->dev) can be used in either case,
> so the extra return &init_net case is not really required AFAICS.

OK, but the debug part will not compile without the ifdef since there is
some symbols that is #ifdef CONFIG_NET_NS.
"&init_net" is faster than the " ? : "
And the rest I guess is obvious.

> 
> >@@ -3446,43 +3471,48 @@ static struct pernet_operations ipvs_control_ops = {
> >-	smp_wmb();
> >+
> >+	smp_wmb();	/* Do wee really need it now ? */
> 
> not "whee" :)


