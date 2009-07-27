From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [RFC][PATCH 1/5] IPVS: prefix EnterFunction and LeaveFunction
 msg with "IPVS:"
Date: Mon, 27 Jul 2009 20:14:30 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0907272013070.20984@fbirervta.pbzchgretzou.qr>
References: <20090727134457.12897.272.stgit@jazzy.zrh.corp.google.com> <20090727134616.12897.7639.stgit@jazzy.zrh.corp.google.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20090727134616.12897.7639.stgit@jazzy.zrh.corp.google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hannes Eder <heder@google.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org


On Monday 2009-07-27 15:46, Hannes Eder wrote:
>
>Now all printk messages from IPVS are prefixed with "IPVS:".
>
>+#define EnterFunction(level)						       \
>+	do {								       \
>+		if (level <= ip_vs_get_debug_level())			       \
>+			printk(KERN_DEBUG "IPVS: Enter: %s, %s line %i\n",     \
>+				__func__, __FILE__, __LINE__);		       \
>+	} while (0)
>+#define LeaveFunction(level)						       \
>+	do {								       \
>+		if (level <= ip_vs_get_debug_level())			       \
>+			printk(KERN_DEBUG "IPVS: Leave: %s, %s line %i\n",     \
>+				__func__, __FILE__, __LINE__);		       \
>+	} while (0)

I think you should rather make use of pr_fmt:

<before any #includes>
#define pr_fmt(x) "IPVS: " x

And then use pr_<level>("Elvis has left the building") in code. This
will add IPVS: automatically to all pr_* calls, alleviating the need
to manually type it into all printks.
Of course, if you only want it for the two defines here, scrap
my idea :)
