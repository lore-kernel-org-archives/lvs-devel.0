From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] ipvs: avoid kfree_rcu without 2nd arg
Date: Thu, 2 Feb 2023 14:02:14 +0100
Message-ID: <Y9u0VuwiC3KGKOS7@salvia>
References: <20230201175653.114334-1-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20230201175653.114334-1-ja@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Uladzislau Rezki <urezki@gmail.com>

On Wed, Feb 01, 2023 at 07:56:53PM +0200, Julian Anastasov wrote:
> Avoid possible synchronize_rcu() as part from the
> kfree_rcu() call when 2nd arg is not provided.

Applied to nf-next, thanks
