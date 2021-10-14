From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next v2 0/4] netfilter: ipvs: remove unneeded hook
 wrappers
Date: Thu, 14 Oct 2021 23:02:53 +0200
Message-ID: <YWia/ZWkCbsa3iUm@salvia>
References: <20211012172959.745-1-fw@strlen.de>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20211012172959.745-1-fw@strlen.de>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Florian Westphal <fw@strlen.de>
Cc: netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, ja@ssi.bg, horms@verge.net.au

On Tue, Oct 12, 2021 at 07:29:55PM +0200, Florian Westphal wrote:
> V2: Patch 4/4 had a bug that would enter ipv6 branch for
> ipv4 packets, fix that.
> 
> This series reduces the number of different hook function
> implementations by merging the ipv4 and ipv6 hooks into
> common code.

Series applied, thanks.
