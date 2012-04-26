From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2 0/2] Fixes for netns initializations
Date: Thu, 26 Apr 2012 15:24:07 +0900
Message-ID: <20120426062407.GF13141@verge.net.au>
References: <1335302999-10702-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1335302999-10702-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

On Wed, Apr 25, 2012 at 12:29:57AM +0300, Julian Anastasov wrote:
> 	This changeset fixes problems with failed netns
> initializations. Hans should provide similar fix for
> LBLC and LBLCR. This is for the stable tree.
> 
> Julian Anastasov (2):
>   ipvs: reset ipvs pointer in netns
>   ipvs: add check in ftp for initialized core
> 
>  net/netfilter/ipvs/ip_vs_core.c |    2 ++
>  net/netfilter/ipvs/ip_vs_ftp.c  |    2 ++
>  2 files changed, 4 insertions(+), 0 deletions(-)

Thanks, both patches pushed to ipvs.
I plan to will wait for Hans's fixes to be finalised
before sending a pull request.
