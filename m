From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 0/2] Changes for PMTU Discovery
Date: Mon, 23 Jul 2012 15:46:09 +0900
Message-ID: <20120723064609.GJ6603@verge.net.au>
References: <1342774793-29234-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1342774793-29234-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

On Fri, Jul 20, 2012 at 11:59:51AM +0300, Julian Anastasov wrote:
> 	This patchset implements PMTU Discovery for TUN
> packets and option to disable it.
> 
> Julian Anastasov (2):
>   ipvs: implement passive PMTUD for IPIP packets
>   ipvs: add pmtu_disc option to disable IP DF for TUN packets
> 
>  include/net/ip_vs.h             |   11 +++++
>  net/netfilter/ipvs/ip_vs_core.c |   76 ++++++++++++++++++++++++++++++++++-
>  net/netfilter/ipvs/ip_vs_ctl.c  |    8 ++++
>  net/netfilter/ipvs/ip_vs_xmit.c |   83 ++++++++++++++++++++++++++------------
>  4 files changed, 149 insertions(+), 29 deletions(-)

Thanks, I have applied these to ipvs-next.

There were some offsets when applying the patches
and a conflict in the last hunk of ip_vs_xmit.c (in the first patch).
Could you check to make sure everything went in ok?
