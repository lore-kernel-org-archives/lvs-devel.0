From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch v2.3 2/4] IPVS: make friends with nf_conntrack
Date: Tue, 06 Jul 2010 13:36:43 +0200
Message-ID: <4C33154B.7090907@trash.net>
References: <20100704113246.562399500@vergenet.net> <20100704114808.668473084@vergenet.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20100704114808.668473084@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org, Malcolm Turnbull <malcolm@loadbalancer.org>, Wensong Zhang <wensong@linux-vs.org>, Julius Volz <julius.volz@gmail.com>, "David S. Miller" <davem@davemloft.net>, Hannes Eder <heder@google.com>

Simon Horman wrote:
> +static void
> +ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp)
> +{
> +	struct nf_conn *ct = (struct nf_conn *)skb->nfct;
> +	struct nf_conntrack_tuple new_tuple;
> +
> +	if (ct == NULL || ct == &nf_conntrack_untracked ||
> +	    nf_ct_is_confirmed(ct))
>   
Similar to the last patch, this needs to use nf_ct_is_untracked().

> +		return;
> +

