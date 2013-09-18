From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCHv2 net 0/4] IPVS fixes for corner cases
Date: Wed, 18 Sep 2013 14:46:27 -0500
Message-ID: <20130918194625.GA8827@verge.net.au>
References: <1378974070-9372-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1378974070-9372-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

On Thu, Sep 12, 2013 at 11:21:06AM +0300, Julian Anastasov wrote:
> 	The patchset contains fixes for races during
> dest and service deletion caused from the recent RCU changes.
> 
> 	The last change is required if CPU 0 can be missing
> from the mask of possible CPUs. Otherwise, it can be
> considered a non-fatal change.
> 
> v2:
> * do not remove rcu_barrier() in "ipvs: make the service replacement
> more robust", we should wait RCU callbacks in LBLC and LBLCR.
> Non-fix change will remove it later.

Thanks, I have queued these up and sent a pull-request to Pablo.
