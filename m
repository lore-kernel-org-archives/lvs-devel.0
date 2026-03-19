Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 326563ED125;
	Thu, 19 Mar 2026 16:36:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1773938205; cv=none; b=bPI2DONl8TAPEuPkhcRlKLg3sStsU4IOy/mkjSa7izgR8tDvemzCq6Mso61OtuiBQ6sutTWNePjd4iVva5kQvPXcutoOcvcc6HPWsExM0RRSnTwKbiuS39OMGKAlwk5LpKefr3jztgUw54d+LqE+DkIAzzQu2xo00TbjqcIY/ho=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1773938205; c=relaxed/simple;
	bh=7S+sw9mF8TJewYvW7cVs+bKNPogMLQz3GWRSiugdtyc=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=LULFs6a21D4/jdA3/gVsQuauUqw9kJE3mfF2/yuJAakC3OqcEwZAOznePvUMjAmfRlLGAtZcp09SfOkvmdr6GPdJQF+42FUjE0Fjl5gZ1Qc60QsSSkLi22PgYSc6ktFrIZFpEBUWOWVOurAW1NEwUWhBJWBpPT9S09wUHOsGikc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=J1NYDEFe; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="J1NYDEFe"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 737E0C19424;
	Thu, 19 Mar 2026 16:36:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1773938204;
	bh=7S+sw9mF8TJewYvW7cVs+bKNPogMLQz3GWRSiugdtyc=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=J1NYDEFe/raeSCrUL/BX9oSVtThyhVPAAkuHylFwhFQgb7ty/7pJr3XD+9MPUKVs1
	 K7GQIy5F6HfEqfN60CYB3jeLBiWHMGsZMUnZsYoM90hXfT4PdR7Z+lUROzJSOkOuiT
	 6oUda3cT2a2uFX8khWtSyFtxz/HBF7Nk6BrBXUcwg8/c+ghkJzxORHAHr8qoe2tF+r
	 vgsuLDx6Nbmotg/IGQQ7gmgx6PGugrz2qWURC4gNdcaEa/KHCIuh+b226dEWHpqpEq
	 oGJsAGjV62WaA5IFPIBwMqDfbzNcQ5RUgBApitZ3mHNve+qTCC7yziWL0RlRpB9fOk
	 VmubECZikG4cg==
Date: Thu, 19 Mar 2026 16:36:37 +0000
From: Simon Horman <horms@kernel.org>
To: Ismael Luceno <iluceno@suse.de>
Cc: linux-kernel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
	"David S . Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
	Marco Crivellari <marco.crivellari@suse.com>,
	Federico Pinca <federico.pinca@suse.com>,
	Andreas Taschner <andreas.taschner@suse.com>,
	Brad Bendily <brad.bendily@suse.com>,
	Brendon Caligari <brendon.caligari@suse.com>,
	Clemens Famulla-Conrad <cfamullaconrad@suse.com>,
	Firo Yang <firo.yang@suse.com>,
	Gabriel Krisman Bertazi <gabriel.bertazi@suse.com>,
	Hans van den Heuvel <hvdheuvel@suse.com>,
	Jean Delvare <jdelvare@suse.com>, Michal Hocko <mhocko@suse.com>,
	Michal =?utf-8?Q?Koutn=C3=BD?= <mkoutny@suse.com>,
	Petr Mladek <pmladek@suse.com>, Petr Tesarik <ptesarik@suse.com>,
	Richard Thompson <richard.thompson@suse.com>,
	William Preston <wpreston@suse.com>, Yu Xu <yu.xu@suse.com>,
	netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org
Subject: Re: [PATCH] ipvs: Move defense_work to system_dfl_long_wq
Message-ID: <20260319163637.GK1753385@horms.kernel.org>
References: <20260317140100.24993-2-iluceno@suse.de>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260317140100.24993-2-iluceno@suse.de>

On Tue, Mar 17, 2026 at 03:00:59PM +0100, Ismael Luceno wrote:
> Under synflood conditions binding defense_work to system_long_wq may
> pin it to a saturated CPU.
> 
> We've observed improved throughtput on a DPDK/VPP application with
> this change. We attribute this to the reduced context switching.
> 
> The defense_work handler has no per-CPU data dependencies and no cache
> locality requirements that would justify this.
> 
> Signed-off-by: Ismael Luceno <iluceno@suse.de>
> ---
> Depends-on: wq/for-7.1 c116737e972e ("workqueue: Add system_dfl_long_wq for long unbound works")

Hi Ismael,

This patch seems suitable to be targeted at the nf-next tree.
That should be annotated like this:

Subject [PATCH nf-next] ipvs: ...

And the patch must compile when applied to it's target tree.
So you'll need to repost this patch once the dependency above
has reached that tree.
