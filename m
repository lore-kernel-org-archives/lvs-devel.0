From: Simon Horman <horms@verge.net.au>
Subject: Re: [GIT PULL nf-next] IPVS
Date: Tue, 19 Mar 2013 09:38:40 +0900
Message-ID: <20130319003840.GG15718@verge.net.au>
References: <1363612543-9787-1-git-send-email-horms@verge.net.au>
 <20130318233115.GA23070@localhost>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130318233115.GA23070@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Tue, Mar 19, 2013 at 12:31:15AM +0100, Pablo Neira Ayuso wrote:
> Hi Simon,
> 
> On Mon, Mar 18, 2013 at 10:15:38PM +0900, Simon Horman wrote:
> [...]
> > ----------------------------------------------------------------
> > IPVS enhancements for v3.10 from Julian Anastasov
> > 
> > ----------------------------------------------------------------
> > Julian Anastasov (5):
> >       ipvs: add backup_only flag to avoid loops
> >       ipvs: remove extra rcu lock
> >       ipvs: fix sctp chunk length order
> >       ipvs: fix hashing in ip_vs_svc_hashkey
> >       ipvs: fix some sparse warnings
> 
> I think that these three fixes:
> 
> ipvs: add backup_only flag to avoid loops
> ipvs: remove extra rcu lock
> ipvs: fix sctp chunk length order
> 
> should find their path to the net tree.
> 
> The remaining two sparse fixes should go to net-next.
> 
> I can manually apply these patch if you want to the corresponding
> trees.

Thanks. I'll send two fresh pull requests shortly.
