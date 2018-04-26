From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [Patch nf] ipvs: initialize tbl->entries after allocation
Date: Fri, 27 Apr 2018 00:21:15 +0200
Message-ID: <20180426222115.dk2xeikoaljqqiwe@salvia>
References: <20180423205341.13142-1-xiyou.wangcong@gmail.com>
 <alpine.LFD.2.20.1804240815120.2470@ja.home.ssi.bg>
 <20180426121423.5c7iy2ddhjy2clzf@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20180426121423.5c7iy2ddhjy2clzf@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>, Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

On Thu, Apr 26, 2018 at 02:14:25PM +0200, Simon Horman wrote:
> On Tue, Apr 24, 2018 at 08:16:14AM +0300, Julian Anastasov wrote:
> > 
> > 	Hello,
> > 
> > On Mon, 23 Apr 2018, Cong Wang wrote:
> > 
> > > tbl->entries is not initialized after kmalloc(), therefore
> > > causes an uninit-value warning in ip_vs_lblc_check_expire()
> > > as reported by syzbot.
> > > 
> > > Reported-by: <syzbot+3dfdea57819073a04f21@syzkaller.appspotmail.com>
> > > Cc: Simon Horman <horms@verge.net.au>
> > > Cc: Julian Anastasov <ja@ssi.bg>
> > > Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> > > Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> > 
> > 	Thanks!
> > 
> > Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> Thanks.
> 
> Pablo, could you take this into nf?
> 
> Acked-by: Simon Horman <horms@verge.net.au>

Done, thanks Simon.
