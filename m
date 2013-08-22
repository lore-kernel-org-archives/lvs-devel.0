From: Julian Anastasov <ja@ssi.bg>
Subject: Re: ipvsadm: One-packet scheduling with UDP service is unstable
Date: Thu, 22 Aug 2013 17:14:02 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1308221558160.2993@ja.ssi.bg>
References: <CAJiejCQPa7V703RwOeWPpbQMJQvfswRn+pvTKFmNdeU05RU3SQ@mail.gmail.com> <alpine.LFD.2.00.1308220925340.1727@ja.ssi.bg> <CAJiejCSdfBKC3c1dqya55R5T0VBCTm3qaM6nL-CY+H0o5hbwoA@mail.gmail.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJiejCSdfBKC3c1dqya55R5T0VBCTm3qaM6nL-CY+H0o5hbwoA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Drunkard Zhang <gongfan193@gmail.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org, linux-kernel <linux-kernel@vger.kernel.org>


	Hello,

On Thu, 22 Aug 2013, Drunkard Zhang wrote:

> 2013/8/22 Julian Anastasov <ja@ssi.bg>:
> >
> >         No kernel options should be related to OPS. I assume
> > you are not using the SH scheduler. Make sure the OPS mode
> > is properly applied to the virtual service, check for "ops"
> > in the configuration:
> >
> > cat /proc/net/ip_vs
> 
> Still no lucky here, ops is set in running config, but it's not like
> that in real world.
> 
> vs3 ~ # cat /proc/net/ip_vs
> IP Virtual Server version 1.2.1 (size=1024)
> Prot LocalAddress:Port Scheduler Flags
>   -> RemoteAddress:Port Forward Weight ActiveConn InActConn
> UDP  96A46478:0202 wrr ops

>   -> 96A46450:0202      Route   25     0          1

	The OPS connections are accounted in InActConn
for a very short period, they live up to 1 jiffie, eg. 10ms.
Also, WRR should be reliable for OPS while other
schedulers (eg. *LC) are not suitable.

> And the traffic routed to each realserver didn't following weight I
> set, it's routed pretty much one to one. I got 17 udp sources sending
> to 16 different realservers, the others are bonding to another VIP.
> 
> Prot LocalAddress:Port                 CPS    InPPS   OutPPS    InBPS   OutBPS
>   -> RemoteAddress:Port
> UDP  x.x.x.120:514                 0    67622        0 12339373        0
>   -> x.x.x.65:514                  0       29        0     2895        0
>   -> x.x.x.66:514                  0      225        0    21850        0

	Do you see the same problem with ipvsadm -Ln --stats ?
ipvsadm -Z may be needed to zero the stats after restoring all
rules. "Conns" counter in stats should be according to WRR
weights, it shows the scheduler decisions.

	In your rates listing CPS 0 is confusing, even for OPS.
Is it from the new ipvsadm?

Regards

--
Julian Anastasov <ja@ssi.bg>
