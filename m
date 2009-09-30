From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 1/2] net/netfilter/ipvs: Move #define KMSG_COMPONENT to
 Makefile
Date: Thu, 1 Oct 2009 00:46:48 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0910010042540.782@obet.zrqbmnf.qr>
References: <cover.1254349374.git.joe@perches.com> <0026bcf5aad9ae5036e68fc2dcda9c778d30dc47.1254349375.git.joe@perches.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754556AbZI3Wqr@vger.kernel.org>
In-Reply-To: <0026bcf5aad9ae5036e68fc2dcda9c778d30dc47.1254349375.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>
Cc: Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org


On Thursday 2009-10-01 00:37, Joe Perches wrote:

>This centralizes the definition and removes the
>replicated #defines from all files

And increases the length of the command line. Not that Linux does not
support long command lines (in fact, configure often determines huge
possible values on the max length test), but sometimes, developers
have to inspect the command lines anyway for bugs, or something. It
is already pretty long due to all the compiler flags. Oh what were
the days of DOS programs that allowed to pass in arguments in a
so-called "response file", wish we had that in gcc.

>+ccflags-y += -D "KMSG_COMPONENT=\"IPVS\""
>+ccflags-y += -D "pr_fmt(fmt)=KMSG_COMPONENT \": \" fmt"
>+
> # IPVS transport protocol load balancing support
> ip_vs_proto-objs-y :=
> ip_vs_proto-objs-$(CONFIG_IP_VS_PROTO_TCP) += ip_vs_proto_tcp.o
>diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
>index 3c7e427..a5283d8 100644
>--- a/net/netfilter/ipvs/ip_vs_app.c
>+++ b/net/netfilter/ipvs/ip_vs_app.c
>@@ -18,9 +18,6 @@
>  *
>  */
> 
>-#define KMSG_COMPONENT "IPVS"
>-#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt

How about an #include file for the ipvs private things?
