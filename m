Received: from zg8tmtyylji0my4xnjqumte4.icoremail.net (zg8tmtyylji0my4xnjqumte4.icoremail.net [162.243.164.118])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 9E85847D952;
	Tue, 14 Jul 2026 14:23:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=162.243.164.118
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784039023; cv=none; b=vEQN07FzzB/0Qd2snOfd0/DOpZ6Izr3kM1HzJ/QSmRUSY+pMQkh2CcqS8fHO8woYflS/yWVC+J74nXgwPDLBpXjJ9uBD13op0wEmCpLa80DNJPy8HE5RoaSNTp7LJKixa2hTYEzx+2VvY50lQFJ47BGForp4yfyhIoHepBTneZc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784039023; c=relaxed/simple;
	bh=Z8VjnggklrUNs8QG1/uP2KHmo0sjUqJ2cOzb4rDHpbY=;
	h=Content-Type:Mime-Version:Subject:From:In-Reply-To:Date:Cc:
	 Message-Id:References:To; b=STX0k1aegnna6gLh3fviSehEXK5DJUZkjhVFSGTNdE+dYgWaXBYcGlNR1ytzzeVBc+3R57ydCZp8hDRXLPhcv1gcg3jHI0GmnRsL3ok+BbflIiDxDubjPCcsZHiFfKtpk4m25UXJZWVvXcHfmo3LGK15anJ1sJ0uBQDXHMEwUKM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=mails.tsinghua.edu.cn; spf=pass smtp.mailfrom=mails.tsinghua.edu.cn; dkim=pass (1024-bit key) header.d=mails.tsinghua.edu.cn header.i=@mails.tsinghua.edu.cn header.b=lNZDkE3f; arc=none smtp.client-ip=162.243.164.118
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=mails.tsinghua.edu.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=mails.tsinghua.edu.cn
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=mails.tsinghua.edu.cn header.i=@mails.tsinghua.edu.cn header.b="lNZDkE3f"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=mails.tsinghua.edu.cn; s=dkim; h=Received:Content-Type:
	Mime-Version:Subject:From:In-Reply-To:Date:Cc:
	Content-Transfer-Encoding:Message-Id:References:To; bh=DHSYqGvrZ
	PnJWzOJGh0A090/BAR3siqh/yxBFxP1Idw=; b=lNZDkE3ffglnosHI63gLZBlHa
	YlHxLzDv3qTBMEG41c4UKMqxogsA5lkjlQLC3CvomouxxrWyVmef1vuouTn2InLB
	n0iVwCW31oMWcSY8zHCv4tNN4TQWRJNQpQe+mXBkKudRWnNue5/NrQcemyX+dzn9
	15B6qqGORfsVLjRcgI=
Received: from smtpclient.apple (unknown [121.229.84.192])
	by web3 (Coremail) with SMTP id ygQGZQCH0Y40RlZqcdYqAw--.29871S2;
	Tue, 14 Jul 2026 22:22:45 +0800 (CST)
Content-Type: text/plain;
	charset=utf-8
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3864.600.51.1.1\))
Subject: Re: [PATCH nf v3 2/2] ipvs: use bitops for destination overload state
From: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
In-Reply-To: <a82b528b-2710-3978-fc18-ef902fd903e1@ssi.bg>
Date: Tue, 14 Jul 2026 22:22:35 +0800
Cc: David Ahern <dsahern@kernel.org>,
 Ido Schimmel <idosch@nvidia.com>,
 Simon Horman <horms@verge.net.au>,
 "David S. Miller" <davem@davemloft.net>,
 Eric Dumazet <edumazet@google.com>,
 Jakub Kicinski <kuba@kernel.org>,
 Paolo Abeni <pabeni@redhat.com>,
 Pablo Neira Ayuso <pablo@netfilter.org>,
 Florian Westphal <fw@strlen.de>,
 Phil Sutter <phil@nwl.cc>,
 netdev@vger.kernel.org,
 lvs-devel@vger.kernel.org,
 linux-kernel@vger.kernel.org,
 netfilter-devel@vger.kernel.org,
 coreteam@netfilter.org,
 stable@vger.kernel.org,
 Yuxiang Yang <yangyx22@mails.tsinghua.edu.cn>,
 Ao Wang <wangao@seu.edu.cn>,
 Xuewei Feng <fengxw06@126.com>,
 Qi Li <qli01@tsinghua.edu.cn>,
 Ke Xu <xuke@tsinghua.edu.cn>
Content-Transfer-Encoding: quoted-printable
Message-Id: <E85B138D-367F-4803-85EE-6D6024C33CC3@mails.tsinghua.edu.cn>
References: <cover.1783931964.git.zhaoyz24@mails.tsinghua.edu.cn>
 <edc095e05c89cc6481613126de5f2a91ed601fa9.1783931964.git.zhaoyz24@mails.tsinghua.edu.cn>
 <a82b528b-2710-3978-fc18-ef902fd903e1@ssi.bg>
To: Julian Anastasov <ja@ssi.bg>
X-Mailer: Apple Mail (2.3864.600.51.1.1)
X-CM-TRANSID:ygQGZQCH0Y40RlZqcdYqAw--.29871S2
X-Coremail-Antispam: 1UD129KBjvJXoW3Gw4DWw48KrWDXF1DXr4xJFb_yoW3ZFWxpF
	yFkFZ3KFZrGr90gFsFqFyfurW8KF4kGF47uF15Ka4fAa4qqr1FqrsYkrWDC3WDZFnakF1f
	tFWaq3y7Aas8AFJanT9S1TB71UUUUU7qnTZGkaVYY2UrUUUUjbIjqfuFe4nvWSU5nxnvy2
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
X-CM-SenderInfo: 52kd05r2suqzpdlo2hxwvl0wxkxdhvlgxou0/1tbiAQIIAWpWBLdUGwAAsK

Hi Julian,

> On Jul 14, 2026, at 19:16, Julian Anastasov <ja@ssi.bg> wrote:
>=20
>=20
> Hi Yizhou,
>=20
> On Mon, 13 Jul 2026, Yizhou Zhao wrote:
>=20
>> IPVS destination schedulers read the overload state from packet =
processing
>> paths, while connection accounting and destination updates can change =
it
>> concurrently. IP_VS_DEST_F_OVERLOAD currently shares dest->flags with
>> IP_VS_DEST_F_AVAILABLE, so plain read-modify-write operations on the =
two
>> independent states can race and lose either update.
>>=20
>> KCSAN reports the race with the SH scheduler and an upper connection
>> threshold configured:
>>=20
>>  BUG: KCSAN: data-race in __ip_vs_update_dest / ip_vs_sh_schedule
>>=20
>> IP_VS_DEST_F_AVAILABLE is changed under service_mutex. Keep it in the
>> existing flags word, but move the overload state to a separate =
unsigned
>> long and access it with bitops. Use test_bit() in scheduler paths and
>> set_bit()/clear_bit() in ip_vs_dest_update_overload(). This =
serializes the
>> overload bit accesses and prevents updates to the available and =
overload
>> states from clobbering each other.
>>=20
>> The destination flags are not exposed by the IPVS sockopt or netlink
>> interfaces, so move their definitions out of the UAPI header. Place =
the
>> new overload word next to weight, which keeps the existing flags,
>> conn_flags and weight offsets unchanged. On x86-64 this grows struct
>> ip_vs_dest from 472 to 480 bytes.
>>=20
>> test_bit() does not add reader-side ordering. Schedulers can still =
observe
>> stale destination state, as they could before this change; this does =
not
>> provide a fresh cross-field snapshot.
>>=20
>> Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
>> Cc: stable@vger.kernel.org
>> Reported-by: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
>> Reported-by: Yuxiang Yang <yangyx22@mails.tsinghua.edu.cn>
>> Reported-by: Ao Wang <wangao@seu.edu.cn>
>> Reported-by: Xuewei Feng <fengxw06@126.com>
>> Reported-by: Qi Li <qli01@tsinghua.edu.cn>
>> Reported-by: Ke Xu <xuke@tsinghua.edu.cn>
>> Assisted-by: Claude-Code:GLM-5.2
>> Suggested-by: Julian Anastasov <ja@ssi.bg>
>> Signed-off-by: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
>> ---
>> include/net/ip_vs.h              | 8 ++++++++
>> include/uapi/linux/ip_vs.h       | 6 ------
>> net/netfilter/ipvs/ip_vs_conn.c  | 7 ++++---
>> net/netfilter/ipvs/ip_vs_dh.c    | 4 ++--
>> net/netfilter/ipvs/ip_vs_fo.c    | 2 +-
>> net/netfilter/ipvs/ip_vs_lblc.c  | 4 ++--
>> net/netfilter/ipvs/ip_vs_lblcr.c | 8 ++++----
>> net/netfilter/ipvs/ip_vs_lc.c    | 2 +-
>> net/netfilter/ipvs/ip_vs_mh.c    | 2 +-
>> net/netfilter/ipvs/ip_vs_nq.c    | 2 +-
>> net/netfilter/ipvs/ip_vs_ovf.c   | 2 +-
>> net/netfilter/ipvs/ip_vs_rr.c    | 2 +-
>> net/netfilter/ipvs/ip_vs_sed.c   | 4 ++--
>> net/netfilter/ipvs/ip_vs_sh.c    | 2 +-
>> net/netfilter/ipvs/ip_vs_twos.c  | 4 ++--
>> net/netfilter/ipvs/ip_vs_wlc.c   | 4 ++--
>> net/netfilter/ipvs/ip_vs_wrr.c   | 2 +-
>> 17 files changed, 34 insertions(+), 31 deletions(-)
>>=20
>> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
>> index 3fc864a320fb..5e8e55f82b04 100644
>> --- a/include/net/ip_vs.h
>> +++ b/include/net/ip_vs.h
>> @@ -36,6 +36,13 @@
>> #define IP_VS_HDR_INVERSE 1
>> #define IP_VS_HDR_ICMP 2
>>=20
>> +/* Destination Server Flags */
>> +#define IP_VS_DEST_F_AVAILABLE 0x0001 /* server is available */
>> +
>> +enum {
>> + IP_VS_DEST_FL_OVERLOAD,
>> +};
>> +
>> /* conn_tab limits (as per Kconfig) */
>> #define IP_VS_CONN_TAB_MIN_BITS 8
>> #if BITS_PER_LONG > 32
>> @@ -976,6 +983,7 @@ struct ip_vs_dest {
>> volatile unsigned int flags; /* dest status flags */
>=20
> Sashiko has some comments that we should fix somehow:
>=20
> =
https://sashiko.dev/#/patchset/cover.1783931964.git.zhaoyz24%40mails.tsing=
hua.edu.cn
>=20
> One option is IP_VS_DEST_F_AVAILABLE to become
> IP_VS_DEST_CF_AVAILABLE (CF=3DConfig Flag)
>=20
>> atomic_t conn_flags; /* flags to copy to conn */
>> atomic_t weight; /* server weight */
>> + unsigned long flags2; /* dest status flags */
>=20
> unsigned long cfg_flags;
>=20
> We then put IP_VS_DEST_CF_AVAILABLE in this new cache line
> that most of the schedulers will not read until dest is selected.
> DH even should not check the IP_VS_DEST_F_AVAILABLE flag,
> only lblc/lblcr should use this flag.

I agree that moving AVAILABLE to a separate cfg_flags word
looks better for the scheduler cacheline footprint than my flags2
placement.

>=20
> We can preserve IP_VS_DEST_F_OVERLOAD in 'flags',
> even we may not need to use bitops if we start to use
> spin_lock_bh(&dest->dst_lock), as this lock is already
> present in the dest structure. See below...
>=20
>> atomic_t last_weight; /* server latest weight */
>> __u16 tun_type; /* tunnel type */
>> __be16 tun_port; /* tunnel port */
>=20
>> diff --git a/net/netfilter/ipvs/ip_vs_conn.c =
b/net/netfilter/ipvs/ip_vs_conn.c
>> index fa3fbd597f3f..2591f4e143f8 100644
>> --- a/net/netfilter/ipvs/ip_vs_conn.c
>> +++ b/net/netfilter/ipvs/ip_vs_conn.c
>> @@ -1006,7 +1006,7 @@ __always_inline void =
ip_vs_dest_update_overload(struct ip_vs_dest *dest)
>=20
> We can add new arg 'bool locked'. Also, we will
> return false if caller should retry under lock.
> It will happen when we change IP_VS_DEST_F_OVERLOAD and
> require its changes to be synchronized with the
> thresholds and the number of connections.
>=20
>> goto unset;
>> conns =3D ip_vs_dest_totalconns(dest);
>> if (conns >=3D u) {
>> - dest->flags |=3D IP_VS_DEST_F_OVERLOAD;
>> + set_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2);
>=20
>=20
> if (conns >=3D u) {
> if (!locked)
> return false;
> dest->flags |=3D IP_VS_DEST_F_OVERLOAD;
> return true;
> }
>=20
>> return;
>> }
>> /* Low threshold defaults to 75% of upper threshold */
>> @@ -1015,7 +1015,8 @@ __always_inline void =
ip_vs_dest_update_overload(struct ip_vs_dest *dest)
>> return;
>>=20
>> unset:
>> - dest->flags &=3D ~IP_VS_DEST_F_OVERLOAD;
>> + if (test_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2))
>> + clear_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2);
>=20
> if (dest->flags & IP_VS_DEST_F_OVERLOAD) {
> if (!locked)
> return false;
> dest->flags &=3D ~IP_VS_DEST_F_OVERLOAD;
> }
> return true;
>=20
>> }
>>=20
>> /*
>> @@ -1174,7 +1175,7 @@ static inline void ip_vs_unbind_dest(struct =
ip_vs_conn *cp)
>> atomic_dec(&dest->persistconns);
>> }
>>=20
>> - if (dest->flags & IP_VS_DEST_F_OVERLOAD)
>> + if (test_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2))
>> ip_vs_dest_update_overload(dest);
>=20
> if (dest->flags & IP_VS_DEST_F_OVERLOAD) {
> if (!ip_vs_dest_update_overload(dest, false)) {
> spin_lock_bh(&dest->dst_lock);
> ip_vs_dest_update_overload(dest, true);
> spin_unlock_bh(&dest->dst_lock);
> }
> }
>=20
> In __ip_vs_update_dest() we will always use lock:
>=20
> spin_lock_bh(&dest->dst_lock);
> WRITE_ONCE(dest->u_threshold, udest->u_threshold);
> WRITE_ONCE(dest->l_threshold, udest->l_threshold);
> ip_vs_dest_update_overload(dest, true);
> spin_unlock_bh(&dest->dst_lock);
>=20
> The goal is to avoid the lock for the common case
> when flag does not change. What do you think?

I looked more closely at the proposed dst_lock retry. I think there
is still a window because the connection counters are modified=20
outside dst_lock in this approach.

For example, CPU A can bind a connection, take dst_lock, and in
ip_vs_dest_update_overload(dest, true) observe conns >=3D u. Before it
sets OVERLOAD, CPU B can expire the remaining connections. Since
OVERLOAD is still clear, B skips the unbind helper and does not take
dst_lock. CPU A can then resume and set OVERLOAD after the connection
count has reached zero.

At that point no later unbind is guaranteed to clear the bit, while
schedulers can avoid the destination because it appears overloaded.

The correct solution is to take dst_lock for every bind/unbind, however, =
it=20
seems costly. I=E2=80=99m sorry I didn=E2=80=99t find a better solution. =
Is there a lighter
synchronization scheme you had in mind?

>=20
> Regards
>=20
> --
> Julian Anastasov <ja@ssi.bg>

Regards,
Yizhou

