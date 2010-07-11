From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch v2.5 3/4] IPVS: make FTP work with full NAT support
Date: Sun, 11 Jul 2010 18:01:31 +0900
Message-ID: <20100711085959.GA28199@verge.net.au>
References: <20100710030057.731118760@vergenet.net>
 <20100710030222.732009020@vergenet.net>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100710030222.732009020@vergenet.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Malcolm Turnbull <malcolm@loadbalancer.org>, Wensong Zhang <wensong@linux-vs.org>, Julius Volz <julius.volz@gmail.com>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, Hannes Eder <heder@google.com>

On Sat, Jul 10, 2010 at 12:01:00PM +0900, Simon Horman wrote:
> From:	Hannes Eder <heder@google.com>
> 
> Use nf_conntrack/nf_nat code to do the packet mangling and the TCP
> sequence adjusting.  The function 'ip_vs_skb_replace' is now dead
> code, so it is removed.
> 
> To SNAT FTP, use something like:
> 
> % iptables -t nat -A POSTROUTING -m ipvs --vaddr 192.168.100.30/32 \
> > --vport 21 -j SNAT --to-source 192.168.10.10
> 
> and for the data connections in passive mode:
> 
> % iptables -t nat -A POSTROUTING -m ipvs --vaddr 192.168.100.30/32 \
> > --vportctl 21 -j SNAT --to-source 192.168.10.10
> 
> using '-m state --state RELATED' would also works.
> 
> Make sure the kernel modules ip_vs_ftp, nf_conntrack_ftp, and
> nf_nat_ftp are loaded.

[snip]

> Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_ftp.c
> ===================================================================
> --- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_ftp.c	2010-07-10 11:48:54.000000000 +0900
> +++ nf-next-2.6/net/netfilter/ipvs/ip_vs_ftp.c	2010-07-10 11:59:19.000000000 +0900

[snip]

> @@ -43,6 +57,16 @@
>  #define SERVER_STRING "227 Entering Passive Mode ("
>  #define CLIENT_STRING "PORT "
>  
> +#define FMT_TUPLE	"%pI4:%u->%pI4:%u/%u"
> +#define ARG_TUPLE(T)	(T)->src.u3.ip, ntohs((T)->src.u.all), \
> +			(T)->dst.u3.ip, ntohs((T)->dst.u.all), \
> +			(T)->dst.protonum
> +
> +#define FMT_CONN	"%pI4:%u->%pI4:%u->%pI4:%u/%u:%u"
> +#define ARG_CONN(C)	(C)->caddr, ntohs((C)->cport), \
> +			(C)->vaddr, ntohs((C)->vport), \
> +			(C)->daddr, ntohs((C)->dport), \
> +			(C)->protocol, (C)->state
>  
>  /*
>   * List of ports (up to IP_VS_APP_MAX_PORTS) to be handled by helper

The argument to the %pI4 needs to be a pointer
so (T)->src.u3.ip should be &(T)->src.u3.ip and
(C)->caddr should be &(C)->caddr.ip.

I'm not sure how this slipped through the cracks so far.
I will repost.
