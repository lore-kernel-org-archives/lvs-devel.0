From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter, ipvs: Avoid undefined order of evaluation
 in assignments to struct nf_conn *
Date: Thu, 02 Jun 2011 14:59:33 +0200
Message-ID: <4DE78935.2030904@netfilter.org>
References: <alpine.LNX.2.00.1105292011450.4411@swampdragon.chaosbits.net> <20110529232337.GD5856@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110529232337.GD5856@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: Jesper Juhl <jj@chaosbits.net>, linux-kernel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Patrick McHardy <kaber@trash.net>, Julian Anastasov <ja@ssi.bg>, Wensong Zhang <wensong@linux-vs.org>

On 30/05/11 01:23, Simon Horman wrote:
> Acked-by: Simon Horman <horms@verge.net.au>

applied, thanks
