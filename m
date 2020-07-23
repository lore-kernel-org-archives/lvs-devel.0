From: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Subject: [PATCH 10/26] netfilter: remove the unused user argument to do_update_counters
Date: Thu, 23 Jul 2020 08:08:52 +0200
Message-ID: <20200723060908.50081-11-hch@lst.de>
References: <20200723060908.50081-1-hch@lst.de>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=casper.20170209; h=Content-Transfer-Encoding:MIME-Version:
        References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:
        Content-Type:Content-ID:Content-Description;
        bh=AjKHhDGZLqL4OuQUXI3ghPRn4d0K9eK+41+WmsKDw4s=; b=CNu8wX7/4AaScPiP+yKasX/Nuq
        00LHKTXAD3IquBRcEMSnRF8bNgMD1cvHh+U+oC9aYlopzyBcHDT20XOh1UxeZFqfjZgeBbGvE1wB6
        /V6nQUH0PdaU2g+5JOnd1u9l8C/s6uwbv4KhpIhdxBK8oLO0ZwY+sqyTh4ne0vagAIgh4N5VQBGx0
        JHE6q8bbDMTkx2eOaxshkvfo9rjtP0ncEN/z4VwN6Hb6/0xYri2cf1nNOzgptOsfvtMuA7wmNkOac
        QLJGCjm4BB8DbTIK1mpqQYiSCZNmMlsC+Vd1KrBSfphtSKPM32mRgHArgFrIC0MlfCF8txHO3F2DP
        u7/I0W5g==;
In-Reply-To: <20200723060908.50081-1-hch-jcswGhMUV9g@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Jakub Kicinski <kuba-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>, Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>, Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bpf-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-hams-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dccp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-decnet-user-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mptcp-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org, lvs-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, linux-afs-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, tipc-discussion-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-x25-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

Signed-off-by: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
---
 net/bridge/netfilter/ebtables.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index fe13108af1f542..12f8929667bf43 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -1242,9 +1242,8 @@ void ebt_unregister_table(struct net *net, struct ebt_table *table,
 
 /* userspace just supplied us with counters */
 static int do_update_counters(struct net *net, const char *name,
-				struct ebt_counter __user *counters,
-				unsigned int num_counters,
-				const void __user *user, unsigned int len)
+			      struct ebt_counter __user *counters,
+			      unsigned int num_counters, unsigned int len)
 {
 	int i, ret;
 	struct ebt_counter *tmp;
@@ -1299,7 +1298,7 @@ static int update_counters(struct net *net, const void __user *user,
 		return -EINVAL;
 
 	return do_update_counters(net, hlp.name, hlp.counters,
-				hlp.num_counters, user, len);
+				  hlp.num_counters, len);
 }
 
 static inline int ebt_obj_to_user(char __user *um, const char *_name,
@@ -2231,7 +2230,7 @@ static int compat_update_counters(struct net *net, void __user *user,
 		return update_counters(net, user, len);
 
 	return do_update_counters(net, hlp.name, compat_ptr(hlp.counters),
-					hlp.num_counters, user, len);
+				  hlp.num_counters, len);
 }
 
 static int compat_do_ebt_get_ctl(struct sock *sk, int cmd,
-- 
2.27.0

