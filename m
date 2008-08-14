From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: Only call init_service, update_service and
	done_service for schedulers if defined
Date: Thu, 14 Aug 2008 14:45:46 +1000
Message-ID: <20080814044544.GB13993@verge.net.au>
References: <alpine.LNX.1.10.0808140034210.12259@titan.stealer.net>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.1.10.0808140034210.12259@titan.stealer.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sven Wegener <sven.wegener@stealer.net>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, wensong@linux-vs.org, ja@ssi.bg

On Thu, Aug 14, 2008 at 12:42:55AM +0200, Sven Wegener wrote:
> There are schedulers that only schedule based on data available in the service
> or destination structures and they don't need any persistent storage or
> initialization routine. These schedulers currently provide dummy functions for
> the init_service, update_service and/or done_service functions. For the
> init_service and done_service cases we already have code that only calls these
> functions, if the scheduler provides them. Do the same for the update_service
> case and remove the dummy functions from all schedulers.

Hi Sven,

I'm fine with this change, but it doesn't apply against net-2.6.
