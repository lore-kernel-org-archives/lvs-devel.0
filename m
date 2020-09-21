From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] ipvs: Remove unused macros
Date: Tue, 22 Sep 2020 01:35:58 +0200
Message-ID: <20200921233557.GA6523@salvia>
References: <20200918131656.46260-1-yuehaibing@huawei.com>
 <20200921072436.GA8437@vergenet.net>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20200921072436.GA8437@vergenet.net>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: YueHaibing <yuehaibing@huawei.com>, wensong@linux-vs.org, ja@ssi.bg, kadlec@netfilter.org, fw@strlen.de, davem@davemloft.net, kuba@kernel.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

On Mon, Sep 21, 2020 at 09:24:40AM +0200, Simon Horman wrote:
> On Fri, Sep 18, 2020 at 09:16:56PM +0800, YueHaibing wrote:
> > They are not used since commit e4ff67513096 ("ipvs: add
> > sync_maxlen parameter for the sync daemon")
> > 
> > Signed-off-by: YueHaibing <yuehaibing@huawei.com>
> 
> Thanks, this look good to me.
> 
> Acked-by: Simon Horman <horms@verge.net.au>
> 
> Pablo, please consider this for nf-next.

Applied, thanks.
