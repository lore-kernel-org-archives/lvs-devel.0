From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [Linux-kernel-mentees] [PATCH net-next v2] ipvs: Fix
 uninit-value in do_ip_vs_set_ctl()
Date: Fri, 28 Aug 2020 19:21:55 +0200
Message-ID: <20200828172155.GA6651@salvia>
References: <20200810220703.796718-1-yepeilin.cs@gmail.com>
 <20200811074640.841693-1-yepeilin.cs@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20200811074640.841693-1-yepeilin.cs@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peilin Ye <yepeilin.cs@gmail.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Cong Wang <xiyou.wangcong@gmail.com>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel-mentees@lists.linuxfoundation.org, syzkaller-bugs@googlegroups.com, linux-kernel@vger.kernel.org

On Tue, Aug 11, 2020 at 03:46:40AM -0400, Peilin Ye wrote:
> do_ip_vs_set_ctl() is referencing uninitialized stack value when `len` is
> zero. Fix it.

Applied to nf-next, thanks.
