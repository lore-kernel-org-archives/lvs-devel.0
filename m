Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D0457389106
	for <lvs-devel@vger.kernel.org>; Sun, 23 Aug 2026 12:18:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787487498; cv=none; b=G2whpmJFUveO2S8VVVbSOU4rgTXG+4EMGHnytKlBI2od2EUXCZUfqcFK/ViU4TaWTauw0wr02m75zHzhabS6kulk2C4E7Epj0utVewzPiEsNh64jdK6iFSUuRx44xK3oSb0qYu6Bi1IKVyGM8QNjSbWGHJAfOQhLT3VaOXF2BiU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787487498; c=relaxed/simple;
	bh=JcNFHADoqkvIv36t5vQofby068WTZ6Vs6qm59ZhdBxU=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=IuJ6WjfrwyE1a8ZLK1qyUGnYflM8sIjWoHAYuhLarmcTfREi5TzSFwwI6FYHU69MjGnexqKqtK+6tOewec1IJ+E1bKl8tKECJq+eIPkd5WbnQ16LOv2V1vdcrdcawTt/Sg0PFzuqInlT5Qh4GvrVgkpRzVAznLPWhO7O/hGjn/E=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=qZNVx7O4; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="qZNVx7O4"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 8D37520DBE;
	Sun, 23 Aug 2026 15:18:07 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=GgOLSgprPfORz/Op4XXj1li5fkYkxVLzZqUWIbojNS4=; b=qZNVx7O4vWgj
	Clk+u28aMJAq8XdAK/K4iEHOhNDOmYgCrtuw8tnpbNlIs0oDQJL2XurNcjmnR/iF
	d9Z0jJQgJWca2Nw0GMmOWoPGuZW238uNOWANpJRtjc4N/1ebI2THN93CjWUftB7s
	wEGHBAt2582Bxu/jg9jzi5vQ97xLiiey4kJnlm9nf9KTWYqjjBVvoo9CDlPAIqQK
	sdWeIMej8c6/QgmTFZHtbQqNb8orNFB8M4208ap1rv9Ngc3mmrpXB7Nb3iidGYCa
	4CExm+FvmUWzY2JqVZVMohsfFYntWNGC1o64HwUoejspgHGwhyp7TwuS0ZesxDPR
	bkpHCOgLMuiyuheLXcXVVQbi2jK30EkM4iIQ5sdtxQlJ5BhqunN8Jfz30s8DRokG
	cJJW4tYw+J0oGVEBlrBr8aASslkVoDrfue/zUOZrQfdXuq+AZGLfF8iFeTX0to1I
	LDRMmNfAcajnvQdjSQl31Bmrh+hoBYF7oYSHvFDZhCsudlMITQQZ+II9ihz50HhB
	k14U0IDeicMahGvTs/wXFCDDOGbrPFjMrjRUm3NVEPCX4iBX4x8hMaDlMXq4rDjH
	EMKmnjA4HI7qmSkVyjdk63FHG9KsuDaQ+jMMOaZFO6mHCsNYWWxPB/DH1Gv8sxBH
	33cZ2l/vba1qCusaR8qJXLX44LjHTOY=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sun, 23 Aug 2026 15:18:07 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 27905603F2;
	Sun, 23 Aug 2026 15:18:10 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 67NCI43p020984;
	Sun, 23 Aug 2026 15:18:08 +0300
Date: Sun, 23 Aug 2026 15:18:04 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Quentin Armitage <quentin@armitage.org.uk>
cc: lvs-devel@vger.kernel.org
Subject: Re: [PATCH] Document support of twos scheduler
In-Reply-To: <57320483-a739-4516-969c-0befbb8d4e74@armitage.org.uk>
Message-ID: <918abcae-6393-15e8-49c0-a670c2401f45@ssi.bg>
References: <57320483-a739-4516-969c-0befbb8d4e74@armitage.org.uk>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="-1463811672-160344681-1787487488=:4081"

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-160344681-1787487488=:4081
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Fri, 21 Aug 2026, Quentin Armitage wrote:

> The Linux kernel has supported the twos scheduler since v5.12. Make
> sure ipvsadm users know it exists.
> 
> Signed-off-by: Quentin Armitage <quentin@armitage.org.uk>
> ---
>  SCHEDULERS | 2 +-
>  ipvsadm.8  | 5 +++++
>  2 files changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/SCHEDULERS b/SCHEDULERS
> index 06d3357..8ddef23 100644
> --- a/SCHEDULERS
> +++ b/SCHEDULERS
> @@ -1 +1 @@
> -rr|wrr|lc|wlc|lblc|lblcr|dh|sh|sed|nq|fo|ovf|mh
> +rr|wrr|lc|wlc|lblc|lblcr|dh|sh|sed|nq|fo|ovf|mh|twos
> diff --git a/ipvsadm.8 b/ipvsadm.8
> index 3d7541a..fe0f481 100644
> --- a/ipvsadm.8
> +++ b/ipvsadm.8
> @@ -286,6 +286,11 @@ server as it was before.
>  This scheduler has two flags: mh-fallback, which enables fallback to a
>  different server if the selected server was unavailable, and mh-port,
>  which adds the source port number to the hash computation.

	The patch does not apply. Probably, the old lines start 
with extra space.

# patch -p1 --dry-run < /tmp/file.diff
checking file SCHEDULERS
checking file ipvsadm.8
Hunk #1 FAILED at 286.
1 out of 1 hunk FAILED

> +.sp
> +\fBtwos\fR - random twos choice: the algorithm picks two random
> +servers based on weights then selects the server with the least
> +amount of connections normalized by weight. The algorithm avoids
> +the "herd behavior" problem.
>  .TP
>  .B -p, --persistent [\fItimeout\fP]
>  Specify that a virtual service is persistent. If this option is
> 
> -- 
> 2.55.0

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-160344681-1787487488=:4081--

