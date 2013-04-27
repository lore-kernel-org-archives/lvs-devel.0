From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL ipvs] ipvs fixes for v3.9 #2
Date: Sat, 27 Apr 2013 20:00:50 +0200
Message-ID: <20130427180050.GA7622@localhost>
References: <1366941190-12135-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1366941190-12135-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans@schillstrom.com>

On Fri, Apr 26, 2013 at 10:53:09AM +0900, Simon Horman wrote:
> Hi Pablo,
> 
> I guess that it is too late in the cycle to get this fix into v3.9.
> If so could you please consider it for v3.10.

Pulled, thanks Simon.

Will try to get this into 3.9, this is fixing a hard crash after all.

> I would also like the patch considered for stable. It seems to be applicable
> to all kernel releases since the sip persistence engine was added
> by my in v2.6.37. In particular I have checked that it applies cleanly to:
> 
> 3.8.8 stable
> 3.4.41 longterm
> 3.2.43 longterm
> 3.0.74 longterm

Will do once the merge window closes and thing calm down a bit.
