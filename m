From: Rumen Bogdanovski <rumen@voicecho.com>
Subject: Re: [PATCH] IPVS: More reliable subchronization on connection
	close.
Date: Wed, 16 Jul 2008 22:49:38 +0300
Message-ID: <1216237778.6260.1.camel@lappy>
References: <20080716063519.GA5144@verge.net.au>
Reply-To: rumen@voicecho.com
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20080716063519.GA5144@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: LVS Devel <lvs-devel@vger.kernel.org>, Linux Netdev List <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>, Joseph Mack NA3T <jmack@wm7d.net>

Would you please change the Subject to (a typo fix):
[PATCH] IPVS: More reliable synchronization on connection close.


On Wed, 2008-07-16 at 16:35 +1000, Simon Horman wrote:
> From: Rumen Bogdanovski <rumen@voicecho.com>
> 
> This patch enhances the synchronization of the closing connections
> between the master and the backup director. It prevents the closed
> connections to expire with the 15 min timeout of the ESTABLISHED
> state on the backup and makes them expire as they would do on the
> master with much shorter timeouts.
> 
> Cc: Joseph Mack NA3T <jmack@wm7d.net>
> Signed-off-by: Rumen G. Bogdanovski <rumen@voicecho.com>
> Acked-by: Simon Horman <horms@verge.net.au>
> 
> --- 
> 
> Hi Dave,
> 
> please consider applying this.
> 
> diff -Naur net-2.6_orig/net/ipv4/ipvs/ip_vs_core.c net-2.6/net/ipv4/ipvs/ip_vs_core.c
> --- net-2.6_orig/net/ipv4/ipvs/ip_vs_core.c	2008-07-15 11:23:44.000000000 +0300
> +++ net-2.6/net/ipv4/ipvs/ip_vs_core.c	2008-07-15 11:27:31.000000000 +0300
> @@ -993,7 +993,8 @@
>  	       == sysctl_ip_vs_sync_threshold[0])) ||
>  	     ((cp->protocol == IPPROTO_TCP) && (cp->old_state != cp->state) &&
>  	      ((cp->state == IP_VS_TCP_S_FIN_WAIT) ||
> -	       (cp->state == IP_VS_TCP_S_CLOSE)))))
> +	       (cp->state == IP_VS_TCP_S_CLOSE_WAIT) ||
> +	       (cp->state == IP_VS_TCP_S_TIME_WAIT)))))
>  		ip_vs_sync_conn(cp);
>  	cp->old_state = cp->state;
>  

