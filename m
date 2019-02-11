From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] ipvs: Use struct_size() helper
Date: Tue, 12 Feb 2019 00:40:33 +0100
Message-ID: <20190211234033.wwpygxamqwvsuxmv@salvia>
References: <20190208004456.GA15845@embeddedor>
 <20190208095648.la4ushbjxkqgqzb6@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20190208095648.la4ushbjxkqgqzb6@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: "Gustavo A. R. Silva" <gustavo@embeddedor.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

On Fri, Feb 08, 2019 at 10:56:48AM +0100, Simon Horman wrote:
> On Thu, Feb 07, 2019 at 06:44:56PM -0600, Gustavo A. R. Silva wrote:
> > One of the more common cases of allocation size calculations is finding
> > the size of a structure that has a zero-sized array at the end, along
> > with memory for some number of elements for that array. For example:
> > 
> > struct foo {
> >     int stuff;
> >     struct boo entry[];
> > };
> > 
> > size = sizeof(struct foo) + count * sizeof(struct boo);
> > instance = alloc(size, GFP_KERNEL)
> > 
> > Instead of leaving these open-coded and prone to type mistakes, we can
> > now use the new struct_size() helper:
> > 
> > size = struct_size(instance, entry, count);
> > 
> > This code was detected with the help of Coccinelle.
> > 
> > Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
> 
> Acked-by: Simon Horman <horms+renesas@verge.net.au>
> 
> Pablo, could you consider applying this?

Applied, thanks!
