Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B5262136E
	for <lvs-devel@vger.kernel.org>; Sat, 18 Jan 2025 08:52:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1737190336; cv=none; b=iS2hd3PC3Vjo3KQpmbhlsHOl5enPu/FnUwaMxOjet98+XXSJ8zWnHKz09T3i0CHDpYAiMpdRrH/nQ6hHTTWtSEPDne9DCe0uOqwrJEMwwMkgmOtiMuIo7S5t9upkYsJhLqRJZm8uNsnZERJnNRniPL21/bEzZh5Mwnb7KxFgBG8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1737190336; c=relaxed/simple;
	bh=F5ARRNcTE7XzUxNp+fcsZX+HuTxNo4z0gQiDegWJ9kw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=s5Bq6M57Q1K8Nh6AG8SqQs7gLdmBxX6L4znz209/HYAvk5mOO/qn3TWBJBD/U547PJbhZNFBEb2lbYnvSB2z9rfRYyhXIrG1o388WAorwdOgRQhTb1pXce7lounp819bLQf32Y8BPxNqSU32tOEWszgJLEUpJEp0NeuWn2n8t14=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=WGEivFGh; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="WGEivFGh"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8956FC4CED1;
	Sat, 18 Jan 2025 08:52:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1737190334;
	bh=F5ARRNcTE7XzUxNp+fcsZX+HuTxNo4z0gQiDegWJ9kw=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=WGEivFGhgvjizHCswLzPdYD6xeracmAhYSczLL+24TwTMwQsXfSo3diqidDZztDQX
	 80VeMgzfZq7fxK2Hqp+d4L3jAG2Z2MY1zXrx6us+RiWAz3a6fj5E2N2uIM3n4BmuYX
	 TAuyXDKz+8hOnJvtkMWRRDvzkZjmSa6ugsTHUWngsFQL0x91avgjNf8tOuWKrefR7Y
	 0xfGIMRaYJMmkt0ygHQ41TwEPI7JEKmI7ka3+iulVvv6krHzaFr/Fn4CmYzfJALTJq
	 xMhV/BMReqxQDyvMz3Kxn3anYuQHJ/BV0FOyQJ0P+QrISEofo3Sy3ok+1cSd0pnfVh
	 5/HOWgBMPbQ6A==
Date: Sat, 18 Jan 2025 08:52:11 +0000
From: Simon Horman <horms@kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: Jeremy Sowden <azazel@debian.org>,
	LVS Devel <lvs-devel@vger.kernel.org>
Subject: Re: [PATCH ipvsadm v3 0/5] Debian package fixes
Message-ID: <20250118085211.GF140570@kernel.org>
References: <20250115183311.3386192-1-azazel@debian.org>
 <65ced269-1b69-3bd9-9ffc-807780e47e16@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <65ced269-1b69-3bd9-9ffc-807780e47e16@ssi.bg>

On Thu, Jan 16, 2025 at 08:44:28PM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Wed, 15 Jan 2025, Jeremy Sowden wrote:
> 
> > The Debian package of ipvsadm carries a few patches.  Some of them have
> > been around for years.  None of them is specific to Debian, so I'm
> > forwarding them upstream.
> > 
> > Patch 1 bumps the maximum weight accepted by ipvsadm.
> > Patch 2 fixes an unclear usage error message.
> > Patches 3-5 make some improvements to the Makefiles.
> > 
> > Changes since v2:
> > 
> > * Reformat the commit messages of patches 1, 2 & 5 according to the
> >   kernel's preferred patch format.
> > 
> > Changes since v1:
> > 
> > * The previous version of patch 2 changed the logic of the option parsing
> >   in such a way that using `-M` after `-6` no longer worked correctly.
> >   Thisversion just rewords the error message.
> > 
> > Jeremy Sowden (5):
> >   ipvsadm: increase maximum weight value
> >   ipvsadm: fix ambiguous usage error message
> >   Use variable for pkg-config in Makefiles
> >   Support environmental and command-line `*FLAGS` variable in Makefiles
> >   Make sure libipvs.a is built before ipvsadm
> 
> 	Patchset looks good to me, thanks!
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> 	Simon, please apply to the ipvsadm tree!

Thanks Jeremy and Julian, applied.

- Make sure libipvs.a is built before ipvsadm
  https://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git/commit/3c9cdaef8216
- Support environmental and command-line `*FLAGS` variable in Makefiles
  https://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git/commit/98d83badc6d7
- Use variable for pkg-config in Makefiles
  https://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git/commit/0d5e6cdae6ab
- ipvsadm: fix ambiguous usage error message
  https://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git/commit/fd1836223ab5
- ipvsadm: increase maximum weight value
  https://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git/commit/78b786958803

