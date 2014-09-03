From: Alex Gartrell <agartrell@fb.com>
Subject: ipvs ipv6 tunnel forwarding sets expires on local route
Date: Wed, 3 Sep 2014 00:03:23 -0700
Message-ID: <5406BD3B.7050600@fb.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=message-id : date : from :
 mime-version : to : cc : subject : content-type :
 content-transfer-encoding; s=facebook;
 bh=KouqS9+Xh6tKpYmN6DzFtMWSr2nWbalZY77LbnmhdiM=;
 b=ZrKHBjn8Ay5Qcj8jeKn0sl5NRpoxBY0P8q62eocEy+99nmZQrJUF1hve9eMCsPz4bC6a
 cPYWo+wSBkbU/4mZ29IPXnAQWYDXsQM8BOeB5u7XQAZfDr3xRrhNNDAdttfFakioUo7d
 NiYjgji18fqNY44Qf7c7UqtAfurERvBglP4= 
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: netdev@vger.kernel.org
Cc: lvs-devel@vger.kernel.org, kernel-team <Kernel-team@fb.com>, ps@fb.com, traffic@fb.com

So we've been debugging a problem for a while in 3.10 stable (we're 
currently upgrading from 3.2) and it appears that we're expiring and 
ultimately garbage collecting the local route for an ip we're adding to 
the loopback device, resulting in ICMPV6_NOROUTE errors for clients. 
I'd like your advice on how to fix this.

Repro:
"""
ipvsadm -R <<EOF
-A -t [face::1]:15213 -s ch
-a -t [face::1]:15213 -r 2401:db00:20:c001:face:0:45:0 -i
EOF

ip addr add dev lo face::1/128 || true
"""

This simply sets up a v6 service in ipvs and adds a real server ip which 
is tunneling over ipip.  This is important because this bug only affects 
tunneling mode.

Within ipvs, in tunneling mode, we do the following when checking the 
MTU in tunneling mode

         /* MTU checking */
         if (likely(!(rt_mode & IP_VS_RT_MODE_TUNNEL)))
                 mtu = dst_mtu(&rt->dst);
         else {
                 struct sock *sk = skb->sk;

                 mtu = dst_mtu(&rt->dst) - sizeof(struct ipv6hdr);
                 if (mtu < IPV6_MIN_MTU) {
                         IP_VS_DBG_RL("%s(): mtu less than %d\n", __func__,
                                      IPV6_MIN_MTU);
                         goto err_put;
                 }
                 ort = (struct rt6_info *) skb_dst(skb);
                 old_flags = ort->rt6i_flags;
                 if (!skb->dev && sk && sk->sk_state != TCP_TIME_WAIT)
                         ort->dst.ops->update_pmtu(&ort->dst, sk, NULL, 
mtu);
         }

So if there's a socket associated with the skb and it's not in 
TCP_TIME_WAIT, we'll invoke the update_pmtu to ensure we generate 
appropriately sized packets.

commit 81aded2 "ipv6: Handle PMTU in ICMP error handlers" introduces the 
following.

@@ -1058,9 +1061,39 @@ static void ip6_rt_update_pmtu(struct dst_entry 
*dst, u32 mtu)
  			dst_metric_set(dst, RTAX_FEATURES, features);
  		}
  		dst_metric_set(dst, RTAX_MTU, mtu);
+		rt6_update_expires(rt6, net->ipv6.sysctl.ip6_rt_mtu_expires);
  	}
  }

The net result is that we end up setting an expiry on the local route. 
When we hit ip6_rt_mtu_expires, the route expires (and is later GC'ed). 
  From that point forward we start ICMPV6_NOROUTE'ing packets in 
ip6_rcv_finish until the address is removed and reinstalled.

I've got a couple of (bad?) ideas on how to fix it.  We could simply 
check rt6i_flags for (RTF_EXPIRES | RTF_CACHE) before setting expires. 
We could also check for RTF_LOCAL.  Alternatively, cloning the rt and 
updating that might be an appropriate thing to do (in case the 
tunneled-to route increases its MTU).  I'm *completely* open to 
suggestions :)

Thank you for your help,

-- 
Alex Gartrell <agartrell@fb.com>
