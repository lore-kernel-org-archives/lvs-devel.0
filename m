Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794290008;
	b=V/ywvs0bnnB49hKlvYTIHXkgboXviHdXCoN8bPqwboZGuwdKqTxWQm7J+FDkWbtPc8K7
	 o42xENOChONHyDMncHrIbjYUyAINLU1EIsj1PyRnqwGT0+Qtorys/Ezwh8vr28floUss6
	 XkuzZ9VA3OR3r8srVmrboPebsNT2nUmwFprsDf84Te65E3/SwGSz7LUpRqp1xBaqHPXye
	 p9xBMSe/oBgtYFmefhQPqdeD2E1sclbjKSuaZJu8R20Ki+34mEru4W2tobcV+YxM8gztf
	 rRxIV1F9/4iCu5WAUMahrXS6mtzvYGjGOn0t9kJVL7ZNazzLFiOOrJrGIYYXlsBEbxQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794290008;
	h=Received:DKIM-Signature:Subject:From:To:Cc:Date:Message-ID:
	 In-Reply-To:References:X-sashiko-severity:Content-Type:
	 Content-Transfer-Encoding:MIME-Version;
	bh=GHNBMVG3Wf/WNwxgQrYTHsnSyslBuFe0XVBpTIsm01s=;
	b=qp9LuGEPXGvsW7zMDldOGxe62ulViijhs6i4MViMoZAy1JA4+SkMfVL3nPOS2a4O+CRo
	 OQAZFEVBN5CfG9hB+emSQnrj/zBe0CeB6o03MXUmudfrgquX5O0m1If04fI9UUN1Diij3
	 Hb3wywQFJGneAUkT52vA4KGrOl7wRxEIMhx7yjg84F/ccfTWWHph9xjennc5ctChj4Awe
	 LYY2rHMi1DhG9rHiGsNRa5rpNPEVjJEKTMnKR786t4Bjq9nrtNx7gyXb0VO2fk/NYgUf3
	 yOqCQYFlW79GNG8502id2ApTajn0tnhYfKZyETL18MEAoKcIeP+ZkuTKIq21br+p5tA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=h8Mg+NTa;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D2A1A606A31C;
	Tue, 10 Nov 2026 05:53:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=h8Mg+NTa
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EDE721F0089F;
	Tue, 10 Nov 2026 05:53:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794290007;
	bh=GHNBMVG3Wf/WNwxgQrYTHsnSyslBuFe0XVBpTIsm01s=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=h8Mg+NTa37D5sdsh5liH4Yogs8ckRV+RW7upQt2VHZvCYyYv+9qAJcvXBkoY9miQk
	 4VRpacdVnuWymYG5w3HQR3fLyZWS1L1UqOGnAmvmP7DHKMkNG3goXHVJ97V3r5qNxJ
	 jrHqgSvgTmBsBJvZFFQnjyupEH4XClD6UcVhLNkb9ss0OY49eFgLMotJdQqXknluT9
	 eFrOF94okwOvhE6RCDe38HY3fSpsdUqwRdKEMOtQfl0tQJCx1cH7hFC/Rj0UnFmIHE
	 6UQSX4Qxv4zoEVIzWMhMqaj7+wk5IEzRFnNdWAKpvHCpURB2k2iPCkFttVabkBwxIN
	 706BHK23tOwsw==
Subject: Re: [PATCH net-next 10/14] netfilter: bridge: annotate data-races
 around br_netfilter and nf_log sysctls
From: netdev-bot+sashiko@kernel.org
To: jiayuan.chen@linux.dev
Cc: netdev@vger.kernel.org, dsahern@kernel.org, idosch@nvidia.com,
 davem@davemloft.net, edumazet@kernel.org, kuba@kernel.org, pabeni@redhat.com,
 horms@kernel.org, pablo@netfilter.org, fw@strlen.de, phil@nwl.cc,
 razor@blackwall.org, paul@paul-moore.com, matttbe@kernel.org,
 martineau@kernel.org, geliang@kernel.org, ja@ssi.bg, achender@kernel.org,
 marcelo.leitner@gmail.com, lucien.xin@gmail.com, alibuda@linux.alibaba.com,
 dust.li@linux.alibaba.com, sidraya@linux.ibm.com, mjambigi@linux.ibm.com,
 tonylu@linux.alibaba.com, guwen@linux.alibaba.com,
 linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
 coreteam@netfilter.org, bridge@lists.linux.dev,
 linux-security-module@vger.kernel.org, mptcp@lists.linux.dev,
 lvs-devel@vger.kernel.org, linux-rdma@vger.kernel.org,
 rds-devel@oss.oracle.com, linux-sctp@vger.kernel.org,
 linux-s390@vger.kernel.org
Date: Tue, 10 Nov 2026 05:53:24 +0000
Message-ID: <179429000449.994134.17609039165328178770@kernel.org>
In-Reply-To: <20261109025425.328445-11-jiayuan.chen@linux.dev>
References: <20261109025425.328445-11-jiayuan.chen@linux.dev>
X-sashiko-severity: Low
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0

Thank you for your contribution! Sashiko AI review found more severe
issue(s) in other patches of this series. This mail is only an FYI, in case
you want to address the nit picks below when you respin.

Low priority / nit picks for your consideration:

- [Low] brnf_sysctl_call_tables() in net/bridge/br_netfilter_hooks.c is
  only half annotated.

--

netfilter: bridge: annotate data-races around br_netfilter and nf_log sysctls

This patch adds READ_ONCE() annotations in the packet path for the
bridge-nf-* sysctls and for sysctl_nf_log_all_netns. It also adds a
WRITE_ONCE() to the normalization store in brnf_sysctl_call_tables().
The goal is to silence KCSAN data-race reports that show up when these
sysctls change while packets are being bridged.

> diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
> index e15355ff215a7..8a47fe4e8eb61 100644
> --- a/net/bridge/br_netfilter_hooks.c
> +++ b/net/bridge/br_netfilter_hooks.c

[ ... ]

> @@ -1178,7 +1178,7 @@ int brnf_sysctl_call_tables(const struct ctl_table *ctl, int write,
>  	ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
>  
>  	if (write && *(int *)(ctl->data))
                     ^^^^^^^^^^^^^^^^^^^
> -		*(int *)(ctl->data) = 1;
> +		WRITE_ONCE(*(int *)(ctl->data), 1);

[Severity: Low]
This isn't a bug, but should the load in the condition also be annotated?

The store is now WRITE_ONCE(), but the check just before it is still a
plain read of *(int *)(ctl->data).

proc_sys_call_handler() in fs/proc/proc_sysctl.c calls
table->proc_handler() without taking any lock. Two concurrent writes to
the same knob (bridge-nf-call-iptables, for example) can therefore run
brnf_sysctl_call_tables() in parallel. In that case one handler's plain
read can race with the other writer's marked store in do_proc_int_conv(),
or with its WRITE_ONCE(..., 1).

That is the same plain-read-vs-marked-write pattern as the splat in the
commit message, so KCSAN would report it as a race between
brnf_sysctl_call_tables and do_proc_int_conv.

There is no functional effect here. The final value is always 0 or 1,
and any non-zero value is treated as true. This only affects how
complete the annotation is.

Would it make sense to use READ_ONCE() for the check? Another option is
to parse into a local value and publish it with a single WRITE_ONCE().

>  	return ret;
>  }

-- 
Sashiko AI review · https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20261109025425.328445-1-jiayuan.chen%40linux.dev
