From: Joel Granados <joel.granados@gmail.com>
Subject: [PATCH v2 12/14] vrf: Update to register_net_sysctl_sz
Date: Mon, 31 Jul 2023 09:17:26 +0200
Message-ID: <20230731071728.3493794-13-j.granados@samsung.com>
References: <20230731071728.3493794-1-j.granados@samsung.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <linux-fsdevel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20221208; t=1690787874; x=1691392674;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=WLmPwUxElpGPIItGBie9qSPLiGC8xTssPnC4wjmH8Co=;
        b=IpykfJb7hcUQStL2f0jwevdksgcPlej76+9Dvlr1etAys3iM7VBIf1dA9mPPbAYwEb
         ovJ3JqI/719OJKxsZ6C+Z8AKuT8aGJ8b4PaOI4zBQOwthNmU3T7saorlPq0OFGxCpSve
         zgNuz5M+is0YyrITjMyHTZmRVk7n/qm4sjOgmkOO54OTjqAif6/SwiRsLOZuEL+B98qp
         GAICvEE8SmvklGodmsUNzWyuYtuSW1QtXfHA5t9EADp21BbKXmmGvog+lzyPMjWS0+o9
         YAQafxqNi3TE5xfJHhmTEkye+I77LFFqaIu/Xim5e2O7+IpfnM5rQvYU0EPtAIag7AvX
         7qPA==
In-Reply-To: <20230731071728.3493794-1-j.granados@samsung.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: mcgrof@kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, Iurii Zaikin <yzaikin@google.com>, Jozsef Kadlecsik <kadlec@netfilter.org>, Sven Schnelle <svens@linux.ibm.com>, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>, Steffen Klassert <steffen.klassert@secunet.com>, Kees Cook <keescook@chromium.org>, "D. Wythe" <alibuda@linux.alibaba.com>, mptcp@lists.linux.dev, Jakub Kicinski <kuba@kernel.org>, Vasily Gorbik <gor@linux.ibm.com>, Paolo Abeni <pabeni@redhat.com>, coreteam@netfilter.org, Jan Karcher <jaka@linux.ibm.com>, Alexander Aring <alex.aring@gmail.com>, Will Deacon <will@kernel.org>, Stefan Schmidt <stefan@datenfreihafen.org>, Matthieu Baerts <matthieu.baerts@tessares.net>, bridge@lists.linux-foundation.org, linux-arm-kernel@lists.infradead.org

Move from register_net_sysctl to register_net_sysctl_sz and pass the
ARRAY_SIZE of the ctl_table array that was used to create the table
variable. We need to move to the new function in preparation for when we
change SIZE_MAX to ARRAY_SIZE() in the register_net_sysctl macro.
Failing to do so would erroneously allow ARRAY_SIZE() to be called on a
pointer. The actual change from SIZE_MAX to ARRAY_SIZE will take place
in subsequent commits.

Signed-off-by: Joel Granados <j.granados@samsung.com>
---
 drivers/net/vrf.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index bdb3a76a352e..f4c3df15a0e5 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -1979,7 +1979,8 @@ static int vrf_netns_init_sysctl(struct net *net, struct netns_vrf *nn_vrf)
 	/* init the extra1 parameter with the reference to current netns */
 	table[0].extra1 = net;
 
-	nn_vrf->ctl_hdr = register_net_sysctl(net, "net/vrf", table);
+	nn_vrf->ctl_hdr = register_net_sysctl_sz(net, "net/vrf", table,
+						 ARRAY_SIZE(vrf_table));
 	if (!nn_vrf->ctl_hdr) {
 		kfree(table);
 		return -ENOMEM;
-- 
2.30.2

