From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL] Second Round of IPVS Fixes for v3.20
Date: Tue, 24 Feb 2015 19:41:12 +0100
Message-ID: <20150224184112.GA32265@salvia>
References: <1424640300-30364-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1424640300-30364-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Sun, Feb 22, 2015 at 04:24:59PM -0500, Simon Horman wrote:
> Hi Pablo,
> 
> please consider this fix for v3.20.
> 
> This patch resolves some memory leaks in connection
> synchronisation code that date back to v2.6.39.

Pulled, thanks.

Applied cleanly starting 3.10 here.
