From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL nf-next] IPVS
Date: Tue, 19 Mar 2013 00:31:15 +0100
Message-ID: <20130318233115.GA23070@localhost>
References: <1363612543-9787-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1363612543-9787-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

Hi Simon,

On Mon, Mar 18, 2013 at 10:15:38PM +0900, Simon Horman wrote:
[...]
> ----------------------------------------------------------------
> IPVS enhancements for v3.10 from Julian Anastasov
> 
> ----------------------------------------------------------------
> Julian Anastasov (5):
>       ipvs: add backup_only flag to avoid loops
>       ipvs: remove extra rcu lock
>       ipvs: fix sctp chunk length order
>       ipvs: fix hashing in ip_vs_svc_hashkey
>       ipvs: fix some sparse warnings

I think that these three fixes:

ipvs: add backup_only flag to avoid loops
ipvs: remove extra rcu lock
ipvs: fix sctp chunk length order

should find their path to the net tree.

The remaining two sparse fixes should go to net-next.

I can manually apply these patch if you want to the corresponding
trees.
