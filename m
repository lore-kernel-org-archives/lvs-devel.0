From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH V2 2/2] ipvs: Extend MTU check to account for IPv6 NAT
 defrag changes
Date: Tue, 28 Aug 2012 22:10:00 +0200 (MEST)
Message-ID: <Pine.GSO.4.63.1208282209030.28772@stinky-local.trash.net>
References: <20120828142051.11475.63775.stgit@dragon> <20120828142248.11475.15917.stgit@dragon>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20120828142248.11475.15917.stgit@dragon>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Hans Schillstrom <hans@schillstrom.com>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org

On Tue, 28 Aug 2012, Jesper Dangaard Brouer wrote:

> This patch is necessary, to make IPVS work, after Patrick McHardys
> IPv6 NAT defragmentation changes.
>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

I've folded this into the defragmentation patch to avoid temporary 
breakage. Thanks Jesper.
