From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCHv7 0/6] ipvs: Use kthreads for stats
Date: Thu, 8 Dec 2022 13:06:11 +0100
Message-ID: <Y5HTM6jY/ZRw+ar0@salvia>
References: <20221122164604.66621-1-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20221122164604.66621-1-ja@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Jiri Wiesner <jwiesner@suse.de>, yunhong-cgl jiang <xintian1976@gmail.com>, dust.li@linux.alibaba.com

On Tue, Nov 22, 2022 at 06:45:58PM +0200, Julian Anastasov wrote:
> 	Hello,
> 
> 	This patchset implements stats estimation in kthread context.
> It replaces the code that runs on single CPU in timer context every
> 2 seconds and causing latency splats as shown in reports [1], [2], [3].
> The solution targets setups with thousands of IPVS services, destinations
> and multi-CPU boxes.

Series applied to nf-next, thanks.
