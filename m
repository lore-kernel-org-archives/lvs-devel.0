From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 2/2] ipvs: Fix reuse connection if real server is dead
Date: Fri, 24 May 2013 12:01:15 +0900
Message-ID: <20130524030115.GB10536@verge.net.au>
References: <1369202209-18570-1-git-send-email-horms@verge.net.au>
 <1369202209-18570-3-git-send-email-horms@verge.net.au>
 <20130523113435.GA30773@localhost>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130523113435.GA30773@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Grzegorz Lyczba <grzegorz.lyczba@gmail.com>

On Thu, May 23, 2013 at 01:34:35PM +0200, Pablo Neira Ayuso wrote:
> Hi Simon,
> 
> On Wed, May 22, 2013 at 02:56:49PM +0900, Simon Horman wrote:
> > From: Grzegorz Lyczba <grzegorz.lyczba@gmail.com>
> > 
> > Expire cached connection for new TCP/SCTP connection if real server is down
> 
> We can get this fix into 3.10-rc.
> 
> Please, address the comestic cleanups proposed by Sergei and resubmit
> against the nf tree.

Sure, will do.
