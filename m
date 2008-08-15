From: Simon Horman <horms@verge.net.au>
Subject: Re: [GIT] Please pull updates for IPVS
Date: Fri, 15 Aug 2008 11:02:37 +1000
Message-ID: <20080815010235.GD15825@verge.net.au>
References: <20080815001250.GC15825@verge.net.au> <20080814.172508.15803616.davem@davemloft.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080814.172508.15803616.davem@davemloft.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, sven.wegener@stealer.net, juliusv@google.com, wensong@linux-vs.org, ja@ssi.bg

On Thu, Aug 14, 2008 at 05:25:08PM -0700, David Miller wrote:
> From: Simon Horman <horms@verge.net.au>
> Date: Fri, 15 Aug 2008 10:12:52 +1000
> 
> > Julius, Sven and I would particularly like Julius' two changes to go
> > in. They add a new interface which is currently unused and thus the
> > likelihood of breakage seems low.
> 
> Actually these are the two changes that should not go in at this
> time.  This netlink stuff is a new feature, therefore not appropriate
> to merge outside of the merge window.
> 
> Bug fixes only now, please.

Hi Dave,

thanks for the clarification. In that case I believe that
all of these changes can wait.

