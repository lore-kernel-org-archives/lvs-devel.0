Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8320C272E6D;
	Wed, 25 Mar 2026 04:55:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774414511; cv=none; b=YgV/ZsCQO2GCYCRNVLx3Ga9hMeKls/ck91MdnkBuZYwuVgkQ9UYmJVNiTghD5HHLTrhxzSaeS/ogvZsBGKBfullLPu0FrBUPyWK8ZQZ8wU5dCdq7Jq1q3AcjBqcILsx0eJjTtEexePMV989rUsD6E02Mrh8sYMEs7fIg/Gw19Cw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774414511; c=relaxed/simple;
	bh=qdImSBPzupl5FH7oqSRosfZOz2xQbStMQCbgPZiDC9o=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=UXVooIgsnvivc0S059KKaeWuCKhcV1nXufatQ/VuWIDV1/C2Qqm4GmSd/yMRgGxZHzT2SE932Hc2DQm1W9GQwCMEwLOUnDFlaPrAPZv6gVMVJmTLPjkGVcEdLsYonttSDKeJsMwKFTSZqF8/Io/KnP1/9aBvb/Ta7hfJQtJ7tec=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=5JeObb8p; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="5JeObb8p"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 1BCA9217F8;
	Wed, 25 Mar 2026 06:54:58 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=7UnVyPtcnhUlOcLDILTbI3B1tbIPUQ62JS9Ucwi6NEY=; b=5JeObb8pWmFE
	vbWlGsRtlmeBiqjI9vwjW1NED5ucvi8JT3v1U0EC7SNgcDDxfbzab60u4K10yLNj
	KPSazQKqqOItueG3D5QVBXR39IJ7hd+z2+ZllYZ54Fr+ErVSajd2ao8vLOlS26AF
	yo3KQNYfpNvmSDcqRERm7WRLpVAmDbf3L7DEyGy5+MUfSQhmUkOPtNmhfPj9ib7Z
	ilFFkzpwCfNlZEuau4U2ig7Ovwp36u1R7WwP5O2zfj8Fe8hFJ+flPZXcJ43S2Dhu
	JkX01PDm5ctFVhijBy//g5fAtVrC/44ae6ZVh/l28WwdAGWZ7z6/kZIQ6zrAmVIA
	ylxdN5PQ8Qw7UPlOAUsieJsNAbpCm2ivG7DLhJ2wmBV6NCIrJUfe0Xmsxd/JG7rZ
	fWAHWWle5YQ/X1k/F8TlGVRD05PKBUkrobu8WS3Jh74Ld07auPBPDw4IGIcAaDWo
	tQv4Wnvtg3CEjpuOTvWTnMxjIsYEaU50sd0ZmDO0r8L+0Ow+DUBwACMOCnwjPB7h
	XawAvlcX3mBI46i9GhkNfLd0yNZdscbCasjEM6q/SSrG320HM9uGk7rDjqaZLTJH
	AUPDWDqsl/6CPQqA/62x+EDzF9x2K1DD+fMdir2qMzwMp8Py+ztcs+ZsTtd4JW78
	bghTJ97nycYlbTg1rQ8JNqdLjOchNzQ=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 25 Mar 2026 06:54:57 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 1E7F6609D8;
	Wed, 25 Mar 2026 06:54:56 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 62P4sgY5004260;
	Wed, 25 Mar 2026 06:54:43 +0200
Date: Wed, 25 Mar 2026 06:54:42 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Florian Westphal <fw@strlen.de>
cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>
Subject: Re: [PATCH nf-next 3/3] ipvs: add conn_lfactor and svc_lfactor sysctl
 vars
In-Reply-To: <acKLSxnxYWCPKDBR@strlen.de>
Message-ID: <331e1dc8-ec57-0a09-bf71-686c53462cb1@ssi.bg>
References: <20260323162523.44964-1-ja@ssi.bg> <20260323162523.44964-4-ja@ssi.bg> <acKLSxnxYWCPKDBR@strlen.de>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Tue, 24 Mar 2026, Florian Westphal wrote:

> Julian Anastasov <ja@ssi.bg> wrote:
> > +			*valp = val;
> > +			if (rcu_dereference_protected(ipvs->conn_tab, 1))
> > +				mod_delayed_work(system_unbound_wq,
> > +						 &ipvs->conn_resize_work, 0);
> 
> Can I change this to rcu_access_pointer()?

	Yes, both proc handlers should use it, thanks!

> rcu_dereference_protected( ... , 1)
> 
> ... always looks like a bug to me, even though its fine here.

Regards

--
Julian Anastasov <ja@ssi.bg>

