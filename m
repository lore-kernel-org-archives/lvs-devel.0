From: Simon Horman <horms@verge.net.au>
Subject: Re: [Linux-kernel-mentees] [PATCH net-next v2] ipvs: Fix
 uninit-value in do_ip_vs_set_ctl()
Date: Tue, 11 Aug 2020 14:59:59 +0200
Message-ID: <20200811125956.GA31293@vergenet.net>
References: <20200810220703.796718-1-yepeilin.cs@gmail.com>
 <20200811074640.841693-1-yepeilin.cs@gmail.com>
 <alpine.LFD.2.23.451.2008111324570.7428@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.23.451.2008111324570.7428@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Peilin Ye <yepeilin.cs@gmail.com>, Wensong Zhang <wensong@linux-vs.org>, Cong Wang <xiyou.wangcong@gmail.com>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel-mentees@lists.linuxfoundation.org, syzkaller-bugs@googlegroups.com, linux-kernel@vger.kernel.org

On Tue, Aug 11, 2020 at 01:29:04PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Tue, 11 Aug 2020, Peilin Ye wrote:
> 
> > do_ip_vs_set_ctl() is referencing uninitialized stack value when `len` is
> > zero. Fix it.
> > 
> > Reported-by: syzbot+23b5f9e7caf61d9a3898@syzkaller.appspotmail.com
> > Link: https://syzkaller.appspot.com/bug?id=46ebfb92a8a812621a001ef04d90dfa459520fe2
> > Suggested-by: Julian Anastasov <ja@ssi.bg>
> > Signed-off-by: Peilin Ye <yepeilin.cs@gmail.com>
> 
> 	Looks good to me, thanks!
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

Pablo, could you consider this for nf-next or should we repost when
net-next re-opens?

Reviewed-by: Simon Horman <horms@verge.net.au>

