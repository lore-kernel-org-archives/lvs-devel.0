Received: from a3.inai.de (a3.inai.de [144.76.212.145])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F164B18DF65;
	Fri,  7 Mar 2025 14:06:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=144.76.212.145
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1741356414; cv=none; b=AhkccHmQDTj7AaXqWX2HmDHoaIGYgEQMhYql1pHByR0r/u0Yc+yP/wGbKsSkPZyzbqlreErzV1EZCQhn1HbQoxLOBNtqz3AKlFWsEfel0KiHHrlbndB7CkTodrpCCqanwSNVzjEWNxHvCnOfPbn/REe0WGE3MJoEMTLo7zJqrsQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1741356414; c=relaxed/simple;
	bh=jLtN1XoC+KbFbaxljC9HVSufCwH5cbdUpS2up+/dMhE=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=OFHKOGRCRni+oayvIXEewGuDz3odSW9Rz1zjhYtzGj+IRhqQxDU/fGmP4tOhwsl/YfUtNfW8sZNQLin9XTnnP6dOXheh7mbk7yvM6s+yVUb7Bgj+egj6KS6eve8QIvsVZy+G/rD1KfuA6bv5US8wRtIhq9M4ZeQ30DTPBnLTuO4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=inai.de; spf=pass smtp.mailfrom=inai.de; arc=none smtp.client-ip=144.76.212.145
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=inai.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=inai.de
Received: by a3.inai.de (Postfix, from userid 25121)
	id 2F84B1003BB142; Fri,  7 Mar 2025 15:06:38 +0100 (CET)
Received: from localhost (localhost [127.0.0.1])
	by a3.inai.de (Postfix) with ESMTP id 2DA401100AD650;
	Fri,  7 Mar 2025 15:06:38 +0100 (CET)
Date: Fri, 7 Mar 2025 15:06:38 +0100 (CET)
From: Jan Engelhardt <ej@inai.de>
To: Dan Carpenter <dan.carpenter@linaro.org>
cc: "Gustavo A. R. Silva" <gustavo@embeddedor.com>, 
    Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, 
    Pablo Neira Ayuso <pablo@netfilter.org>, 
    Jozsef Kadlecsik <kadlec@netfilter.org>, 
    "David S. Miller" <davem@davemloft.net>, 
    Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, 
    Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org, 
    lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, 
    coreteam@netfilter.org, linux-kernel@vger.kernel.org, 
    kernel-janitors@vger.kernel.org
Subject: Re: [PATCH net] ipvs: prevent integer overflow in
 do_ip_vs_get_ctl()
In-Reply-To: <6dddcc45-78db-4659-80a2-3a2758f491a6@stanley.mountain>
Message-ID: <rp565ps2-86qn-0806-qpss-314qr3r0n700@vanv.qr>
References: <6dddcc45-78db-4659-80a2-3a2758f491a6@stanley.mountain>
User-Agent: Alpine 2.26 (LSU 649 2022-06-02)
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


On Friday 2025-03-07 14:44, Dan Carpenter wrote:
> 	case IP_VS_SO_GET_SERVICES:
> 	{
> 		struct ip_vs_get_services *get;
>-		int size;
>+		size_t size;
> 
> 		get = (struct ip_vs_get_services *)arg;
> 		size = struct_size(get, entrytable, get->num_services);
> 		if (*len != size) {
>-			pr_err("length: %u != %u\n", *len, size);
>+			pr_err("length: %u != %lu\n", *len, size);

size_t wants %z not %l.
