From: Mike Maxim <mike@okcupid.com>
Subject: Re: [PATCH] IPVS: Modify the SH scheduler to use weights
Date: Wed, 7 Dec 2011 10:24:09 -0500
Message-ID: <CAOgH2dsHepr7Dyx7pNOutFNRh5SoO-oC9mx1MLm6Ncai8Ma3rQ@mail.gmail.com>
References: <1323245223-13646-1-git-send-email-horms@verge.net.au>
	<1323245223-13646-2-git-send-email-horms@verge.net.au>
	<20111207113038.GA18166@1984>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20111207113038.GA18166@1984>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Simon Horman <horms@verge.net.au>, Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

The reason I put that in is because the size of that table becomes
more relevant/important if you decide to use the weights in the manner
the patch lets you. It would be conceivable that someone might need to
increase the size of that table to accommodate their configuration, so
I thought it would be handy to be able to do that through the regular
configuration system instead of editing the source.

On Wed, Dec 7, 2011 at 6:30 AM, Pablo Neira Ayuso <pablo@netfilter.org>=
 wrote:
> On Wed, Dec 07, 2011 at 05:07:03PM +0900, Simon Horman wrote:
>> From: Michael Maxim <mike@okcupid.com>
>>
>> Modify the algorithm to build the source hashing hash table to add
>> extra slots for destinations with higher weight. This has the effect
>> of allowing an IPVS SH user to give more connections to hosts that
>> have been configured to have a higher weight.
>>
>> Signed-off-by: Michael Maxim <mike@okcupid.com>
>> Signed-off-by: Simon Horman <horms@verge.net.au>
>> ---
>> =A0net/netfilter/ipvs/Kconfig =A0 =A0| =A0 15 +++++++++++++++
>> =A0net/netfilter/ipvs/ip_vs_sh.c | =A0 20 ++++++++++++++++++--
>> =A02 files changed, 33 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
>> index 70bd1d0..af4c0b8 100644
>> --- a/net/netfilter/ipvs/Kconfig
>> +++ b/net/netfilter/ipvs/Kconfig
>> @@ -232,6 +232,21 @@ config =A0 IP_VS_NQ
>> =A0 =A0 =A0 =A0 If you want to compile it in kernel, say Y. To compi=
le it as a
>> =A0 =A0 =A0 =A0 module, choose M here. If unsure, say N.
>>
>> +comment 'IPVS SH scheduler'
>> +
>> +config IP_VS_SH_TAB_BITS
>> + =A0 =A0 int "IPVS source hashing table size (the Nth power of 2)"
>> + =A0 =A0 range 4 20
>> + =A0 =A0 default 8
>> + =A0 =A0 ---help---
>> + =A0 =A0 =A0 The source hashing scheduler maps source IPs to destin=
ations
>> + =A0 =A0 =A0 stored in a hash table. This table is tiled by each de=
stination
>> + =A0 =A0 =A0 until all slots in the table are filled. When using we=
ights to
>> + =A0 =A0 =A0 allow destinations to receive more connections, the ta=
ble is
>> + =A0 =A0 =A0 tiled an amount proportional to the weights specified.=
 The table
>> + =A0 =A0 =A0 needs to be large enough to effectively fit all the de=
stinations
>> + =A0 =A0 =A0 multiplied by their respective weights.
>
> Hm, does this really belong to this patch?
>
>> +
>> =A0comment 'IPVS application helper'
>>
>> =A0config =A0 =A0 =A0 IP_VS_FTP
>> diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_v=
s_sh.c
>> index 33815f4..e0ca520 100644
>> --- a/net/netfilter/ipvs/ip_vs_sh.c
>> +++ b/net/netfilter/ipvs/ip_vs_sh.c
>> @@ -30,6 +30,11 @@
>> =A0 * server is dead or overloaded, the load balancer can bypass the=
 cache
>> =A0 * server and send requests to the original server directly.
>> =A0 *
>> + * The weight destination attribute can be used to control the
>> + * distribution of connections to the destinations in servernode. T=
he
>> + * greater the weight, the more connections the destination
>> + * will receive.
>> + *
>> =A0 */
>>
>> =A0#define KMSG_COMPONENT "IPVS"
>> @@ -99,9 +104,11 @@ ip_vs_sh_assign(struct ip_vs_sh_bucket *tbl, str=
uct ip_vs_service *svc)
>> =A0 =A0 =A0 struct ip_vs_sh_bucket *b;
>> =A0 =A0 =A0 struct list_head *p;
>> =A0 =A0 =A0 struct ip_vs_dest *dest;
>> + =A0 =A0 int d_count;
>>
>> =A0 =A0 =A0 b =3D tbl;
>> =A0 =A0 =A0 p =3D &svc->destinations;
>> + =A0 =A0 d_count =3D 0;
>> =A0 =A0 =A0 for (i=3D0; i<IP_VS_SH_TAB_SIZE; i++) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (list_empty(p)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 b->dest =3D NULL;
>> @@ -113,14 +120,23 @@ ip_vs_sh_assign(struct ip_vs_sh_bucket *tbl, s=
truct ip_vs_service *svc)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 atomic_inc(&dest->refcnt=
);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 b->dest =3D dest;
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p =3D p->next;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 IP_VS_DBG_BUF(6, "assigned=
 i: %d dest: %s weight: %d\n",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 i, IP_VS_DBG_ADDR(svc->af, &dest->addr),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 atomic_read(&dest->weight));
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Don't move to next dest=
 until filling weight */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (++d_count >=3D atomic_=
read(&dest->weight)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p =3D p->n=
ext;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 d_count =3D=
 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> +
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 b++;
>> =A0 =A0 =A0 }
>> +
>> =A0 =A0 =A0 return 0;
>> =A0}
>>
>> -
>
> While at it, would you remove this unnecessary deletions/additions.
>
> Thanks!
