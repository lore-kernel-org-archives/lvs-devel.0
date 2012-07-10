From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: generalize app registration in netns
Date: Tue, 10 Jul 2012 17:58:37 +0900
Message-ID: <20120710085836.GB12776@verge.net.au>
References: <1341682347-4843-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1341682347-4843-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

On Sat, Jul 07, 2012 at 08:32:27PM +0300, Julian Anastasov wrote:
> 	Get rid of the ftp_app pointer and allow applications
> to be registered without adding fields in the netns_ipvs structure.

Thanks, I have also added this to my ipvs-next tree for inclusion in 3.6.

> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>  include/net/ip_vs.h            |    5 +--
>  net/netfilter/ipvs/ip_vs_app.c |   61 +++++++++++++++++++++++++++++----------
>  net/netfilter/ipvs/ip_vs_ftp.c |   21 +++----------
>  3 files changed, 52 insertions(+), 35 deletions(-)
