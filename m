From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] ipvs: avoid oops for passive FTP
Date: Thu, 02 Sep 2010 10:05:17 -0700 (PDT)
Message-ID: <20100902.100517.59674924.davem@davemloft.net>
References: <20100902090709.GA15401@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100902090709.GA15401@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: horms@verge.net.au
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, kaber@trash.net, wensong@linux-vs.org, ja@ssi.bg

From: Simon Horman <horms@verge.net.au>
Date: Thu, 2 Sep 2010 18:07:10 +0900

> From: Julian Anastasov <ja@ssi.bg>
> 
> Fix Passive FTP problem in ip_vs_ftp:
> 
> - Do not oops in nf_nat_set_seq_adjust (adjust_tcp_sequence) when
>   iptable_nat module is not loaded
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Simon Horman <horms@verge.net.au>

Also applied, thanks Simon.
