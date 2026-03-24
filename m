Received: from mail-wm1-f41.google.com (mail-wm1-f41.google.com [209.85.128.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E906839DBFD
	for <lvs-devel@vger.kernel.org>; Tue, 24 Mar 2026 19:00:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.41
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774378807; cv=none; b=ZZXVv0st7ejw0E9RRJeFIC5VgYcZlUK2kQfaXgumVQ5eeiEWawWixzhgxWZeouDsn8LZlCTVX6z61vOhMDwHQUdbtdvxZ/kwmC3J8NChZVdf56H/W4qjDVA6cBq7cPOPewar6zsFbnXNjDALiqHf3Gi6GbgaRShfQiPc1RkGc+o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774378807; c=relaxed/simple;
	bh=jUFJvtaq69nRHMngc02znHC4Tix157JRHOphEm1e344=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ilLRHq2hUFFJl1JniIyjZdGBT5birJALFN/UEZ8MQIj1aM/e+9hFppXQDqxtVDK7vNqwvbghPpmwzdGY8xE1CxuE+5nBqj4iI//5WVKsqQaohD34S0prH+LGN0LkG/D/aehA9lVgCnNc813c62Ed1eU30lM/rqjc6v+da16IA1I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=ZFYiSSQN; arc=none smtp.client-ip=209.85.128.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZFYiSSQN"
Received: by mail-wm1-f41.google.com with SMTP id 5b1f17b1804b1-486fb14227cso17471435e9.3
        for <lvs-devel@vger.kernel.org>; Tue, 24 Mar 2026 12:00:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1774378803; x=1774983603; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=jUFJvtaq69nRHMngc02znHC4Tix157JRHOphEm1e344=;
        b=ZFYiSSQNv4KpQKmAMOrfP1CH/SlvSKEyOSfSlwNXgAXDFN3XHRV/5nQJFBks6keLCy
         u42OvH7vA8FhMXPkXAcS4KNIgmbDQvyqZ98hhPGZoandyBsBL6NJyfxvlwA4m1sxDH2x
         aVchJnGH1ruvODq0MirxQDfJSh4q6gveaq6AAb3ojto9oPAgwnARcGuZhpae20iAW5vo
         aK2T7xugPewi3/AjDh9+kwYM/ebhIxt9pao5a5rITk3ZyIb27/9p6h8IQw/BxtIev4hf
         tK2jEgq6INjIBWKuClp0H+Sn++OD1OX/2Oqnwhy1czR7/6lm6ec88Y6goC5JD47BFd1l
         ydgQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1774378803; x=1774983603;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=jUFJvtaq69nRHMngc02znHC4Tix157JRHOphEm1e344=;
        b=gDVP/+IA0BYV5YPPdNAf00VlX2QPAxVF9O7MuMFdvtjJgQ316CYVEaigOndc6oc0vz
         UInW5jhpwQ74enq0AX7prN0i8UPSGGY7LsA7EYBvBPzAkX5h9aoCoEictsEPfeI8YMjG
         djV3G6EKr4eEy3RCTNFfgDBIyyHKci1YAoX05x7ev4QsXSdqZIUixRlWEizGoeDHlShx
         Opv0cvROiy6Vz33I+Uto4y+SRs3lZzulOn7NbeC/OyvPWEXitt+FaleQiYbvglPq3wWX
         HwMPhURHXlRSSNrAwPwkyoEGmBZU/qvvSs8EeGFm9512Jj1p5gBhm2HnhqeqrPGKDukM
         E2Ag==
X-Forwarded-Encrypted: i=1; AJvYcCUdJJ8Ak9/0eYS3iYetsbja8NBtKBDy+i3AR9652+RL5eQjR81mUVuFIwThcza0RCdlVP9vYaL8KJk=@vger.kernel.org
X-Gm-Message-State: AOJu0YyJdLzADL3Dmgc84ox9FI6+h5AbvFlvCq6ojKzRVNKAXMuPiUNE
	hWyICPBnOFVjlLC8BntKQg4+B9EmRPsU3/Byb//vCn0WEUzvK6GdVuwn
X-Gm-Gg: ATEYQzwhgiA4PUJcyWAT53ruTquqwb4xs/hriG/1h6qk/mekbR8UwBS8FJpnOz6ATO+
	VXdmsrz1a1+wLcCEZ/eYEuFF6qzHPZt+R4qK51p/Fmk8ANslMfFzVoFtt3vGNKQqQ7IyoSvZ4Tf
	+6REZeXB7/2bWM9LppS2/pDpAJ1X+K8WWxsmbFcLpeYmtu/IzLwI0Z09dnG1nmLsDVy5xVkdRht
	jLNu9OyL7CRogfxx+aiMyV2TnWdyDD57MIb/13p38a6f5ilqOROKci5bE8HnKLkvYkUXI/jnP3C
	6bvkTGaMLvksw5X5RTmdJ8y6nPbEQhbpTXFAxCDhgtAbe8LwkZpyi6q9vb6RiMqrG3CMwRxvdt9
	LQqsOHc4CAo/GxJhx3b12Ba2PYBqqOM/K5M8xy4sdwA9Gk+egmrlsQxxCgFapuyy1lb0i2nTIjg
	k+GZbGhseq3RHF6ySpjdlvILyz0fxcnZ5vg8oLVZI=
X-Received: by 2002:a05:600c:a4f:b0:485:3a03:ceca with SMTP id 5b1f17b1804b1-4871606c9e8mr11861135e9.23.1774378803195;
        Tue, 24 Mar 2026 12:00:03 -0700 (PDT)
Received: from localhost.localdomain ([102.164.100.74])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-487116ee57esm64387355e9.14.2026.03.24.11.59.50
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 24 Mar 2026 12:00:02 -0700 (PDT)
From: David Dull <monderasdor@gmail.com>
To: longman@redhat.com
Cc: linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	linux-sched@vger.kernel.org,
	kuba@kernel.org,
	pabeni@redhat.com,
	horms@kernel.org,
	David Dull <monderasdor@gmail.com>
Subject: Re: [PATCH 1/2] sched/isolation: Make HK_TYPE_KTHREAD an alias of HK_TYPE_DOMAIN
Date: Tue, 24 Mar 2026 20:59:29 +0200
Message-ID: <review-monkeos-20260324@monderasdor>
X-Mailer: git-send-email 2.49.0.windows.1
In-Reply-To: <20260324151827.2006656-2-longman@redhat.com>
References: <20260324151827.2006656-1-longman@redhat.com>
 <20260324151827.2006656-2-longman@redhat.com>
 <20260324151827.2006656-3-longman@redhat.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

I went through the series.=0D
=0D
Patch 1 correctly updates HK_TYPE_KTHREAD to reflect the post-041ee6f3727a=
=0D
behavior where kthreads follow HK_TYPE_DOMAIN. Keeping it mapped to=0D
HK_TYPE_KERNEL_NOISE is no longer accurate, so the alias is the right fix.=
=0D
=0D
Patch 2 properly introduces RCU protection for accessing the=0D
HK_TYPE_KTHREAD/HK_TYPE_DOMAIN cpumask in IPVS. Since the mask can now=0D
change at runtime, guarding against potential UAF is required. The=0D
changes are minimal and the helper wrappers keep call sites clean.=0D
=0D
Reviewed-by: David Dull <monderasdor@gmail.com>=
