From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: Fix race conditions in lblcr scheduler
Date: Tue, 19 Aug 2008 17:41:06 +1000
Message-ID: <20080819074103.GB4387@verge.net.au>
References: <alpine.LNX.1.10.0808180052160.12259@titan.stealer.net> <20080818233243.GC7785@verge.net.au> <alpine.LNX.1.10.0808190140180.12259@titan.stealer.net> <20080819004129.GC23626@verge.net.au> <alpine.LNX.1.10.0808190814580.12259@titan.stealer.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.1.10.0808190814580.12259@titan.stealer.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sven Wegener <sven.wegener@stealer.net>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, wensong@linux-vs.org, ja@ssi.bg

On Tue, Aug 19, 2008 at 08:16:19AM +0200, Sven Wegener wrote:
> We can't access the cache entry outside of our critical read-locked region,
> because someone may free that entry. Also getting an entry under read lock,
> then locking for write and trying to delete that entry looks fishy, but should
> be no problem here, because we're only comparing a pointer. Also there is no
> need for our own rwlock, there is already one in the service structure for use
> in the schedulers.
> 
> Signed-off-by: Sven Wegener <sven.wegener@stealer.net>

Thanks, applied to lvs-2.6
