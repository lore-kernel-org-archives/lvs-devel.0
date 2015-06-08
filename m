From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [patch] ipvs: prevent some underflows
Date: Mon, 8 Jun 2015 22:16:23 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1506082137420.1552@ja.home.ssi.bg>
References: <20150605093315.GD24871@mwanda>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20150605093315.GD24871@mwanda>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, kernel-janitors@vger.kernel.org


	Hello,

On Fri, 5 Jun 2015, Dan Carpenter wrote:

> @@ -1363,7 +1363,8 @@ static int set_sync_mesg_maxlen(struct net *net, int sync_state)

	May be we should use min(dev->mtu, 1500) instead of
dev->mtu to avoid sending too large packets for the common
case.

>  		       sizeof(struct udphdr) -
>  		       SYNC_MESG_HEADER_LEN - 20) / SIMPLE_CONN_SIZE;
>  		ipvs->send_mesg_maxlen = SYNC_MESG_HEADER_LEN +
> -			SIMPLE_CONN_SIZE * min(num, MAX_CONNS_PER_SYNCBUFF);
> +			SIMPLE_CONN_SIZE * min_t(uint, num,
> +						 MAX_CONNS_PER_SYNCBUFF);

	ipvs->send_mesg_maxlen = max(min(dev->mtu, 1500) -
		sizeof(struct iphdr) - sizeof(struct udphdr),
		/* Some new const is needed here: */
		2 * FULL_CONN_SIZE);

	And may be we should add more correct checks in
ip_vs_sync_conn() in case dev->mtu was changed after thread
start. Currently, it is assumed that fresh new buffer from
ip_vs_sync_buff_create() will have space for at least one
message... We can even set inet->pmtudisc to IP_PMTUDISC_DONT
so that packets can be fragmented for too small MTU.

>  		IP_VS_DBG(7, "setting the maximum length of sync sending "
>  			  "message %d.\n", ipvs->send_mesg_maxlen);
>  	} else if (sync_state == IP_VS_STATE_BACKUP) {
> @@ -1371,8 +1372,11 @@ static int set_sync_mesg_maxlen(struct net *net, int sync_state)
>  		if (!dev)
>  			return -ENODEV;
>  
> -		ipvs->recv_mesg_maxlen = dev->mtu -
> -			sizeof(struct iphdr) - sizeof(struct udphdr);
> +		if (dev->mtu < sizeof(struct iphdr) + sizeof(struct udphdr))
> +			ipvs->recv_mesg_maxlen = 0;
> +		else
> +			ipvs->recv_mesg_maxlen = dev->mtu -
> +				sizeof(struct iphdr) - sizeof(struct udphdr);

	May be ipvs->recv_mesg_maxlen = max(dev->mtu, 1500);
This is single buffer allocated when backup starts...

>  		IP_VS_DBG(7, "setting the maximum length of sync receiving "
>  			  "message %d.\n", ipvs->recv_mesg_maxlen);
>  	}
> 

Regards

--
Julian Anastasov <ja@ssi.bg>
