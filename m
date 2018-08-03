From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v3] ipvs: fix race between ip_vs_conn_new() and
 ip_vs_del_dest()
Date: Fri, 3 Aug 2018 13:25:16 +0200
Message-ID: <20180803112516.zexgzi4hewvy6oo6@salvia>
References: <1532503387-3800-1-git-send-email-tan.hu@zte.com.cn>
 <alpine.LFD.2.20.1807252208320.2437@ja.home.ssi.bg>
 <20180731165421.ee265xghmbqcy54g@verge.net.au>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20180731165421.ee265xghmbqcy54g@verge.net.au>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>, Tan Hu <tan.hu@zte.com.cn>, wensong@linux-vs.org, kadlec@blackhole.kfki.hu, fw@strlen.de, davem@davemloft.net, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, zhong.weidong@zte.com.cn, jiang.biao2@zte.com.cn

On Tue, Jul 31, 2018 at 06:54:21PM +0200, Simon Horman wrote:
> On Wed, Jul 25, 2018 at 10:12:48PM +0300, Julian Anastasov wrote:
[...]
> > 	v3 looks good to me,
> > 
> > Acked-by: Julian Anastasov <ja@ssi.bg>
> > 
> > 	Simon and Pablo, this can be applied to ipvs/nf tree...
> 
> Acked-by: Simon Horman <horms@verge.net.au>
> 
> Pablo, please consider this for the nf tree.

Applied, thanks!
