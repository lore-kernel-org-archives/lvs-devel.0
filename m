From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 1/1] IPVS: Modify the SH scheduler to use weights
Date: Wed, 7 Dec 2011 15:20:57 +0900
Message-ID: <20111207062057.GB5813@verge.net.au>
References: <1322604142-15514-1-git-send-email-mike@okcupid.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1322604142-15514-1-git-send-email-mike@okcupid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michael Maxim <mike@okcupid.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org

On Tue, Nov 29, 2011 at 05:02:22PM -0500, Michael Maxim wrote:
> Modify the algorithm to build the source hashing hash table to add
> extra slots for destinations with higher weight. This has the effect
> of allowing an IPVS SH user to give more connections to hosts that
> have been configured to have a higher weight.

Thanks, applied.
