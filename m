From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next] ipvs: add sync_persist_mode flag
Date: Wed, 26 Jun 2013 17:57:11 +0900
Message-ID: <20130626085711.GA23429@verge.net.au>
References: <1372103081-1818-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1372103081-1818-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

On Mon, Jun 24, 2013 at 10:44:41PM +0300, Julian Anastasov wrote:
> Add sync_persist_mode flag to reduce sync traffic
> by syncing only persistent templates.

Thanks, I have applied this to ipvs-next.

> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> Tested-by: Aleksey Chudov <aleksey.chudov@gmail.com>
> ---
>  Documentation/networking/ipvs-sysctl.txt |   13 +++++++++++++
>  include/net/ip_vs.h                      |   11 +++++++++++
>  net/netfilter/ipvs/ip_vs_ctl.c           |    7 +++++++
>  net/netfilter/ipvs/ip_vs_sync.c          |   12 ++++++++++++
>  4 files changed, 43 insertions(+), 0 deletions(-)
