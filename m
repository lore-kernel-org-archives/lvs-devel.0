From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL nf-next] IPVS
Date: Mon, 7 Nov 2011 09:29:56 +0100
Message-ID: <20111107082956.GA32329@1984>
References: <1319160783-28422-1-git-send-email-horms@verge.net.au>
 <20111021072715.GA842@1984>
 <20111107030659.GA24405@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111107030659.GA24405@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Krzysztof Wilczynski <krzysztof.wilczynski@linux.com>

Hi Simon,

On Mon, Nov 07, 2011 at 12:07:01PM +0900, Simon Horman wrote:
> Hi Pablo,
> 
> I am a little confused. The nf-next branch seems to have disappeared.
> 
> Could you consider pulling git://github.com/horms/ipvs-next.git master
> to get the following changes that were in your nf-next branch.

I was late to get it into net-next. Since net-next became net after
the 3.1 release, my moved those changes to net to get it into 3.2
once Linus announced that the merge window was opened again.

> Or would
> you like me to rebase the ipvs patches (9 or the 11 changes below) on
> top of git://1984.lsi.us.es/net-next/.git master ?

They are already in net davem's tree, they will be included in the
upcoming 3.2 release.

http://git.kernel.org/?p=linux%2Fkernel%2Fgit%2Fdavem%2Fnet.git&a=search&h=HEAD&st=commit&s=Neira
