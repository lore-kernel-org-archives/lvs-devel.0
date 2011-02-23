From: Wensong Zhang <wensong@linux-vs.org>
Subject: Re: [PATCH v2] ipvs: unify the formula to estimate the overhead of
 processing connections
Date: Wed, 23 Feb 2011 09:56:54 +0800
Message-ID: <AANLkTini6JkOQenO+bzF3AbzePPe1vMtMK_5pqfLifzz@mail.gmail.com>
References: <1298107948-9224-1-git-send-email-xiaosuo@gmail.com>
	<20110222055553.GA4192@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:mime-version:sender:in-reply-to:references:date
         :x-google-sender-auth:message-id:subject:from:to:cc:content-type
         :content-transfer-encoding;
        bh=XxW9cMyOmUSYtQav8DcI/dcpSOdNKfPFDK+6lrylLnw=;
        b=Y5KV6TUcJP4EOranCCV0iGnZO7WL5Ruhy69zJBmS+1CM24224o7qwtMx2YLKhgx1Bv
         Xb9UB6Fye6N1OpQ53Q7Z3VWEOPhXB6OXK3p29yq4tdKtS0UgcLcNDkLVFgvAChXWE496
         DvJpHCOy1K7YoTJyKMkpRz7sx8MCsfMFfQsNg=
In-Reply-To: <20110222055553.GA4192@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Simon Horman <horms@verge.net.au>
Cc: Changli Gao <xiaosuo@gmail.com>, "David S. Miller" <davem@davemloft.net>, Patrick McHardy <kaber@trash.net>, Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

Sure, I am ok with this patch. Thanks!

On Tue, Feb 22, 2011 at 1:56 PM, Simon Horman <horms@verge.net.au> wrot=
e:
> On Sat, Feb 19, 2011 at 05:32:28PM +0800, Changli Gao wrote:
>> lc and wlc use the same formula, but lblc and lblcr use another one.=
 There
>> is no reason for using two different formulas for the lc variants.
>>
>> The formula used by lc is used by all the lc variants in this patch.
>
> Wensong, are you ok with this version of the patch?
>
>>
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>> ---
>> v2: use ip_vs_dest_conn_overhead() instead.
>> =A0include/net/ip_vs.h =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 14 +++++++++=
+++++
>> =A0net/netfilter/ipvs/ip_vs_lblc.c =A0| =A0 13 +++----------
>> =A0net/netfilter/ipvs/ip_vs_lblcr.c | =A0 25 +++++++----------------=
--
>> =A0net/netfilter/ipvs/ip_vs_lc.c =A0 =A0| =A0 18 +-----------------
>> =A0net/netfilter/ipvs/ip_vs_wlc.c =A0 | =A0 20 ++------------------
>> =A05 files changed, 27 insertions(+), 63 deletions(-)
>> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
>> index 5d75fea..e80ffb7 100644
>> --- a/include/net/ip_vs.h
>> +++ b/include/net/ip_vs.h
>> @@ -1241,6 +1241,20 @@ static inline void ip_vs_conn_drop_conntrack(=
struct ip_vs_conn *cp)
>> =A0/* CONFIG_IP_VS_NFCT */
>> =A0#endif
>>
>> +static inline unsigned int
>> +ip_vs_dest_conn_overhead(struct ip_vs_dest *dest)
>> +{
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* We think the overhead of processing active connection=
s is 256
>> + =A0 =A0 =A0* times higher than that of inactive connections in ave=
rage. (This
>> + =A0 =A0 =A0* 256 times might not be accurate, we will change it la=
ter) We
>> + =A0 =A0 =A0* use the following formula to estimate the overhead no=
w:
>> + =A0 =A0 =A0* =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dest->activeconns*256 =
+ dest->inactconns
>> + =A0 =A0 =A0*/
>> + =A0 =A0 return (atomic_read(&dest->activeconns) << 8) +
>> + =A0 =A0 =A0 =A0 =A0 =A0 atomic_read(&dest->inactconns);
>> +}
>> +
>> =A0#endif /* __KERNEL__ */
>>
>> =A0#endif =A0 =A0 =A0 /* _NET_IP_VS_H */
>> diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip=
_vs_lblc.c
>> index 00b5ffa..58ae403 100644
>> --- a/net/netfilter/ipvs/ip_vs_lblc.c
>> +++ b/net/netfilter/ipvs/ip_vs_lblc.c
>> @@ -389,12 +389,7 @@ __ip_vs_lblc_schedule(struct ip_vs_service *svc=
)
>> =A0 =A0 =A0 int loh, doh;
>>
>> =A0 =A0 =A0 /*
>> - =A0 =A0 =A0* We think the overhead of processing active connection=
s is fifty
>> - =A0 =A0 =A0* times higher than that of inactive connections in ave=
rage. (This
>> - =A0 =A0 =A0* fifty times might not be accurate, we will change it =
later.) We
>> - =A0 =A0 =A0* use the following formula to estimate the overhead:
>> - =A0 =A0 =A0* =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dest->activeconns*50 +=
 dest->inactconns
>> - =A0 =A0 =A0* and the load:
>> + =A0 =A0 =A0* We use the following formula to estimate the load:
>> =A0 =A0 =A0 =A0* =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(dest overhead) / de=
st->weight
>> =A0 =A0 =A0 =A0*
>> =A0 =A0 =A0 =A0* Remember -- no floats in kernel mode!!!
>> @@ -410,8 +405,7 @@ __ip_vs_lblc_schedule(struct ip_vs_service *svc)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (atomic_read(&dest->weight) > 0) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 least =3D dest;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 loh =3D atomic_read(&least=
->activeconns) * 50
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 + atomic_r=
ead(&least->inactconns);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 loh =3D ip_vs_dest_conn_ov=
erhead(least);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto nextstage;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 }
>> @@ -425,8 +419,7 @@ __ip_vs_lblc_schedule(struct ip_vs_service *svc)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (dest->flags & IP_VS_DEST_F_OVERLOAD)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 doh =3D atomic_read(&dest->activeconns) * =
50
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 + atomic_read(&dest->inact=
conns);
>> + =A0 =A0 =A0 =A0 =A0 =A0 doh =3D ip_vs_dest_conn_overhead(dest);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (loh * atomic_read(&dest->weight) >
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 doh * atomic_read(&least->weight=
)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 least =3D dest;
>> diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/i=
p_vs_lblcr.c
>> index bfa25f1..2ddefe8 100644
>> --- a/net/netfilter/ipvs/ip_vs_lblcr.c
>> +++ b/net/netfilter/ipvs/ip_vs_lblcr.c
>> @@ -178,8 +178,7 @@ static inline struct ip_vs_dest *ip_vs_dest_set_=
min(struct ip_vs_dest_set *set)
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((atomic_read(&least->weight) > 0)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 && (least->flags & IP_VS_DEST_F_=
AVAILABLE)) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 loh =3D atomic_read(&least=
->activeconns) * 50
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 + atomic_r=
ead(&least->inactconns);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 loh =3D ip_vs_dest_conn_ov=
erhead(least);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto nextstage;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 }
>> @@ -192,8 +191,7 @@ static inline struct ip_vs_dest *ip_vs_dest_set_=
min(struct ip_vs_dest_set *set)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (dest->flags & IP_VS_DEST_F_OVERLOAD)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 doh =3D atomic_read(&dest->activeconns) * =
50
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 + atomic_read(&dest->inact=
conns);
>> + =A0 =A0 =A0 =A0 =A0 =A0 doh =3D ip_vs_dest_conn_overhead(dest);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((loh * atomic_read(&dest->weight) >
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0doh * atomic_read(&least->wei=
ght))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 && (dest->flags & IP_VS_DEST_F_A=
VAILABLE)) {
>> @@ -228,8 +226,7 @@ static inline struct ip_vs_dest *ip_vs_dest_set_=
max(struct ip_vs_dest_set *set)
>> =A0 =A0 =A0 list_for_each_entry(e, &set->list, list) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 most =3D e->dest;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (atomic_read(&most->weight) > 0) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 moh =3D atomic_read(&most-=
>activeconns) * 50
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 + atomic_r=
ead(&most->inactconns);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 moh =3D ip_vs_dest_conn_ov=
erhead(most);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto nextstage;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 }
>> @@ -239,8 +236,7 @@ static inline struct ip_vs_dest *ip_vs_dest_set_=
max(struct ip_vs_dest_set *set)
>> =A0 =A0nextstage:
>> =A0 =A0 =A0 list_for_each_entry(e, &set->list, list) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 dest =3D e->dest;
>> - =A0 =A0 =A0 =A0 =A0 =A0 doh =3D atomic_read(&dest->activeconns) * =
50
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 + atomic_read(&dest->inact=
conns);
>> + =A0 =A0 =A0 =A0 =A0 =A0 doh =3D ip_vs_dest_conn_overhead(dest);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* moh/mw < doh/dw =3D=3D> moh*dw < doh*=
mw, where mw,dw>0 */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((moh * atomic_read(&dest->weight) <
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0doh * atomic_read(&most->weig=
ht))
>> @@ -563,12 +559,7 @@ __ip_vs_lblcr_schedule(struct ip_vs_service *sv=
c)
>> =A0 =A0 =A0 int loh, doh;
>>
>> =A0 =A0 =A0 /*
>> - =A0 =A0 =A0* We think the overhead of processing active connection=
s is fifty
>> - =A0 =A0 =A0* times higher than that of inactive connections in ave=
rage. (This
>> - =A0 =A0 =A0* fifty times might not be accurate, we will change it =
later.) We
>> - =A0 =A0 =A0* use the following formula to estimate the overhead:
>> - =A0 =A0 =A0* =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dest->activeconns*50 +=
 dest->inactconns
>> - =A0 =A0 =A0* and the load:
>> + =A0 =A0 =A0* We use the following formula to estimate the load:
>> =A0 =A0 =A0 =A0* =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(dest overhead) / de=
st->weight
>> =A0 =A0 =A0 =A0*
>> =A0 =A0 =A0 =A0* Remember -- no floats in kernel mode!!!
>> @@ -585,8 +576,7 @@ __ip_vs_lblcr_schedule(struct ip_vs_service *svc=
)
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (atomic_read(&dest->weight) > 0) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 least =3D dest;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 loh =3D atomic_read(&least=
->activeconns) * 50
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 + atomic_r=
ead(&least->inactconns);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 loh =3D ip_vs_dest_conn_ov=
erhead(least);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto nextstage;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 }
>> @@ -600,8 +590,7 @@ __ip_vs_lblcr_schedule(struct ip_vs_service *svc=
)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (dest->flags & IP_VS_DEST_F_OVERLOAD)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 doh =3D atomic_read(&dest->activeconns) * =
50
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 + atomic_read(&dest->inact=
conns);
>> + =A0 =A0 =A0 =A0 =A0 =A0 doh =3D ip_vs_dest_conn_overhead(dest);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (loh * atomic_read(&dest->weight) >
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 doh * atomic_read(&least->weight=
)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 least =3D dest;
>> diff --git a/net/netfilter/ipvs/ip_vs_lc.c b/net/netfilter/ipvs/ip_v=
s_lc.c
>> index 4f69db1..160cb80 100644
>> --- a/net/netfilter/ipvs/ip_vs_lc.c
>> +++ b/net/netfilter/ipvs/ip_vs_lc.c
>> @@ -22,22 +22,6 @@
>>
>> =A0#include <net/ip_vs.h>
>>
>> -
>> -static inline unsigned int
>> -ip_vs_lc_dest_overhead(struct ip_vs_dest *dest)
>> -{
>> - =A0 =A0 /*
>> - =A0 =A0 =A0* We think the overhead of processing active connection=
s is 256
>> - =A0 =A0 =A0* times higher than that of inactive connections in ave=
rage. (This
>> - =A0 =A0 =A0* 256 times might not be accurate, we will change it la=
ter) We
>> - =A0 =A0 =A0* use the following formula to estimate the overhead no=
w:
>> - =A0 =A0 =A0* =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dest->activeconns*256 =
+ dest->inactconns
>> - =A0 =A0 =A0*/
>> - =A0 =A0 return (atomic_read(&dest->activeconns) << 8) +
>> - =A0 =A0 =A0 =A0 =A0 =A0 atomic_read(&dest->inactconns);
>> -}
>> -
>> -
>> =A0/*
>> =A0 * =A0 Least Connection scheduling
>> =A0 */
>> @@ -62,7 +46,7 @@ ip_vs_lc_schedule(struct ip_vs_service *svc, const=
 struct sk_buff *skb)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((dest->flags & IP_VS_DEST_F_OVERLOAD=
) ||
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 atomic_read(&dest->weight) =3D=3D=
 0)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> - =A0 =A0 =A0 =A0 =A0 =A0 doh =3D ip_vs_lc_dest_overhead(dest);
>> + =A0 =A0 =A0 =A0 =A0 =A0 doh =3D ip_vs_dest_conn_overhead(dest);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!least || doh < loh) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 least =3D dest;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 loh =3D doh;
>> diff --git a/net/netfilter/ipvs/ip_vs_wlc.c b/net/netfilter/ipvs/ip_=
vs_wlc.c
>> index bbddfdb..db751f5 100644
>> --- a/net/netfilter/ipvs/ip_vs_wlc.c
>> +++ b/net/netfilter/ipvs/ip_vs_wlc.c
>> @@ -27,22 +27,6 @@
>>
>> =A0#include <net/ip_vs.h>
>>
>> -
>> -static inline unsigned int
>> -ip_vs_wlc_dest_overhead(struct ip_vs_dest *dest)
>> -{
>> - =A0 =A0 /*
>> - =A0 =A0 =A0* We think the overhead of processing active connection=
s is 256
>> - =A0 =A0 =A0* times higher than that of inactive connections in ave=
rage. (This
>> - =A0 =A0 =A0* 256 times might not be accurate, we will change it la=
ter) We
>> - =A0 =A0 =A0* use the following formula to estimate the overhead no=
w:
>> - =A0 =A0 =A0* =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dest->activeconns*256 =
+ dest->inactconns
>> - =A0 =A0 =A0*/
>> - =A0 =A0 return (atomic_read(&dest->activeconns) << 8) +
>> - =A0 =A0 =A0 =A0 =A0 =A0 atomic_read(&dest->inactconns);
>> -}
>> -
>> -
>> =A0/*
>> =A0 * =A0 Weighted Least Connection scheduling
>> =A0 */
>> @@ -71,7 +55,7 @@ ip_vs_wlc_schedule(struct ip_vs_service *svc, cons=
t struct sk_buff *skb)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!(dest->flags & IP_VS_DEST_F_OVERLOA=
D) &&
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 atomic_read(&dest->weight) > 0) =
{
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 least =3D dest;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 loh =3D ip_vs_wlc_dest_ove=
rhead(least);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 loh =3D ip_vs_dest_conn_ov=
erhead(least);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto nextstage;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 }
>> @@ -85,7 +69,7 @@ ip_vs_wlc_schedule(struct ip_vs_service *svc, cons=
t struct sk_buff *skb)
>> =A0 =A0 =A0 list_for_each_entry_continue(dest, &svc->destinations, n=
_list) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (dest->flags & IP_VS_DEST_F_OVERLOAD)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> - =A0 =A0 =A0 =A0 =A0 =A0 doh =3D ip_vs_wlc_dest_overhead(dest);
>> + =A0 =A0 =A0 =A0 =A0 =A0 doh =3D ip_vs_dest_conn_overhead(dest);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (loh * atomic_read(&dest->weight) >
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 doh * atomic_read(&least->weight=
)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 least =3D dest;
>>
>
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
