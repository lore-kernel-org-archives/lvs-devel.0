Received: from mail-lj1-f177.google.com (mail-lj1-f177.google.com [209.85.208.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2B8D13A6B76
	for <lvs-devel@vger.kernel.org>; Sun, 27 Sep 2026 15:24:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.208.177
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790522650; cv=pass; b=euBoCdWs8Nrw0l0W0/KkB+umhTE7eu0GSZ4oMI6fIfD2KkNgX0uSoTqA3/hzHZvCXrgk2Nozrj2/3yaqW63Kk2mDC76ANsNR/BWPaHwBT6gLsRbdnvjoehsMhgpapt1AXkCU4NnVLGV2tO1vY28qQc9Ba4B94c3DIXDZYSWMAwM=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790522650; c=relaxed/simple;
	bh=IqYOXuenTrd/G7JC31ZlM5cYuEr0pOS90JESQYxp+5A=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=IWns8NDeS70Tg6l0eufLD9lBetubwq+24A7qRf2PraQ2BVy0R/ndu8QXALs1eZDf0OFaEBEo7g+dtpTFmzGG6I8JadUAZZl6SaFP5aHD3xvF2IcvaZ7kl9NFHi0A4BiAzAUFNf/kdndPoOhfdH9tXoHhII0JtQ9SOzoaHKzDjhI=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai; spf=pass smtp.mailfrom=nebusec.ai; dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b=bvDNLnlw; arc=pass smtp.client-ip=209.85.208.177
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b="bvDNLnlw"
Received: by mail-lj1-f177.google.com with SMTP id 38308e7fff4ca-3a5a0703ae7so16456051fa.0
        for <lvs-devel@vger.kernel.org>; Sun, 27 Sep 2026 08:24:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1790522647; cv=none;
        d=google.com; s=arc-20260327;
        b=LCiJPXQ61CxKi8FGYlB7kkzswA6JvoH1BinUOPuRDnaBHMyi26eP3UCyTFln+XxSLj
         0mM7g+ReKpyErqKUgGcF90CTtCc+0LkDDBG3nr0RMwJzNyUD2BKDcWwZrs5wnRKyfdek
         HBkNA4QvILaf9nau2kYUa02UQxqO/9+JEZ0YRhTDuKLLDnjCUEd7TXeBOLudeX9pAHNA
         woTXV4O4rX1r4RT5HIwZ0tZXXayMWG3vJ+Bqac88iZcTdya0oRPF9c/BzAMBpeXkmj3Q
         YVvicRvUcReD8TuhAgWi520MN+oQxFuQXsom6HimQHV4KhYog2gQOdF3/dzxgLNG6aDk
         qdUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=lYYzgThSGrD/5n0iLNuP+nmqXn5Ij30rBL7XkqdHCKk=;
        fh=ZOxYtfd21VYsCWi+kjA0CSMVCpeugj2MbVhbORGp62c=;
        b=pjYyTVCMPcPdrcehT5ZsXJsA/NZC1NfsKsCFFTxDL/e0yGtPcRDScEbTABKIAkAcbu
         YTL+d2hPS/A4Gguzv8pdG3QJ/D4Bc4y141R4PKBXIJ9L6ZKAtZphtyrOFwaazuPyitSk
         i9pSL+zvZgFOlQXsNgZgE3QSumdFBxe33KOgEAyA3/Hj6XHXuhU4/7TkzbPgGVA57G98
         3KefWlpxl5QuRYrSXbYveFoHXg9cW0lEeQo+6BdcUPaz4GZNL/z1T8vlosQPeh7f61Ek
         4XtB9tR+k86EX4wgmdTAMBFtEGRlmQA4l3D8J3k+A/9Lcu0NIGaMHzfkIBaSedv9mCOq
         tOUA==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=nebusec.ai; s=google; t=1790522647; x=1791127447; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=lYYzgThSGrD/5n0iLNuP+nmqXn5Ij30rBL7XkqdHCKk=;
        b=bvDNLnlw3JWJDcmPd1MdT2k8B/AD8S1/hBjBPSJfveFXjXweDtRMb6xHaSLFcvHEjt
         6hceiOSwN3ndIPKPTRB/32pmlI4+YDqNN+sDOcKC1rQGCzDtFsPOr9HQhltk2PXDoCuH
         B/VJXKsTUvALDvnAI1c1VlIlUOZGY47Lteh4Qh5aLu1vvbkOWw6Godf5Fp65Hnq/16/6
         0sZ34cy7So17e4pmIjOnFVt0YWZFID3UogeyuNN9qeWCLFNziTUhsrQDC8aE70EOf7sO
         u9IoXKkjPfhv/GtIJO52vYBzc6W+gjv17Lc3Jx6EXZ52ymTPadq6FT6DqDkGKn9xuI7i
         XnfQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790522647; x=1791127447;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=lYYzgThSGrD/5n0iLNuP+nmqXn5Ij30rBL7XkqdHCKk=;
        b=JjGcyITSz6Nc/WytBimdA1Z44qWuo4GrYXk/F1atFoELS/G/hqEmyCqzMV7t3t1Gqt
         lggTDZC9OBGoGg2khz5I3a4s93zu3p11RCZkUwDfDQkOewKEGpbWT/TF4MMQuz/fE3rI
         Q3FdJhApAApMOQY/bZIZtKJ6pmuvzo/l9HM7BUzYnIFGz1uiqE/GL01NDOmWgStZ6roC
         Xv95Oo43KSt+19RxJ5WFY6gROe4X8VM76izNRmqYYgfbpo8qInuk1qnUyjYBqDmbPNIi
         mukijlxpAaIm6vKbifOBaKQ6832t5cV6u56L8lMhqBMgRVWjA4QwMji+Vwzv0hrFa2c9
         +JYg==
X-Forwarded-Encrypted: i=1; AKwUvBwF6bmEggNQnwTG4CY+1dk5WMtDWCf3HBo3kUaqf0Hz7tTLghsMnwOEMzzZWhTZH5ZOSPCVkVYxKSk=@vger.kernel.org
X-Gm-Message-State: AFq9FYJKxORIAiYDyjw6yF7FWrkCHlDLkcf7tMczcN6Sya13ARUnLxTb
	XcupmqUVaHQYkAXsbjf0SoEl/mOGMpeaWM992KuWCZaSTlYw+aYs2A0gb8FQc9mhEY2GDGQ5kGB
	CaZYyByHalt4f4n2uue8iU5vGl4TTdn/GYgig+k2dRKgUOLuREYI0JbxhmTd42Q==
X-Gm-Gg: AYBFou2CKCo3FeTai6pb6Pjjw82Z2UWqruRw5ADODeDxwmLHNGjDpdwgvaNpiZuLgyg
	MHU/06V9htbIojY6UfCKkJpWqQkxvf4f1Usgb6dB0c7wi3sfkTKD6INtXA1F8CP9CEJYqzmsyys
	CSv4U/ELESyRqDSDWTwL7rX+9otpJknS6nGqQJ6XpmjGO61o/kDUxBW+OmLA7MfMvzOXQfS3SuC
	JSaP1+cM1MK1BwJMUwzogH2k3F8KdkywlhICYpTbhsHKXMvRpM8RmrexmwQpccuCoue77c4EfaG
	nV3ty4CVxzf+LXYQ69X5JzxTMgFuKUWL8lQ3xG/htDrscOxMZ00HbudIGj8DuiSmnmh8e8UJa+X
	Qtw/y9i0dIQ==
X-Received: by 2002:a05:651c:1585:b0:3a3:61ec:43c7 with SMTP id
 38308e7fff4ca-3a63c2fbf19mr25857111fa.24.1790522646186; Sun, 27 Sep 2026
 08:24:06 -0700 (PDT)
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <cover.1790266803.git.zihanx@nebusec.ai> <ce3d490f-4be4-7eaa-0993-c1e4d1fd863c@ssi.bg>
In-Reply-To: <ce3d490f-4be4-7eaa-0993-c1e4d1fd863c@ssi.bg>
From: zihan xi <zihanx@nebusec.ai>
Date: Sun, 27 Sep 2026 23:23:52 +0800
X-Gm-Features: AclHuK_dLGbaKOOdt-gDveLynvCg56unCBYk_KeFbEJfV6pwu-pvHxZdAFl9y-U
Message-ID: <CAANe3eTgtXLVzrXuXQykh67XaUzGj-kWKzB1Sp0fwT0kZ_74Pg@mail.gmail.com>
Subject: Re: [PATCH nf v5 0/3] ipvs: avoid stack overflow from recursive
 connection expiration
To: Julian Anastasov <ja@ssi.bg>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, 
	netfilter-devel@vger.kernel.org, horms@verge.net.au, pablo@netfilter.org, 
	fw@strlen.de, phil@nwl.cc
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, Sep 27, 2026 at 10:07=E2=80=AFPM Julian Anastasov <ja@ssi.bg> wrote=
:
>
>
>         Hello,
>
> On Fri, 25 Sep 2026, Zihan Xi wrote:
>
> > Hi Linux kernel maintainers,
> >
> > We found and validated an issue in
> > net/netfilter/ipvs/ip_vs_ftp.c and net/netfilter/ipvs/ip_vs_conn.c. The
> > bug is reachable by a non-root user via a user namespace and a network
> > namespace.
> > We've tested it, and it should not affect any other functionality.
> >
> > This series contains 3 patches:
> >
> >   1/3 Fix the timer callback race during IPVS connection deletion.
> >   2/3 Replace recursive controller expiration with an iterative cleanup
> >       path.
> >   3/3 Reject zero and configured FTP control ports as data ports.
> >
> > We will provide detailed information about the bug
> > in this email, along with PoCs to trigger it.
>
>         There are some valid concerns in the Sashiko review
> that we should solve with v6, so we are dropping v5.
>
> pw-bot: changes-requested
>
> > Best regards,
> > Zihan Xi
> >
> > Julian Anastasov (1):
> >   ipvs: wait the running timer cb on conn deletion
> >
> > Zihan Xi (2):
> >   ipvs: avoid stack overflow from recursive connection expiration
> >   ipvs: reject FTP control ports as data ports
> >
> >  net/netfilter/ipvs/ip_vs_conn.c | 117 ++++++++++++++++++--------------
> >  net/netfilter/ipvs/ip_vs_ftp.c  |  18 +++++
> >  2 files changed, 85 insertions(+), 50 deletions(-)
> >
> > --
> > 2.43.0
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
>

Hi Julian,

Thanks for the review and for preparing the timer-callback fix. Understood
that v5 is dropped and the series will be resent as v6.

I=E2=80=99ll revise my iterative-expiration and FTP-port patches to address=
 the
relevant review points. Once your v6 patch is available, I=E2=80=99ll rebas=
e the
series on it and recheck the combined changes, particularly the controller
lifetime handling. I=E2=80=99ll also clarify the active-mode condition and =
how the
FTP path can extend the controlled-connection chain.

Regards,
Zihan
