Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3300E395243;
	Tue, 21 Jul 2026 06:19:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784614760; cv=none; b=WYfQZhKEy1NBDE2bxRIl+Iowg7ty4g/0+cBP9+mLfDkO/1dteWot1eXqyERJvHqglv+qqvhELYuqycEqBTxW8ZOvLo0lJuO4ikTkOma8UsH5BmKT3pYHDC9Fm78DuSekXA3mv3k0HkT+zZKKwHtVA7MTjaEsj6ka0in/l8GHe1k=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784614760; c=relaxed/simple;
	bh=G8qajlR1rHRi5g91l+aqa/cCyF9IFQw8YtX9O3Ghcc4=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=Iebv+Qk0BuyoJFo172T8hdMNuyKqdvyOFHZpEgpoQFj8QXBXioZBVzOfagj8sTv2SprA1b/EJC+TKXUsMWSDp0c8/vw8f+bkG1rXeI0MjhCAO+zihpI2R2NuVJt/zvJ1YhfHIaKehga/nAFnEaUGg9C18r9YFjJ2kjfI2f8GrsA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=WTDgHnj4; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="WTDgHnj4"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 8CF5622280;
	Tue, 21 Jul 2026 09:19:10 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=1OgyT6W3Fp+l6f05zqt5+InPEn9gCdqcwekwYa1FJV4=; b=WTDgHnj4RiQP
	2Wst0gOHQuQPKiMOC2BzxvmLcOplQM3iDZgE1U9/NIsl3chi0e9Zas+Et3jIqyBL
	zBQ6i3oZT5qwabEnDD4qzPvyJRhU5CCQyl53Wf/Oa7luiqBrdIc+iHDB7xtLQb+v
	E9befos0MmUih84D5a1yxj8rQF8a2aGN471Brx+FgHv7zy2BdfxOxK/sZbEYbLId
	Yg6NQGvrEtCOsmiITXlDp7pq5hmFHjdTFB6+YZaRSx/odac/Jk7H5CIyj+xeB9xM
	0HRmvzJLGKEKyQih/BN9QubnpSpjTZHHMbuHIVL/r0o0pe9hJl4cfF5GN+J/zSog
	Qrs/e1U8LoMSmND9jw6MLOAGwyn+3NdnRYsUXRIUP7sStnUxyLG8JnjJxPwkk17S
	5GalnDN0D/i4SOaJjSNBm2XZXHxXoP7oXFV4DhTIPlQUlSDmsFXfEquUejF5x92p
	DjIvJFxiN/tQuzFl6OoLt32l4AsHHePVZavIEPyM0m+4oWMNPBOTs97exa/fzECl
	miLec1jTqx6XF68cn/a+L1u1qaaBTnI5TD60cLqzmcEDiuNSNPF3BSXzoW2o3X7K
	pS6FFI3BAwQBPzAUsVaWoQH/8Otkm1dVRotlg9ZliP0yI5DoMwV+0TdRr+pPLkeL
	PaT08wAYVlEQhVvuQf4ZEswkzXAvfhE=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 21 Jul 2026 09:19:10 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id DBCFC604ED;
	Tue, 21 Jul 2026 09:19:11 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 66L6J6s3011289;
	Tue, 21 Jul 2026 09:19:09 +0300
Date: Tue, 21 Jul 2026 09:19:06 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: Re: [PATCH nf v2 0/2] ipvs: csum validations and data offsets
In-Reply-To: <20260720201122.79882-1-ja@ssi.bg>
Message-ID: <e12eab08-78a5-1a36-3c91-4115e401da0e@ssi.bg>
References: <20260720201122.79882-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 20 Jul 2026, Julian Anastasov wrote:

> 	This patchset contains fixes for the checksum
> validations for ICMPv6 and switches TCP, UDP and ICMP to
> use nf_checksum for LOCAL_IN.
> 
> 	It also corrects offsets to be based on skb->data and to
> respect the network offset.
> 
> Julian Anastasov (2):
>   ipvs: fix the checksum validations
>   ipvs: fix places with wrong packet offsets

	There are some compiler warnings for unused vars,
will send v3...

pw-bot: changes-requested

>  include/net/ip_vs.h                   |  49 +++++++--
>  net/netfilter/ipvs/ip_vs_app.c        |   4 +-
>  net/netfilter/ipvs/ip_vs_core.c       | 149 ++++++++++++++------------
>  net/netfilter/ipvs/ip_vs_proto_sctp.c |  19 ++--
>  net/netfilter/ipvs/ip_vs_proto_tcp.c  |  48 ++-------
>  net/netfilter/ipvs/ip_vs_proto_udp.c  |  54 +++-------
>  net/netfilter/ipvs/ip_vs_xmit.c       |  26 ++---
>  7 files changed, 172 insertions(+), 177 deletions(-)

Regards

--
Julian Anastasov <ja@ssi.bg>

