From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next] netfilter: ipvs: Remove useless ipvsh param of
 frag_safe_skb_hp
Date: Wed, 6 Dec 2017 09:35:43 +0100
Message-ID: <20171206083543.GA21940@salvia>
References: <1510585098-27428-1-git-send-email-gfree.wind@vip.163.com>
 <20171122181428.qaqyodgflfmhtm25@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171122181428.qaqyodgflfmhtm25@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: gfree.wind@vip.163.com, wensong@linux-vs.org, ja@ssi.bg, kadlec@blackhole.kfki.hu, fw@strlen.de, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

On Wed, Nov 22, 2017 at 07:14:28PM +0100, Simon Horman wrote:
> On Mon, Nov 13, 2017 at 10:58:18PM +0800, gfree.wind@vip.163.com wrote:
> > From: Gao Feng <gfree.wind@vip.163.com>
> > 
> > The param of frag_safe_skb_hp, ipvsh, isn't used now. So remove it and
> > update the callers' codes too.
> > 
> > Signed-off-by: Gao Feng <gfree.wind@vip.163.com>
> > ---
> >  Simon advise me send the patch to netfilter group
> 
> Acked-by: Simon Horman <horms+renesas@verge.net.au>
> 
> Pablo, can you take this through the nf-next tree?

Applied, thanks.
