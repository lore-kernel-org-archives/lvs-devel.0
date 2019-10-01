From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: no need to update skb route entry for local
 destination packets.
Date: Tue, 1 Oct 2019 11:54:07 +0200
Message-ID: <20191001095404.4sufoczzm7o3z7e2@verge.net.au>
References: <20190930051455.GA20692@toolchain>
 <alpine.LFD.2.21.1909302146530.2706@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.21.1909302146530.2706@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: zhang kai <zhangkaiheb@126.com>, Wensong Zhang <wensong@linux-vs.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org

On Mon, Sep 30, 2019 at 09:49:38PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 30 Sep 2019, zhang kai wrote:
> 
> > In the end of function __ip_vs_get_out_rt/__ip_vs_get_out_rt_v6,the
> > 'local' variable is always zero.
> > 
> > Signed-off-by: zhang kai <zhangkaiheb@126.com>
> 
> 	Looks good to me, thanks!
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> 	Simon, this is for -next kernels...

Thanks, applied to ipvs-next.
