From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Long delay on estimation_timer causes packet latency
Date: Fri, 17 Apr 2020 10:47:34 +0300 (EEST)
Message-ID: <alpine.LFD.2.21.2004171029240.3962@ja.home.ssi.bg>
References: <D25792C1-1B89-45DE-9F10-EC350DC04ADC@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <D25792C1-1B89-45DE-9F10-EC350DC04ADC@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: yunhong-cgl jiang <xintian1976@gmail.com>
Cc: horms@verge.net.au, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Yunhong Jiang <yunhjiang@ebay.com>


	Hello,

On Thu, 16 Apr 2020, yunhong-cgl jiang wrote:

> Hi, Simon & Julian,
> 	We noticed that on our kubernetes node utilizing IPVS, the estimation_timer() takes very long (>200sm as shown below). Such long delay on timer softirq causes long packet latency.  
> 
>           <idle>-0     [007] dNH. 25652945.670814: softirq_raise: vec=1 [action=TIMER]
> .....
>           <idle>-0     [007] .Ns. 25652945.992273: softirq_exit: vec=1 [action=TIMER]
> 
> 	The long latency is caused by the big service number (>50k) and large CPU number (>80 CPUs),
> 
> 	We tried to move the timer function into a kernel thread so that it will not block the system and seems solves our problem. Is this the right direction? If yes, we will do more testing and send out the RFC patch. If not, can you give us some suggestion?

	Using kernel thread is a good idea. For this to work, we can
also remove the est_lock and to use RCU for est_list.
The writers ip_vs_start_estimator() and ip_vs_stop_estimator() already
run under common mutex __ip_vs_mutex, so they not need any
synchronization. We need _bh lock usage in estimation_timer().
Let me know if you need any help with the patch.

Regards

--
Julian Anastasov <ja@ssi.bg>
