From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf,v2] ipvs: correctly print the memory size of
 ip_vs_conn_tab
Date: Tue, 19 Apr 2022 11:04:24 +0200
Message-ID: <Yl57GONaSbzgMJY8@salvia>
References: <1649761545-1864-1-git-send-email-yangpc@wangsu.com>
 <dd2f82a6-bf70-2b10-46e0-9d81e4dde6@ssi.bg>
 <Yl55e0mDsrgcCAX2@vergenet.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Yl55e0mDsrgcCAX2@vergenet.net>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>, Pengcheng Yang <yangpc@wangsu.com>, lvs-devel@vger.kernel.org, Florian Westphal <fw@strlen.de>, Jozsef Kadlecsik <kadlec@netfilter.org>, netfilter-devel@vger.kernel.org

On Tue, Apr 19, 2022 at 10:57:31AM +0200, Simon Horman wrote:
> On Fri, Apr 15, 2022 at 04:22:47PM +0300, Julian Anastasov wrote:
> > 
> > 	Hello,
> > 
> > On Tue, 12 Apr 2022, Pengcheng Yang wrote:
> > 
> > > The memory size of ip_vs_conn_tab changed after we use hlist
> > > instead of list.
> > > 
> > > Fixes: 731109e78415 ("ipvs: use hlist instead of list")
> > > Signed-off-by: Pengcheng Yang <yangpc@wangsu.com>
> > > ---
> > 
> > 	v2 looks better to me for nf-next, thanks!
> > 
> > Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> Acked-by: Simon Horman <horms@verge.net.au>

Applied to nf.git, thanks
