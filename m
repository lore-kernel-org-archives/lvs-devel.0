From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCHv2 net-next 0/4] update ipvs sysctl document
Date: Tue, 21 Feb 2017 22:01:44 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1702212154590.1840@ja.home.ssi.bg>
References: <1487313241-11361-1-git-send-email-liuhangbin@gmail.com> <1487579498-18967-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1487579498-18967-1-git-send-email-liuhangbin@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hangbin Liu <liuhangbin@gmail.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>, Simon Horman <horms@verge.net.au>


	Hello,

On Mon, 20 Feb 2017, Hangbin Liu wrote:

> Fix and add some new ipvs sysctl options. Also use tab instead of
> whitespaces to indent the descriptions.
> 
> V2: Fix some descriptions based on Julian's advice.
> 
> Hangbin Liu (4):
>   ipvs: fix sync_threshold description and add sync_refresh_period, sync_retries
>   ipvs: Document sysctl sync_qlen_max and sync_sock_size
>   ipvs: Document sysctl sync_ports
>   ipvs: Document sysctl pmtu_disc

	All patches look ok to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

	Simon, can we keep this patchset while in merge window?

>  Documentation/networking/ipvs-sysctl.txt | 68 ++++++++++++++++++++++++++++----
>  1 file changed, 60 insertions(+), 8 deletions(-)
> 
> -- 
> 2.5.5

Regards

--
Julian Anastasov <ja@ssi.bg>
