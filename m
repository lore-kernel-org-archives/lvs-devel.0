From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 0/4] IPVS: sysctl Documentation and Various Clean-Ups
Date: Mon, 26 Sep 2011 08:39:02 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1109260829190.1530@ja.ssi.bg>
References: <1317000233-11169-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1317000233-11169-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Patrick McHardy <kaber@trash.net>


	Hello,

On Mon, 26 Sep 2011, Simon Horman wrote:

> Hi,
> 
> patch one of this series adds some missing entries to the sysctl
> documentation. Julian, I would appreciate a review of this change.

Acked-by: Julian Anastasov <ja@ssi.bg>

	for all changes, with one minor problem in patch 1
for sync_version: 'sh[uo]ld be used [Use this ]when'

> The remaining three patches are minor code clean-ups flagged
> by gcc 4.6.1.
> 
> My intention for this post is to solicit review.
> I intend to post a pull request separately at a later date.

Regards

--
Julian Anastasov <ja@ssi.bg>
