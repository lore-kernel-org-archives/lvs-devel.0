Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792572155;
	b=FyeYYCAIj9PNZjgZhO5+VjpRzCDfesyQOLdxVNgHPojDTPQBsCJDAFb6Ssjdhms2IIyz
	 kgIqD+1+SzprUHIlD12Lqj4LL4w80kHao50YUd8n7PkRQT0gqH3Bu37WI+V/IdtWpxegL
	 R23nu2zu1Req3q5or41Viizc3GjIHCIxX7nP8GsjEwK17dQc7+r1IyYy43cKzV9ze6tfN
	 HHUTztRK1daQMqPlhX9cgAJZh4CDLOa+wRRFzNmYKsFBbWw6lSK85KLXc751aWk/HVmV1
	 Jt/XbLJLK0S7hwO0wAxHerjCye+bLlS9jlrznc4PeXSActYtvmMVnHd8VEZGDAdSxyg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792572155;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:Date:
	 From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:
	 Content-Type;
	bh=skQcbSuVjqpZNCt1Ke99gaFd34uQCkMwfTktELG/qks=;
	b=JDsoKJ+pjtarZc0abmLTlh2BL1G7XzQ/jn9qigQXz3YB407e5CFD8dAjZVlb244pNDwX
	 /7wfImodT0o/cspp5WN3oRCRL7Npi8jyCj1fbF2XcmwWcO9mqp7+gKQD6Nmqtnu4f8zOR
	 v9iDzjZw5MhetJ8zYVWeFibQCSNc9x9KehcROLzpLclvSAzATfQKWgW4+irW9LhCba6lA
	 IVEXWQGfI6RB5u8g4OUy/znym4bTmkSqGY0QS/hZgWYO5/6x7YqQlXsQNz95BE5rTQLE+
	 9LqXaY4Eyz8CQ7yyIcCJKIoJat9DAJgguwa8omlK1prkux9mXt/fFZL3sw0Nouy937A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=0eV6a22L;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 15CE4606A31E;
	Wed, 21 Oct 2026 08:42:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 15CE4606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=0eV6a22L
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id BA1DE225B5;
	Wed, 21 Oct 2026 11:42:23 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=skQcbSuVjqpZNCt1Ke99gaFd34uQCkMwfTktELG/qks=; b=0eV6a22LKlqO
	07cQsbXfzE5Gk5sY12xcTeExUWDWoEBZMXwJ5dBdZ6nvjOjDgEoLhvz93yofE7/r
	cWKze3CyVok3T9uXjd4iZjQhIibGgQBlW1mWwBdhQwndNL6PQdlVOn4UQkTou0B4
	oDaoO9jPJT+hme6A2Gv1qNZX+EqVdYJq6QXd3BFWQ1TLxj4XpjqVBkxZW3iBq5+0
	WBJMBxaKPkSm1J/fVjRdAGp22emTVQ4wXIBOkcIwWwzC9XErrVjuaTYof7k5gcLh
	AXytRJzpHpXUzGuld2Y1C8KT1P6s8aPENnkTWf4jpgda6QXgp9JcnSt0pdXTOZQ2
	nqi4DTqIPEO/BTs1kGsE+HTFdckKnPBH9RRpUm+7v4LayLyPUZ7TlvpXwiGxUGv6
	dv/MTYKcTr9I3AecEO39mXeKg2HdVUjLt4tLoRDU0N8VzwPEyIYUEsUhKE9Fwzyx
	FQxEB1X8AyVHnzJSun7reMVGSolrOdAvF01c5GkbK+JFHjPwgM4nIqmiBwmGjzwW
	HHQH3T2gjy5St15YpN9C9R1QnFqZ1AnZTxY4yHoyLS4ZHWW3tyqqMMg5FglWFIVX
	+5Oy/FMWRFKeTnBT3bUM2YudwnlfEb1foicBGwK3S+IXjggBfEK6Z2zMho5ZGfZi
	ngWBeyPIoELI3Vp8ZaPjhmho6lyjqcI=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 21 Oct 2026 11:42:23 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 8754060F66;
	Wed, 21 Oct 2026 11:42:24 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 69L8gKZ6017963;
	Wed, 21 Oct 2026 11:42:23 +0300
Date: Wed, 21 Oct 2026 11:42:20 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: Re: [PATCH nf v2 0/2] ipvs: read conn fields during sync
 atomically
In-Reply-To: <20260929113436.44306-1-ja@ssi.bg>
Message-ID: <58d08a64-2510-16b8-7a60-644785930cdf@ssi.bg>
References: <20260929113436.44306-1-ja@ssi.bg>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Tue, 29 Sep 2026, Julian Anastasov wrote:

>         The following patches make sure the connection
> fields such as flags, sync_conn_opt (seqs), state, old_state
> and timeout are updated atomically in the backup server
> and the first two also in the master server to avoid
> buffer overflow.
> 
> v1->v2:
> * add patch 1
> * patch 2: read seqs with flags under lock
> 
> Julian Anastasov (2):
>   ipvs: update flags and seqs in backup server under lock
>   ipvs: fix buffer overflow when sending sync messages

	After v1 of patch 2 is applied, we should create
a followup patch (v3), so this v2 should be dropped.

pw-bot: changes-requested

>  net/netfilter/ipvs/ip_vs_sync.c | 55 ++++++++++++++++++++++++---------
>  1 file changed, 40 insertions(+), 15 deletions(-)
> 
> -- 
> 2.55.0

Regards

--
Julian Anastasov <ja@ssi.bg>

