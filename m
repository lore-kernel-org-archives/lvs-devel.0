From: Sasha Levin <sashal@kernel.org>
Subject: [PATCH AUTOSEL 6.1 39/49] ipvs: Update width of source for ip_vs_sync_conn_options
Date: Thu,  4 May 2023 15:46:16 -0400
Message-ID: <20230504194626.3807438-39-sashal@kernel.org>
References: <20230504194626.3807438-1-sashal@kernel.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <netdev+bounces-408-gl-netdev-2=m.gmane-mx.org@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1683229686;
	bh=eDAFbRTWheX6wqUdnZQ2u5zCbnmhV7R6tselF0fsGAs=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=pQizVjYK7nQs6PCpc9dJGslXSbOIdcxVyLDdGdm00v4ivenmc6hMtjCpVW47IhUF2
	 mAteA8zr2Jn7JzEkOAiyfprzSuyZ1Vs9jw7ugEF4hd3T3aCIrhhZ+RQ0JW7iiIR42C
	 r4kAl83ytQPClM6xd1hYvYyqyReC2jfJ6DMxKvpFZMtm712bkJ//OVyj4UuKW6jXEO
	 lgl7XQJqdeCPVhOFNkZ5xi13HeSQxpeqTkkO7q166oITfTBnTdwB8p5SHLckbeE4iy
	 /iXZ6p0y+dKj0K6YNrFLLhIIOT4MFGC/r/YFQN+F6Uz7rr86PWbeWx/kB+j0u3UdHd
	 CYw2AUAE9SQ5g==
In-Reply-To: <20230504194626.3807438-1-sashal@kernel.org>
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:netdev+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:netdev+unsubscribe@vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc: Simon Horman <horms@kernel.org>, Horatiu Vultur <horatiu.vultur@microchip.com>, Pablo Neira Ayuso <pablo@netfilter.org>, Sasha Levin <sashal@kernel.org>, horms@verge.net.au, ja@ssi.bg, davem@davemloft.net, dsahern@kernel.org, edumazet@google.com, kuba@kernel.org, pabeni@redhat.com, kadlec@netfilter.org, fw@strlen.de, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org

From: Simon Horman <horms@kernel.org>

[ Upstream commit e3478c68f6704638d08f437cbc552ca5970c151a ]

In ip_vs_sync_conn_v0() copy is made to struct ip_vs_sync_conn_options.
That structure looks like this:

struct ip_vs_sync_conn_options {
        struct ip_vs_seq        in_seq;
        struct ip_vs_seq        out_seq;
};

The source of the copy is the in_seq field of struct ip_vs_conn.  Whose
type is struct ip_vs_seq. Thus we can see that the source - is not as
wide as the amount of data copied, which is the width of struct
ip_vs_sync_conn_option.

The copy is safe because the next field in is another struct ip_vs_seq.
Make use of struct_group() to annotate this.

Flagged by gcc-13 as:

 In file included from ./include/linux/string.h:254,
                  from ./include/linux/bitmap.h:11,
                  from ./include/linux/cpumask.h:12,
                  from ./arch/x86/include/asm/paravirt.h:17,
                  from ./arch/x86/include/asm/cpuid.h:62,
                  from ./arch/x86/include/asm/processor.h:19,
                  from ./arch/x86/include/asm/timex.h:5,
                  from ./include/linux/timex.h:67,
                  from ./include/linux/time32.h:13,
                  from ./include/linux/time.h:60,
                  from ./include/linux/stat.h:19,
                  from ./include/linux/module.h:13,
                  from net/netfilter/ipvs/ip_vs_sync.c:38:
 In function 'fortify_memcpy_chk',
     inlined from 'ip_vs_sync_conn_v0' at net/netfilter/ipvs/ip_vs_sync.c:606:3:
 ./include/linux/fortify-string.h:529:25: error: call to '__read_overflow2_field' declared with attribute warning: detected read beyond size of field (2nd parameter); maybe use struct_group()? [-Werror=attribute-warning]
   529 |                         __read_overflow2_field(q_size_field, size);
       |

Compile tested only.

Signed-off-by: Simon Horman <horms@kernel.org>
Reviewed-by: Horatiu Vultur <horatiu.vultur@microchip.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 include/net/ip_vs.h             | 6 ++++--
 net/netfilter/ipvs/ip_vs_sync.c | 2 +-
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 1fca6a88114ad..abc46f05762e6 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -549,8 +549,10 @@ struct ip_vs_conn {
 	 */
 	struct ip_vs_app        *app;           /* bound ip_vs_app object */
 	void                    *app_data;      /* Application private data */
-	struct ip_vs_seq        in_seq;         /* incoming seq. struct */
-	struct ip_vs_seq        out_seq;        /* outgoing seq. struct */
+	struct_group(sync_conn_opt,
+		struct ip_vs_seq  in_seq;       /* incoming seq. struct */
+		struct ip_vs_seq  out_seq;      /* outgoing seq. struct */
+	);
 
 	const struct ip_vs_pe	*pe;
 	char			*pe_data;
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 4963fec815da3..d4fe7bb4f853a 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -603,7 +603,7 @@ static void ip_vs_sync_conn_v0(struct netns_ipvs *ipvs, struct ip_vs_conn *cp,
 	if (cp->flags & IP_VS_CONN_F_SEQ_MASK) {
 		struct ip_vs_sync_conn_options *opt =
 			(struct ip_vs_sync_conn_options *)&s[1];
-		memcpy(opt, &cp->in_seq, sizeof(*opt));
+		memcpy(opt, &cp->sync_conn_opt, sizeof(*opt));
 	}
 
 	m->nr_conns++;
-- 
2.39.2


