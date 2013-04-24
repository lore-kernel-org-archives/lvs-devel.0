From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL nf-next v2] IPVS fixes for v3.10
Date: Thu, 25 Apr 2013 01:42:06 +0200
Message-ID: <20130424234206.GA6447@localhost>
References: <1366686240-23493-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1366686240-23493-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Dan Carpenter <dan.carpenter@oracle.com>

On Tue, Apr 23, 2013 at 12:03:51PM +0900, Simon Horman wrote:
> Hi Pablo,
> 
> this is a revision of a previous pull request.
> The previous pull request contained one fix-all patch.
> As per your request it has been split into a number of separate patches.
> This request also includes several new patches that fix
> yet more problems flagged by static analysis.
> 
> Separately, I have also posted the following SCTP patch
> "[PATCH] sctp: Correct type and usage of sctp_end_cksum()"
> 
> With this series and the above patch applied I
> believe that IPVS is now sparse-clean.
> 
> Much thanks to Julian Anastasov for his patience, and
> Dan Carpenter and Hans Schillstrom for their help.

Pulled, thanks Simon!
