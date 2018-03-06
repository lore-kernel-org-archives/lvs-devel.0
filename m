From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] ipvs: use true and false for boolean values
Date: Tue, 6 Mar 2018 11:40:54 +0100
Message-ID: <20180306104054.glcbnnqbyb5ztctk@salvia>
References: <20180305213557.GA12365@embeddedor.com>
 <20180306080208.xxz27gffcd7z5fqi@verge.net.au>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20180306080208.xxz27gffcd7z5fqi@verge.net.au>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: "Gustavo A. R. Silva" <garsilva@embeddedor.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

On Tue, Mar 06, 2018 at 09:02:08AM +0100, Simon Horman wrote:
> On Mon, Mar 05, 2018 at 03:35:57PM -0600, Gustavo A. R. Silva wrote:
> > Assign true or false to boolean variables instead of an integer value.
> > 
> > This issue was detected with the help of Coccinelle.
> > 
> > Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
> 
> Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> Pablo, could you take this one?

Applied, thanks Simon!
