From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] netfilter: ipvs: fix compiler warnings
Date: Sat, 22 Jan 2011 10:34:23 +0800
Message-ID: <AANLkTimoSQbjH-iW6x36FHs6yzDgsey9RS+yFXnKOxq5@mail.gmail.com>
References: <1295604133-6869-1-git-send-email-xiaosuo@gmail.com> <20110122022232.GL2661@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:mime-version:in-reply-to:references:from:date
         :message-id:subject:to:cc:content-type:content-transfer-encoding;
        bh=tWNr5e3se9NRUmqFo02FQkQneJfRyNj2ga7RxIIAUtI=;
        b=hNjKigqAM4L0Lg95JtFWgdf2Dr1MsHH/tsqqulv1xMzVJyaYa+fW7//ioa420o4C0v
         Hfbxi/33A7Glr61M0Y9B7uSkOPSDs1LI6KRTp7VHgJga7xPdExsf0Cc6U0a0ctXWTYy2
         RVDyYHReUkDf6QUwtZoqTjdb2a6TM4+LyxNkc=
In-Reply-To: <20110122022232.GL2661@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Simon Horman <horms@verge.net.au>
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

On Sat, Jan 22, 2011 at 10:22 AM, Simon Horman <horms@verge.net.au> wro=
te:
> On Fri, Jan 21, 2011 at 06:02:13PM +0800, Changli Gao wrote:
>> Fix compiler warnings when no transport protocol load balancing supp=
ort
>> is configured.
>>
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>> ---
>> =A0net/netfilter/ipvs/ip_vs_core.c =A0| =A0 =A04 +---
>> =A0net/netfilter/ipvs/ip_vs_ctl.c =A0 | =A0 =A04 ++++
>> =A0net/netfilter/ipvs/ip_vs_proto.c | =A0 =A04 ++++
>> =A03 files changed, 9 insertions(+), 3 deletions(-)
>> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip=
_vs_core.c
>> index f36a84f..d889f4f 100644
>> --- a/net/netfilter/ipvs/ip_vs_core.c
>> +++ b/net/netfilter/ipvs/ip_vs_core.c
>> @@ -1894,9 +1894,7 @@ static int __net_init __ip_vs_init(struct net =
*net)
>>
>> =A0static void __net_exit __ip_vs_cleanup(struct net *net)
>> =A0{
>> - =A0 =A0 struct netns_ipvs *ipvs =3D net_ipvs(net);
>> -
>> - =A0 =A0 IP_VS_DBG(10, "ipvs netns %d released\n", ipvs->gen);
>> + =A0 =A0 IP_VS_DBG(10, "ipvs netns %d released\n", net_ipvs(net)->g=
en);
>> =A0}
>>
>
> The hunk above seems unrelated to the problem described.
> The rest of the changes look good. I will double check and
> apply them to my tree.
>

Yes, is a separated patch needed? It is trivial. Thanks.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
