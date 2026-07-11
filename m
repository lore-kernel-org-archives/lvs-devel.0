Received: from zg8tmtyylji0my4xnjqumte4.icoremail.net (zg8tmtyylji0my4xnjqumte4.icoremail.net [162.243.164.118])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id E343E28FFF6;
	Sat, 11 Jul 2026 14:10:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=162.243.164.118
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783779049; cv=none; b=nD2WwFfaZ+8LbH3y+i8pdjBldAwDe2jbiUiArPRf5fj+WUPkLg/f9m+vh5KkTQwozdOkW+aT3TZMw2ud2DnuY9uNsxkOHfMOCpJpADRhLtIJI66CFKeOKd8r3bYsHAuBxVdqY4tEPVwUG1I3wneh64mkXm7SKsenWndAAtvtr3A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783779049; c=relaxed/simple;
	bh=iZrV/G6W2EBYy/GOZ2MrGZG+vuXDtEmGSA/u5BOK/jE=;
	h=Content-Type:Mime-Version:Subject:From:In-Reply-To:Date:Cc:
	 Message-Id:References:To; b=k5OMQ9XBpK6OCJffjC+vMjRVcs55vg3Dm6RfZAtY3IpGAbXF2vm+Pevw5Yv/KMxLer7pm0Tbdu75Gt2rhdyD+8Ld2I6wyBtvH4sHKvUVQVOAwmjypX88e+PNIFHGw6s+YG8eF5podf09Q4szwoabZDC62h8nC56yDgV+gueXcTI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=mails.tsinghua.edu.cn; spf=pass smtp.mailfrom=mails.tsinghua.edu.cn; dkim=pass (1024-bit key) header.d=mails.tsinghua.edu.cn header.i=@mails.tsinghua.edu.cn header.b=BtZFF6a5; arc=none smtp.client-ip=162.243.164.118
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=mails.tsinghua.edu.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=mails.tsinghua.edu.cn
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=mails.tsinghua.edu.cn header.i=@mails.tsinghua.edu.cn header.b="BtZFF6a5"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=mails.tsinghua.edu.cn; s=dkim; h=Received:Content-Type:
	Mime-Version:Subject:From:In-Reply-To:Date:Cc:
	Content-Transfer-Encoding:Message-Id:References:To; bh=Atq63KY0v
	n5TLHmiu/IOKgqIrZXoAVWMmb1SR6++EHo=; b=BtZFF6a5iiI2iKEvmvYgt/tMi
	ECQiU1oh9gcF4W+jfHvN+kMdbkYRFsF5HGsAiENHHqsJ0Rgs8lKW2BZfdIqEjqHZ
	wVhHLxfCQ3OmiO1In795vNCABLiDo/xJlLFu9gC4Ms26qOg71SczP8YW/yRUCOuo
	j97GlazvAk+9szIJK8=
Received: from smtpclient.apple (unknown [121.229.84.237])
	by web2 (Coremail) with SMTP id yQQGZQAnA5utTlJqBuXeAg--.58248S2;
	Sat, 11 Jul 2026 22:09:50 +0800 (CST)
Content-Type: text/plain;
	charset=us-ascii
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3864.600.51.1.1\))
Subject: Re: [PATCH nf] ipvs: make destination flags atomic
From: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
In-Reply-To: <afcdb34c-ec10-de8e-083c-624bcedca90e@ssi.bg>
Date: Sat, 11 Jul 2026 22:09:39 +0800
Cc: Simon Horman <horms@verge.net.au>,
 David Ahern <dsahern@kernel.org>,
 Ido Schimmel <idosch@nvidia.com>,
 "David S. Miller" <davem@davemloft.net>,
 Eric Dumazet <edumazet@google.com>,
 Jakub Kicinski <kuba@kernel.org>,
 Paolo Abeni <pabeni@redhat.com>,
 Pablo Neira Ayuso <pablo@netfilter.org>,
 Florian Westphal <fw@strlen.de>,
 Phil Sutter <phil@nwl.cc>,
 Alexander Frolkin <avf@eldamar.org.uk>,
 netdev@vger.kernel.org,
 lvs-devel@vger.kernel.org,
 linux-kernel <linux-kernel@vger.kernel.org>,
 netfilter-devel@vger.kernel.org,
 coreteam@netfilter.org,
 stable@vger.kernel.org,
 Yuxiang Yang <yangyx22@mails.tsinghua.edu.cn>,
 Ao Wang <wangao@seu.edu.cn>,
 Xuewei Feng <fengxw06@126.com>,
 Qi Li <qli01@tsinghua.edu.cn>,
 Ke Xu <xuke@tsinghua.edu.cn>
Content-Transfer-Encoding: quoted-printable
Message-Id: <F48F3350-4E00-46F0-BD11-AECB45AD8722@mails.tsinghua.edu.cn>
References: <20260707085706.96322-1-zhaoyz24@mails.tsinghua.edu.cn>
 <41c3d792-af7d-5582-5057-ac3df5f7bfd6@ssi.bg>
 <91509A0C-9E4A-4F0E-A45C-ABD29396067E@mails.tsinghua.edu.cn>
 <afcdb34c-ec10-de8e-083c-624bcedca90e@ssi.bg>
To: Julian Anastasov <ja@ssi.bg>
X-Mailer: Apple Mail (2.3864.600.51.1.1)
X-CM-TRANSID:yQQGZQAnA5utTlJqBuXeAg--.58248S2
X-Coremail-Antispam: 1UD129KBjvJXoW3AF45tFWDWF18WFW5Kw18uFg_yoW3Wr4fpr
	W8JF929rWUWa1UGFs8tF13ZrWFkF18JFyUWFn8Ka43J3WDArn0qFnYkFWDCFs7CFs7Cr1f
	CFW5t34qka4kXFDanT9S1TB71UUUUU7qnTZGkaVYY2UrUUUUjbIjqfuFe4nvWSU5nxnvy2
	9KBjDU0xBIdaVrnRJUUU9v1xkIjI8I6I8E6xAIw20EY4v20xvaj40_Wr0E3s1l8cAvFVAK
	0II2c7xJM28CjxkF64kEwVA0rcxSw2x7M28EF7xvwVC0I7IYx2IY67AKxVW5JVW7JwA2z4
	x0Y4vE2Ix0cI8IcVCY1x0267AKxVWxJVW8Jr1l84ACjcxK6I8E87Iv67AKxVW0oVCq3wA2
	z4x0Y4vEx4A2jsIEc7CjxVAFwI0_GcCE3s1lnxkEFVAIw20F6cxK64vIFxWle2I262IYc4
	CY6c8Ij28IcVAaY2xG8wAqx4xG64xvF2IEw4CE5I8CrVC2j2WlYx0E74AGY7Cv6cx26r4r
	Kr1UJr1lOx8S6xCaFVCjc4AY6r1j6r4UM4x0Y48IcxkI7VAKI48JM4x0x7Aq67IIx4CEVc
	8vx2IErcIFxwACI402YVCY1x02628vn2kIc2xKxwCY1x0262kKe7AKxVW8ZVWrXwCY02Av
	z4vE14v_Xryl42xK82IYc2Ij64vIr41l42xK82IY6x8ErcxFaVAv8VW8Ww4UJr1UMxC20s
	026xCaFVCjc4AY6r1j6r4UMI8I3I0E5I8CrVAFwI0_Jr0_Jr4lx2IqxVCjr7xvwVAFwI0_
	JrI_JrWlx4CE17CEb7AF67AKxVW8ZVWrXwCIc40Y0x0EwIxGrwCI42IY6xIIjxv20xvE14
	v26r1j6r1xMIIF0xvE2Ix0cI8IcVCY1x0267AKxVW8JVWxJwCI42IY6xAIw20EY4v20xva
	j40_Jr0_JF4lIxAIcVC2z280aVAFwI0_Jr0_Gr1lIxAIcVC2z280aVCY1x0267AKxVW8JV
	W8JrUvcSsGvfC2KfnxnUUI43ZEXa7VU1m9aPUUUUU==
X-CM-SenderInfo: 52kd05r2suqzpdlo2hxwvl0wxkxdhvlgxou0/1tbiAQMFAWpRcLLNAQABsy

Hello Julian,

Thank you for the detailed proposal. Yes, I am happy to handle the
follow-up conversion of the overload flag to bitops.


> On Jul 8, 2026, at 23:53, Julian Anastasov <ja@ssi.bg> wrote:
>=20
>=20
> Hello,
>=20
> On Wed, 8 Jul 2026, Yizhou Zhao wrote:
>=20
>>> On Jul 8, 2026, at 03:18, Julian Anastasov <ja@ssi.bg> wrote:
>>>=20
>>> On Tue, 7 Jul 2026, Yizhou Zhao wrote:
>>>=20
>>=20
>> We have posted a v2 patch at:
>> =
https://lore.kernel.org/netfilter-devel/20260708060454.20534-1-zhaoyz24@ma=
ils.tsinghua.edu.cn/
>>=20
>> The v2 patch updates the commit message with more conservative
>> wording, and fixes the checkpatch logical-continuation warnings.
>=20
> After looking again at the code, I think we can
> do it in different way:
>=20
> - IP_VS_DEST_F_AVAILABLE and IP_VS_DEST_F_OVERLOAD are defined
> in include/uapi/linux/ip_vs.h but we never export them to user
> space. So, we are free to change them. We can move them to=20
> include/net/ip_vs.h, see below...
>=20
> - IP_VS_DEST_F_AVAILABLE is changed only under service_mutex,
> so we can keep its usage
>=20
> - IP_VS_DEST_F_OVERLOAD needs different access methods.
> We can add 'unsigned long flags2;', may be after l_threshold.
> And to switch to such usage (F_OVERLOAD -> FL_OVERLOAD):
>=20
> - test_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2)
> - set_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2)
>=20
> Sometimes if (test_bit()) clear_bit() can avoid
> full memory barrier in ip_vs_dest_update_overload()
>=20
> - clear_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2)
> test_bit() guard can help here too
>=20
> As there are other races involved, something like
> this can be a starting point for such change. It tries harder
> to update the overload flag on dest edit/add but it does not
> include the proposed bitops:
>=20
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 49297fec448a..b34631270e24 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -1906,6 +1906,8 @@ static inline void =
ip_vs_dest_put_and_free(struct ip_vs_dest *dest)
> kfree(dest);
> }
>=20
> +void ip_vs_dest_update_overload(struct ip_vs_dest *dest);
> +
> /* IPVS sync daemon data and function prototypes
>  * (from ip_vs_sync.c)
>  */
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c =
b/net/netfilter/ipvs/ip_vs_conn.c
> index d19caf66afeb..3fd221996e6e 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -1087,6 +1087,26 @@ static inline int ip_vs_dest_totalconns(struct =
ip_vs_dest *dest)
> + atomic_read(&dest->inactconns);
> }
>=20
> +__always_inline void ip_vs_dest_update_overload(struct ip_vs_dest =
*dest)
> +{
> + int conns, l, u;
> +
> + u =3D READ_ONCE(dest->u_threshold);
> + if (!u)
> + goto unset;
> + conns =3D ip_vs_dest_totalconns(dest);
> + if (conns >=3D u) {
> + dest->flags |=3D IP_VS_DEST_F_OVERLOAD;
> + return;
> + }
> + l =3D READ_ONCE(dest->l_threshold) ? : (u * 3 / 4);
> + if (conns >=3D l && l)
> + return;
> +

I noticed one integer-rounding detail in the proposed helper. The
existing default lower-threshold check:

ip_vs_dest_totalconns(dest) * 4 < dest->u_threshold * 3

clears OVERLOAD when conns is below ceil(3 * u / 4), assuming the
multiplications do not overflow. In the proposed helper:

l =3D u * 3 / 4;
if (conns >=3D l && l)
return;

the division rounds down, so the boundary is different when u is not a
multiple of four. For example, with u =3D=3D 2 and conns =3D=3D 1, the =
existing
code clears OVERLOAD while the helper keeps it set. Would using

l =3D u - u / 4;

for the default lower threshold preserve the existing behavior while
also avoiding the multiplication overflow?

> +unset:
> + dest->flags &=3D ~IP_VS_DEST_F_OVERLOAD;
> +}
> +
> /*
>  * Bind a connection entry with a virtual service destination
>  * Called just after a new connection entry is created.
> @@ -1161,9 +1181,7 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct =
ip_vs_dest *dest)
> atomic_inc(&dest->persistconns);
> }
>=20
> - if (dest->u_threshold !=3D 0 &&
> -    ip_vs_dest_totalconns(dest) >=3D dest->u_threshold)
> - dest->flags |=3D IP_VS_DEST_F_OVERLOAD;
> + ip_vs_dest_update_overload(dest);
> }
>=20
>=20
> @@ -1257,16 +1275,8 @@ static inline void ip_vs_unbind_dest(struct =
ip_vs_conn *cp)
> atomic_dec(&dest->persistconns);
> }
>=20
> - if (dest->l_threshold !=3D 0) {
> - if (ip_vs_dest_totalconns(dest) < dest->l_threshold)
> - dest->flags &=3D ~IP_VS_DEST_F_OVERLOAD;
> - } else if (dest->u_threshold !=3D 0) {
> - if (ip_vs_dest_totalconns(dest) * 4 < dest->u_threshold * 3)
> - dest->flags &=3D ~IP_VS_DEST_F_OVERLOAD;
> - } else {
> - if (dest->flags & IP_VS_DEST_F_OVERLOAD)
> - dest->flags &=3D ~IP_VS_DEST_F_OVERLOAD;
> - }
> + if (dest->flags & IP_VS_DEST_F_OVERLOAD)
> + ip_vs_dest_update_overload(dest);
>=20
> ip_vs_dest_put(dest);
> }
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c =
b/net/netfilter/ipvs/ip_vs_ctl.c
> index bcf40b8c41cf..2871116e46ec 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -1315,6 +1315,7 @@ __ip_vs_update_dest(struct ip_vs_service *svc, =
struct ip_vs_dest *dest,
> struct ip_vs_service *old_svc;
> struct ip_vs_scheduler *sched;
> int conn_flags;
> + bool upd_thresh;
>=20
> /* We cannot modify an address and change the address family */
> BUG_ON(!add && udest->af !=3D dest->af);
> @@ -1370,10 +1371,12 @@ __ip_vs_update_dest(struct ip_vs_service *svc, =
struct ip_vs_dest *dest,
> /* set the dest status flags */
> dest->flags |=3D IP_VS_DEST_F_AVAILABLE;
>=20
> - if (udest->u_threshold =3D=3D 0 || udest->u_threshold > =
dest->u_threshold)
> - dest->flags &=3D ~IP_VS_DEST_F_OVERLOAD;
> - dest->u_threshold =3D udest->u_threshold;
> - dest->l_threshold =3D udest->l_threshold;
> + upd_thresh =3D READ_ONCE(dest->u_threshold) !=3D udest->u_threshold =
||
> +     READ_ONCE(dest->l_threshold) !=3D udest->l_threshold;
> + WRITE_ONCE(dest->u_threshold, udest->u_threshold);
> + WRITE_ONCE(dest->l_threshold, udest->l_threshold);
> + if (upd_thresh)
> + ip_vs_dest_update_overload(dest);
>=20
> dest->af =3D udest->af;
>=20
> @@ -3667,8 +3670,8 @@ __ip_vs_get_dest_entries(struct netns_ipvs =
*ipvs, const struct ip_vs_get_dests *
> entry.port =3D dest->port;
> entry.conn_flags =3D atomic_read(&dest->conn_flags);
> entry.weight =3D atomic_read(&dest->weight);
> - entry.u_threshold =3D dest->u_threshold;
> - entry.l_threshold =3D dest->l_threshold;
> + entry.u_threshold =3D READ_ONCE(dest->u_threshold);
> + entry.l_threshold =3D READ_ONCE(dest->l_threshold);
> entry.activeconns =3D atomic_read(&dest->activeconns);
> entry.inactconns =3D atomic_read(&dest->inactconns);
> entry.persistconns =3D atomic_read(&dest->persistconns);
> @@ -4277,8 +4280,10 @@ static int ip_vs_genl_fill_dest(struct sk_buff =
*skb, struct ip_vs_dest *dest)
> dest->tun_port) ||
>    nla_put_u16(skb, IPVS_DEST_ATTR_TUN_FLAGS,
> dest->tun_flags) ||
> -    nla_put_u32(skb, IPVS_DEST_ATTR_U_THRESH, dest->u_threshold) ||
> -    nla_put_u32(skb, IPVS_DEST_ATTR_L_THRESH, dest->l_threshold) ||
> +    nla_put_u32(skb, IPVS_DEST_ATTR_U_THRESH,
> + READ_ONCE(dest->u_threshold)) ||
> +    nla_put_u32(skb, IPVS_DEST_ATTR_L_THRESH,
> + READ_ONCE(dest->l_threshold)) ||
>    nla_put_u32(skb, IPVS_DEST_ATTR_ACTIVE_CONNS,
> atomic_read(&dest->activeconns)) ||
>    nla_put_u32(skb, IPVS_DEST_ATTR_INACT_CONNS,
>=20
> Regards
>=20
> --
> Julian Anastasov <ja@ssi.bg>

Please go ahead with the ip_vs_dest_update_overload() patch. I will base
the follow-up on the posted version and check the resulting struct
ip_vs_dest layout as Vadim suggested.

Regards,
Yizhou

