From: Simon Horman <horms@verge.net.au>
Subject: Re: [GIT PULL nf-next-2.6] ipvs namespaces
Date: Thu, 13 Jan 2011 10:57:09 +0900
Message-ID: <20110113015707.GA7082@verge.net.au>
References: <1294294578-8601-1-git-send-email-horms@verge.net.au>
 <4D2E0F32.8020602@netfilter.org>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4D2E0F32.8020602@netfilter.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>

On Wed, Jan 12, 2011 at 09:29:38PM +0100, Pablo Neira Ayuso wrote:
> Hi Simon,
> 
> On 06/01/11 07:15, Simon Horman wrote:
> > Hi Patrick,
> > 
> > please consider pulling
> > git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git master
> > in order to get the netns changes to IPVS from Hans Schillstrom.
> 
> I'm hitting some conflicts when pulling from your tree.
> 
> >From git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6
>  * branch            master     -> FETCH_HEAD
> Auto-merging include/linux/netfilter.h
> Auto-merging include/linux/skbuff.h
> Auto-merging include/net/netfilter/nf_conntrack.h
> Auto-merging net/core/skbuff.c
> Auto-merging net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
> Auto-merging net/ipv6/netfilter/nf_conntrack_reasm.c
> Auto-merging net/netfilter/core.c
> Auto-merging net/netfilter/ipvs/ip_vs_ctl.c
> CONFLICT (content): Merge conflict in net/netfilter/ipvs/ip_vs_ctl.c

Hi Pablo,

I've sent a fresh series "[PATCH 00/22] ipvs namespaces v3.3" that should
resolve the conficts (I think).  More details in the cover email for that
series.

