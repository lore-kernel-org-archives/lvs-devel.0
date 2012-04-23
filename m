From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2 7/8] ipvs: add support for sync threads
Date: Mon, 23 Apr 2012 21:54:16 +0900
Message-ID: <20120423125412.GD20296@verge.net.au>
References: <1334872199-8826-1-git-send-email-ja@ssi.bg>
 <1334872199-8826-8-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1334872199-8826-8-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Aleksey Chudov <aleksey.chudov@gmail.com>

On Fri, Apr 20, 2012 at 12:49:58AM +0300, Julian Anastasov wrote:
> 	Allow master and backup servers to use many threads
> for sync traffic. Add sysctl var "sync_ports" to define the
> number of threads. Every thread will use single UDP port,
> thread 0 will use the default port 8848 while last thread
> will use port 8848+sync_ports-1.
>=20
> 	The sync traffic for connections is scheduled to many
> master threads based on the cp address but one connection is
> always assigned to same thread to avoid reordering of the
> sync messages.
>=20
> 	Remove ip_vs_sync_switch_mode because this check
> for sync mode change is still risky. Instead, check for mode
> change under sync_buff_lock.
>=20
> 	Make sure the backup socks do not block on reading.
>=20
> Special thanks to Aleksey Chudov for helping in all tests.

[snip]

> @@ -397,31 +392,10 @@ get_curr_sync_buff(struct netns_ipvs *ipvs, uns=
igned long time)
>  	return sb;
>  }
> =20
> -/*
> - * Switch mode from sending version 0 or 1
> - *  - must handle sync_buf
> - */
> -void ip_vs_sync_switch_mode(struct net *net, int mode)
> +static inline int
> +select_master_thread_id(struct netns_ipvs *ipvs, struct ip_vs_conn *=
cp)
>  {
> -	struct netns_ipvs *ipvs =3D net_ipvs(net);
> -	struct ip_vs_sync_buff *sb;
> -
> -	spin_lock_bh(&ipvs->sync_buff_lock);
> -	if (!(ipvs->sync_state & IP_VS_STATE_MASTER))
> -		goto unlock;
> -	sb =3D ipvs->sync_buff;
> -	if (mode =3D=3D sysctl_sync_ver(ipvs) || !sb)
> -		goto unlock;
> -
> -	/* Buffer empty ? then let buf_create do the job  */
> -	if (sb->mesg->size <=3D sizeof(struct ip_vs_sync_mesg)) {
> -		ip_vs_sync_buff_release(sb);
> -		ipvs->sync_buff =3D NULL;
> -	} else
> -		sb_queue_tail(ipvs);
> -
> -unlock:
> -	spin_unlock_bh(&ipvs->sync_buff_lock);
> +	return ((int) cp >> (1 + ilog2(sizeof(*cp)))) & ipvs->threads_mask;
>  }

Hi Julian,

My gcc running on x86_64 doesn't seem to like this cast.

# gcc --version
gcc (Debian 4.6.3-1) 4.6.3
# make
=2E..
  CC      net/netfilter/ipvs/ip_vs_est.o
net/netfilter/ipvs/ip_vs_sync.c: In function =E2=80=98select_master_thr=
ead_id=E2=80=99:
net/netfilter/ipvs/ip_vs_sync.c:398:10: warning: cast from pointer to i=
nteger of different size [-Wpointer-to-int-cast]

[snip]
