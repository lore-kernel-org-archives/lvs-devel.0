From: Matteo Croce <mcroce@redhat.com>
Subject: [PATCH net v2 1/2] jiffies: add utility function to calculate delta in ms
Date: Tue, 31 Jul 2018 18:03:32 +0200
Message-ID: <20180731160333.12215-2-mcroce@redhat.com>
References: <20180731160333.12215-1-mcroce@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20180731160333.12215-1-mcroce@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>

add jiffies_delta_to_msecs() helper func to calculate the delta between
two times and eventually 0 if negative.

Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Matteo Croce <mcroce@redhat.com>
---
 include/linux/jiffies.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/jiffies.h b/include/linux/jiffies.h
index a27cf6652327..fa928242567d 100644
--- a/include/linux/jiffies.h
+++ b/include/linux/jiffies.h
@@ -447,6 +447,11 @@ static inline clock_t jiffies_delta_to_clock_t(long delta)
 	return jiffies_to_clock_t(max(0L, delta));
 }
 
+static inline unsigned int jiffies_delta_to_msecs(long delta)
+{
+	return jiffies_to_msecs(max(0L, delta));
+}
+
 extern unsigned long clock_t_to_jiffies(unsigned long x);
 extern u64 jiffies_64_to_clock_t(u64 x);
 extern u64 nsec_to_clock_t(u64 x);
-- 
2.17.1

