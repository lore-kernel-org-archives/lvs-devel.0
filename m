From: Joel Granados <joel.granados@gmail.com>
Subject: [PATCH v2 09/14] ax.25: Update to register_net_sysctl_sz
Date: Mon, 31 Jul 2023 09:17:23 +0200
Message-ID: <20230731071728.3493794-10-j.granados@samsung.com>
References: <20230731071728.3493794-1-j.granados@samsung.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <linux-hams-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20221208; t=1690787867; x=1691392667;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=FA2Np0axnCcM7zYYQ9J3PNsrfsw3IGeC9vgEKu3nCGU=;
        b=jpMYG4ou2L8vx2RUTUVRXZn7QJd4O0UHRyIOfry+GKXNJ0D69hHzOKIYQpPA6HaqRE
         umaqJcW9NZXGPZQINuL3wnrYgUKUIPz5ES5koMDs9pynqpjXiHO0T4X35LGLZqyvkUxt
         y5rrXas7E/57rsua1yTM/R2vhj/Ln+GI8yIlALAZZMw+DMJp7xcL95cs4+PT6jO7lxJI
         4in1qYNAa9Mp3ldQ5ZuTfU2Jnxvms9t8PJfqgFhC+6X45niZPOKR6/+AYAJtA4d2Uv0Q
         yYLYFl1l8p0M4CNtbKY9eLk022rVeciWFTXU+gb6zmEVa9stfbrZfEcpkrfARkIYsZwN
         eKjA==
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
pointer. We hold off the SIZE_MAX to ARRAY_SIZE change until we have
migrated all the relevant net sysctl registering functions to
register_net_sysctl_sz in subsequent commits.

Signed-off-by: Joel Granados <j.granados@samsung.com>
---
 net/ax25/sysctl_net_ax25.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ax25/sysctl_net_ax25.c b/net/ax25/sysctl_net_ax25.c
index 2154d004d3dc..db66e11e7fe8 100644
--- a/net/ax25/sysctl_net_ax25.c
+++ b/net/ax25/sysctl_net_ax25.c
@@ -159,7 +159,8 @@ int ax25_register_dev_sysctl(ax25_dev *ax25_dev)
 		table[k].data = &ax25_dev->values[k];
 
 	snprintf(path, sizeof(path), "net/ax25/%s", ax25_dev->dev->name);
-	ax25_dev->sysheader = register_net_sysctl(&init_net, path, table);
+	ax25_dev->sysheader = register_net_sysctl_sz(&init_net, path, table,
+						     ARRAY_SIZE(ax25_param_table));
 	if (!ax25_dev->sysheader) {
 		kfree(table);
 		return -ENOMEM;
-- 
2.30.2

