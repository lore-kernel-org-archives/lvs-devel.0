From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [net-next 1/2] ipvs: batch __ip_vs_cleanup
Date: Mon, 29 Jul 2019 23:03:31 +0300 (EEST)
Message-ID: <alpine.LFD.2.21.1907292300580.2909@ja.home.ssi.bg>
References: <1563031186-2101-1-git-send-email-yanhaishuang@cmss.chinamobile.com> <1563031186-2101-2-git-send-email-yanhaishuang@cmss.chinamobile.com> <alpine.LFD.2.21.1907152333300.5700@ja.home.ssi.bg>
 <8441EA26-E197-4F40-A6D7-5B7D59AA7F7F@cmss.chinamobile.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8441EA26-E197-4F40-A6D7-5B7D59AA7F7F@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Cc: "David S. Miller" <davem@davemloft.net>, Pablo Neira Ayuso <pablo@netfilter.org>, Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org


	Hello,

On Thu, 18 Jul 2019, Haishuang Yan wrote:

> As the following benchmark testing results show, there is a little performance improvement:

	OK, can you send v2 after removing the LIST_HEAD(list) from
both patches, I guess, it is not needed. If you prefer, you can
include these benchmark results too.

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
> 
> > 
> >> +		ipvs = net_ipvs(net);
> >> +		ip_vs_conn_net_cleanup(ipvs);
> >> +		ip_vs_app_net_cleanup(ipvs);
> >> +		ip_vs_protocol_net_cleanup(ipvs);
> >> +		ip_vs_control_net_cleanup(ipvs);
> >> +		ip_vs_estimator_net_cleanup(ipvs);
> >> +		IP_VS_DBG(2, "ipvs netns %d released\n", ipvs->gen);
> >> +		net->ipvs = NULL;

Regards

--
Julian Anastasov <ja@ssi.bg>
