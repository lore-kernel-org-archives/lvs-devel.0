From: Simon Horman <horms@kernel.org>
Subject: [PATCH nf-next v2 4/4] ipvs: Correct spelling in comments
Date: Tue, 11 Apr 2023 09:10:42 +0200
Message-ID: <20230409-ipvs-cleanup-v2-4-204cd17da708@kernel.org>
References: <20230409-ipvs-cleanup-v2-0-204cd17da708@kernel.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1681197059;
        bh=GyhEHiJkt5kFXmysrQx6eDNO7cufe6HICtq92px6MeM=;
        h=From:Date:Subject:References:In-Reply-To:To:Cc:From;
        b=Tupdy+JxQySyI8Lm8YHNBoLU3bnxQhHlkrjBxnOfiwfpdtt82dgsb9m00iLSdIff+
         vGqFY1WoGRWvwC9xwhEKTq42fYB5rv3CTFPMuH6vD9ABRvn/kC82ObR8NOE5itmaFK
         o/eCF4Haq3RlLHtn5IT9a3RuNzClv4xTIL3L56MzslCPPnLk1w5dOiNaoKx6Bf2qZb
         cn6reH+xNI8Ww555d/OoKOQ5QKVi9i1F3u8eyyPm4Q/sk45uLngU0R9kDDDLnWaOEj
         8RKc5uTHlX+WUrysQAuZUMkxjxGAdbbd7Jchku9tLkHPfTjyQ0o8mMd8Aovd5Dsf8V
         P0G/ymHq7pjfQ==
In-Reply-To: <20230409-ipvs-cleanup-v2-0-204cd17da708@kernel.org>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, David Ahern <dsahern@kernel.org>, Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org

Correct some spelling errors flagged by codespell and found by inspection.

Signed-off-by: Simon Horman <horms@kernel.org>
---
 include/net/ip_vs.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index a3adc246ee31..ff406ef4fd4a 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -584,7 +584,7 @@ struct ip_vs_conn {
 	spinlock_t              lock;           /* lock for state transition */
 	volatile __u16          state;          /* state info */
 	volatile __u16          old_state;      /* old state, to be used for
-						 * state transition triggerd
+						 * state transition triggered
 						 * synchronization
 						 */
 	__u32			fwmark;		/* Fire wall mark from skb */
@@ -635,7 +635,7 @@ struct ip_vs_service_user_kern {
 	u16			protocol;
 	union nf_inet_addr	addr;		/* virtual ip address */
 	__be16			port;
-	u32			fwmark;		/* firwall mark of service */
+	u32			fwmark;		/* firewall mark of service */
 
 	/* virtual service options */
 	char			*sched_name;
@@ -1036,7 +1036,7 @@ struct netns_ipvs {
 	struct ipvs_sync_daemon_cfg	bcfg;	/* Backup Configuration */
 	/* net name space ptr */
 	struct net		*net;            /* Needed by timer routines */
-	/* Number of heterogeneous destinations, needed becaus heterogeneous
+	/* Number of heterogeneous destinations, needed because heterogeneous
 	 * are not supported when synchronization is enabled.
 	 */
 	unsigned int		mixed_address_family_dests;

-- 
2.30.2

