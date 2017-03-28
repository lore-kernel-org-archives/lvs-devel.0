From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH v2] netfilter: Clean up tests if NULL returned on
 failure
Date: Tue, 28 Mar 2017 15:54:40 +0200 (CEST)
Message-ID: <alpine.LSU.2.20.1703281552040.21255@n3.vanv.qr>
References: <20170328131340.GA19688@singhal-Inspiron-5558>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20170328131340.GA19688@singhal-Inspiron-5558>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: simran singhal <singhalsimran0@gmail.com>
Cc: wensong@linux-vs.org, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, outreachy-kernel@googlegroups.com

On Tuesday 2017-03-28 15:13, simran singhal wrote:

>Some functions like kmalloc/kzalloc return NULL on failure. When NULL
>represents failure, !x is commonly used.
>
>@@ -910,7 +910,7 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
> 	}
> 
> 	dest = kzalloc(sizeof(struct ip_vs_dest), GFP_KERNEL);
>-	if (dest == NULL)
>+	if (!dest)
> 		return -ENOMEM;

This kind of transformation however is not cleanup anymore, it's really 
bikeshedding and should be avoided. There are pro and cons for both 
variants, and there is not really an overwhelming number of arguments 
for either variant to justify the change.
