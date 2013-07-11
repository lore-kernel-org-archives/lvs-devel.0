From: Dragos Foianu <dragos.foianu@gmail.com>
Subject: [PATCH] ipvs: fixed style error in ip_vs_sched
Date: Thu, 11 Jul 2013 22:20:38 +0300
Message-ID: <1373570438-4946-1-git-send-email-dragos.foianu@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=from:to:cc:subject:date:message-id:x-mailer;
        bh=Fh4kUhV4rCHhEapsz4kskX7nDOvNVkl2yyAF4GGUZic=;
        b=CTQdnJMY3d3khy/cXXja8OQLxhmoA5oQIiB0eEuBpclVQljH4pH9NhfIRGMycu+M24
         D0nKAO/e6PbpmbiUj9uWzjrR0Jxq5d2qEeJOn5/7Sp2Y4ny5JaYuQtdKgpxyWpI8yiVS
         4xFLWYjYLmRu4x/GjgJQr4+ujSLjlbYxreAXe5tBPNhRhhRhElQsDqe+ehVzvx47xtI/
         UQ8SIhEwM3UOluj6xeaSWV2Dl7vh7bN3+HRk+qfaHZuxo6UYEHAqxWblWc3kRg91mtNy
         OXiIm5cDdOLJMLgc6V2QLCbkb0mywN0euP5UnfSB+KsS5B4uaw6UDr9amZfVKHXAXeDI
         86sQ==
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org
Cc: horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu, davem@davemloft.net, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, Dragos Foianu <dragos.foianu@gmail.com>

found with the help of checkpatch.pl

Signed-off-by: Dragos Foianu <dragos.foianu@gmail.com>
---
 net/netfilter/ipvs/ip_vs_sched.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_sched.c b/net/netfilter/ipvs/ip_vs_sched.c
index 4dbcda6..a67980d 100644
--- a/net/netfilter/ipvs/ip_vs_sched.c
+++ b/net/netfilter/ipvs/ip_vs_sched.c
@@ -99,7 +99,7 @@ static struct ip_vs_scheduler *ip_vs_sched_getbyname(const char *sched_name)
 			 */
 			continue;
 		}
-		if (strcmp(sched_name, sched->name)==0) {
+		if (strcmp(sched_name, sched->name) == 0) {
 			/* HIT */
 			mutex_unlock(&ip_vs_sched_mutex);
 			return sched;
-- 
1.7.10.4

