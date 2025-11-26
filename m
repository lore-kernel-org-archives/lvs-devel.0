Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0F92B30E834;
	Wed, 26 Nov 2025 20:02:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1764187368; cv=none; b=bntcHLqKSdI9g1xep04h7Wlp5Sir0TD7mrdSFBhaHJUK5J/LUpBlEX0eO3wC6lLssyLRO+VhfykdnBnMlglD3ADo/L2qbdvpYmdQcmKd79vVihYS1ArAufGwChT255drkRJjSmPGQMCk+XmB1mNs/y6tKU5Y1DNFxX5ai/gnlv0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1764187368; c=relaxed/simple;
	bh=swHNL7Astol3mtUfSLWjsXSpnRrL56D88xeNj415+7E=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=HVMLu4wbGt9VXS2jvLkfozbxZEXIGhVHwEw4aUVQnetCFXc96SAfWEtY/S87Mza0b7mV3lSKTEajn5+eenR5VI3Wzq2GVQwKESdry0w6P5fwL/HFnH8335TY9OAq2R6McnAhwSKMOBLRV8CdksNs/Zo/jpCDokVi4EVop0DEJs4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=aOvUDYmW; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="aOvUDYmW"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 6A5442119C;
	Wed, 26 Nov 2025 22:02:43 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=dA1HP9Zb2cwoZpjsbrvUt01UYlu83tVPVNoBg2uJTA8=; b=aOvUDYmWAbp5
	4mySTnCRW34N22IiK1WcibwK0d8zAoIEaJ8a97TUsAhdaiRssh6ucN07uIM37G2C
	Wsnn7/HeHeUhtSAA689jfYR+uBHKaWNX7TkARSiNKDcu208SPY+jsV9SHr84Nu+s
	onTpijPsbOLKWv8IsMX2tP5RG1u+sZ9RqZ449AO1Sur1IS/4uTj5u5pE6iOCnRUM
	bCpgswg+0tDYSY+qmJHKfRDejYhhe4pCjggmRhIEjASSdjkVZwiOnISdHMcSXLEm
	4JTw9nU1jv7oKWjHYqTxpRD2kbP4E7UXegKOr+pS2rwtOiMB8k6QxppAbr3q4OxL
	2NEQJ5ftuqEebl5z05evkgjVWAxEMKXzxryCSQXjaZ3iL3LVJn6iwAlmnxsqWB98
	isArZoOFfno7KBg1W+YCU9iCj6/gJyzjPfpPDKvpFwOtFAR4qK1VaWfh7V+VVEot
	NLtPF3XZti8lxMtnfJ5TG2r+3AkHdfx/lwrW64TRAoSiCCI3+cUyzLoRfqInPjVL
	E1PW3smK94UTsj7PkxxsLEs8hzjf8gBScMzu7oK/FahGEgd4vU3AlvJiDgBn0K4G
	kPYqxY9u+mVm7JbKPQOtIp1PL6vdzHwNP7VJufg5eKSBWHfyAhj1nIe+BtW9o2RP
	L5q8bQ5VH8P0ejbWJ2/II2gBZiEhqDc=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 26 Nov 2025 22:02:42 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id E8608603CB;
	Wed, 26 Nov 2025 22:02:40 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 5AQK2bLG043085;
	Wed, 26 Nov 2025 22:02:37 +0200
Date: Wed, 26 Nov 2025 22:02:37 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Pablo Neira Ayuso <pablo@netfilter.org>
cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>, rcu@vger.kernel.org
Subject: Re: [PATCHv6 net-next 07/14] ipvs: add resizable hash tables
In-Reply-To: <aSTLQ0a6LjYjQZFe@calendula>
Message-ID: <ac8f6246-afd2-59ce-0aef-b420b9c262c4@ssi.bg>
References: <20251019155711.67609-1-ja@ssi.bg> <20251019155711.67609-8-ja@ssi.bg> <aSTLQ0a6LjYjQZFe@calendula>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 24 Nov 2025, Pablo Neira Ayuso wrote:

> On Sun, Oct 19, 2025 at 06:57:04PM +0300, Julian Anastasov wrote:
> > Add infrastructure for resizable hash tables based on hlist_bl
> > which we will use in followup patches.
> > 
> > The tables allow RCU lookups during resizing, bucket modifications
> > are protected with per-bucket bit lock and additional custom locking,
> > the tables are resized when load reaches thresholds determined based
> > on load factor parameter.
> 
> I understand the generic rhashtable implementation cannot be used in
> this case, but I am missing the reason why (comparison?).

	The main differences are:

- our hash keys are not on contiguous memory, need to fit
properly in cachelines
- we avoid IRQ locks: local_irq_save/local_irq_restore
- we will use double hashing for NAT
- we allow entries with duplicate keys, for performance reasons
- we do not lookup the entry that is to be removed, we know its
table and bucket id and unlink it with hlist_bl_del_rcu
- we prefer to customize the grow/shrink process

Regards

--
Julian Anastasov <ja@ssi.bg>

