From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 06/15] ipv4: Merge ip_local_out and
 ip_local_out_sk
Date: Wed, 7 Oct 2015 16:48:59 +0200
Message-ID: <561530DB.10309@6wind.com>
References: <878u7fesrg.fsf_-_@x220.int.ebiederm.org>
 <1444157595-28816-6-git-send-email-ebiederm@xmission.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1444157595-28816-6-git-send-email-ebiederm@xmission.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"; format="flowed"
To: "Eric W. Biederman" <ebiederm@xmission.com>, David Miller <davem@davemloft.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>

Le 06/10/2015 20:53, Eric W. Biederman a =C3=A9crit :
> It is confusing and silly hiding a paramater so modify all of
> the callers to pass in the appropriate socket or skb->sk if
> no socket is known.
>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
[snip]
> @@ -456,7 +456,7 @@ packet_routed:
>   	skb->priority =3D sk->sk_priority;
>   	skb->mark =3D sk->sk_mark;
>
> -	res =3D ip_local_out(skb);
> +	res =3D ip_local_out(sk, skb);
As stated in the comment at the top of this function (ip_queue_xmit()),=
 skb->sk
can be different from sk. See also commit b0270e91014d ("ipv4: add a so=
ck
pointer to ip_queue_xmit()").
Not sure if this change is right.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
