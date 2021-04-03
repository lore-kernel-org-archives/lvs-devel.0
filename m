From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next] netfilter: ipvs: do not printk on netns creation
Date: Sat, 3 Apr 2021 20:17:51 +0200
Message-ID: <20210403181751.GA4780@salvia>
References: <20210330064232.11960-1-fw@strlen.de>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20210330064232.11960-1-fw@strlen.de>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Florian Westphal <fw@strlen.de>
Cc: netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, ja@ssi.bg, horms@verge.net.au

On Tue, Mar 30, 2021 at 08:42:32AM +0200, Florian Westphal wrote:
> This causes dmesg spew during normal operation, so remove this.

Applied, thanks
