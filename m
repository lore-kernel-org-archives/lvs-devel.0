From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [GIT PULL nf-next] IPVS for 3.7 #2
Date: Mon, 22 Oct 2012 13:53:50 +0200
Message-ID: <1350906830.22194.451.camel@localhost>
References: <1348800904-23902-1-git-send-email-horms@verge.net.au>
	 <20121022105557.GA16283@1984>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20121022105557.GA16283@1984>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Hans Schillstrom <hans@schillstrom.com>

On Mon, 2012-10-22 at 12:55 +0200, Pablo Neira Ayuso wrote:
> Hi Simon, Jesper,
> 
> On Fri, Sep 28, 2012 at 11:54:57AM +0900, Simon Horman wrote:
> > Hi Pablo,
> > 
> > please consider the following enhancements to IPVS for inclusion in 3.7.
> > 
> > ----------------------------------------------------------------
> > The following changes since commit 82c93fcc2e1737fede2752520f1bf8f4de6304d8:
> > 
> >   x86: bpf_jit_comp: add XOR instruction for BPF JIT (2012-09-24 16:54:35 -0400)
> > 
> > are available in the git repository at:
> > 
> >   git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git master
> 
> I've pulled this now that net-next is back open.
> 
> Please, next time re-submit again if you miss the merge window.

I did plan to resubmit (incl. with the changes mentioned below)
But thanks a lot for pulling this.

> BTW, I expect one follow-up patch to move ipv6_find_hdr to
> net/ipv6/netfilter.c (so you don't need to depend on ip6_tables for
> just one single function).
> 
> Thanks a lot!

Before finishing this email, Yuanhan Liu <yuanhan.liu(at)intel.com>
kicked by butt, and pointed out a build error, when compiling *without*
CONFIG_IP_VS_IPV6.  I'm really really really sorry for this, I'll
quickly submit a patch fixing this!



