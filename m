From: Jakub Kicinski <kuba@kernel.org>
Subject: Re: [PATCH v2] ipvs: Add traffic statistic up even it is VS/DR or
 VS/TUN mode
Date: Tue, 29 Sep 2020 07:41:49 -0700
Message-ID: <20200929074110.33d7d740@kicinski-fedora-pc1c0hjn.dhcp.thefacebook.com>
References: <20200929050302.28105-1-bigclouds@163.com>
        <20200929081811.32302-1-bigclouds@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1601390511;
        bh=rlxZTqkHGASpy0VXo23eN5mfvz25J2rFjnkZaQYej98=;
        h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
        b=yHDdlYwRzUhkbZyyYtV9YYBHku6hBE2UeNGym6GDDJAcRStczYOZxy/AnZ+8oUrjN
         PSywjhxEz3cqeijhgVPHGrSRiy1a55BMBsc330tzRttZe72castSolnes7h7hhW2TM
         OXpRUbNSiadzUlh+wgrxXzdHR1tkMM1Hrz5SaBfI=
In-Reply-To: <20200929081811.32302-1-bigclouds@163.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: "longguang.yue" <bigclouds@163.com>
Cc: yuelongguang@gmail.com, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

On Tue, 29 Sep 2020 16:18:11 +0800 longguang.yue wrote:
> @@ -411,10 +413,17 @@ struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p)
>  	rcu_read_lock();
>  
>  	hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[hash], c_list) {
> -		if (p->vport == cp->cport && p->cport == cp->dport &&
> +		if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ){
> +			cport = cp->vport;

checkpatch says:

ERROR: space required before the open brace '{'
#25: FILE: net/netfilter/ipvs/ip_vs_core.c:1416:
+		if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ){
