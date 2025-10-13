Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4426E2FF650;
	Mon, 13 Oct 2025 10:18:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1760350735; cv=none; b=WGtumaahmMczBISbypxtE2vc61RfupKI/PEfNIHAYxJpha5lEOmoBm3aMJl6KWGMMOjmghtBQC1kDK6BNVtneYo1btJ2BSKQh65r0xEKChK1USZhsZH9MCdj7s6yRd2ErJ1I0e/ZXATLdOVut6RESxPyvpDKTjN3kp+dxPRphAU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1760350735; c=relaxed/simple;
	bh=Fl245tHyo2NourQS+BjUBp1+4uEs2rcZLFCGOrm7tPY=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Z+naopoly9GXtPcy0JvL2UXDxQ6YOorzmavNSeu24CUPiK4DaM//XdeAV57MjowaP5EGGnZ5Wh+056IgsK5HeoQeYVaik1l39iVXlQGeNMvpvCKAmGjQVcHdTyPQ0B+2g5nCtoYj5JPcQ0htT06tkVn0xfKa+enXdjgmV7HLDNI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (1024-bit key) header.d=linuxfoundation.org header.i=@linuxfoundation.org header.b=EaYStjdI; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linuxfoundation.org header.i=@linuxfoundation.org header.b="EaYStjdI"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 80699C4CEF8;
	Mon, 13 Oct 2025 10:18:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=linuxfoundation.org;
	s=korg; t=1760350734;
	bh=Fl245tHyo2NourQS+BjUBp1+4uEs2rcZLFCGOrm7tPY=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=EaYStjdIGnmmuK/R8r2BmMocOJRkIu51vtBVXslVz05+yjSOMuhjR+VQycc0Pypjb
	 MtDB+Nm2iqw5IoX8TOZz6xLV7cwGqdAi7J3Jx2Scr1OJxgnUjc0iTOAxVz1lFEEEV9
	 U8dWFpsBWZYfp53SrbYrxLQBKcaQb57uQb+NXjek=
Date: Mon, 13 Oct 2025 12:18:52 +0200
From: Greg KH <gregkh@linuxfoundation.org>
To: Slavin Liu <slavin452@gmail.com>
Cc: stable@vger.kernel.org, Julian Anastasov <ja@ssi.bg>,
	Florian Westphal <fw@strlen.de>, Simon Horman <horms@verge.net.au>,
	Pablo Neira Ayuso <pablo@netfilter.org>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org
Subject: Re: Backport request for commit 134121bfd99a ("ipvs: Defer ip_vs_ftp
 unregister during netns cleanup")
Message-ID: <2025101332-banked-marrow-4f56@gregkh>
References: <20251013093449.465-1-slavin452@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20251013093449.465-1-slavin452@gmail.com>

On Mon, Oct 13, 2025 at 05:34:49PM +0800, Slavin Liu wrote:
> Hi,
> 
> I would like to request backporting 134121bfd99a ("ipvs: Defer ip_vs_ftp 
> unregister during netns cleanup") to all LTS kernels.
> 
> This fixes a UAF vulnerability in IPVS that was introduced since v2.6.39, and 
> the patch applies cleanly to the LTS kernels.

It's already queued up for all of the next stable releases.

thanks,

greg k-h
