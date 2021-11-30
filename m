From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] ipvs: remove unused variable for ip_vs_new_dest
Date: Tue, 30 Nov 2021 22:46:40 +0100
Message-ID: <YaabwJ/EG5l7fTkG@salvia>
References: <1636112380-11040-1-git-send-email-zhenggy@chinatelecom.cn>
 <25e945b7-9027-43cb-f79c-573fdce42a26@ssi.bg>
 <20211114180206.GA2757@vergenet.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20211114180206.GA2757@vergenet.net>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>, GuoYong Zheng <zhenggy@chinatelecom.cn>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, coreteam@netfilter.org, linux-kernel <linux-kernel@vger.kernel.org>

On Sun, Nov 14, 2021 at 07:02:06PM +0100, Simon Horman wrote:
> On Sat, Nov 13, 2021 at 11:56:36AM +0200, Julian Anastasov wrote:
> > 
> > 	Hello,
> > 
> > On Fri, 5 Nov 2021, GuoYong Zheng wrote:
> > 
> > > The dest variable is not used after ip_vs_new_dest anymore in
> > > ip_vs_add_dest, do not need pass it to ip_vs_new_dest, remove it.
> > > 
> > > Signed-off-by: GuoYong Zheng <zhenggy@chinatelecom.cn>
> > 
> > 	Looks good to me for -next, thanks!
> > 
> > Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> Thanks GuoYong,
> 
> Acked-by: Simon Horman <horms@verge.net.au>
> 
> Pablo, please consider this for nf-next at your convenience.

Applied to nf-next, thanks
