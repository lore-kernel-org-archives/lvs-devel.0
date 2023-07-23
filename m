From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2 net-next] ipvs: make ip_vs_svc_table and ip_vs_svc_fwm_table
 per netns
Date: Sun, 23 Jul 2023 20:19:54 +0300 (EEST)
Message-ID: <ff4612e3-bb5a-7acc-1607-5761e5d052c4@ssi.bg>
References: <20230723154426.81242-1-dust.li@linux.alibaba.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
        t=1690132803; bh=YrVeEtTivAdP2fxw9gd4b9AW6XhLSsJtD12xMtYk0Ko=;
        h=Date:From:To:cc:Subject:In-Reply-To:References;
        b=vvWvHfFCa+NSSrT/PIHNLWy+7Kj0snPJa0hUdEfXgNrMayTvUtxktkFIa6awNoW3m
         dlz0zO40oQMA50f+HkwSiExYDhZEJSwsDDVsjtsyOZ27tYkfLbxSmg99vgxMxfi3+p
         x8K+sUZ/LngP1QD9keNQXTZzMsszBpR+gyO7tMjY=
In-Reply-To: <20230723154426.81242-1-dust.li@linux.alibaba.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dust Li <dust.li@linux.alibaba.com>
Cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Jiejian Wu <jiejian@linux.alibaba.com>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org


	Hello,

On Sun, 23 Jul 2023, Dust Li wrote:

> From: Jiejian Wu <jiejian@linux.alibaba.com>
> 
> Current ipvs uses one global mutex "__ip_vs_mutex" to keep the global
> "ip_vs_svc_table" and "ip_vs_svc_fwm_table" safe. But when there are
> tens of thousands of services from different netns in the table, it
> takes a long time to look up the table, for example, using "ipvsadm
> -ln" from different netns simultaneously.
> 
> We make "ip_vs_svc_table" and "ip_vs_svc_fwm_table" per netns, and we
> add "service_mutex" per netns to keep these two tables safe instead of
> the global "__ip_vs_mutex" in current version. To this end, looking up
> services from different netns simultaneously will not get stuck,
> shortening the time consumption in large-scale deployment. It can be
> reproduced using the simple scripts below.
> 
> init.sh: #!/bin/bash
> for((i=1;i<=4;i++));do
>         ip netns add ns$i
>         ip netns exec ns$i ip link set dev lo up
>         ip netns exec ns$i sh add-services.sh
> done
> 
> add-services.sh: #!/bin/bash
> for((i=0;i<30000;i++)); do
>         ipvsadm -A  -t 10.10.10.10:$((80+$i)) -s rr
> done
> 
> runtest.sh: #!/bin/bash
> for((i=1;i<4;i++));do
>         ip netns exec ns$i ipvsadm -ln > /dev/null &
> done
> ip netns exec ns4 ipvsadm -ln > /dev/null
> 
> Run "sh init.sh" to initiate the network environment. Then run "time
> ./runtest.sh" to evaluate the time consumption. Our testbed is a 4-core
> Intel Xeon ECS. The result of the original version is around 8 seconds,
> while the result of the modified version is only 0.8 seconds.
> 
> Signed-off-by: Jiejian Wu <jiejian@linux.alibaba.com>
> Co-developed-by: Dust Li <dust.li@linux.alibaba.com>
> Signed-off-by: Dust Li <dust.li@linux.alibaba.com>

	Changes look good to me, thanks! But checkpatch is reporting
for some cosmetic changes that you have to do in v3:

scripts/checkpatch.pl --strict /tmp/file.patch

Regards

--
Julian Anastasov <ja@ssi.bg>

