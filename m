Received: from mail.netfilter.org (mail.netfilter.org [217.70.190.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2F2232E3701;
	Tue, 22 Jul 2025 03:25:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.190.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1753154718; cv=none; b=WLEWqgf8/IzfsyOJpPaL4txFGfc9n7PP6ox3+MjUNb33GV/wPhf4q/bHdP6K8AaoM6b1vPpMe6qsaEcGC3uOUG3QOLSUnxQjRT7uWPxu1ePekRqW61cYOJplZtZxEMYp60dVPlaTrNJ7MU0ObQAbBOmAxNGBdQVQQGUeckCz+/Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1753154718; c=relaxed/simple;
	bh=MkHa2Rdf1jArpN8hWytBpulfVw27vR2vgyRxDMy6PZo=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=ThnMRzsWh2vmUFdkDWb0F6TFAns0x0G3qOBwF0B5715LULE8VEOtrHk/DsInA+Vd8iAj7/GHtRxu1g7l2ukuIqAmiNqlUgijuNoH1sonzFEMHqj/kJuvYgGx0n+/MdBXFWtGXV8KcHTcxnx3kceqtZyfBMXInR9z7N/7pM3Uzt4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org; spf=pass smtp.mailfrom=netfilter.org; dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b=LVHFLvCC; dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b=T9uXlCKt; arc=none smtp.client-ip=217.70.190.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netfilter.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b="LVHFLvCC";
	dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b="T9uXlCKt"
Received: by mail.netfilter.org (Postfix, from userid 109)
	id 6FFED600B5; Tue, 22 Jul 2025 05:25:14 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netfilter.org;
	s=2025; t=1753154714;
	bh=vSmlOCs6gbQah62oYlIxODdqyVaW5UP6v8LmxDYaaKo=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=LVHFLvCCcHNTAHRzbn95RxCrd74PD6GFF8aR3tBeJZTNhqIC0CRjQXEcP3BCCAm2m
	 u3+p1N4abgGxYHtNsdlmlptkCAa6RKurZlmFM75o5/fk2vi049eb8gxWTxfnNEeIs/
	 hD7nYdX0Q2TxI9tTvyIAG7hnP13cUqD4dU5a1eUx4t75u0FrU9lbuAflkn8NSyUOGD
	 jGVVFzgtxnv4VF64einUQ9aUSGw46RIqz/I+N03e05tG9oK528LVjK7sDfKe5Tv0nK
	 m/7TuyF7e8/W2dQpd7jaOg8pe+134N2x01DS4WqGjczC27cPeFAOGskHjZCvDUS5er
	 yPt+8AK4tw16Q==
X-Spam-Level: 
Received: from netfilter.org (mail-agni [217.70.190.124])
	by mail.netfilter.org (Postfix) with ESMTPSA id 64652600B5;
	Tue, 22 Jul 2025 05:25:11 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netfilter.org;
	s=2025; t=1753154711;
	bh=vSmlOCs6gbQah62oYlIxODdqyVaW5UP6v8LmxDYaaKo=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=T9uXlCKtDZASD999IgqgLU6aw90CeEfxIsYDOvODaqu4pzvNsocV9HVZMrC34y256
	 wXnahlMO90OXKGQFbZRDAFSWzw7NUBsg5ALj2VHT4ZsQbkZxJIragcypeJ1uiGIJDB
	 1xJwI7j9xta7bhpwYWHXsOZD+ySgRil2ZiCjf/eQlJjIdpoNI01lrYL9shcEz/kb6e
	 HlAbiKRyPd94PUXXcZylXyyHxMYcyRGTlFz9RzfSvATNz7qGI/QTgvUPZ8j7ksHdvr
	 HSef6jMkYibxo5d+4fw0YulLfTP4sX50dYiR5hhYS0xwujxDvPuT+ZuHWQ9waGuiHk
	 +jwLP0gDh48Fw==
Date: Tue, 22 Jul 2025 05:25:07 +0200
From: Pablo Neira Ayuso <pablo@netfilter.org>
To: WangYuli <wangyuli@uniontech.com>
Cc: horms@verge.net.au, ja@ssi.bg, kadlec@netfilter.org,
	davem@davemloft.net, edumazet@google.com, kuba@kernel.org,
	pabeni@redhat.com, netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, linux-kernel@vger.kernel.org,
	zhanjun@uniontech.com, niecheng1@uniontech.com,
	guanwentao@uniontech.com, wangyuli@deepin.org
Subject: Re: [PATCH RESEND] ipvs: ip_vs_conn_expire_now: Rename del_timer in
 comment
Message-ID: <aH8Ek6XA_EFr_XWh@calendula>
References: <E5403EE80920424D+20250704083553.313144-1-wangyuli@uniontech.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <E5403EE80920424D+20250704083553.313144-1-wangyuli@uniontech.com>

On Fri, Jul 04, 2025 at 04:35:53PM +0800, WangYuli wrote:
> Commit 8fa7292fee5c ("treewide: Switch/rename to timer_delete[_sync]()")
> switched del_timer to timer_delete, but did not modify the comment for
> ip_vs_conn_expire_now(). Now fix it.

$ git grep del_timer net/netfilter/
net/netfilter/ipvs/ip_vs_lblc.c: *     Julian Anastasov        :    replaced del_timer call with del_timer_sync
net/netfilter/ipvs/ip_vs_lblc.c: *                                   handler and del_timer thread in SMP

Wider search, in the net tree:

net/ipv4/igmp.c: *                                      which caused a "del_timer() called
net/ipv4/igmp.c: *              Christian Daudt :       removed del_timer from

Maybe these are only for historical purpose, so leaving them untouched
is fine.
