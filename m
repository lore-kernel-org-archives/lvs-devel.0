Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8D7C02DA756;
	Wed, 20 May 2026 04:11:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779250306; cv=none; b=abGC4wePjkDTX9yJFroskcewhaXbSmGY0bs0uI9CDchpyWlb9QiooWJ9LCEndCRWFayOhgzLVeYKYJ+6ouUadWdTfKvgVlQAALCqTCyBeIiXE6ZALiUEDeBlsdQ6Ivt2+6hGgiA2imCYawGYcH0073OQwpxPPiX0GoNo9psBDS8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779250306; c=relaxed/simple;
	bh=+nULNlyf4O/uiWjCAvQrgQHSz8xiGemqV8ciNy0wcQY=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=pq6WoJn2+2eOSJOBrRDJIpEGRaGFApcfZwTkGOxQLHqfL7IRubFl3zQMpuGRQadcNukKRMl6LLVdUYqbtmCObr0qcqCfDxkAluW0PCtN7+d0oFMECiuj0ejmhaHUvtq7VjJA1srvVnDAL0Gmc4u3lVZw4B8oODBTrTw2+6ZoVEA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=NPN1XABn; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="NPN1XABn"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id C41F5217D5;
	Wed, 20 May 2026 07:11:35 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=4PfbLACuCQpSYnAR5qGzVx9PtsB1XBBP8U4mGrcUZcI=; b=NPN1XABnYshL
	HYIJogFTb/2iePgLwlYe2Mnzyc49TfZNKCcekXgMjpRfBYnTf/lG7QzGwERaG/Yy
	RNCJarJh1Q9UvVC/6HcVsLqEgS/+XbNP5kov3CR/aX/OXlnv1sUTa2+ZrAkSOX7e
	eh+amjuwYZ04F7avpPuX+nguBMZMO6rsccr6o3OU/U0lX8sS5Wnx9URJtuZiKmfH
	gBprEneIW+s4c7fG1m1RsgeETR0QnKBJsygwPVfz575stsMLwP4OTtLhT8pEZrUE
	ZcVFLhAUkPCIaP5N0PqJLJlUNj9No4fdX+lGe4I3P4YJkdLcAODm0zBQHAefGglj
	DLCQqwpuDiVTjC1VyUgawxfSR7UnZY1mdJC/Uk+bUggNZxYKUBWdEloJNtyuAD+Z
	KtXJbJ2Wrw1zhwJFfc1/29UsuDFTKSGDB9ag71G3N+tYppx+9m9yL205/2Sw4MKl
	/x6AQ1dOA5uBROxCa1KOGu1lBBeO0ZorIG58r/vJdAizMqgvHmyYkjRUx5RBGFag
	1a7TofYPR/zRWxNM/0F1Rwsb8ScT0yDh+ukUwT7UnU+mHtKF/EnH+rwzF1AYSVcS
	j6HUrMUE3M0Ca9mJD4/nSxSiQtJE3J3o3IY03yHzsTQ9TmFp61uuevcfSbVoHlDg
	jDAcfHfI3Khf3lCZkxPQ0RIbtLXkZ1M=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 20 May 2026 07:11:35 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id BC78560FA8;
	Wed, 20 May 2026 07:11:33 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.1) with ESMTP id 64K4BSM5008476;
	Wed, 20 May 2026 07:11:28 +0300
Date: Wed, 20 May 2026 07:11:28 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Jakub Kicinski <kuba@kernel.org>
cc: Marco Crivellari <marco.crivellari@suse.com>, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>,
        Lai Jiangshan <jiangshanlai@gmail.com>,
        Frederic Weisbecker <frederic@kernel.org>,
        Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
        Michal Hocko <mhocko@suse.com>, Simon Horman <horms@verge.net.au>,
        Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        Paolo Abeni <pabeni@redhat.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org
Subject: Re: [PATCH v2 net-next 2/2] ipvs: Replace use of system_unbound_wq
 with system_dfl_long_wq
In-Reply-To: <20260519182219.0d685a27@kernel.org>
Message-ID: <10173685-596f-1eb0-0903-a3d7ba4dff9b@ssi.bg>
References: <20260515135143.259669-1-marco.crivellari@suse.com> <20260515135143.259669-3-marco.crivellari@suse.com> <20260519182219.0d685a27@kernel.org>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Tue, 19 May 2026, Jakub Kicinski wrote:

> On Fri, 15 May 2026 15:51:37 +0200 Marco Crivellari wrote:
> > Subject: [PATCH v2 net-next 2/2] ipvs: Replace use of system_unbound_wq with system_dfl_long_wq
> 
> FTR leaving this one to netfilter folks

	Yep, we wait net to be merged to net-next because the patch
depends on commit 5522d65d81a7
("ipvs: avoid possible loop in ip_vs_dst_event on resizing")

Regards

--
Julian Anastasov <ja@ssi.bg>

