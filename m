Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794590219;
	b=B7x6Xk4YV4Wimy/WY5AhTZoPg2eu5drYZnyrGtkBAr4nS05pyudV2JFRkAur3LAHB9/w
	 rVkaUpRpJB/qtSdzgy+nERpK2eL2gTCsRt+w+7ZMqctSKhjEqGVVb+BAifXGhbp143l9E
	 1sy1DZpT6pdhY5QaNhZnZN353AqqiEC4tw28TpTz2pElumX2B/x1MtpApYA1W9zie04uT
	 x1ZY5Z5EKCh7ONe7EkGx1ckNgPUOUw0S69/11G1JlYMb3zRlcHqRByhNpfLB/GDnHCauy
	 NotNcWUoqxOQ0lrecHpH6Sb91SQkDdL3MzgvowZkiJsmzOK1IZrNQvpFYGySa6tR2JQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794590219;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=uh2pTSLECQz4oYCHxJGXmr/VWfmQ+mjF1tzIfd9bMkQ=;
	b=nHJVROBcgX/+KBPs1zfO8koGH9fujqkSSuXJDgU5GnVrDigJ3V58FLLBZrwJhzuO9eql
	 KcFzVMBKyNPfwX+HRjTc9Q1jcyuX0OiR4j99eoSO++5ACnEjmbLYc32vzoUeyw3lykZ5B
	 R1PA+rhhFNX2/yFg0wN4cdoAeyQ6IBgZ24Iwz2Y11nsRKRfKjzGLQlmoNCD71KAwGSy5y
	 P/mz/dez4RHWq3OkdJyvtp7WIgbrgKm1B0zUQ/NsCHGUES1XE6wOWF/AMfeoUOxkHFZXG
	 Klgm0aGABYkz0LPIqLsTSpEGprusE3EbItdDAMJsqYF6vPHijR3D88YdlstJ1yl3KTg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=R7qT+Vwy;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 063A5606BD29;
	Fri, 13 Nov 2026 17:16:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=R7qT+Vwy
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 94EE61F000C6;
	Fri, 13 Nov 2026 17:16:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794590218;
	bh=uh2pTSLECQz4oYCHxJGXmr/VWfmQ+mjF1tzIfd9bMkQ=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=R7qT+VwyjC4rTsYzxSkOqSSyySehtXjxvTzit4084gMI+yIpm+s1wVBFZ1WW21TG6
	 0DvqLo7M9dN4MzAwCW2vMzkVx+o0nJhr9vSTlu7OQio4sPlCNXQRPS/ipFa1FCquZG
	 8s3vqs7IZ/xDPgpdcvacI+hLaJr3CbPq6V18kO9EMnW5z7tp821F0HnM/91rMuFO0f
	 y8R5A/e77pE1/+seGC1hji+PPvsfVYwmF8ZLGf8tYllUqwonmh2Ojs2v5LJT2qyaIO
	 +kWEwVlhGUc3KHQ7MDKzw/j5GcymwU7v1sa9PzfLkFY0lAuHy5JvGzkLKIpmMltL/S
	 YQIojLL/PsqlA==
Date: Fri, 13 Nov 2026 17:16:50 +0000
From: Simon Horman <horms@kernel.org>
To: netdev-bot+sashiko@kernel.org
Cc: jiayuan.chen@linux.dev, netdev@vger.kernel.org, dsahern@kernel.org,
	idosch@nvidia.com, davem@davemloft.net, edumazet@kernel.org,
	kuba@kernel.org, pabeni@redhat.com, pablo@netfilter.org,
	fw@strlen.de, phil@nwl.cc, razor@blackwall.org, paul@paul-moore.com,
	matttbe@kernel.org, martineau@kernel.org, geliang@kernel.org,
	ja@ssi.bg, achender@kernel.org, marcelo.leitner@gmail.com,
	lucien.xin@gmail.com, alibuda@linux.alibaba.com,
	dust.li@linux.alibaba.com, sidraya@linux.ibm.com,
	mjambigi@linux.ibm.com, tonylu@linux.alibaba.com,
	guwen@linux.alibaba.com, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	bridge@lists.linux.dev, linux-security-module@vger.kernel.org,
	mptcp@lists.linux.dev, lvs-devel@vger.kernel.org,
	linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
	linux-sctp@vger.kernel.org, linux-s390@vger.kernel.org
Subject: Re: [PATCH net-next 10/14] netfilter: bridge: annotate data-races
 around br_netfilter and nf_log sysctls
Message-ID: <20261113171650.GT18859@horms.kernel.org>
References: <20261109025425.328445-11-jiayuan.chen@linux.dev>
 <179429000449.994134.17609039165328178770@kernel.org>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <179429000449.994134.17609039165328178770@kernel.org>

On Tue, Nov 10, 2026 at 05:53:24AM +0000, netdev-bot+sashiko@kernel.org wrote:
> Thank you for your contribution! Sashiko AI review found more severe
> issue(s) in other patches of this series. This mail is only an FYI, in case
> you want to address the nit picks below when you respin.
> 
> Low priority / nit picks for your consideration:
> 
> - [Low] brnf_sysctl_call_tables() in net/bridge/br_netfilter_hooks.c is
>   only half annotated.
> 
> --
> 
> netfilter: bridge: annotate data-races around br_netfilter and nf_log sysctls
> 
> This patch adds READ_ONCE() annotations in the packet path for the
> bridge-nf-* sysctls and for sysctl_nf_log_all_netns. It also adds a
> WRITE_ONCE() to the normalization store in brnf_sysctl_call_tables().
> The goal is to silence KCSAN data-race reports that show up when these
> sysctls change while packets are being bridged.
> 
> > diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
> > index e15355ff215a7..8a47fe4e8eb61 100644
> > --- a/net/bridge/br_netfilter_hooks.c
> > +++ b/net/bridge/br_netfilter_hooks.c
> 
> [ ... ]
> 
> > @@ -1178,7 +1178,7 @@ int brnf_sysctl_call_tables(const struct ctl_table *ctl, int write,
> >  	ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
> >  
> >  	if (write && *(int *)(ctl->data))
>                      ^^^^^^^^^^^^^^^^^^^
> > -		*(int *)(ctl->data) = 1;
> > +		WRITE_ONCE(*(int *)(ctl->data), 1);
> 
> [Severity: Low]
> This isn't a bug, but should the load in the condition also be annotated?
> 
> The store is now WRITE_ONCE(), but the check just before it is still a
> plain read of *(int *)(ctl->data).
> 
> proc_sys_call_handler() in fs/proc/proc_sysctl.c calls
> table->proc_handler() without taking any lock. Two concurrent writes to
> the same knob (bridge-nf-call-iptables, for example) can therefore run
> brnf_sysctl_call_tables() in parallel. In that case one handler's plain
> read can race with the other writer's marked store in do_proc_int_conv(),
> or with its WRITE_ONCE(..., 1).
> 
> That is the same plain-read-vs-marked-write pattern as the splat in the
> commit message, so KCSAN would report it as a race between
> brnf_sysctl_call_tables and do_proc_int_conv.
> 
> There is no functional effect here. The final value is always 0 or 1,
> and any non-zero value is treated as true. This only affects how
> complete the annotation is.
> 
> Would it make sense to use READ_ONCE() for the check? Another option is
> to parse into a local value and publish it with a single WRITE_ONCE().

This one looks like it ought to be addressed for completeness.
