Received: from mail-ed1-f45.google.com (mail-ed1-f45.google.com [209.85.208.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A65644C7B
	for <lvs-devel@vger.kernel.org>; Thu, 25 Jul 2024 20:19:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.208.45
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1721938753; cv=none; b=Af2n6+1r9D9DAEv2TaroA/alO3qdyu/7ksgBMF24joDeNsafeCsM+D8gv6UCx9XFq1ub8ygs61/4Jcm8nypxofhBfUa+NNaoFgT+pE4GuECnpu72LdrNM2Q04Bvj2YbGZCWEe4xw1rdlb+OYagFy1wOWesM+bmsTXpqIFIRfbdg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1721938753; c=relaxed/simple;
	bh=IvdqZvTacjy6MAQ5qDRh4fw3aGKlpJ5TgBBkoXVfd24=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=gyuym198tZEZ+AXbwIJjFtv1O94AkiOgofcNxIpoTBuE9MlRvLRoAncxthZOp4PIPN/huTrwIQyeJEElh+t6t5pUNpwX/YKf2vw5fFfc8bsx48OIpF0UeQRfCrAfbAvAQHT/8oa1rfFu1xnnAUp56EHl7WK9VjXTAGaxQPKF7QI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org; spf=pass smtp.mailfrom=linuxfoundation.org; dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b=a2pJi2dQ; arc=none smtp.client-ip=209.85.208.45
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linuxfoundation.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="a2pJi2dQ"
Received: by mail-ed1-f45.google.com with SMTP id 4fb4d7f45d1cf-5a2ffc3447fso1633707a12.1
        for <lvs-devel@vger.kernel.org>; Thu, 25 Jul 2024 13:19:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google; t=1721938750; x=1722543550; darn=vger.kernel.org;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:from:to:cc:subject:date:message-id:reply-to;
        bh=HYXza095pMOoHpnczk24pBNsoS9nyihsTN3J/3umgZw=;
        b=a2pJi2dQLzPLdfs5zFm8zRHFCeVxxi6csgW1tqjyOZdgGoDXVpi8Pg736NWywrdXDF
         BrABHMyrP6Ixsuqfe5cRh3e5mU3Od13YFqmBFlQU2okbWjBlLaYUF3SVJ4WmQYTgNBfH
         mj2cAutZ4+RvNCUDbh/peDHp6XdqfyUDf9ouw=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1721938750; x=1722543550;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=HYXza095pMOoHpnczk24pBNsoS9nyihsTN3J/3umgZw=;
        b=MXqBetlL/AgIpMVaPZ2mHzx+oo0aiU7ZeyLxX7TQXI1gT1tLCvOMtsowuBfwyKMkzu
         7FOiDI2+P+NLztV5VN8HxdjrC8/t+0PBv35ipJHOLXsJW3SYqZoAIV7yxs4tfsczqfXI
         qgnHOB++4UTaUWKKKXMV3oJM4vi79VraPcvQBnDXurhEU4eNHM3VzrsAs7OrQ/UpPXx1
         JITbOPgml0GDux4WOBX0qyHwR7FCYEFWNfNUTDrL65Zfwgv555xWbxfmgYIeSoVLVwn4
         +43ppCqn/myPbcNVxjvodMj5kuYraQ2m66bl4Iw2N9Qn8Pe1QJCDI8XhAIpiZhFX4IRO
         CTnw==
X-Forwarded-Encrypted: i=1; AJvYcCWM9St5ppqSwq0Z2ShcFNpElKYoPE8EUFapt/FF8lDRH08fhmQTkHCozdtvLy3h7rxRl9tdpqmWHZZLWVUBBiX9Mzhr+5vFau4q
X-Gm-Message-State: AOJu0YwF9xBssaWYHNQSKvRSz19UNkHugEU6cTlR5wVDa+zzOvwRDc0n
	Q307rkYJLJYPZ9us5NsV7W5zOHEdLgxkaWKDhSZJxT8rgCvHqm0nXj8NXU+I5DUVtJWKkNQ20Tc
	hSsg=
X-Google-Smtp-Source: AGHT+IG8HUhZMIXmTksAHF67PpKTEPIAC9LaxVCExe4Af3bENaMBmn4RYaZxdQXt3ylBHgNMXI9aog==
X-Received: by 2002:a05:6402:27c7:b0:5a1:6198:10be with SMTP id 4fb4d7f45d1cf-5ac608248e9mr2918947a12.0.1721938749959;
        Thu, 25 Jul 2024 13:19:09 -0700 (PDT)
Received: from mail-ed1-f44.google.com (mail-ed1-f44.google.com. [209.85.208.44])
        by smtp.gmail.com with ESMTPSA id 4fb4d7f45d1cf-5ac631b04e1sm1136919a12.12.2024.07.25.13.19.09
        for <lvs-devel@vger.kernel.org>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 25 Jul 2024 13:19:09 -0700 (PDT)
Received: by mail-ed1-f44.google.com with SMTP id 4fb4d7f45d1cf-5a88be88a3aso1728740a12.3
        for <lvs-devel@vger.kernel.org>; Thu, 25 Jul 2024 13:19:09 -0700 (PDT)
X-Forwarded-Encrypted: i=1; AJvYcCUfHKPsYrNdQuaHfUFt1MCdBJ6unRaNfGdAWx5MEjUNcJgLRvydNvffAE/e+ACXG79Zf0+w11a0NDeF18kXBwu5oiZjdmrdrlvp
X-Received: by 2002:a50:a686:0:b0:5a1:1:27a9 with SMTP id 4fb4d7f45d1cf-5ac63b59c17mr2468749a12.18.1721938304541;
 Thu, 25 Jul 2024 13:11:44 -0700 (PDT)
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <CGME20240724210020eucas1p2db4a3e71e4b9696804ac8f1bad6e1c61@eucas1p2.samsung.com>
 <20240724210014.mc6nima6cekgiukx@joelS2.panther.com>
In-Reply-To: <20240724210014.mc6nima6cekgiukx@joelS2.panther.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 25 Jul 2024 13:11:27 -0700
X-Gmail-Original-Message-ID: <CAHk-=wiHHDGQ03qJc+yZKmUpmKOgbz26Tq=XBrYcmNww8L_V0A@mail.gmail.com>
Message-ID: <CAHk-=wiHHDGQ03qJc+yZKmUpmKOgbz26Tq=XBrYcmNww8L_V0A@mail.gmail.com>
Subject: Re: [GIT PULL] sysctl constification changes for v6.11-rc1
To: Joel Granados <j.granados@samsung.com>
Cc: =?UTF-8?B?VGhvbWFzIFdlae+/vXNjaHVo?= <linux@weissschuh.net>, 
	Luis Chamberlain <mcgrof@kernel.org>, Kees Cook <kees@kernel.org>, Jakub Kicinski <kuba@kernel.org>, 
	Dave Chinner <david@fromorbit.com>, linux-arm-kernel@lists.infradead.org, 
	linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, 
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org, 
	linux-riscv@lists.infradead.org, linux-fsdevel@vger.kernel.org, 
	linux-mm@kvack.org, linux-xfs@vger.kernel.org, 
	linux-trace-kernel@vger.kernel.org, linux-perf-users@vger.kernel.org, 
	linux-security-module@vger.kernel.org, netfilter-devel@vger.kernel.org, 
	coreteam@netfilter.org, bpf@vger.kernel.org, kexec@lists.infradead.org, 
	linux-hardening@vger.kernel.org, bridge@lists.linux.dev, 
	mptcp@lists.linux.dev, lvs-devel@vger.kernel.org, linux-rdma@vger.kernel.org, 
	rds-devel@oss.oracle.com, linux-sctp@vger.kernel.org, 
	linux-nfs@vger.kernel.org, apparmor@lists.ubuntu.com
Content-Type: text/plain; charset="UTF-8"

On Wed, 24 Jul 2024 at 14:00, Joel Granados <j.granados@samsung.com> wrote:
>
> This is my first time sending out a semantic patch, so get back to me if
> you have issues or prefer some other way of receiving it.

Looks fine to me.

Sometimes if it's just a pure scripting change, people send me the
script itself and just ask me to run it as a final thing before the
rc1 release or something like that.

But since in practice there's almost always some additional manual
cleanup, doing it this way with the script documented in the commit is
typically the right way to go.

This time it was details like whitespace alignment, sometimes it's
"the script did 95%, but there was another call site that also needed
updating", or just a documentation update to go in together with the
change or whatever.

Anyway, pulled and just going through my build tests now.

              Linus
