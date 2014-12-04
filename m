From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [patch] ipvs: uninitialized data with IP_VS_IPV6
Date: Thu, 4 Dec 2014 23:19:34 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1412042308100.4841@ja.home.ssi.bg>
References: <20141203101213.GC29583@mwanda>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20141203101213.GC29583@mwanda>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, kernel-janitors@vger.kernel.org


	Hello,

On Wed, 3 Dec 2014, Dan Carpenter wrote:

> The app_tcp_pkt_out() function expects "*diff" to be set and ends up
> using uninitialized data if CONFIG_IP_VS_IPV6 is turned on.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> This bug is very old.

	I guess ip_vs_ftp_in() needs the same fix?

Regards

--
Julian Anastasov <ja@ssi.bg>
