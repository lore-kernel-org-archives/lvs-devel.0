From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] ipvs: Fix reuse connection if real server is dead
Date: Mon, 27 May 2013 13:49:11 +0200
Message-ID: <20130527114911.GA30491@localhost>
References: <1369523799-27082-1-git-send-email-horms@verge.net.au>
 <1369523799-27082-2-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1369523799-27082-2-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Grzegorz Lyczba <grzegorz.lyczba@gmail.com>

On Sun, May 26, 2013 at 08:16:39AM +0900, Simon Horman wrote:
> From: Grzegorz Lyczba <grzegorz.lyczba@gmail.com>
> 
> Expire cached connection for new TCP/SCTP connection if real server is down

Applied, thanks Simon.

I have mangled the description to insist on the fact that newly
(reused) connections break as they will be directed to the dead
server.
