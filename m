From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2] ipvs: add checksum support for gue encapsulation
Date: Wed, 29 May 2019 01:04:14 +0300 (EEST)
Message-ID: <alpine.LFD.2.21.1905290059380.4284@ja.home.ssi.bg>
References: <20190526064819.16420-1-hengqing.hu@gmail.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20190526064819.16420-1-hengqing.hu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jacky Hu <hengqing.hu@gmail.com>
Cc: jacky.hu@walmart.com, jason.niesz@walmart.com, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, "David S. Miller" <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org


	Hello,

On Sun, 26 May 2019, Jacky Hu wrote:

> +/* Tunnel encapsulation flags */
> +#define IP_VS_TUNNEL_ENCAP_FLAG_NOCSUM		(0)
> +#define IP_VS_TUNNEL_ENCAP_FLAG_CSUM		(1<<0)
> +#define IP_VS_TUNNEL_ENCAP_FLAG_REMCSUM		(1<<1)

	scripts/checkpatch.pl --strict file.patch
reports for some issues you should resolve for v3.
Otherwise, the patch looks good to me.

Regards

--
Julian Anastasov <ja@ssi.bg>
