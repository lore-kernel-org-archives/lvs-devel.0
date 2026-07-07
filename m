Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5B2022D876A;
	Tue,  7 Jul 2026 19:18:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783451929; cv=none; b=U+VywhXRyDJ0/UmUdsxPn8Y6ZwAK1Z+uZPW3bwTGe47UBTzHSI3tOZDGXTGWBvNKeQ9NtCG2OSvB3sflLqZMknCq7u2+V02fY6YgU2j5gjxxRypiY/bz27Rl0fjHtYYYT+DOczs/Wz2wm6DDVxFutzazIsa7CfL+hM2cL6WViYE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783451929; c=relaxed/simple;
	bh=84RAJy1+m4IDIpbc/Vr19KuJOpMAkhJJBnJ4PFLm/yY=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=qO8OWjTXvccjYEfpiy2tYcN0J0asDIxIC2SGqW/B1TVhM32LHg4cVv/csVQ85caR5DwmVV7D6uw06H0hIDZ8XPZ8HymBq4DY4aYqniPB/Osabo6XIgTBpvZm/1QAsif7FJY15DH772+R3tnGrO7JXMecvJg/a8IqkQ9+EpwljOY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=PyXjxGrQ; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="PyXjxGrQ"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 512BC2121F;
	Tue, 07 Jul 2026 22:18:44 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=RWeYm4FQ+YZWg9e8z0ezoKNKTxN0sebs0a4TpewL3uQ=; b=PyXjxGrQFt+h
	h5EO+BlT99UkJFRP/r+SJRH3z1CXcQvz4Fp61Fsy3Aujg6L8EmvtZZ7OCsjOM0nZ
	QbDRXnbzRJGBXiyxb2EcEkUnYdJwDyclbK3TDIbe9U4mlgqV25J3En96EzM+lD6E
	I3oV5pcreqUA90E7Q5lihGpaLhTCeL6GJrxTdz0DfVcDKM4BtHHLq1teo4dz2SVg
	VKlZe9Ghx2eWMv2+uDp0eDSZPbuxVVNyabGtJnGq7hUmY1DNZICDL1xEd675nZS3
	ggJjCECIyTLZrEMP6xSLjZKBithvRkQ6j09kxWLlq2VlyrPaiyiZjOFWKMyMkTJT
	z1jWgDEaSqckjhca80LQr/R8fxmzpjsv1/XSyaK7BwB5/JprqXh2h2H5VSaOku6+
	3Q/2FgRIwiuZt9a+1gIDDX7mq3EfWef6KdmZ+sKtLDsTNkqn3L6V8E1uzVmR6iW7
	uo3Tg5E1EzmfPMwLVG0s8v7/0WIim6f1GtZh6S8ZUhtLXt6ez2T3OXU2t5Aq+G+J
	q6PHNuzPm4xbkUTFxb27eGj6RR36PzHnkYruxr+mKEXA8RDgTkJ/K413nYEFfM2H
	O0NbAnJO9lGM0a+RBarQuZO61dDj3Lvq1yRPwUVzoEr89JjpzQJKiFTK8+vFFk4r
	eM4qGV2mDCt/BoxR1Qe4SSSuQzrteCI=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 07 Jul 2026 22:18:44 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 393C161C4F;
	Tue,  7 Jul 2026 22:18:39 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 667JIQNR076297;
	Tue, 7 Jul 2026 22:18:28 +0300
Date: Tue, 7 Jul 2026 22:18:26 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
cc: Simon Horman <horms@verge.net.au>, David Ahern <dsahern@kernel.org>,
        Ido Schimmel <idosch@nvidia.com>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        Alexander Frolkin <avf@eldamar.org.uk>, netdev@vger.kernel.org,
        lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        stable@vger.kernel.org, Yuxiang Yang <yangyx22@mails.tsinghua.edu.cn>,
        Ao Wang <wangao@seu.edu.cn>, Xuewei Feng <fengxw06@126.com>,
        Qi Li <qli01@tsinghua.edu.cn>, Ke Xu <xuke@tsinghua.edu.cn>
Subject: Re: [PATCH nf] ipvs: make destination flags atomic
In-Reply-To: <20260707085706.96322-1-zhaoyz24@mails.tsinghua.edu.cn>
Message-ID: <41c3d792-af7d-5582-5057-ac3df5f7bfd6@ssi.bg>
References: <20260707085706.96322-1-zhaoyz24@mails.tsinghua.edu.cn>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Tue, 7 Jul 2026, Yizhou Zhao wrote:

> is_unavailable() in the SH scheduler reads dest->flags from the packet
> scheduling path while holding only the RCU read lock.  The same word is
> updated by read-modify-write operations from connection accounting and
> destination update paths, for example ip_vs_bind_dest(),
> ip_vs_unbind_dest(), and __ip_vs_update_dest().
> 
> The RCU read lock only protects the destination lifetime; it does not
> serialize accesses to dest->flags.  A racing plain load or RMW update can
> therefore observe stale state or lose an AVAILABLE/OVERLOAD bit update,
> which can make the scheduler choose an overloaded destination or report no
> available destination even though one should be usable.

	While the patch correctly serializes the concurrent
modifications for the flags, we can not claim that the scheduler
will not choose an overloaded or unavailable destination.
The patch does not change the fact that we can work with
stale data.

	We can compare 3 solutions, from fast to slow:

1. atomic_read or test_bit
	- no memory barriers for the readers
	- no memory ordering (=> stale data)

	PRO:
	- serializes RMW operations

	CON:
	- readers can use old values
	- writers may need to synchronize while changing
	the flags, eg. to check the thresholds and update the
	flags in atomic way. We do not do this.

2. Use refcount_inc_not_zero(&dest->available) from readers

	- and put the ref immediately or later:

	smp_mb__before_atomic();
	refcount_dec(&dest->available);

	- alternative: RMW such as atomic_fetch_add

	- writers can synchronize by using the IP_VS_DEST_F_AVAILABLE
	flag and then to inc/dec &dest->available when the
	flag changes
	- the same can be done for &dest->not_overloaded and
	IP_VS_DEST_F_OVERLOAD
	- PRO: readers are serialized perfectly with the
	changed value, new packets will detect the changes
	immediately
	- CON:
		- 2 full memory barriers for the readers
		- writers may need to synchronize while changing
		the flags

3. read_lock/write_lock
	- PRO: can modify more things under write lock
	- CON: full memory barriers

	With this patch you choose solution 1.
The other solutions can be expensive for the fast path.
Lets fix the commit message. Also, it is better to fix the
scripts/checkpatch.pl warnings about the 'if' conditions,
even if they are not introduced now.

Regards

--
Julian Anastasov <ja@ssi.bg>

