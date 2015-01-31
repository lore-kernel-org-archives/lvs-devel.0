From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL nf] IPVS Fixes for v3.19
Date: Sat, 31 Jan 2015 21:40:57 +0100
Message-ID: <20150131204057.GA4866@salvia>
References: <1422580938-31520-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1422580938-31520-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Fri, Jan 30, 2015 at 10:22:17AM +0900, Simon Horman wrote:
> Hi Pablo,
> 
> please consider this fix for v3.19.
> 
> It resolves a crash in xfrm reported by Florian Wiessner.
> 
> I believe this problem manifests since 0a5ebb8000c5 ("ipv4: Pass explicit
> daddr arg to ip_send_reply().") which was included in v2.6.39.
> 
> Julian reports that the patch has been tested on net tree (Dec 7), 3.14.25,
> 3.12.33, 3.10.61. 3.4.104 needs a modified fix that resolves rejects. It
> applies with little fuzz on 3.2.64. Please let us know if we should post
> separate 3.2 and 3.4 patches.

Pulled, thanks Simon.
