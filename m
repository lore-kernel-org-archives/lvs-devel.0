Received: from azure-sdnproxy.icoremail.net (azure-sdnproxy.icoremail.net [13.76.78.106])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id E331E386429;
	Tue,  7 Jul 2026 05:39:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=13.76.78.106
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783402758; cv=none; b=CZYGeEJgMOgUvbflfBPfjb5FRWzpvv5C5QQHfhFSs/VZUuZ5yLLDmizYHkvGFhllk0M1J2L9xRtNNqS9dslp4XP9CW9Xo5TNhgCZriH+HPATffZQfuPEcPhPfHRT8Xxnpxvw1CNF4NwlKp56ASrN18VY46zbBgTWoSXwqJGpObU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783402758; c=relaxed/simple;
	bh=SY4IMC/Ddp2wMdcBI7IRusXV9eWYkEXvUrqXCdfG+fc=;
	h=Content-Type:Mime-Version:Subject:From:In-Reply-To:Date:Cc:
	 Message-Id:References:To; b=dwhGqTbEf4I6diQsQzaNu6PMZsP05Gsbp6iH+9L99GddSniaHsgziu9kgKYjW7f+HA26Zepca5xXGOS11uuH9o8hi25lCkHVZoMmna/HNlafb2FIC+Gx67de12ixzi5C15NVtJ9UFzhlb5BfnsjwnLgKfB3WuVaI7I/Af/BHKHs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=mails.tsinghua.edu.cn; spf=pass smtp.mailfrom=mails.tsinghua.edu.cn; dkim=pass (1024-bit key) header.d=mails.tsinghua.edu.cn header.i=@mails.tsinghua.edu.cn header.b=q/k/j+Vd; arc=none smtp.client-ip=13.76.78.106
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=mails.tsinghua.edu.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=mails.tsinghua.edu.cn
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=mails.tsinghua.edu.cn header.i=@mails.tsinghua.edu.cn header.b="q/k/j+Vd"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=mails.tsinghua.edu.cn; s=dkim; h=Received:Content-Type:
	Mime-Version:Subject:From:In-Reply-To:Date:Cc:
	Content-Transfer-Encoding:Message-Id:References:To; bh=HKp8jKsDh
	acYe+U+r45zxu77QLGaXMYgMAaK8XzGGzQ=; b=q/k/j+VdJCH26dQXVLdbqVw2q
	CRlvaLbEIVhEbjKcpgOUlKSuyWKIOqtMNIaNePn0b5jdb8hqSbKeKYQUw4Y59PrM
	meEQm3Pq/mntTBo3pUJylvUbuBI6jNQOIwwGQQLURksDZK/m1EFhgucMCAkfDnlo
	e6ckUPbatU0N2hFAxQ=
Received: from smtpclient.apple (unknown [101.5.13.242])
	by web2 (Coremail) with SMTP id yQQGZQDXsprTkExqpkjKAg--.28065S2;
	Tue, 07 Jul 2026 13:38:28 +0800 (CST)
Content-Type: text/plain;
	charset=us-ascii
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3826.700.81.1.8\))
Subject: Re: [PATCH nf] ipvs: skip IPv6 extension headers in SCTP state lookup
From: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
In-Reply-To: <bcd7f0e6-b2fc-4e54-f9ac-e1c8b1b0c497@ssi.bg>
Date: Tue, 7 Jul 2026 13:38:18 +0800
Cc: netdev@vger.kernel.org,
 Simon Horman <horms@verge.net.au>,
 Pablo Neira Ayuso <pablo@netfilter.org>,
 Florian Westphal <fw@strlen.de>,
 Phil Sutter <phil@nwl.cc>,
 "David S. Miller" <davem@davemloft.net>,
 Eric Dumazet <edumazet@google.com>,
 Jakub Kicinski <kuba@kernel.org>,
 Paolo Abeni <pabeni@redhat.com>,
 lvs-devel@vger.kernel.org,
 netfilter-devel@vger.kernel.org,
 coreteam@netfilter.org,
 linux-kernel@vger.kernel.org,
 Yuxiang Yang <yangyx22@mails.tsinghua.edu.cn>,
 Ao Wang <wangao@seu.edu.cn>,
 Xuewei Feng <fengxw06@126.com>,
 Qi Li <qli01@tsinghua.edu.cn>,
 Ke Xu <xuke@tsinghua.edu.cn>,
 stable@vger.kernel.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <52493DF7-5590-48A1-B76B-21BBC2401687@mails.tsinghua.edu.cn>
References: <20260705123040.35755-1-zhaoyz24@mails.tsinghua.edu.cn>
 <92783c87-7e6a-e90a-b2fc-e5d1332139e0@ssi.bg>
 <87E04893-B2B2-485F-B242-9CACF2F176D6@mails.tsinghua.edu.cn>
 <bcd7f0e6-b2fc-4e54-f9ac-e1c8b1b0c497@ssi.bg>
To: Julian Anastasov <ja@ssi.bg>
X-Mailer: Apple Mail (2.3826.700.81.1.8)
X-CM-TRANSID:yQQGZQDXsprTkExqpkjKAg--.28065S2
X-Coremail-Antispam: 1UD129KBjvJXoWxAryrZry8Kw48KF1UXFyfCrg_yoW5tFWUpa
	ykKa4fXrZrJrWftwn7GryfXa48Gr1DGry7WrZ5KryfCFn8tr13KFnIk3yYkFZruryqkFy8
	tFyYva4DZ3Wqy3DanT9S1TB71UUUUU7qnTZGkaVYY2UrUUUUjbIjqfuFe4nvWSU5nxnvy2
	9KBjDU0xBIdaVrnRJUUU9v1xkIjI8I6I8E6xAIw20EY4v20xvaj40_Wr0E3s1l8cAvFVAK
	0II2c7xJM28CjxkF64kEwVA0rcxSw2x7M28EF7xvwVC0I7IYx2IY67AKxVW7JVWDJwA2z4
	x0Y4vE2Ix0cI8IcVCY1x0267AKxVWxJVW8Jr1l84ACjcxK6I8E87Iv67AKxVW0oVCq3wA2
	z4x0Y4vEx4A2jsIEc7CjxVAFwI0_GcCE3s1lnxkEFVAIw20F6cxK64vIFxWle2I262IYc4
	CY6c8Ij28IcVAaY2xG8wAqx4xG64xvF2IEw4CE5I8CrVC2j2WlYx0E74AGY7Cv6cx26r4r
	Kr1UJr1lOx8S6xCaFVCjc4AY6r1j6r4UM4x0Y48IcxkI7VAKI48JM4x0x7Aq67IIx4CEVc
	8vx2IErcIFxwACI402YVCY1x02628vn2kIc2xKxwCY1x0262kKe7AKxVW8ZVWrXwCY02Av
	z4vE14v_GrWl42xK82IYc2Ij64vIr41l42xK82IY6x8ErcxFaVAv8VW8Ww4UJr1UMxC20s
	026xCaFVCjc4AY6r1j6r4UMI8I3I0E5I8CrVAFwI0_Jr0_Jr4lx2IqxVCjr7xvwVAFwI0_
	JrI_JrWlx4CE17CEb7AF67AKxVW8ZVWrXwCIc40Y0x0EwIxGrwCI42IY6xIIjxv20xvE14
	v26r1j6r1xMIIF0xvE2Ix0cI8IcVCY1x0267AKxVW8JVWxJwCI42IY6xAIw20EY4v20xva
	j40_Jr0_JF4lIxAIcVC2z280aVAFwI0_Jr0_Gr1lIxAIcVC2z280aVCY1x0267AKxVW8JV
	W8JrUvcSsGvfC2KfnxnUUI43ZEXa7VU1veHPUUUUU==
X-CM-SenderInfo: 52kd05r2suqzpdlo2hxwvl0wxkxdhvlgxou0/1tbiAQUBAWpMKrKTLgABsG

Hi Julian,

> On Jul 6, 2026, at 22:17, Julian Anastasov <ja@ssi.bg> wrote:
>=20
>=20
> Hello,
>=20
> On Mon, 6 Jul 2026, Yizhou Zhao wrote:
>=20
>>> On Jul 6, 2026, at 01:35, Julian Anastasov <ja@ssi.bg> wrote:
>>>=20
>>> May be it is better starting from ip_vs_set_state()
>>> to provide new arg 'int iph_len/offset' (set to iph.len), down to
>>> state_transition(), sctp_state_transition() and set_sctp_state().
>>> Same for all protos. It should cost less stack and ipv6_find_hdr()
>>> calls and what matters most, correct iph context in case we
>>> have IP+ICMP+TCP (with just two ports or even with TCP flags)
>>> and are scheduling ICMP, i.e. not IP+TCP as usually.
>>=20
>> I agree that the already parsed transport-header offset should be=20
>> passed from ip_vs_set_state() down to the protocol state_transition()=20=

>> callbacks, instead of reparsing the skb in set_sctp_state(). We will=20=

>> send a v2 that does this for SCTP, TCP and the other IPVS protocols=20=

>> in one combined fix.
>>=20
>>> But what I see is that ip_vs_in_icmp*() are missing
>>> the ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pd) call just
>>> after ip_vs_in_stats() and before ip_vs_icmp_xmit() where
>>> we should provide ciph.len. That is why we don't reach the
>>> set_tcp_state() calls to set correct cp->state and timeout
>>> when scheduling related ICMP. So, this should be fixed too.
>>=20
>> For the ICMP path, I agree that the missing ip_vs_set_state() call is
>> worth looking at, but using ICMP errors to drive the upper L4 state=20=

>> needs some care, because spoofed ICMP packets can match an=20
>> existing embedded tuple before the endpoint TCP/SCTP stack=20
>> performs its own validation. Maybe this change needs further
>> discussion?
>=20
> May be only for the schedule_icmp case while the other
> ICMP replies should not change it:
>=20
> diff --git a/net/netfilter/ipvs/ip_vs_core.c =
b/net/netfilter/ipvs/ip_vs_core.c
> index 7f93239898ff..05fdcf4ce2c0 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1971,6 +1971,8 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct =
sk_buff *skb, int *related,
>=20
> /* do the statistics and put it back */
> ip_vs_in_stats(cp, skb);
> + if (new_cp)
> + ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pd, offset);
> if (IPPROTO_TCP =3D=3D cih->protocol || IPPROTO_UDP =3D=3D =
cih->protocol ||
>    IPPROTO_SCTP =3D=3D cih->protocol)
> offset +=3D 2 * sizeof(__u16);
>=20
> Here is why schedule_icmp was added:
>=20
> =
https://archive.linuxvirtualserver.org/html/lvs-devel/2015-08/msg00015.htm=
l
>=20
> But the inner TCP header should be generated by the
> real server, not from the client, so things can go wrong. We can
> leave it as it is now - we will forward the ICMP to the right real=20
> server by using short conn timeout...

I agree. The embedded TCP/SCTP header in this path may not have the same
meaning as a normal client packet reaching the virtual service, so I do =
not
see a good fix for the ICMP state update part at the moment.

BTW, we have kept the ICMP handling unchanged and submitted a v2 series
for the parsed transport-offset issue only, following your earlier =
suggestion
to pass the already parsed offset from ip_vs_set_state() down to the =
protocol
state handlers. The v2 also puts the TCP and SCTP fixes in the same =
thread:

=
https://lore.kernel.org/netdev/20260706101624.69471-1-zhaoyz24@mails.tsing=
hua.edu.cn/

Thanks for the review.

>=20
> Regards
>=20
> --
> Julian Anastasov <ja@ssi.bg>

Thanks,
Yizhou=

