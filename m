From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [RFC][PATCH 5/5] libxt_ipvs: user space lib for netfilter matcher
 xt_ipvs
Date: Mon, 27 Jul 2009 20:40:23 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0907272037500.20984@fbirervta.pbzchgretzou.qr>
References: <20090727134457.12897.272.stgit@jazzy.zrh.corp.google.com> <20090727134852.13319.39035.stgit@jazzy.zrh.corp.google.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090727134852.13319.39035.stgit@jazzy.zrh.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hannes Eder <heder@google.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org


On Monday 2009-07-27 15:48, Hannes Eder wrote:
>+
>+	switch (c) {
>+	case '0': /* --ipvs */
>+		/* Nothing to do here. */

		Then why add it?

>+	char buf[BUFSIZ];
>+
>+	if (family == NFPROTO_IPV4) {
>+		if (!numeric && addr->ip == 0) {
>+			printf("anywhere ");
>+			return;
>+		}
>+		if (numeric)
>+			strcpy(buf, xtables_ipaddr_to_numeric(&addr->in));
>+		else
>+			strcpy(buf, xtables_ipaddr_to_anyname(&addr->in));
>+		strcat(buf, xtables_ipmask_to_numeric(&mask->in));
>+		printf("%s ", buf);

There is no need to use the strcpy/strcat hacks. Just directly printf it.

>--- /dev/null
>+++ b/extensions/libxt_ipvs.man
>@@ -0,0 +1,7 @@
>+ipvs tests where the packet was modified by IPVS, i.e. is the
>+skb_buff->ipvs_property set.
>+.TP
>+[\fB!\fP] \fB--ipvs
>+Does the packet have to IPVS property?
>+
>+TODO: Write proper documentation.

Yes.
