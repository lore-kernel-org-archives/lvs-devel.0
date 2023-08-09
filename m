From: Joel Granados <joel.granados@gmail.com>
Subject: [PATCH v3 08/14] sysctl: Add size to register_net_sysctl function
Date: Wed,  9 Aug 2023 12:50:00 +0200
Message-ID: <20230809105006.1198165-9-j.granados@samsung.com>
References: <20230809105006.1198165-1-j.granados@samsung.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <linux-fsdevel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20221208; t=1691578225; x=1692183025;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=y0Ehqjwr7n7aalL24v3eoFH6zkXkMLmEA1uyOzpkdUI=;
        b=H2CgJ05O88mtUkv8Ftw6TkmecV0v7sKcIi3Tsn9GBrQX05jqDPhbD2B/ScxcMO29RM
         Lj6x0UzluUoOPs98f6Tlr+Tk8cGJaXK6l+9ZOTDUmVPUSgcWt30XAdDS43WgFLBBaExy
         98susFYk9dmGQlPIVAf3Nbucn1IQCKFadE8y8S5N2AQhSJCuQMHeZhgnicADH0kuanTH
         4QycPhkp2niM9RbeZNtJ03nQE1qAuEoo0lyE0g8KEHFXcIx+jfcEIKnvHU/7dm6jE4RQ
         na8Dh+Z2zcd3s79bUfBxcF4kRpNxRKt7x1KPsfrKIp8ELBr/vYWA2+4F7+Hg2zmMT0S6
         ILQg==
In-Reply-To: <20230809105006.1198165-1-j.granados@samsung.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: mcgrof@kernel.org
Cc: rds-devel@oss.oracle.com, "David S. Miller" <davem@davemloft.net>, Florian Westphal <fw@strlen.de>, willy@infradead.org, Jan Karcher <jaka@linux.ibm.com>, Wen Gu <guwen@linux.alibaba.com>, Simon Horman <horms@verge.net.au>, Tony Lu <tonylu@linux.alibaba.com>, linux-wpan@vger.kernel.org, Matthieu Baerts <matthieu.baerts@tessares.net>, Christian Borntraeger <borntraeger@linux.ibm.com>, mptcp@lists.linux.dev, Heiko Carstens <hca@linux.ibm.com>, Stefan Schmidt <stefan@datenfreihafen.org>, Will Deacon <will@kernel.org>, Julian Anastasov <ja@ssi.bg>, netfilter-devel@vger.kernel.org, Joerg Reuter <jreuter@yaina.de>, linux-kernel@vger.kernel.org, Alexander Gordeev <agordeev@linux.ibm.com>, linux-sctp@vger.kernel.org, Xin Long <lucien.xin@gmail.com>, Herbert Xu <herbert@gond>

This commit adds size to the register_net_sysctl indirection function to
facilitate the removal of the sentinel elements (last empty markers)
from the ctl_table arrays. Though we don't actually remove any sentinels
in this commit, register_net_sysctl* now has the capability of
forwarding table_size for when that happens.

We create a new function register_net_sysctl_sz with an extra size
argument. A macro replaces the existing register_net_sysctl. The size in
the macro is SIZE_MAX instead of ARRAY_SIZE to avoid compilation errors
while we systematically migrate to register_net_sysctl_sz. Will change
to ARRAY_SIZE in subsequent commits.

Care is taken to add table_size to the stopping criteria in such a way
that when we remove the empty sentinel element, it will continue
stopping in the last element of the ctl_table array.

Signed-off-by: Joel Granados <j.granados@samsung.com>
Suggested-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 include/net/net_namespace.h | 10 ++++++----
 net/sysctl_net.c            | 22 +++++++++++++---------
 2 files changed, 19 insertions(+), 13 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 78beaa765c73..e4e5fe75a281 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -469,15 +469,17 @@ void unregister_pernet_device(struct pernet_operations *);
 
 struct ctl_table;
 
+#define register_net_sysctl(net, path, table)	\
+	register_net_sysctl_sz(net, path, table, SIZE_MAX)
 #ifdef CONFIG_SYSCTL
 int net_sysctl_init(void);
-struct ctl_table_header *register_net_sysctl(struct net *net, const char *path,
-					     struct ctl_table *table);
+struct ctl_table_header *register_net_sysctl_sz(struct net *net, const char *path,
+					     struct ctl_table *table, size_t table_size);
 void unregister_net_sysctl_table(struct ctl_table_header *header);
 #else
 static inline int net_sysctl_init(void) { return 0; }
-static inline struct ctl_table_header *register_net_sysctl(struct net *net,
-	const char *path, struct ctl_table *table)
+static inline struct ctl_table_header *register_net_sysctl_sz(struct net *net,
+	const char *path, struct ctl_table *table, size_t table_size)
 {
 	return NULL;
 }
diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index d9cbbb51b143..051ed5f6fc93 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -122,12 +122,13 @@ __init int net_sysctl_init(void)
  *    allocated.
  */
 static void ensure_safe_net_sysctl(struct net *net, const char *path,
-				   struct ctl_table *table)
+				   struct ctl_table *table, size_t table_size)
 {
 	struct ctl_table *ent;
 
 	pr_debug("Registering net sysctl (net %p): %s\n", net, path);
-	for (ent = table; ent->procname; ent++) {
+	ent = table;
+	for (size_t i = 0; i < table_size && ent->procname; ent++, i++) {
 		unsigned long addr;
 		const char *where;
 
@@ -160,21 +161,24 @@ static void ensure_safe_net_sysctl(struct net *net, const char *path,
 	}
 }
 
-struct ctl_table_header *register_net_sysctl(struct net *net,
-	const char *path, struct ctl_table *table)
+struct ctl_table_header *register_net_sysctl_sz(struct net *net,
+						const char *path,
+						struct ctl_table *table,
+						size_t table_size)
 {
-	int count = 0;
+	int count;
 	struct ctl_table *entry;
 
 	if (!net_eq(net, &init_net))
-		ensure_safe_net_sysctl(net, path, table);
+		ensure_safe_net_sysctl(net, path, table, table_size);
 
-	for (entry = table; entry->procname; entry++)
-		count++;
+	entry = table;
+	for (count = 0 ; count < table_size && entry->procname; entry++, count++)
+		;
 
 	return __register_sysctl_table(&net->sysctls, path, table, count);
 }
-EXPORT_SYMBOL_GPL(register_net_sysctl);
+EXPORT_SYMBOL_GPL(register_net_sysctl_sz);
 
 void unregister_net_sysctl_table(struct ctl_table_header *header)
 {
-- 
2.30.2

