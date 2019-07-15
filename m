From: hujunwei <hujunwei4@huawei.com>
Subject: [PATCH net] ipvs: Improve robustness to the ipvs sysctl
Date: Mon, 15 Jul 2019 22:48:18 +0800
Message-ID: <1997375e-815d-137f-20c9-0829a8587ee9@huawei.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kadlec@blackhole.kfki.hu, fw@strlen.de, davem@davemloft.net
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, Mingfangsen <mingfangsen@huawei.com>, wangxiaogang3@huawei.com, xuhanbing@huawei.com

From: Junwei Hu <hujunwei4@huawei.com>

The ipvs module parse the user buffer and save it to sysctl,
then check if the value is valid. invalid value occurs
over a period of time.
Here, I add a variable, struct ctl_table tmp, used to read
the value from the user buffer, and save only when it is valid.

Fixes: f73181c8288f ("ipvs: add support for sync threads")
Signed-off-by: Junwei Hu <hujunwei4@huawei.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 61 +++++++++++++++++++++++-----------
 1 file changed, 42 insertions(+), 19 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 741d91aa4a8d..e78fd05f108b 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1680,12 +1680,18 @@ proc_do_defense_mode(struct ctl_table *table, int write,
 	int val = *valp;
 	int rc;

-	rc = proc_dointvec(table, write, buffer, lenp, ppos);
+	struct ctl_table tmp = {
+		.data = &val,
+		.maxlen = sizeof(int),
+		.mode = table->mode,
+	};
+
+	rc = proc_dointvec(&tmp, write, buffer, lenp, ppos);
 	if (write && (*valp != val)) {
-		if ((*valp < 0) || (*valp > 3)) {
-			/* Restore the correct value */
+		if (val < 0 || val > 3)
+			rc = -EINVAL;
+		else {
 			*valp = val;
-		} else {
 			update_defense_level(ipvs);
 		}
 	}
@@ -1699,15 +1705,20 @@ proc_do_sync_threshold(struct ctl_table *table, int write,
 	int *valp = table->data;
 	int val[2];
 	int rc;
+	struct ctl_table tmp = {
+		.data = &val,
+		.maxlen = table->maxlen,
+		.mode = table->mode,
+	};

-	/* backup the value first */
 	memcpy(val, valp, sizeof(val));
-
-	rc = proc_dointvec(table, write, buffer, lenp, ppos);
-	if (write && (valp[0] < 0 || valp[1] < 0 ||
-	    (valp[0] >= valp[1] && valp[1]))) {
-		/* Restore the correct value */
-		memcpy(valp, val, sizeof(val));
+	rc = proc_dointvec(&tmp, write, buffer, lenp, ppos);
+	if (write) {
+		if (val[0] < 0 || val[1] < 0 ||
+		    (val[0] >= val[1] && val[1]))
+			rc = -EINVAL;
+		else
+			memcpy(valp, val, sizeof(val));
 	}
 	return rc;
 }
@@ -1720,12 +1731,18 @@ proc_do_sync_mode(struct ctl_table *table, int write,
 	int val = *valp;
 	int rc;

-	rc = proc_dointvec(table, write, buffer, lenp, ppos);
+	struct ctl_table tmp = {
+		.data = &val,
+		.maxlen = sizeof(int),
+		.mode = table->mode,
+	};
+
+	rc = proc_dointvec(&tmp, write, buffer, lenp, ppos);
 	if (write && (*valp != val)) {
-		if ((*valp < 0) || (*valp > 1)) {
-			/* Restore the correct value */
+		if (val < 0 || val > 1)
+			rc = -EINVAL;
+		else
 			*valp = val;
-		}
 	}
 	return rc;
 }
@@ -1738,12 +1755,18 @@ proc_do_sync_ports(struct ctl_table *table, int write,
 	int val = *valp;
 	int rc;

-	rc = proc_dointvec(table, write, buffer, lenp, ppos);
+	struct ctl_table tmp = {
+		.data = &val,
+		.maxlen = sizeof(int),
+		.mode = table->mode,
+	};
+
+	rc = proc_dointvec(&tmp, write, buffer, lenp, ppos);
 	if (write && (*valp != val)) {
-		if (*valp < 1 || !is_power_of_2(*valp)) {
-			/* Restore the correct value */
+		if (val < 1 || !is_power_of_2(val))
+			rc = -EINVAL;
+		else
 			*valp = val;
-		}
 	}
 	return rc;
 }
-- 
2.21.GIT

