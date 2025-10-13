Received: from mail-pf1-f193.google.com (mail-pf1-f193.google.com [209.85.210.193])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C71282C15AE
	for <lvs-devel@vger.kernel.org>; Mon, 13 Oct 2025 09:35:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.193
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1760348103; cv=none; b=IKOdMsIcyNVunzJKad3RBnxsaKIsXt92W5wURq8oJpUcQGqjXVTQGuUiWr72oOi1Crb2nMfoDR66W3gRAyU0zx7lQGgdFhwyapaf6yAeDeEbDNmx6UuxYX61m1B75aRT8vfNKo7yHbuHxt/92aFPcilorZEkNPQqp2s2mSBhSbI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1760348103; c=relaxed/simple;
	bh=h/7JTy6TbprU+dCtnUq5sVaFosiidQqOxR/pPvZSvKA=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=vFCtYpF2WeJFqPytoiPS71BAGpgu4viaWSI1fAPRsai3crqoFwDOHY7tW+hFVMb/DEIr6nCGisCvkvTEej5qUSsVB+qSXxHlI0QU+ct4uIZ3BHk+hsEGbCmQi4zm1iSFTBNhUkTsCC6ePguYWvFX5+II+8gEKqQvCY9YT70BWeQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=mnx1SxTk; arc=none smtp.client-ip=209.85.210.193
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mnx1SxTk"
Received: by mail-pf1-f193.google.com with SMTP id d2e1a72fcca58-77f67ba775aso5726733b3a.3
        for <lvs-devel@vger.kernel.org>; Mon, 13 Oct 2025 02:35:01 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1760348101; x=1760952901; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=H5bKclxFecJJ5GNJZlIb9xGDoD2UnMroqAQc+H9CWag=;
        b=mnx1SxTkrQzHYji3aeb3q4OJ91PiRt+A7UU+c/8zJExuePN2QeB0IklJwTH08iodb9
         88kDaaj4FBNqNOtBTe+OejuT3GlNCJcZwjgASUnCU4a0lR1yY7M6QZR6UMYWSiSh5+GO
         Tx9y1tJ+iZiuZITt5suiuPdQ8g+j6ane0nytRhF/zsYd6TqiinT29kbbjZ70akhtMZz1
         gFItwEi5eZMaL56EE8dNlJGvP1yNkZmlgkCw3CxS2OJ+o/H2ayhEoUVgXk9QYP8jfPEG
         9VDEIuB/nihlBX/vMp1CSrmHCqgPinTh+LVg7YqCqf5zQyg0oGEC9NUJm0Go6V+SR27i
         L8/w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1760348101; x=1760952901;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=H5bKclxFecJJ5GNJZlIb9xGDoD2UnMroqAQc+H9CWag=;
        b=YViRSRZl2u5xn0XYYqG2uLTI7ithjsmMwUCUp8RXwnZfuDBiJ4Qq+XBOXUxzbRI5Ly
         oj8UXGMBOCGDxnLRDaCPdGhu8aD1F/9YCs4m11jlvhP/X6+vUu+KRaluOSjC343Q8TZp
         33LURR5CmAjOV1itkBjh+w/55+YltE+2hzO5JeJTYyE8ZxwFI2Y6vdlDRVJrKBIepmtA
         1ZvgyWiWXfnbdTnj9KRv+gduqrmVzkQ+Ubmf7FiGM6nzysyXvpBdsscPYzxjRgzGAFhI
         HkQm/UYH1r4txy0J+CPaJiDPnB49EjWvx7GesB9vvv5PO3gjJdRFf3kYVnlJ1IKnBrbt
         NwQQ==
X-Forwarded-Encrypted: i=1; AJvYcCXOdSHyutv4gYviN6mFl6njlMHqudFphNMOJsemcJan8vXT71G3qCl252U41U1WJwlXSLdATu4vY94=@vger.kernel.org
X-Gm-Message-State: AOJu0YwXyTb4nGRvQAmCp9EHzWz7G1nnm59GM2Nl/tPPowWMBmS4LMwl
	wLfd/BOq1Wom3B6KgPlEK0N1ASF2cvn9UXPZMQkiDbxaYOsboCfQ8mtG
X-Gm-Gg: ASbGncuxwEuqUOTTGXTijdLFkTbQ1PAzKPuGzA0qFo6Z6s3ZatXyMpjKTicCZpbbZiJ
	34sZHBSPsV/1/+TI2jMMkS9/u1fQaJ0CO7BysITgWnYCA4gI6vWklRPIX4CoXKCimEAPUpSnV1k
	8o6gGsNIIkZXLlcbEp7Vu0gtWVuZx9pHhRYnAbHVE5xV8EKMYvDTKS21OWDN7228mCbShuEYbAI
	6Eb2SicZZOt9OUw2nu31/iSXpTy66o96ZOFQ7JJ588uzSYk1HceCiFFmpxL9j/CHX3vCdGwAb5W
	iH75aGXl5FdxDGU2vUyWxcyNBaNMFIY7IoAcMLnovjZ4/xrWyRu3D1Na8UHkedWyz5r20JMc91P
	FAqrhxYPzxAfMWpQvAqrBehz6vztZyWSRn0vY/KnE/3rCxafFot9B6d046PdMfPoaC9QWzHc/+g
	==
X-Google-Smtp-Source: AGHT+IGPAzAetlOptAzw9GaNxbD3zKkFT2GadJ1WyMX5hnKkmmcKAsypxbC/VTf8veeCOAjENtE2yQ==
X-Received: by 2002:a05:6a20:7291:b0:2fc:a1a1:4839 with SMTP id adf61e73a8af0-32da80da6dfmr27467709637.10.1760348101035;
        Mon, 13 Oct 2025 02:35:01 -0700 (PDT)
Received: from LAPTOP-PN4ROLEJ.localdomain ([222.191.246.242])
        by smtp.gmail.com with ESMTPSA id 41be03b00d2f7-b678df952cbsm8693944a12.45.2025.10.13.02.34.55
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 13 Oct 2025 02:35:00 -0700 (PDT)
From: Slavin Liu <slavin452@gmail.com>
To: stable@vger.kernel.org
Cc: Slavin Liu <slavin452@gmail.com>,
	Julian Anastasov <ja@ssi.bg>,
	Florian Westphal <fw@strlen.de>,
	Simon Horman <horms@verge.net.au>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	lvs-devel@vger.kernel.org
Subject: Backport request for commit 134121bfd99a ("ipvs: Defer ip_vs_ftp unregister during netns cleanup")
Date: Mon, 13 Oct 2025 17:34:49 +0800
Message-Id: <20251013093449.465-1-slavin452@gmail.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Hi,

I would like to request backporting 134121bfd99a ("ipvs: Defer ip_vs_ftp 
unregister during netns cleanup") to all LTS kernels.

This fixes a UAF vulnerability in IPVS that was introduced since v2.6.39, and 
the patch applies cleanly to the LTS kernels.

thanks,

Slavin Liu
