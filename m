Received: from mail-lf1-f50.google.com (mail-lf1-f50.google.com [209.85.167.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 599F82D3ECF
	for <lvs-devel@vger.kernel.org>; Wed, 20 May 2026 13:35:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.167.50
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779284131; cv=pass; b=cY+x3Fd1SC0OIhHrT+cg7ym+MLDWuOAfBwn3GpVTEY4iHMGHe9ep1X8u03qaedD1EDMB6uZ5QrShrHOTjBhpuwg1r0h3QmiqnRpeRY+hZEKEZi51IozLG5GOy3Ibj3Nv4g4WJMhctrLhXGHL2uXD076RGnT1rrQfjxLWXIUArl4=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779284131; c=relaxed/simple;
	bh=TaewVaaJSRTgVv7uiAvCvNN525apvixVpdwb+G50UPM=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=bH7M472NnuBSGlFXVkB9XfoYWroJyPse0OD9kexeJPgj7Hvexx3pTPUOxNnXi+SlneGASX2nY39jysNUZXOi/OEyz/2z+1CHCyC1i90yo21lo33HaErB+Zl8jhFNYCbB+A7Opf2hV7+QtSa04cEQFhrw0lrovO3tVIM3SnZAlgw=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b=LGn1XMEq; arc=pass smtp.client-ip=209.85.167.50
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b="LGn1XMEq"
Received: by mail-lf1-f50.google.com with SMTP id 2adb3069b0e04-5a88db610ccso5521311e87.2
        for <lvs-devel@vger.kernel.org>; Wed, 20 May 2026 06:35:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1779284128; cv=none;
        d=google.com; s=arc-20240605;
        b=kkb7gXyxm0R3i/4iJ/Tdv0lzBoVTG3KoMksAtKH5tns9OqMiBbrA8DyOpXQjG7MZKe
         5dSezcqNbQup1xElo6STO5kmSw+bIZhFZ5Ngia14iJzjGoVRubVfCb6wykiGzSgCGDw9
         RE2su7kv596VY2Ecib6TNeLzU4TvIoLze89dJoJ13amO9+SjBa178z9I83KAcM2/6t5k
         ZH3OAy/ThdezOrFwJRyaKuJPhIBXbkFe/H0g3BqWb9fkSWHQ61h2IkZVrT5QDp/mPaYm
         1Q6yIxmF3EL8/ZNKaSagEquzIOOv8B5trVCEdGshF8tdgz74lmxC/7XzXjbSoQ4cGYGw
         kjxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20240605;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=Yu0/XtO4dIfAu/cztcBneHSKuN0SeWCUAeJO4rKJAag=;
        fh=i6rf0pa+8LFi7jkkArSVuPezk4ZEDQr+p4dtvW4usyE=;
        b=DYYq+9+xUsMdNayUFuSIfVp68alv2u0lhgEAuSdfYhZlnmiqOEKHDB1Bg3HNl11wU8
         2JsbOc5a4ZrIpS0v9oIWjj83nbsbioeiD1AOJ3zRinF/mRBcdFKTZeMPx9hDo/CwA2NH
         tXhWxU6t2fSPNxvLyAv5krmAryY4nbT5nuugdMPpND9A4TRmy1eyz6wIgh45s4XJBXA6
         ausFaS4uMqKb0UlN4FlLnvsPxZlVPx8Iyl6DxtvdMWL3lKjI5znq6aj3u/DLoTzEW8l7
         q5t1EJXpm3pR/Ypd680IfK2/myImBa3JjvctkcVA9VkWHC3c/1u/y1OLkHw05Pjqwgx5
         VAGQ==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=suse.com; s=google; t=1779284128; x=1779888928; darn=vger.kernel.org;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=Yu0/XtO4dIfAu/cztcBneHSKuN0SeWCUAeJO4rKJAag=;
        b=LGn1XMEqc7BwAhuIEoaGJz1Ki15lwdTkwh5ZqSasJbAHLIPYwItSy8PyDWIqj7TiRL
         +/tqPFnreQHSqMjI+CDSKlR5UmBY80l3eOzhsVNwsHk2hFT3IMlzAqjI0HAw2QdbQLWy
         xluVpgZ55mwkiBKrJNRzafPc5fdTSbXQfXgOIhqvjd5owAMLxTmTEYriHrHqu048yPpp
         iYwowOEwcgfbNesWsaDGvFmot3AM/WxdRjaM24e/8Ubil/X06kWrSLd6OaUIaM5S3+Aw
         skpgfWDVFbWWvacsKCsNzYkSWoI4yjb+kPgO3iPVHAv3bj2BpJuNYTXL2/xW2Cr21+8U
         BKtw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1779284128; x=1779888928;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=Yu0/XtO4dIfAu/cztcBneHSKuN0SeWCUAeJO4rKJAag=;
        b=OJg3shVG+iIBifT85euEtTPJSCNKNmhKDWVxbNvprMvW1RWrxvW61/VDWyVtFyeHXe
         2MY6VEddhS4MPR2EEfwzMouTF5Mfz/U19P42rc/MoYYNkCR0AS8za6JtJR0tPkviMDGm
         u+Kq100hqtfP8IGo1wwzgq5WIgDuDPPUxEjDaKwikF6hwbwiD6SBuyAhsml+JnXac1yj
         IRIL0M7Grcvcrz2YLTwjatAEmmD7hQalxCg51t6nmRqIjUjo8okECtrT18ToIEcE2FwX
         SDob2K6XDhACZFt/Tro2F/ubRCYeIjrORTx6K89CdiS+xCfc7Bts0JAHFL/k6Sj50TqH
         BWlg==
X-Forwarded-Encrypted: i=1; AFNElJ9GdFWtaIA++l57DeNbOQfcXtWJU2yTsgK0AcOks/IX6ix0fjIo2y3gBPuTAZawdd7TN2SF4unqyk4=@vger.kernel.org
X-Gm-Message-State: AOJu0YwfIGqmLJ0DjWo+IOojeRYJVVdVDM8VpxAd4SFs1zBAAIQsZraQ
	N3xhnJ6QHG54LuHfP0onGweUpnqJEAD2G4eHSgrKPMEN0hW2CoOKXblUawP5yNybUZTS8ZtPfl0
	+X43jtkZA9qDbEc8ATBpASHHTTW9XLMZqHtoA3iklEQ==
X-Gm-Gg: Acq92OFobzPyCC4e1Pr5wq1C1+b5RD3fSpOac/FuhOdtjOcoYRrzBtQaHHqyJXiV326
	Y9RkbQZg0HYOfBq7ssJzrv1YJuw+qbbW5CC0scs04XGq8qq2q3DrF5iVGUg1rNUrVZVGe2tqPYU
	iP/GRVn5no2dB+kZoGpMEl+3hg+XIWWIrlDcSR4+WGSP0LMAtlFyP03e/MQS+UWqA03ecfR/vO9
	RSj4g0Digg54+OdtVI46DwWm1dM7pIonZ8ZHtskh683JdF4u89QQetuDRxyjFXKliP58r6ARZxT
	6nldVGyt81yMPmPdPUs=
X-Received: by 2002:a05:6512:3d17:b0:5a4:1096:94e4 with SMTP id
 2adb3069b0e04-5aa0e73f375mr6835140e87.2.1779284128482; Wed, 20 May 2026
 06:35:28 -0700 (PDT)
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260515135143.259669-1-marco.crivellari@suse.com>
 <20260515135143.259669-3-marco.crivellari@suse.com> <20260519182219.0d685a27@kernel.org>
 <10173685-596f-1eb0-0903-a3d7ba4dff9b@ssi.bg>
In-Reply-To: <10173685-596f-1eb0-0903-a3d7ba4dff9b@ssi.bg>
From: Marco Crivellari <marco.crivellari@suse.com>
Date: Wed, 20 May 2026 15:35:17 +0200
X-Gm-Features: AVHnY4IeRKHo331ej-I0dmnws79oeyR-8QctDEsIk4GCUGbIHbl2IQWDS5Yw-jk
Message-ID: <CAAofZF47k3FiALNvNzaU8W=sNXXUH2Wfx==0G9qJAGM1rFOS_A@mail.gmail.com>
Subject: Re: [PATCH v2 net-next 2/2] ipvs: Replace use of system_unbound_wq
 with system_dfl_long_wq
To: Julian Anastasov <ja@ssi.bg>
Cc: Jakub Kicinski <kuba@kernel.org>, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, 
	Tejun Heo <tj@kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, 
	Frederic Weisbecker <frederic@kernel.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, 
	Michal Hocko <mhocko@suse.com>, Simon Horman <horms@verge.net.au>, Eric Dumazet <edumazet@google.com>, 
	"David S . Miller" <davem@davemloft.net>, Paolo Abeni <pabeni@redhat.com>, 
	Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>, 
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, 
	coreteam@netfilter.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, May 20, 2026 at 6:11=E2=80=AFAM Julian Anastasov <ja@ssi.bg> wrote:
> [...]
> > On Fri, 15 May 2026 15:51:37 +0200 Marco Crivellari wrote:
> > > Subject: [PATCH v2 net-next 2/2] ipvs: Replace use of system_unbound_=
wq with system_dfl_long_wq
> >
> > FTR leaving this one to netfilter folks
>
>         Yep, we wait net to be merged to net-next because the patch
> depends on commit 5522d65d81a7
> ("ipvs: avoid possible loop in ip_vs_dst_event on resizing")

Thanks to both of you.

--=20

Marco Crivellari

SUSE Labs
