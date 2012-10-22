From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL nf-next] IPVS for 3.7 #2
Date: Mon, 22 Oct 2012 12:55:57 +0200
Message-ID: <20121022105557.GA16283@1984>
References: <1348800904-23902-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1348800904-23902-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Hans Schillstrom <hans@schillstrom.com>, Jesper Dangaard Brouer <brouer@redhat.com>

Hi Simon, Jesper,

On Fri, Sep 28, 2012 at 11:54:57AM +0900, Simon Horman wrote:
> Hi Pablo,
> 
> please consider the following enhancements to IPVS for inclusion in 3.7.
> 
> ----------------------------------------------------------------
> The following changes since commit 82c93fcc2e1737fede2752520f1bf8f4de6304d8:
> 
>   x86: bpf_jit_comp: add XOR instruction for BPF JIT (2012-09-24 16:54:35 -0400)
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git master

I've pulled this now that net-next is back open.

Please, next time re-submit again if you miss the merge window.

BTW, I expect one follow-up patch to move ipv6_find_hdr to
net/ipv6/netfilter.c (so you don't need to depend on ip6_tables for
just one single function).

Thanks a lot!
