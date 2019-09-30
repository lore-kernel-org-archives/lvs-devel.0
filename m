From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2 0/2] ipvs: speedup ipvs netns dismantle
Date: Mon, 30 Sep 2019 22:08:23 +0300 (EEST)
Message-ID: <alpine.LFD.2.21.1909302205360.2706@ja.home.ssi.bg>
References: <1569560091-20553-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1569560091-20553-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Cc: "David S. Miller" <davem@davemloft.net>, Pablo Neira Ayuso <pablo@netfilter.org>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>, netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>


	Hello,

On Fri, 27 Sep 2019, Haishuang Yan wrote:

> Implement exit_batch() method to dismantle more ipvs netns
> per round.
> 
> Tested:
> $  cat add_del_unshare.sh
> #!/bin/bash
> 
> for i in `seq 1 100`
>     do
>      (for j in `seq 1 40` ; do  unshare -n ipvsadm -A -t 172.16.$i.$j:80 >/dev/null ; done) &
>     done
> wait; grep net_namespace /proc/slabinfo
> 
> Befor patch:
> $  time sh add_del_unshare.sh
> net_namespace       4020   4020   4736    6    8 : tunables    0    0    0 : slabdata    670    670      0
> 
> real    0m8.086s
> user    0m2.025s
> sys     0m36.956s
> 
> After patch:
> $  time sh add_del_unshare.sh
> net_namespace       4020   4020   4736    6    8 : tunables    0    0    0 : slabdata    670    670      0
> 
> real    0m7.623s
> user    0m2.003s
> sys     0m32.935s
> 
> Haishuang Yan (2):
>   ipvs: batch __ip_vs_cleanup
>   ipvs: batch __ip_vs_dev_cleanup
> 
>  include/net/ip_vs.h             |  2 +-
>  net/netfilter/ipvs/ip_vs_core.c | 47 ++++++++++++++++++++++++-----------------
>  net/netfilter/ipvs/ip_vs_ctl.c  | 12 ++++++++---
>  3 files changed, 38 insertions(+), 23 deletions(-)

	Both patches in v2 look good to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

	This is for the -next kernels...

Regards

--
Julian Anastasov <ja@ssi.bg>
