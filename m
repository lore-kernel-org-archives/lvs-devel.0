From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] ipvs: fix sparse warnings reported by kbuild test robot
Date: Wed, 17 Apr 2013 14:07:12 +0200
Message-ID: <20130417120712.GA4177@localhost>
References: <1366165082-11156-1-git-send-email-horms@verge.net.au>
 <1366165082-11156-2-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1366165082-11156-2-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

Hi,

On Wed, Apr 17, 2013 at 11:18:02AM +0900, Simon Horman wrote:
> From: Julian Anastasov <ja@ssi.bg>
> 
> Some are from recent commits. Add comments
> that we provide both netmask and prefix len in svc
> netmask.

OK, all these changes have in common that they are mostly fixing
sparse warnings, but these need to be split into several patches
including a description of what that is fixing.

I want these fixes in my tree, but this has to be done in a better
way

Please, resubmit.
