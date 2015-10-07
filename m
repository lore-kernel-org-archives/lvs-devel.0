From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 01/15] ipv4: Fix ip_local_out_sk by passing the
 sk into __ip_local_out_sk
Date: Wed, 7 Oct 2015 16:48:38 +0200
Message-ID: <561530C6.1030306@6wind.com>
References: <878u7fesrg.fsf_-_@x220.int.ebiederm.org>
 <1444157595-28816-1-git-send-email-ebiederm@xmission.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1444157595-28816-1-git-send-email-ebiederm@xmission.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"; format="flowed"
To: "Eric W. Biederman" <ebiederm@xmission.com>, David Miller <davem@davemloft.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org

Le 06/10/2015 20:53, Eric W. Biederman a =C3=A9crit :
> In the rare case where sk !=3D skb->sk ip_local_out_sk arranges
> to call dst->output differently if the skb is queued or not.
> This is a bug.
>
> Fix this bug by passing the sk parameter of ip_local_out_sk through
> from ip_local_out_sk to __ip_local_out_sk (skipping __ip_local_out).
>
> Fixes: 7026b1ddb6b8d4e6ee33dc2bd06c0ca8746fa7ab
=46ixes: 7026b1ddb6b8 ("netfilter: Pass socket pointer down through okf=
n().")

It's in 4.1, so I assume this patch is for net also?
