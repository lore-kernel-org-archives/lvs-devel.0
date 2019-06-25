From: Vadim Fedorenko <vfedorenko@yandex-team.ru>
Subject: [PATCH] ipvs: allow tunneling with gre encapsulation
Date: Tue, 25 Jun 2019 18:59:54 +0300
Message-ID: <2caa3152-f90d-1ad6-3f98-b07960fed171@yandex-team.ru>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
        t=1561478394; bh=j3Za4mwvXNVcqNaWOAH0WO4UYFFwM7tME+Ca1jP3/m0=;
        h=Date:Message-ID:Cc:To:Subject:From;
        b=zdMjhoD1ItE+n+mm0424Eh2c5rsUgNs0S4yXnHpec/RINRbh3pKznPMhwKGZA1RQO
         OrxMd8r2BHN6auHwuIEqQ28kJsSnp3RpIu17KtfogJJLh9K56l0bMOPJ4KhKJlBRlJ
         z6bWE/k9n35Pwb8JuAXWCu2AeRF75HU8kmevyW3Q=
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

windows real servers can handle gre tunnels, this patch allows
gre encapsulation with the tunneling method, thereby letting ipvs
be load balancer for windows-based services

Signed-off-by: Vadim Fedorenko <vfedorenko@yandex-team.ru>
---
  include/uapi/linux/ip_vs.h      |  1 +
  net/netfilter/ipvs/ip_vs_xmit.c | 76 +++++++++++++++++++++++++++++++++++++++++
  2 files changed, 77 insertions(+)

diff --git a/include/uapi/linux/ip_vs.h b/include/uapi/linux/ip_vs.h
index e4f1806..4102ddc 100644
--- a/include/uapi/linux/ip_vs.h
+++ b/include/uapi/linux/ip_vs.h
@@ -128,6 +128,7 @@
  enum {
  	IP_VS_CONN_F_TUNNEL_TYPE_IPIP = 0,	/* IPIP */
  	IP_VS_CONN_F_TUNNEL_TYPE_GUE,		/* GUE */
+	IP_VS_CONN_F_TUNNEL_TYPE_GRE,		/* GRE */
  	IP_VS_CONN_F_TUNNEL_TYPE_MAX,
  };

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 71fc6d6..fad3f33 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -29,6 +29,7 @@
  #include <linux/tcp.h>                  /* for tcphdr */
  #include <net/ip.h>
  #include <net/gue.h>
+#include <net/gre.h>
  #include <net/tcp.h>                    /* for csum_tcpudp_magic */
  #include <net/udp.h>
  #include <net/icmp.h>                   /* for icmp_send */
@@ -389,6 +390,12 @@ static inline bool decrement_ttl(struct netns_ipvs *ipvs,
  			    skb->ip_summed == CHECKSUM_PARTIAL)
  				mtu -= GUE_PLEN_REMCSUM + GUE_LEN_PRIV;
  		}
+		if (dest->tun_type == IP_VS_CONN_F_TUNNEL_TYPE_GRE) {
+			__be16 tflags = 0;
+			if (dest->tun_flags & IP_VS_TUNNEL_ENCAP_FLAG_CSUM)
+				tflags |= TUNNEL_CSUM;
+			mtu -= gre_calc_hlen(tflags);
+		}
  		if (mtu < 68) {
  			IP_VS_DBG_RL("%s(): mtu less than 68\n", __func__);
  			goto err_put;
@@ -549,6 +556,12 @@ static inline bool decrement_ttl(struct netns_ipvs *ipvs,
  			    skb->ip_summed == CHECKSUM_PARTIAL)
  				mtu -= GUE_PLEN_REMCSUM + GUE_LEN_PRIV;
  		}
+		if (dest->tun_type == IP_VS_CONN_F_TUNNEL_TYPE_GRE) {
+			__be16 tflags = 0;
+			if (dest->tun_flags & IP_VS_TUNNEL_ENCAP_FLAG_CSUM)
+				tflags |= TUNNEL_CSUM;
+			mtu -= gre_calc_hlen(tflags);
+		}
  		if (mtu < IPV6_MIN_MTU) {
  			IP_VS_DBG_RL("%s(): mtu less than %d\n", __func__,
  				     IPV6_MIN_MTU);
@@ -1079,6 +1092,24 @@ static inline int __tun_gso_type_mask(int encaps_af, int 
orig_af)
  	return 0;
  }

+static void
+ipvs_gre_encap(struct net *net, struct sk_buff *skb,
+	       struct ip_vs_conn *cp, __u8 *next_protocol)
+{
+	size_t hdrlen;
+	__be16 tflags = 0;
+	__be16 proto = *next_protocol == IPPROTO_IPIP ? htons(ETH_P_IP) : 
htons(ETH_P_IPV6);
+
+	if (cp->dest->tun_flags & IP_VS_TUNNEL_ENCAP_FLAG_CSUM)
+		tflags |= TUNNEL_CSUM;
+
+	hdrlen = gre_calc_hlen(tflags);
+
+	gre_build_header(skb, hdrlen, tflags, proto, 0, 0);
+
+	*next_protocol = IPPROTO_GRE;
+}
+
  /*
   *   IP Tunneling transmitter
   *
@@ -1153,6 +1184,18 @@ static inline int __tun_gso_type_mask(int encaps_af, int 
orig_af)
  		max_headroom += sizeof(struct udphdr) + gue_hdrlen;
  	}

+	if (tun_type == IP_VS_CONN_F_TUNNEL_TYPE_GRE) {
+		size_t gre_hdrlen;
+		__be16 tflags = 0;
+
+		if (tun_flags & IP_VS_TUNNEL_ENCAP_FLAG_CSUM)
+			tflags |= TUNNEL_CSUM;
+
+		gre_hdrlen = gre_calc_hlen(tflags);
+
+		max_headroom += gre_hdrlen;
+	}
+
  	/* We only care about the df field if sysctl_pmtu_disc(ipvs) is set */
  	dfp = sysctl_pmtu_disc(ipvs) ? &df : NULL;
  	skb = ip_vs_prepare_tunneled_skb(skb, cp->af, max_headroom,
@@ -1174,6 +1217,13 @@ static inline int __tun_gso_type_mask(int encaps_af, int 
orig_af)
  		}
  	}

+	if (tun_type == IP_VS_CONN_F_TUNNEL_TYPE_GRE) {
+		if (tun_flags & IP_VS_TUNNEL_ENCAP_FLAG_CSUM)
+			gso_type |= SKB_GSO_GRE_CSUM;
+		else
+			gso_type |= SKB_GSO_GRE;
+	}
+
  	if (iptunnel_handle_offloads(skb, gso_type))
  		goto tx_error;

@@ -1194,6 +1244,9 @@ static inline int __tun_gso_type_mask(int encaps_af, int 
orig_af)
  		udp_set_csum(!check, skb, saddr, cp->daddr.ip, skb->len);
  	}

+	if (tun_type == IP_VS_CONN_F_TUNNEL_TYPE_GRE) {
+		ipvs_gre_encap(net, skb, cp, &next_protocol);
+	}

  	skb_push(skb, sizeof(struct iphdr));
  	skb_reset_network_header(skb);
@@ -1289,6 +1342,18 @@ static inline int __tun_gso_type_mask(int encaps_af, int 
orig_af)
  		max_headroom += sizeof(struct udphdr) + gue_hdrlen;
  	}

+	if (tun_type == IP_VS_CONN_F_TUNNEL_TYPE_GRE) {
+		size_t gre_hdrlen;
+		__be16 tflags = 0;
+
+		if (tun_flags & IP_VS_TUNNEL_ENCAP_FLAG_CSUM)
+			tflags |= TUNNEL_CSUM;
+
+		gre_hdrlen = gre_calc_hlen(tflags);
+
+		max_headroom += gre_hdrlen;
+	}
+
  	skb = ip_vs_prepare_tunneled_skb(skb, cp->af, max_headroom,
  					 &next_protocol, &payload_len,
  					 &dsfield, &ttl, NULL);
@@ -1308,6 +1373,13 @@ static inline int __tun_gso_type_mask(int encaps_af, int 
orig_af)
  		}
  	}

+	if (tun_type == IP_VS_CONN_F_TUNNEL_TYPE_GRE) {
+		if (tun_flags & IP_VS_TUNNEL_ENCAP_FLAG_CSUM)
+			gso_type |= SKB_GSO_GRE_CSUM;
+		else
+			gso_type |= SKB_GSO_GRE;
+	}
+
  	if (iptunnel_handle_offloads(skb, gso_type))
  		goto tx_error;

@@ -1328,6 +1400,10 @@ static inline int __tun_gso_type_mask(int encaps_af, int 
orig_af)
  		udp6_set_csum(!check, skb, &saddr, &cp->daddr.in6, skb->len);
  	}

+	if (tun_type == IP_VS_CONN_F_TUNNEL_TYPE_GRE) {
+		ipvs_gre_encap(net, skb, cp, &next_protocol);
+	}
+
  	skb_push(skb, sizeof(struct ipv6hdr));
  	skb_reset_network_header(skb);
  	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
-- 
1.9.1
