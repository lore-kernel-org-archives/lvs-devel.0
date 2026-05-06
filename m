Received: from mail.netfilter.org (mail.netfilter.org [217.70.190.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AE78649552A;
	Wed,  6 May 2026 15:16:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.190.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1778080615; cv=none; b=q+p0YXOYpIDsdhCqKkDc0olSMbIKZn2ru8sKI2d0DIbCbYJLSs0rmJ895aDJpi1/aOJkCi+KX4EkL3zd1jmuT5ZCA35xLjbpEICxtSb5MzjrCBmuX0G8lEDcX2c6IR2gl3vhuuphx3lYp7QlGbZe14hYX2lJAM87UnCJ6fyVuHM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1778080615; c=relaxed/simple;
	bh=HbNUVoNn0UvMzTFMT0itCEbXtQr+xvOqAu9n+w7dQEI=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=lzDfl9xRjm3Bm0F79auZoUSOeSUC4yfq3ULqf/E1nWoDKCWV6G5t+RIAFN+S7en6dw/feDzl9FBYHK3uDyvpMdK0Kch8T9sTsPd24/Rh/cUcXNioLtJ0Tm/9Nk17n41McOzl0lbIkQAasvtND9pt9IiBHSs5Tk6V+D+eeo4/AiM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org; spf=pass smtp.mailfrom=netfilter.org; dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b=TVCoimB+; arc=none smtp.client-ip=217.70.190.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netfilter.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b="TVCoimB+"
Received: from netfilter.org (mail-agni [217.70.190.124])
	by mail.netfilter.org (Postfix) with UTF8SMTPSA id 9F67D6017E;
	Wed,  6 May 2026 17:16:40 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netfilter.org;
	s=2025; t=1778080600;
	bh=RJ1A/R2xAxhIIDE+NnUuNvr5m7CXGdUHfnv0OIYQ3I8=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=TVCoimB+NE9uyplFahaQ130fZscGf0zNVo+RF/iolpER1MS2/ClxsFktTA5f3BTZw
	 ra2tP1AU5Kr8sIomyIW0L9+HfvzliT9D3ZxcuFFznlCdKdwOBs/cPEYTaqtA3kohkG
	 u4mgyYYSHyCrS0m3SAUDbqXRU33CqwkpbBZt0WRrLqWtO2FmuUGnRsF29577VWAcT4
	 43Nr6up+PULwz/smBoYZ7zAmhQb1Aq5b3yuh5vnCB2CObOQ+5XUn1sjSbzcOT39MF3
	 9c+741Tk9Ob8e09/7znst0H2BLeQAAcQGEBpfI0v7VZeKxNyFW5qNcjUPyaPf9+Ga0
	 Vfp/kiSrK7zsw==
Date: Wed, 6 May 2026 17:16:38 +0200
From: Pablo Neira Ayuso <pablo@netfilter.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, kuba@kernel.org, pabeni@redhat.com,
	edumazet@google.com, fw@strlen.de, horms@kernel.org,
	longman@redhat.com, lvs-devel@vger.kernel.org,
	Anna-Maria Behnsen <anna-maria@linutronix.de>,
	Frederic Weisbecker <frederic@kernel.org>,
	Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@kernel.org>
Subject: Re: [PATCH net 0/8] IPVS fixes for net
Message-ID: <aftbVlmSOAFegQgf@chamomile>
References: <20260505001648.360569-1-pablo@netfilter.org>
 <bce80830-1e2d-43ad-ba7f-055cb352b348@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <bce80830-1e2d-43ad-ba7f-055cb352b348@ssi.bg>

Hi Julian,

Cc'ing Waiman Long and NOHZ maintainers (apologies if this is dragging
more people that I should into this issue).

On Wed, May 06, 2026 at 11:56:05AM +0300, Julian Anastasov wrote:
[...]
> 	Here are some comments after the last review from
> Sashiko:
> 
> https://sashiko.dev/#/patchset/20260505001648.360569-1-pablo%40netfilter.org
> 
> Patch 1:
> - while ip_vs_dst_event() should loop and ensure all dev
> references are released, single change of svc_table_changes
> does not indicate the old references are dropped by ip_vs_flush() or
> ip_vs_del_service(). I'll post new change to abort the loop
> when we are sure the services are at least once released.
> 
> Patch 5:
> - after executing ip_vs_est_calc_phase(), data can
> remain only for kt0 because all estimators are stopped,
> unlinked and the kt data structures for kt > 0 are empty
> and as result freed and the kthread tasks stopped (which
> happens early). After this, kt 0 calls
> ip_vs_est_drain_temp_list() as part of its loop,
> so it will eventually call ip_vs_est_add_kthread()
> and ip_vs_est_reload_start() to request kthread tasks
> to be started if data for new kthreads are created.
> So, I don't see problem here.
> 
> Patch 6:
> - we will add conn_max sysctl soon

OK, just follow up on these for 1 and 6, thanks.

> Patch 7 and 8:
> - I can not decide how valid are the concerns in the review.

Placing here links for convenience:

https://sashiko.dev/#/message/20260505001648.360569-8-pablo%40netfilter.org
https://sashiko.dev/#/message/20260505001648.360569-9-pablo%40netfilter.org

This is away from my limited scope of knowledged.
