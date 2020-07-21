From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH,v2] ipvs: fix the connection sync failed in some cases
Date: Wed, 22 Jul 2020 01:23:27 +0200
Message-ID: <20200721232327.GA6430@salvia>
References: <1594887128-7453-1-git-send-email-geffrey.guo@huawei.com>
 <alpine.LFD.2.23.451.2007190837120.3463@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.23.451.2007190837120.3463@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: guodeqing <geffrey.guo@huawei.com>, wensong@linux-vs.org, horms@verge.net.au, kadlec@netfilter.org, fw@strlen.de, davem@davemloft.net, kuba@kernel.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

On Sun, Jul 19, 2020 at 09:08:39AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 16 Jul 2020, guodeqing wrote:
> 
> > The sync_thread_backup only checks sk_receive_queue is empty or not,
> > there is a situation which cannot sync the connection entries when
> > sk_receive_queue is empty and sk_rmem_alloc is larger than sk_rcvbuf,
> > the sync packets are dropped in __udp_enqueue_schedule_skb, this is
> > because the packets in reader_queue is not read, so the rmem is
> > not reclaimed.
> > 
> > Here I add the check of whether the reader_queue of the udp sock is
> > empty or not to solve this problem.
> > 
> > Fixes: 2276f58ac589 ("udp: use a separate rx queue for packet reception")
> > Reported-by: zhouxudong <zhouxudong8@huawei.com>
> > Signed-off-by: guodeqing <geffrey.guo@huawei.com>
> 
> 	Looks good to me, thanks!
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> 	Simon, Pablo, this patch should be applied to the nf tree.

Applied, thanks.

> As the reader_queue appears in 4.13, this patch can be backported
> to 4.14, 4.19, 5.4, etc, they all have skb_queue_empty_lockless.

The Fixes: tag should help -stable maintainer pull this into the next
batch. Otherwise, feel free to drop a line to stable@vger.kernel.org
to request inclusion after this patch hits Linus' tree.

Thanks.
