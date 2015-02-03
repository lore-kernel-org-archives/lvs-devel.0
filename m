From: Alex Gartrell <agartrell@fb.com>
Subject: Re: Question: should local address be expired when updating PMTU?
Date: Mon, 2 Feb 2015 16:52:58 -0800
Message-ID: <54D01BEA.2070501@fb.com>
References: <54CF3348.40207@huawei.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=message-id : date : from :
 mime-version : to : cc : subject : references : in-reply-to : content-type
 : content-transfer-encoding; s=facebook;
 bh=hjYJUCmWpnEONiVx+RZxjOxVa0OgfuZk4rzlDnSW8eg=;
 b=YN2JoqQknBWL0nJgHjhThONzu8F37X7dAimUoNNB6SYTtr8f7SjzFG7A0l37PzpFr2mF
 FG9XTPuwBwmHbZkWdeANJ1ODU4w1wuAMmQ3c2oP8LudwNU7yb+z8hFFeUFQNmOoG1WCF
 RvwNd2LhcbhO988p5xy3XVZt3vv6d4cbndE= 
In-Reply-To: <54CF3348.40207@huawei.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: shengyong <shengyong1@huawei.com>, davem@davemloft.net
Cc: netdev@vger.kernel.org, yangyingling@huawei.com, steffen.klassert@secunet.com, hannes@redhat.com, lvs-devel@vger.kernel.org, Calvin Owens <calvinowens@fb.com>, kernel-team@fb.com

Hello Shengyong,

 > diff --git a/net/ipv6/route.c b/net/ipv6/route.c
 > index b2614b2..b80317a 100644
 > --- a/net/ipv6/route.c
 > +++ b/net/ipv6/route.c
 > @@ -1136,6 +1136,9 @@ static void ip6_rt_update_pmtu(struct dst_entry 
*dst, struct sock *sk,
 >   {
 >          struct rt6_info *rt6 = (struct rt6_info*)dst;
 >
 > +       if (rt6->rt6i_flags & RTF_LOCAL)
 > +               return;
 > +
 >          dst_confirm(dst);
 >          if (mtu < dst_mtu(dst) && rt6->rt6i_dst.plen == 128) {
 >                  struct net *net = dev_net(dst->dev);
 >
 > So is this modification correct? Or how can we avoid such expiring?


FWIW, we encountered this problem with IPVS tunneling.  Here's a patch 
done by Calvin (cc'ed) that fixes my attempted fix for this.  We're not 
particularly proud of this...

At a high level, I don't think the RTF_LOCAL check was sufficient, but I 
didn't investigate deeply enough and hopefully Calvin can say why.

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f14d49b..c607a42 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1159,18 +1159,18 @@ static void ip6_rt_update_pmtu(struct dst_entry 
*dst, struct sock *sk,
                 }
                 dst_metric_set(dst, RTAX_MTU, mtu);

-               /* FACEBOOK HACK: We need to not expire local non-expiring
-                * routes so that we don't accidentally start blackholing
-                * ipvs traffic when we happen to use it locally for
-                * healthchecking (see ip_vs_xmit.c --
-                * __ip_vs_get_out_rt_v6 invokes update_pmtu if the rt is
-                * associated with a socket)
-                * Alex Gartrell <agartrell@fb.com>
+               /*
+                * FACEBOOK HACK: Only expire routes that aren't 
destined for
+                * the loopback interface.
+                *
+                * This prevents the strange route coalescing that 
happens when
+                * you add an address to the loopback that had a route 
that had
+                * been used when the address didn't exist from getting 
expired
+                * and causing packet loss in shiv.
                  */
-               if (!(rt6->rt6i_flags & RTF_LOCAL) ||
-                   (rt6->rt6i_flags & (RTF_EXPIRES | RTF_CACHE)))
-                       rt6_update_expires(
-                               rt6, net->ipv6.sysctl.ip6_rt_mtu_expires);
+               if (!(dst->dev->flags & IFF_LOOPBACK))
+                       rt6_update_expires(rt6,
+ 
net->ipv6.sysctl.ip6_rt_mtu_expires);
         }
  }


Cheers,
-- 
Alex Gartrell <agartrell@fb.com>
