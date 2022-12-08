From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCHv7 0/6] ipvs: Use kthreads for stats
Date: Thu, 8 Dec 2022 13:17:20 +0100
Message-ID: <Y5HV0EpOrQtdU11y@salvia>
References: <20221122164604.66621-1-ja@ssi.bg>
 <Y5HTM6jY/ZRw+ar0@salvia>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Y5HTM6jY/ZRw+ar0@salvia>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Jiri Wiesner <jwiesner@suse.de>, yunhong-cgl jiang <xintian1976@gmail.com>, dust.li@linux.alibaba.com

On Thu, Dec 08, 2022 at 01:06:14PM +0100, Pablo Neira Ayuso wrote:
> On Tue, Nov 22, 2022 at 06:45:58PM +0200, Julian Anastasov wrote:
> > 	Hello,
> > 
> > 	This patchset implements stats estimation in kthread context.
> > It replaces the code that runs on single CPU in timer context every
> > 2 seconds and causing latency splats as shown in reports [1], [2], [3].
> > The solution targets setups with thousands of IPVS services, destinations
> > and multi-CPU boxes.
> 
> Series applied to nf-next, thanks.

Oh wait. I have to hold this back, I have a fundamental question:

[PATCHv7 4/6] ipvs: use kthreads for stats estimation

uses kthreads, these days the preferred interface for this is the
generic workqueue infrastructure.

Then, I can see patch:

 [PATCHv7 5/6] ipvs: add est_cpulist and est_nice sysctl vars

allows for CPU pinning which is also possible via sysfs.

Is there any particular reason for not using the generic workqueue
infrastructure? I could not find a reason in the commit logs.

Thanks.
