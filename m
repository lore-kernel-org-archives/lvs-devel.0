From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvsadm: Fix list daemon to show backup daemon
Date: Fri, 6 Jun 2014 10:24:09 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1406061018180.12067@ja.home.ssi.bg>
References: <1400642071-10408-1-git-send-email-rohara@redhat.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1400642071-10408-1-git-send-email-rohara@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ryan O'Hara <rohara@redhat.com>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Tue, 20 May 2014, Ryan O'Hara wrote:

> The list_daemon function in ipvsadm.c will show the master daemon
> twice, but never the backup daemon. This patch replaces the redundant
> check for IP_VS_STATE_MASTER with a check for IP_VS_STATE_BACKUP, then
> prints the appropriate message.
> 
> Signed-off-by: Ryan O'Hara <rohara@redhat.com>

	In case you still wait for ack:

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  ipvsadm.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/ipvsadm.c b/ipvsadm.c
> index 4c83a8b..755827f 100644
> --- a/ipvsadm.c
> +++ b/ipvsadm.c
> @@ -1732,8 +1732,8 @@ static void list_daemon(void)
>  		if (u[i].state & IP_VS_STATE_MASTER)
>  			printf("master sync daemon (mcast=%s, syncid=%d)\n",
>  			       u[i].mcast_ifn, u[i].syncid);
> -		if (u[i].state & IP_VS_STATE_MASTER)
> -			printf("master sync daemon (mcast=%s, syncid=%d)\n",
> +		if (u[i].state & IP_VS_STATE_BACKUP)
> +			printf("backup sync daemon (mcast=%s, syncid=%d)\n",
>  			       u[i].mcast_ifn, u[i].syncid);
>  	}
>  	free(u);
> -- 
> 1.9.0

Regards

--
Julian Anastasov <ja@ssi.bg>
