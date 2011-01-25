From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] netfilter: ipvs: fix compiler warnings
Date: Tue, 25 Jan 2011 15:05:36 +1000
Message-ID: <20110125050535.GB7183@verge.net.au>
References: <1295930418-14980-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1295930418-14980-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Changli Gao <xiaosuo@gmail.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

On Tue, Jan 25, 2011 at 12:40:18PM +0800, Changli Gao wrote:
> Fix compiler warnings when IP_VS_DBG() isn't defined.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Thanks, I will queue this up for when nf-next-2.6 is open again.
