Received: from zg8tmja2lje4os4yms4ymjma.icoremail.net (zg8tmja2lje4os4yms4ymjma.icoremail.net [206.189.21.223])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 5C1C7346E70;
	Wed,  8 Jul 2026 06:11:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=206.189.21.223
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783491112; cv=none; b=lc6WRIYua8GSWvLFo3BUhswEtLLsSm1rBcsg4PhQQ1EthsnIsJ9nD3Hge8avdlOwHZGLORHHexXLLBAGYy2knCWUaW5hjdIDYWbZP+nPD2wGIfV/jfJ66rtW7QcqRhS6KJmlMiaRfTthNIYLUaLMd5U6p0s06pez3BpzR+oRJQE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783491112; c=relaxed/simple;
	bh=NCDSq0bVfwbwV1n+rWGUYBeBmBz37eP6OqsknRr0HPo=;
	h=Content-Type:Mime-Version:Subject:From:In-Reply-To:Date:Cc:
	 Message-Id:References:To; b=mjBDd3uW/ND5ULtA/nAbDrul4SuAMWh/cLgo2A2PHUp0i7FSNKdTL0hz9X1PBiXjTCYugCCikBkdUrfbBA6cZbcoI3O78f4mijEAQwxA4/RDDzi6iZFa9jziQCcyokBcj+5XiaL/xbp9IWzo+HpyE0UzJ1HNKDl8EqHMrgvOJJ8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=mails.tsinghua.edu.cn; spf=pass smtp.mailfrom=mails.tsinghua.edu.cn; dkim=pass (1024-bit key) header.d=mails.tsinghua.edu.cn header.i=@mails.tsinghua.edu.cn header.b=lG/5n0MP; arc=none smtp.client-ip=206.189.21.223
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=mails.tsinghua.edu.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=mails.tsinghua.edu.cn
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=mails.tsinghua.edu.cn header.i=@mails.tsinghua.edu.cn header.b="lG/5n0MP"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=mails.tsinghua.edu.cn; s=dkim; h=Received:Content-Type:
	Mime-Version:Subject:From:In-Reply-To:Date:Cc:
	Content-Transfer-Encoding:Message-Id:References:To; bh=xY7vm8/nb
	YuNfFUTtT+pfhWgkWxH7nBjPPBDaOT7fcE=; b=lG/5n0MPPBzKoEiu8BMWR5Z5z
	qkVLYzxcafDUoTdqexCS3EKJ5//4GaAslhjFpeQU3a25V7sJvI2DrHZfVo42VtLR
	tmhccIbAT+55MEFq3bt8M2B9rFZmN3a0rZqGLzQDfl0+CK5uBNf5wZhe3ZBYfYuj
	PXMC6eJiY0NYPzOqIA=
Received: from smtpclient.apple (unknown [211.102.241.101])
	by web3 (Coremail) with SMTP id ygQGZQAndZIC6k1q6sUIAw--.47788S2;
	Wed, 08 Jul 2026 14:11:14 +0800 (CST)
Content-Type: text/plain;
	charset=us-ascii
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3826.700.81.1.8\))
Subject: Re: [PATCH nf] ipvs: make destination flags atomic
From: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
In-Reply-To: <41c3d792-af7d-5582-5057-ac3df5f7bfd6@ssi.bg>
Date: Wed, 8 Jul 2026 14:11:04 +0800
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
 linux-kernel@vger.kernel.org,
 netfilter-devel@vger.kernel.org,
 coreteam@netfilter.org,
 stable@vger.kernel.org,
 Yuxiang Yang <yangyx22@mails.tsinghua.edu.cn>,
 Ao Wang <wangao@seu.edu.cn>,
 Xuewei Feng <fengxw06@126.com>,
 Qi Li <qli01@tsinghua.edu.cn>,
 Ke Xu <xuke@tsinghua.edu.cn>,
 zhaoyz24@mails.tsinghua.edu.cn
Content-Transfer-Encoding: quoted-printable
Message-Id: <91509A0C-9E4A-4F0E-A45C-ABD29396067E@mails.tsinghua.edu.cn>
References: <20260707085706.96322-1-zhaoyz24@mails.tsinghua.edu.cn>
 <41c3d792-af7d-5582-5057-ac3df5f7bfd6@ssi.bg>
To: Julian Anastasov <ja@ssi.bg>
X-Mailer: Apple Mail (2.3826.700.81.1.8)
X-CM-TRANSID:ygQGZQAndZIC6k1q6sUIAw--.47788S2
X-Coremail-Antispam: 1UD129KBjvJXoWxCw45KFykZF18uFyUtry8uFg_yoW5Ww1Up3
	y7KFZ5KayDKr9a9r12yw4aqFW8C3WkGa4jyr1Dtw17Z3s0vr1Yqr93tFW5CFy7ZFZ3Z3WI
	vFWjq3srAasFyFJanT9S1TB71UUUUU7qnTZGkaVYY2UrUUUUjbIjqfuFe4nvWSU5nxnvy2
	9KBjDU0xBIdaVrnRJUUUP014x267AKxVW5JVWrJwAFc2x0x2IEx4CE42xK8VAvwI8IcIk0
	rVWrJVCq3wAFIxvE14AKwVWUJVWUGwA2ocxC64kIII0Yj41l84x0c7CEw4AK67xGY2AK02
	1l84ACjcxK6xIIjxv20xvE14v26F1j6w1UM28EF7xvwVC0I7IYx2IY6xkF7I0E14v26r4U
	JVWxJr1l84ACjcxK6I8E87Iv67AKxVW0oVCq3wA2z4x0Y4vEx4A2jsIEc7CjxVAFwI0_Gc
	CE3s1lnxkEFVAIw20F6cxK64vIFxWle2I262IYc4CY6c8Ij28IcVAaY2xG8wAqx4xG64xv
	F2IEw4CE5I8CrVC2j2WlYx0E2Ix0cI8IcVAFwI0_JrI_JrylYx0Ex4A2jsIE14v26r1j6r
	4UMcvjeVCFs4IE7xkEbVWUJVW8JwACjcxG0xvY0x0EwIxGrwACjI8F5VA0II8E6IAqYI8I
	648v4I1lFIxGxcIEc7CjxVA2Y2ka0xkIwI1lc7CjxVAaw2AFwI0_GFv_Wrylc2xSY4AK67
	AK6r47MxAIw28IcxkI7VAKI48JMxC20s026xCaFVCjc4AY6r1j6r4UMI8I3I0E5I8CrVAF
	wI0_Jr0_Jr4lx2IqxVCjr7xvwVAFwI0_JrI_JrWlx4CE17CEb7AF67AKxVW8ZVWrXwCIc4
	0Y0x0EwIxGrwCI42IY6xIIjxv20xvE14v26r1j6r1xMIIF0xvE2Ix0cI8IcVCY1x0267AK
	xVW8JVWxJwCI42IY6xAIw20EY4v20xvaj40_Jr0_JF4lIxAIcVC2z280aVAFwI0_Jr0_Gr
	1lIxAIcVC2z280aVCY1x0267AKxVW8JVW8JrUvcSsGvfC2KfnxnUUI43ZEXa7sRETKZJUU
	UUU==
X-CM-SenderInfo: 52kd05r2suqzpdlo2hxwvl0wxkxdhvlgxou0/1tbiAgACAWpNfR6iqQAAsO

Hi Julian,


> On Jul 8, 2026, at 03:18, Julian Anastasov <ja@ssi.bg> wrote:
>=20
>=20
> Hello,
>=20
> On Tue, 7 Jul 2026, Yizhou Zhao wrote:
>=20
>> is_unavailable() in the SH scheduler reads dest->flags from the =
packet
>> scheduling path while holding only the RCU read lock.  The same word =
is
>> updated by read-modify-write operations from connection accounting =
and
>> destination update paths, for example ip_vs_bind_dest(),
>> ip_vs_unbind_dest(), and __ip_vs_update_dest().
>>=20
>> The RCU read lock only protects the destination lifetime; it does not
>> serialize accesses to dest->flags.  A racing plain load or RMW update =
can
>> therefore observe stale state or lose an AVAILABLE/OVERLOAD bit =
update,
>> which can make the scheduler choose an overloaded destination or =
report no
>> available destination even though one should be usable.
>=20
> While the patch correctly serializes the concurrent
> modifications for the flags, we can not claim that the scheduler
> will not choose an overloaded or unavailable destination.
> The patch does not change the fact that we can work with
> stale data.
>=20
> We can compare 3 solutions, from fast to slow:
>=20
> 1. atomic_read or test_bit
> - no memory barriers for the readers
> - no memory ordering (=3D> stale data)
>=20
> PRO:
> - serializes RMW operations
>=20
> CON:
> - readers can use old values
> - writers may need to synchronize while changing
> the flags, eg. to check the thresholds and update the
> flags in atomic way. We do not do this.
>=20
> 2. Use refcount_inc_not_zero(&dest->available) from readers
>=20
> - and put the ref immediately or later:
>=20
> smp_mb__before_atomic();
> refcount_dec(&dest->available);
>=20
> - alternative: RMW such as atomic_fetch_add
>=20
> - writers can synchronize by using the IP_VS_DEST_F_AVAILABLE
> flag and then to inc/dec &dest->available when the
> flag changes
> - the same can be done for &dest->not_overloaded and
> IP_VS_DEST_F_OVERLOAD
> - PRO: readers are serialized perfectly with the
> changed value, new packets will detect the changes
> immediately
> - CON:
> - 2 full memory barriers for the readers
> - writers may need to synchronize while changing
> the flags
>=20
> 3. read_lock/write_lock
> - PRO: can modify more things under write lock
> - CON: full memory barriers
>=20
> With this patch you choose solution 1.
> The other solutions can be expensive for the fast path.
> Lets fix the commit message. Also, it is better to fix the
> scripts/checkpatch.pl warnings about the 'if' conditions,
> even if they are not introduced now.
>=20
> Regards
>=20
> --
> Julian Anastasov <ja@ssi.bg>

Thank you for your suggestions.

We have posted a v2 patch at:
=
https://lore.kernel.org/netfilter-devel/20260708060454.20534-1-zhaoyz24@ma=
ils.tsinghua.edu.cn/

The v2 patch updates the commit message with more conservative
wording, and fixes the checkpatch logical-continuation warnings.

Regards,
Yizhou=

