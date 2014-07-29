From: "Alexey Andriyanov" <alan@al-an.info>
Subject: Re: What is the best way to accomplish "decapsulate any" functionality?
Date: Wed, 30 Jul 2014 00:45:37 +0400
Message-ID: <53D75BF0.3050000@al-an.info>
References: <20140728112632.5f8e8f5f@agartrell-SH67H>
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=al-an.info; s=mail; t=1406666738;
	bh=9Va8CD/uTN+P66Gk8FBXgmwCdvu4kES62r6+m2tqjws=;
	h=From:Date:Message-ID:To:CC:Subject:References:In-Reply-To:
	 Content-Type:Content-Transfer-Encoding;
	b=JqiLl8ArQ/XDHDGiW5r0oyBpXmCrSeX0BhxptjVAyO/n0HfL1JUWTNL5D5oK/xnua
	 FAuGmgIJN1gFfF6Sy44GllGl1+NOL6sRYmlfnD322va3BV+SBS/Gmr9dN/N7cjIwWh
	 aOpmLV+cLNlBmhHlP9OLXrwL93EF46dddEFKo2mo=
In-Reply-To: <20140728112632.5f8e8f5f@agartrell-SH67H>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Alex Gartrell <agartrell@fb.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: kernel-team@fb.com, ps@fb.com

28.07.2014 22:26, Alex Gartrell wrote:
> Short Version:
> 
> What's the best way to accomplish "decapsulate any" functionality for
> "IPv{4,6} in IPv{4,6}?"  Should I write an xfrm module or is there a
> simple, existing method?

Hi, Alex.

I also wanted to decapsulate 4in6 packets without configuring the endpoints. The ip6_tunnel module already has the mode parameter (6in6, 4in6, any).

The problem is the fallback device "ip6tnl0" has preconfigured mode 6in6 that you can not change. All other tunnel devices work only with specified endpoints.

I've found two ways for fixing this:
The first is to change mode of the ip6tnl0 to 'any' at compile-time. Very simple, but may cause compatibility issues.
The idea behing the second is to allow changing mode of the ip6tnl0 device as for any other tunnel device

Hereby I'm requesting for comments on these changes. If somebody decides to merge one of these into upstream kernel tree, I will repost the patch with proper formalities.


diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 46ba243..2c43ec9 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1524,7 +1524,7 @@ static int __net_init ip6_fb_tnl_dev_init(struct net_device *dev)
 	if (err)
 		return err;
 
-	t->parms.proto = IPPROTO_IPV6;
+	t->parms.proto = 0;
 	dev_hold(dev);
 
 	ip6_tnl_link_config(t);
--

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 46ba243..4b03bd9 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1269,6 +1269,14 @@ static int ip6_tnl_update(struct ip6_tnl *t, struct __ip6_tnl_parm *p)
 	return err;
 }
 
+static int ip6_tnl0_update(struct ip6_tnl *t, struct __ip6_tnl_parm *p)
+{
+	/* for default tnl0 device allow changing only proto */
+	t->parms.proto = p->proto;
+	netdev_state_change(t->dev);
+	return 0;
+}
+
 static void
 ip6_tnl_parm_from_user(struct __ip6_tnl_parm *p, const struct ip6_tnl_parm *u)
 {
@@ -1368,7 +1376,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			break;
 		ip6_tnl_parm_from_user(&p1, &p);
 		t = ip6_tnl_locate(net, &p1, cmd == SIOCADDTUNNEL);
-		if (dev != ip6n->fb_tnl_dev && cmd == SIOCCHGTUNNEL) {
+		if (cmd == SIOCCHGTUNNEL) {
 			if (t != NULL) {
 				if (t->dev != dev) {
 					err = -EEXIST;
@@ -1376,8 +1384,10 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 				}
 			} else
 				t = netdev_priv(dev);
