From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL nf-next-2.6] ipvs namespaces
Date: Wed, 12 Jan 2011 21:29:38 +0100
Message-ID: <4D2E0F32.8020602@netfilter.org>
References: <1294294578-8601-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1294294578-8601-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>

Hi Simon,

On 06/01/11 07:15, Simon Horman wrote:
> Hi Patrick,
> 
> please consider pulling
> git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git master
> in order to get the netns changes to IPVS from Hans Schillstrom.

I'm hitting some conflicts when pulling from your tree.

From git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6
 * branch            master     -> FETCH_HEAD
Auto-merging include/linux/netfilter.h
Auto-merging include/linux/skbuff.h
Auto-merging include/net/netfilter/nf_conntrack.h
Auto-merging net/core/skbuff.c
Auto-merging net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
Auto-merging net/ipv6/netfilter/nf_conntrack_reasm.c
Auto-merging net/netfilter/core.c
Auto-merging net/netfilter/ipvs/ip_vs_ctl.c
CONFLICT (content): Merge conflict in net/netfilter/ipvs/ip_vs_ctl.c
