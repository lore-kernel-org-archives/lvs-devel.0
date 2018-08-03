From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net v2 0/2] fix glitch in IPVS /proc handlers
Date: Fri, 3 Aug 2018 12:40:24 +0200
Message-ID: <20180803104024.ccfjhl6ybtcnhjxp@salvia>
References: <20180731160333.12215-1-mcroce@redhat.com>
 <20180731162822.egqgbh6rbekoqvqk@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20180731162822.egqgbh6rbekoqvqk@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Matteo Croce <mcroce@redhat.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>

On Tue, Jul 31, 2018 at 06:28:22PM +0200, Simon Horman wrote:
> On Tue, Jul 31, 2018 at 06:03:31PM +0200, Matteo Croce wrote:
> > Fix a bug which shows negative values in IPVS /proc handlers.
> > Also add an helper function to calculate a time delta
> > 
> > Matteo Croce (2):
> >   jiffies: add utility function to calculate delta in ms
> >   ipvs: don't show negative times in ip_vs_conn
> 
> Acked-by: Simon Horman <horms@verge.net.au>
> 
> Pablo, please consider taking these via the nf tree.

Applied, thanks Simon.
