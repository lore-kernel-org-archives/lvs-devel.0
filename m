From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL nf] IPVS Fixes for v3.19
Date: Tue, 3 Feb 2015 12:47:17 +0100
Message-ID: <20150203114717.GA4934@salvia>
References: <1422580938-31520-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1422580938-31520-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
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

Regarding -stable. This seems to apply cleanly to:

3.10.x
3.12.x
3.14.x
3.18.x

Not compiled tested yet, just clean application.

Lower versions need some backporting, I leave this to you to evaluate
if it is worth the effort.

Thanks!
