From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2] ipvs: add a 'default' case in do_ip_vs_set_ctl()
Date: Tue, 13 Dec 2022 12:28:24 +0100
Message-ID: <Y5hh2NPmmkmD4VTt@salvia>
References: <272315c8-5e3b-e8ca-3c7f-68eccd0f2430@nfschina.com>
 <20221212074351.26440-1-liqiong@nfschina.com>
 <c3ca27a-f923-6eb6-bbe4-5e99b65c5940@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <c3ca27a-f923-6eb6-bbe4-5e99b65c5940@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Li Qiong <liqiong@nfschina.com>, Simon Horman <horms@verge.net.au>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, kernel-janitors@vger.kernel.org, coreteam@netfilter.org, Yu Zhe <yuzhe@nfschina.com>

On Mon, Dec 12, 2022 at 04:20:41PM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 12 Dec 2022, Li Qiong wrote:
> 
> > It is better to return the default switch case with
> > '-EINVAL', in case new commands are added. otherwise,
> > return a uninitialized value of ret.
> > 
> > Signed-off-by: Li Qiong <liqiong@nfschina.com>
> > Reviewed-by: Simon Horman <horms@verge.net.au>
> 
> 	Change looks correct to me for -next, thanks!
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

Applied, thanks.
