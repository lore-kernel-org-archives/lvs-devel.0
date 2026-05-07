Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7B9EC34678C;
	Thu,  7 May 2026 07:20:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1778138444; cv=none; b=KjVwOXKFFTrq632r/jsB4EN14xtYUT6nQnSps6e7peGju9GwZH11hPvztrYpETM9lg67itQljNycJEsQ/qXSKtIowMbLiD+qPSR8kxbFZPbE1ifLX6kFuCUeB9l/t7boX5wbPVHSIIDKPG8aiiW54iPxQQX7gSBqtoT+lArBBPA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1778138444; c=relaxed/simple;
	bh=2ONu8z+tBNUs9O8PBz9zsWZugH5XQsMbYNd4EqmyM50=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=fqruBsryQP+xjNerKz42+nd1hJSaTmfZankEzJyRJ2SIFrd/uhAgUOObsC8FZaHBCt7Rh/wJRXBn+8UO+qSI9o+oL8peMLfGg5zyt4/0YOAXHYopHcVVdliaV+hASIAu2+XsQ5n/d017CN748rP4GnZzfHRwxFJ8dNR7m/XRZDs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=n0jtlflj; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="n0jtlflj"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 79E0222964;
	Thu, 07 May 2026 10:20:36 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=3thlrBShDZBMgC0qrhKwxd8r2acTXEkqzIapB4W1O/4=; b=n0jtlflj1zEN
	++eV4uUZN+c+ZGS5UgLeYFVjSsN1mMY545mOFy28hIT/FXqkcXK2gCx22LB0c4VQ
	NTjKARAogkj9jfcQ3z8YsyGRpESZffXYafWgc9+EQAnuuOlwJf0Q6a7moKWLtTfm
	c108cTxFtMGWzBN4kXW8c5yfkLZQwGUSCzExwr+d3xmU9UVMzPkLOdGgPfj8yGub
	aoZn0BvktKRmbsYb+WGfT02AzINB5r6mL7vgS5WKRsynouJTp+MNuuVtA+5H5gCY
	pX7bOXa37fcb+8qj7xujr8DrBzu3sH7eIgX/0CswweEykbhiWD62FgOuuZ3HoQhL
	TV46TVt+j67c4JVuo+/SNav1u8YeSnC5K6e66B3X/TYnEhcY/eh/Yld1V0y6Do3H
	gMuRGHR/hdnhrBoXW+z4b4wj36t91CLfRa7S9QgKSNoDTKF7GBAQ2k9lo9R7c49v
	unuhpvoYG8/92poGszhYYQ3xLGIWhsPCkrzw1jW2Zw0fiFq1sTFPHk8rl44YBTcc
	xOfNLuCsa8Jamkso6mYlp7Qe6zm13kI1MHY40ukNjjiZi9twMMexIOTbthobv7ri
	G9XIJHRnXS2dgTuhI2UqL0S0ig3GUjmpl9Hj1s8A5CgidkNI2Jn0PAzXrG0VKy+R
	WFfeREkz7MuHJaimuq6+0GcSUIxStqA=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Thu, 07 May 2026 10:20:36 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 528DE605F0;
	Thu,  7 May 2026 10:20:35 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 6477KSPD014662;
	Thu, 7 May 2026 10:20:31 +0300
Date: Thu, 7 May 2026 10:20:28 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: Re: [PATCH nf] ipvs: avoid possible loop in ip_vs_dst_event on
 resizing
In-Reply-To: <20260506184421.75877-1-ja@ssi.bg>
Message-ID: <a7152fea-49ba-a4bb-ed99-648254a41164@ssi.bg>
References: <20260506184421.75877-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Wed, 6 May 2026, Julian Anastasov wrote:

> Sashiko points out that unprivileged user can frequently
> call ip_vs_flush() or ip_vs_del_service() to trigger
> svc_table_changes updates that can lead to infinite loop
> in ip_vs_dst_event(). This can also happen if the user
> triggers frequent table resizing without deleting all
> services.
> 
> One way to solve it is to hold svc_resize_work in
> ip_vs_dst_event() but this can block the dev notifier
> during the whole resizing process.
> 
> Instead, use new rw_semaphore svc_replace_sem to protect
> the svc_table replacement which is a short code section.
> Then hold svc_replace_sem in ip_vs_dst_event() to serialize
> with replacing the svc_table. By this way changes in
> svc_table_changes can happen only when all services are
> removed and all dev references dropped which allows us
> to exit the loop.
> 
> Link: https://sashiko.dev/#/patchset/20260505001648.360569-1-pablo%40netfilter.org
> Fixes: 840aac3d900d ("ipvs: use resizable hash table for services")
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

	The patch can be improved, will send v2 later today.

pw-bot: changes-requested

Regards

--
Julian Anastasov <ja@ssi.bg>

