Received: from mail-wr2-f12.google.com (mail-wr2-f12.google.com [74.125.225.76])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6E3963E49CC
	for <lvs-devel@vger.kernel.org>; Mon, 21 Sep 2026 21:30:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.225.76
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790026257; cv=none; b=J5ar1TxjHyztac/7W77rQzk4C5bDWiIE9cbMkBajRMs3kvcdLFxhCxKvzjt9+UIIZ2D1e4r4jcvBZWjxdZnBcUBXOcj+/zU74RvtRU8bnnU7XdiJmFs8j2EqZHcgX07F+PkHvV5iTxdWMz/hU1Tcple9+ei4ghqvQEjFxpgNVlA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790026257; c=relaxed/simple;
	bh=SDD5uJHfK6z8nRdxuK0ng0TRvAY5EGWTNJID3QGutxE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=O1nSoMXIPIh5P3Gg9FV0s/M+CtTC5X8Dy2zUUKKFwjFwxKYsGEkZ/JgsGYpkK6EhDXIlSgm06SRA23fw72d2UEbHfjRT+9AHVnpEicOuP7mlaDePvefhk2lowOraWaj4l4SlEa3fVu/f8uH+YlbrwUuSbhGoftOEkyWFvQAs/SQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=NRroXxKS; arc=none smtp.client-ip=74.125.225.76
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NRroXxKS"
Received: by mail-wr2-f12.google.com with SMTP id ffacd0b85a97d-4843f22dcb8so2275039f8f.0
        for <lvs-devel@vger.kernel.org>; Mon, 21 Sep 2026 14:30:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790026253; x=1790631053; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=SDD5uJHfK6z8nRdxuK0ng0TRvAY5EGWTNJID3QGutxE=;
        b=NRroXxKSntq3xO4MSo3ErmviL4Xxw4fuz8NUWG+GV0sooY5EtQX558oSc0esSAbopE
         XsyztbYzA2x7Dkqy2hio380jFCPzVTeSCYgqYM3aKDUa3kGTG7FfTX9ZfT6sJEONx/dr
         knuUYZ9++zkefwgL9ghci1AJybaWRPftuwsqDAfe05Gey0dt4T+geSFR64uIvYscBtiY
         5pGFDZy1wEAQFuTHX9McyL8Tlh+5YJqDs7rKaxCyk8e9nNGM5tzPwYIfB1bMXfgsOeZm
         lS2lSCpIoUEd3Z73iI+sqnXuYqYL5GVZuh+a3MkXN4+2de/TEl9NXBOVDCJybNx3cf+R
         nRVw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790026253; x=1790631053;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=SDD5uJHfK6z8nRdxuK0ng0TRvAY5EGWTNJID3QGutxE=;
        b=j8i7jIWVc83NOqScYE1Inht59OK3vE2/+rqEATpFiu29T8btOOKJvPKH7GpwPe1jWG
         WLHekSqTNhDumk/LyqCYrTqWPLVccaG4oGYp+rZtH//pnpHbCQ1Zzd80WS4qm9ggVrqW
         BPQdztgMjd+k5RlBkyYimRMBYaWrClQSei5//toxaQjZRvV6eFo1oIbT3tkwCxhZtgfq
         bOj8EelwKEsfXoVPJfd0D2+W0pifS0HzWe8wK+u3mMaWPwZ1dg7f3y9RryDyoMGqpy1l
         tligjmrj7f1yBF7x8VOWFDRZP8AiLI6zzo3NQjT2MtaISWH6s01puKBCNwTEaC+zD8KR
         af4w==
X-Forwarded-Encrypted: i=1; AKwUvBzJqk1nXtkZ60FzorXoCC+LjovRH45IW03nS8+8CW+ls69IUjHe1uBDSBVq2dUwvryQAJIA6PLiYXM=@vger.kernel.org
X-Gm-Message-State: AFuF++mt1JEjMIJYVjO5WQmJFygCBrRJHvIoHCfNXjsqv8bzPU287gQw
	EhlGSmX9bFwf6Y1U2a4PptI3yyDaMxxFsfomWBzIcesXoTX8z2YnPVVX
X-Gm-Gg: AYBFou3t2ip+W2R6GW5yYgpZu3gqMqa65vSHjzovSMaDqf5ynpUoYo5heC4F2DVN5rD
	NQQbCESXxF8T3HpBRL5eA2H5JfqYCKpjCEfNOX/Gv1Zl8n8IjqSDxjUTDmA4aDWH7ZE21K41HEQ
	nIXcxaubG7ah6Fh5WAIUH/20yCkpKGbGi3qFOUT7CPIMGS1Euf0Hu2mgprIZR6pqDkY+IAkXaa4
	YvtrR27UrsT4HW9FcuS2Ky4x2CEsgJkiOEpM+5YaSHvV+IqaqBjXl4lpPFWk2Br5GJs352Vwusd
	7qabUjLpScmYGfymAYkZDyCrc3Vuoeemlq5lIDedNdZ7G6d1UiSrgMxbgNGTPxyTIr+fhmF0sT7
	Y0hfz1xvVnuuFZTNR/kUaWEr50m/vUQJaLvoBuWcCUkq2crf9Y9756vOMnISdIBT2OS5P4vtzgv
	umYmT6wbbYu3No8UNoEfwqLS8Skf52hqn2ODmof+SUUyTnL+5xvJ3U/KSoD4ZOyHtmqtjecjHIT
	nXS9NGfLU1Y8iPK2EP/yjdaDTCPrFhz7wjvZUw60U4ZZwkikg==
X-Received: by 2002:a05:6000:2890:b0:486:fa7b:d3aa with SMTP id ffacd0b85a97d-4871e2273a5mr15062011f8f.23.1790026252444;
        Mon, 21 Sep 2026 14:30:52 -0700 (PDT)
Received: from linus-personal-clanker ([102.164.100.122])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-48862287b6esm239042f8f.33.2026.09.21.14.30.49
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 21 Sep 2026 14:30:52 -0700 (PDT)
From: "David .B. Dull" <monderasdor@gmail.com>
To: adrianox@gmail.com
Cc: fw@strlen.de,
	horms@verge.net.au,
	ja@ssi.bg,
	linux-kernel@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	pablo@netfilter.org
Subject: Re: [PATCH v5 nf-next 3/3] selftests: netfilter: ipvs: add per-service secure_tcp test
Date: Mon, 21 Sep 2026 23:30:31 +0200
Message-ID: <20260921213031.6160-1-monderasdor@gmail.com>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260921205706.1055288-4-adrianox@gmail.com>
References: <20260921205706.1055288-4-adrianox@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: David Dull

To: Adriano Cordova

Cc: Simon Horman, Julian Anastasov, Pablo Neira Ayuso, Florian Westphal, netfilter-devel, lvs-devel, netdev, linux-kernel

This patch has already been reviewed by the netdev bot with Sashiko on 2026-09-21 for the v4 revision of this same selftest patch. That review found three possible issues. First the changelog wording claimed a bare SYN ACK suffices but the probe actually sends a bare SYN followed by a separate bare ACK. Second the script has no kernel side prerequisite check and no skip path for when ip_vs is unavailable. Third the secure side assertion cannot distinguish between the per service secure_tcp working correctly and the ACK probe never arriving at all.

This v5 revision appears to address the first and second points by rewording the changelog to say a bare SYN followed by a bare ACK and by adding module availability checks for ip_vs and ip_vs_rr. The third concern about the assertion being ambiguous if the ACK probe fails is addressed by the addition of checking the probe exit status so a probe that dies after the SYN cannot leave the secure side SYN_RECV assertion passing incorrectly.

The code itself is well structured with proper error checking in the libmnl helper for setsockopt sendto and mnl_socket_bind return values. The fallback definition for IP_VS_SVC_F_SECURE_TCP in the helper is a reasonable approach for older userspace headers. The test topology and the approach of using TTL one probes to prevent the packets from reaching the real server is sound.

However there is one remaining concern. The assertion that the plain service reaches ESTABLISHED state depends on the probe successfully sending both the SYN and the ACK. If the second sendto call fails in the probe the exit status will be non zero and the test will report failure. But if the ACK packet is sent successfully and simply does not reach IPVS for some reason the connection may still be in SYN_RECV when the assertion runs. The sleep between the probe and the assertion is only one second which may not be sufficient on a heavily loaded system. Consider increasing the sleep or adding a retry loop for the state check.

Overall the patch is in good shape and addresses the prior review comments appropriately.

Reviewed-by: David Dull

Signed-off-by: David Dull
