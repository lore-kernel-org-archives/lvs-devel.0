From: Simon Horman <horms@verge.net.au>
Subject: Re: [RFC] ipvs: Keep track of backlog connections
Date: Wed, 1 Sep 2010 11:57:57 +0900
Message-ID: <20100901025756.GB9723@verge.net.au>
References: <alpine.LNX.2.00.1008311411190.5292@titan.stealer.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1008311411190.5292@titan.stealer.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sven Wegener <sven.wegener@stealer.net>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Tue, Aug 31, 2010 at 02:19:02PM +0200, Sven Wegener wrote:
> Hi all,
> 
> this patch has been sitting in my local repository for quite some time 
> now. The number of backlog connections helps diagnosing realserver related 
> overload and configuration problems. Is it worth merging? If yes, I'm 
> going to tidy it up and prepare the userspace portion for ipvsadm.

Hi Sven,

this seems like a good change to me.

