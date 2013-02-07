From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL nf] IPVS fixes #2
Date: Thu, 7 Feb 2013 19:12:13 +0100
Message-ID: <20130207181213.GA18181@localhost>
References: <1360113878-31051-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1360113878-31051-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Daniel Borkmann <dborkman@redhat.com>

On Wed, Feb 06, 2013 at 10:24:37AM +0900, Simon Horman wrote:
> Hi Pablo,
> 
> Another fix. This one seems suitable for stable all the way back to
> 2.6.34. I suspect this change may not apply cleanly all the way back there.
> Please let me know if I should prepare some backports.
> 
> ----------------------------------------------------------------
> The following changes since commit b425df4cdd953a400d814b4474c9d3ec04481858:
> 
>   ipvs: freeing uninitialized pointer on error (2013-01-28 10:14:37 +0900)
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes2-for-v3.8

Pulled, thanks Simon.
