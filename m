From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH net-next v1 1/4] ipv6: silence compilation warning for non-IPV6 builds
Date: Wed,  3 Feb 2021 12:16:09 +0200
Message-ID: <20210203101612.4004322-2-leon@kernel.org>
References: <20210203101612.4004322-1-leon@kernel.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1612347383;
        bh=2wOV7+W6rAll0XgIt3CapU4I+kcslY5MEhMOUMT8zTg=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=NZnuRjoJAVEW8n11eD+8vyQ3KAjWTWr8TEjo8QDlLD9gQVb/v5fOw98uym40EQN9R
         Yb1pdy9hGWIA6G5m8/xEX3eHfFzsWJjcyLn9ETdKP0ZwU3qLISKHgsRU7K+L+hzxlz
         EXdWFqujUcD+3cZSkhkxqG9WnnWBItPdi25BpyJsZkPRNnYjToO5AViBw+0ypvgGLi
         0IMdLLSw+NBFHB3QGtes2UlePLzTAyqk4ryOrlHW6QlSdXLv9hRWmoiasvymbg4dHt
         +LNqWgQbsy7MFLgVEdwJUZmVzhcCE9MxiV15iwZLSe5BqMSO49MVsaPrJR6rSm3ouQ
         hSEYC6EWDgZJg==
In-Reply-To: <20210203101612.4004322-1-leon@kernel.org>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Jakub Kicinski <kuba@kernel.org>, "David S. Miller" <davem@davemloft.net>, Pablo Neira Ayuso <pablo@netfilter.org>, Eric Dumazet <edumazet@google.com>
Cc: Leon Romanovsky <leonro@nvidia.com>, coreteam@netfilter.org, Florian Westphal <fw@strlen.de>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, Matteo Croce <mcroce@redhat.com>, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>

From: Leon Romanovsky <leonro@nvidia.com>

The W=1 compilation of allmodconfig generates the following warning:

net/ipv6/icmp.c:448:6: warning: no previous prototype for 'icmp6_send' [-Wmissing-prototypes]
  448 | void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info,
      |      ^~~~~~~~~~

Fix it by providing function declaration for builds with ipv6 as a module.

Signed-off-by: Leon Romanovsky <leonro@nvidia.com>
---
 include/linux/icmpv6.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/icmpv6.h b/include/linux/icmpv6.h
index 1b3371ae8193..452d8978ffc7 100644
--- a/include/linux/icmpv6.h
+++ b/include/linux/icmpv6.h
@@ -16,9 +16,9 @@ static inline struct icmp6hdr *icmp6_hdr(const struct sk_buff *skb)

 typedef void ip6_icmp_send_t(struct sk_buff *skb, u8 type, u8 code, __u32 info,
 			     const struct in6_addr *force_saddr);
-#if IS_BUILTIN(CONFIG_IPV6)
 void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info,
 		const struct in6_addr *force_saddr);
+#if IS_BUILTIN(CONFIG_IPV6)
 static inline void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 {
 	icmp6_send(skb, type, code, info, NULL);
--
2.29.2

