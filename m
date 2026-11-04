Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793789327;
	b=T+QCJg0j5rBtZ4ocPR9mBc/349ezWLjBOzd31z1eySpznXx0EOKE31l1Juyg9WnFBzYO
	 W6Ujp/wXDFGa7pSPZccETguK7lVSTqrqK6J/HJ1YMiUkFjPf00S5UnibJo0yYvrj5weL1
	 36dShpWc+4KeI0xdoeiupI6Y6j8hK0FNx47biRS8uy1mMLkP2imrFeJ4KVxvdrniXCIw/
	 Kbfj6SlqY5Sd3fI7SlqaeAEgGbPR3eVEU+uA/8mbkII1xXrDcz/x1c3fUJe2RVGUPrKA0
	 MlyZKFg20VBj3LWdU12zau7bUQde4VS54IRFbI433w5avjMg6igNrQQxITpLz9I48WA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793789327;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:Date:
	 From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:
	 Content-Type;
	bh=QXE8b4q+2ID93xF5dNf4h2orIMjvofD99DTXnCzElBw=;
	b=0McMhxtnAo+6qehaiYZnhg2V0R30zVpj4Muac/ehexyMvbr9qdwcSTXltXo5tA0MKnNk
	 syuZb6aHnkFCFUwygYlXDdfHjtD0El5imam5m0EqHIgfw2AJP3iZphc/tuaLM+/ONK6C4
	 q1UvPBRSTkTI4eUmlLrmXy/e26BV17S16ghOYnuCUkbLVXdP7NXdWes0n26gJibgtkLmx
	 8OmbdqtvDmaJmqpDvbrAEMwBKYTehfZNr7hGbFDVh9H4soXoTTRWqv30Ka7Uq3k3tKPGn
	 EPW4Ry7+z3O41oQi/JIfsDNBfdjXyqssf7o58q1NW1EOHWiPS3T2eXwyQtSXlwvbfyQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=3nsNKccH;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E4035606A31B;
	Wed,  4 Nov 2026 10:48:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E4035606A31B
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=3nsNKccH
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id ECF90213F4;
	Wed, 04 Nov 2026 12:48:41 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=QXE8b4q+2ID93xF5dNf4h2orIMjvofD99DTXnCzElBw=; b=3nsNKccH7jMU
	AlfXLWrEF4/HW0GlGGUHdIzhjtd8aJ1Sq3GbOHHVPWVsOmJA4nMXXy2LGEmJVmKB
	kZzthEeMNKvil3LecuuzhOIUerCxKV3G9Uz3tYFodo8fi8H44WW1RbhrpeSaIiB1
	tjq0m92c7H90uC0qeoWLGHVYR9xjS9NswIeg/TFpELa2Aomz2A0YJ4HTI+WuYynb
	UuqkUgHDEp/KGF9j/CPYTOeO0qZcWXBvLXMZUsDF3KMOXlg0Yxm+jOsMG2+wwcAk
	e1sT6Pb2W9uj0L85NkFLGg82bVc0mKstl8qIj8oVwor8fcpy0nsBfHBGsQq7wdTT
	blbJmwpvtvfGyTXNLhr5n+YwB0dOGmd6oaPuaTufbG+yyNNNpTifb69dE2Q1YAMx
	u9/C7yNMOgOekqvWo/1XuulPjtr2fa8o4sWgZ9fs+Nbuj9bW+ifhh2o4u/gyLuwL
	+TeQ5i85ygvzo2BF003Vlsl7rsmasZRJTCpzpGgfXkNZHoWuiwwCWf0JYI8FaT41
	JSzVGrmuyIIpWT0rXwS6x0xyNpru6lUuGd1InazATPbtwrd9YjWnu/+WlRPUZmKw
	Hz7kMZmyGrDCI98VhkEQfj9qG5AbQz1AMwQYO0DRnorAAVHXY0mcpuTaePEIsNVt
	iPKnkuF3i7eGo4tH5NJfliLsgLOlQHk=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 04 Nov 2026 12:48:41 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 8646F609D0;
	Wed,  4 Nov 2026 12:48:41 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6A4Ama6d078633;
	Wed, 4 Nov 2026 12:48:37 +0200
Date: Wed, 4 Nov 2026 12:48:36 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Axel Mierczuk <axel.mierczuk@1password.com>
cc: horms@verge.net.au, pablo@netfilter.org, fw@strlen.de, phil@nwl.cc,
        netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org, w@1wt.eu
Subject: Re: [PATCH nf v2 0/2] ipvs: keep templates and cport 0 conns away
 from packet lookups
In-Reply-To: <20261103165746.39516-1-axel.mierczuk@1password.com>
Message-ID: <2bfafeeb-bb2c-cf2c-e4a8-4d262c507eb3@ssi.bg>
References: <20261103165746.39516-1-axel.mierczuk@1password.com>
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

On Tue, 3 Nov 2026, Axel Mierczuk wrote:

> A template received over the unauthenticated sync protocol with a
> nonzero cport is matched by data packets in ip_vs_conn_in_get() and
> the protocol state machine runs on it. Patch 1 rejects sync records
> with inconsistent cport and IP_VS_CONN_F_NO_CPORT combinations on
> the backup.
> 
> Patch 2 applies the cport rule of __ip_vs_conn_in_get() to
> ip_vs_conn_out_get(): a lookup for client port 0 matches only
> connections flagged IP_VS_CONN_F_NO_CPORT, so templates and cport 0
> connections cannot be matched through the out hook, while the
> "update or create" lookup in ip_vs_ftp_out() keeps working.
> 
> The companion patch "ipvs: filter some flags received in the backup
> server" is already applied and rejects template records carrying
> IP_VS_CONN_F_NO_CPORT.
> 
> Packets with port 0 are handled separately by Julian's patch "ipvs: do
> not create conns from packets with port 0".
> 
> Changes since v1:
> - Patch 1: unchanged, added Acked-by from Julian.
> - Patch 2: test p->vport against IP_VS_CONN_F_NO_CPORT instead of
>   requiring a nonzero cp->cport. The v1 check made the
>   ip_vs_conn_out_get() lookup in ip_vs_ftp_out() always miss, so a
>   duplicate data connection was created for every PASV/EPSV reply,
>   and it read cp->cport twice. Reported by the Sashiko review and
>   Julian. Commit message rewritten.
> 
> v1: https://lore.kernel.org/netfilter-devel/20260925141115.16126-1-axel.mierczuk@1password.com/
> 
> Axel Mierczuk (2):
>   ipvs: validate cport in received sync records
>   ipvs: skip cport 0 connections in ip_vs_conn_out_get()

	Both patches look good to me, thanks! Patch 1 includes
my ack, so this is also ack for patch 2:

Acked-by: Julian Anastasov <ja@ssi.bg>

> 
>  net/netfilter/ipvs/ip_vs_conn.c |  2 ++
>  net/netfilter/ipvs/ip_vs_sync.c | 19 +++++++++++++++++++
>  2 files changed, 21 insertions(+)
> 
> 
> base-commit: 734bef548a96e8774d6eef5dfa2026c6edc4e80b
> -- 
> 2.50.1 (Apple Git-155)

Regards

--
Julian Anastasov <ja@ssi.bg>

