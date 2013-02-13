From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL nf] IPVS fixes #2
Date: Wed, 13 Feb 2013 21:13:01 +0100
Message-ID: <20130213201301.GA7245@localhost>
References: <1360113878-31051-1-git-send-email-horms@verge.net.au>
 <20130207181213.GA18181@localhost>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130207181213.GA18181@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Daniel Borkmann <dborkman@redhat.com>

Hi again Simon,

On Thu, Feb 07, 2013 at 07:12:13PM +0100, Pablo Neira Ayuso wrote:
> On Wed, Feb 06, 2013 at 10:24:37AM +0900, Simon Horman wrote:
> > Hi Pablo,
> > 
> > Another fix. This one seems suitable for stable all the way back to
> > 2.6.34. I suspect this change may not apply cleanly all the way back there.
> > Please let me know if I should prepare some backports.

While reviewing patches that I'll pass to -stable, I noticed that:

4b47bc9 ipvs: sctp: fix checksumming on snat and dnat handlers

depends on:

commit d4383f04d145cce8b855c463f40020639ef83ea0
Author: Jesper Dangaard Brouer <brouer@redhat.com>
Date:   Wed Sep 26 14:07:17 2012 +0200

    ipvs: API change to avoid rescan of IPv6 exthdr

which is too big to add as dependency (it does not fulfill -stable
rule of not bigger patches than 100 lines).

If you want to me pass this sctp fix to -stable, you or Daniel will
have to send me a backport.

Regards.
