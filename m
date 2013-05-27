From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: Fix reuse connection if real server is dead
Date: Tue, 28 May 2013 08:48:52 +0900
Message-ID: <20130527234849.GA8096@verge.net.au>
References: <1369523799-27082-1-git-send-email-horms@verge.net.au>
 <1369523799-27082-2-git-send-email-horms@verge.net.au>
 <20130527114911.GA30491@localhost>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130527114911.GA30491@localhost>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Grzegorz Lyczba <grzegorz.lyczba@gmail.com>

On Mon, May 27, 2013 at 01:49:11PM +0200, Pablo Neira Ayuso wrote:
> On Sun, May 26, 2013 at 08:16:39AM +0900, Simon Horman wrote:
> > From: Grzegorz Lyczba <grzegorz.lyczba@gmail.com>
> > 
> > Expire cached connection for new TCP/SCTP connection if real server is down
> 
> Applied, thanks Simon.
> 
> I have mangled the description to insist on the fact that newly
> (reused) connections break as they will be directed to the dead
> server.

Thanks.
