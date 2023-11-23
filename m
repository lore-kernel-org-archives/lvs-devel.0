Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8F4384412
	for <lvs-devel@vger.kernel.org>; Thu, 23 Nov 2023 02:46:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linuxfoundation.org header.i=@linuxfoundation.org header.b="emGUSb6F"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CD706C433C8;
	Thu, 23 Nov 2023 02:46:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=linuxfoundation.org;
	s=korg; t=1700707563;
	bh=rRbIXqjq8DKBA6vW+7glleky65j8TQodsqrm6IeWtY0=;
	h=Date:From:To:Subject:From;
	b=emGUSb6FOYXRFx5zOxeP60WwTBc603sLQ2pobUlHMikxEUAfkoeXiOwpiDSebrqdf
	 Nl5vRiEdw/UupcKo7UUkYlVN1dih5NzTUM6wo7j7M1iwT4Rf1QBxJpjCvveaPLJCXR
	 m6IelcuFDHcDx4YAUsktUKTVbD0KcmwznwziivSc=
Date: Wed, 22 Nov 2023 21:46:01 -0500
From: Konstantin Ryabitsev <konstantin@linuxfoundation.org>
To: lvs-devel@vger.kernel.org
Subject: PSA: this list has moved to new vger infra (no action required)
Message-ID: <20231122-platinum-snake-of-shopping-cdcdc8@nitro>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

Hello, all:

This list has been migrated to the new vger infrastructure. No action is
required on your part and there should be no change in how you interact with
this list.

This message acts as a verification test that the archives are properly
updating.

If something isn't working or looking right, please reach out to
helpdesk@kernel.org.

Best regards,
-K
