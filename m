Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D092C3D5C38;
	Sun, 27 Sep 2026 10:22:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790504522; cv=none; b=nNxmehQGFsoBVJGf+Kbsl44Ombo1rfFJEz3XTLPtGSIgtA1mGTacsxiwxGY69+B7gja2hc8QymDDtXHBD6RQmk5BGd1RFbo0XVeeb4mX6kwtcuOYaf1zEH8GWo/n4XLfge3QJWusfyrKNlfRLmzsWjyGVuGsTt+lre1EGKYG5Yc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790504522; c=relaxed/simple;
	bh=UZWD9XmTQ+/2qz68wcHZYN9MPYjZmu61YhRLeaxEPpU=;
	h=Subject:From:To:Cc:Date:Message-ID:In-Reply-To:References:
	 Content-Type:MIME-Version; b=nYPjMfbWc2bOxKNuMNIClg6b3juq8TOounhJfaBqkrCiv01isebrtQpiOyxdlKPqWzY8XoiAVSaQDXhgfx9TlPLpwnbNq1rxy+8xpK+IGsxy1jNvFEwU8treVARvTkQFNVNnSO38N8Dfge/k2qpKp5UswD28uGsmgpKmy4HcTjA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=a1VJmnti; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="a1VJmnti"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2E94C1F000FF;
	Sun, 27 Sep 2026 10:21:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790504520;
	bh=lzzFY78ztyNear9nk6/+Zra8mBmRNWrZdDcHL5sj8Ys=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=a1VJmntivuBXplxzgrRrtM7EsbhTcY860l6SKSd+Itk7RmRtMoLbI17wqup51EdqT
	 Ma8sMl0KaEC8ihQmQ214YIDDbH4oD43Dwbj6kQOZcKF8jw7nubcqN5NRo9pLmw0Iiz
	 ZABod/4XuwaWUG1kCBJnuy63Fiji1basVYEeV/ydj3bvOAVHhq+KZVsjxBHqIt7N/4
	 CRCR+n7jtv4vbcrkXgbeFfVqMu/pfMbFNWlk2pQshJ711TKykITGH08C54Et+66Eef
	 pQ4RXUsF9znSmDX22/XYJFrhgQUVwbsw/T7cJY5SUvpGBFuoO3Zup2jk5Cxb6bkVbJ
	 lhJMWzlF12ylw==
Subject: Re: [PATCH nf v4 3/3] ipvs: reject FTP control ports as data ports
From: netdev-bot+sashiko@kernel.org
To: zihanx@nebusec.ai
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
 lvs-devel@vger.kernel.org, coreteam@netfilter.org,
 linux-kernel@vger.kernel.org, horms@verge.net.au, ja@ssi.bg,
 pablo@netfilter.org, fw@strlen.de, phil@nwl.cc, davem@davemloft.net,
 edumazet@google.com, kuba@kernel.org, pabeni@redhat.com,
 stable@vger.kernel.org, vega@nebusec.ai, root@tr0jan.top
Date: Sun, 27 Sep 2026 10:21:58 +0000
Message-ID: <179050451874.2160803.17236009960023426401@kernel.org>
In-Reply-To:
 <b5c5a01607eabe55a6a5a27a9ed40a0ac8ec65fe.1790146910.git.zihanx@nebusec.ai>
References:
 <b5c5a01607eabe55a6a5a27a9ed40a0ac8ec65fe.1790146910.git.zihanx@nebusec.ai>
X-sashiko-severity: Low
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

Thank you for your contribution! Sashiko AI review found more severe
issue(s) in other patches of this series. This mail is only an FYI, in case
you want to address the nit picks below when you respin.

Low priority / nit picks for your consideration:

- [Low] The commit message is imprecise, and for a Cc: stable fix it
  leaves out the impact.

--

ipvs: reject FTP control ports as data ports

With this patch, ip_vs_ftp_out() will not create a passive-mode data
connection if the port advertised by the server is zero or is one of the
configured FTP control ports. It also changes ip_vs_ftp_in() so that
active-mode handling is refused when the client port is zero or when
vport - 1 is a configured control port.

> ip_vs_ftp_out() creates a wildcard data connection from the
> server-advertised passive port. If that port is one of the configured FTP
> control ports, ip_vs_conn_new() binds the FTP helper to the new connection
> again. A subsequent wildcard lookup can then extend a controlled-connection
> chain.
>
> Reject zero and configured control ports before creating passive
> connections. For active mode, reject a zero client port and a data port
> derived from a configured control port.

[Severity: Low]
This is tagged for stable. Could the commit message say what goes wrong
once the controlled-connection chain gets extended?

The earlier patch in this series, "ipvs: avoid stack overflow from
recursive connection expiration", points to the actual consequence. That
consequence is chains of controlled connections pinned through n_control,
and stack exhaustion from recursive ip_vs_conn_expire(). This message does
not mention that, or any dependency on that patch.

The message also doesn't say where the trigger comes from. In passive mode
the port comes from the real server's 227/229 reply. The active case needs
an admin configuration where vport - 1 is also a configured FTP port.

Is the active-mode sentence accurate? Every active-mode data port is
derived from a configured control port. The data port is vport - 1, and
vport is always a configured FTP port, because tcp_app_conn_bind() only
binds the helper when:

    if (inc->port == cp->vport) {

Read literally, the sentence says all active transfers are rejected. The
code in ip_vs_ftp_in() only rejects them when the derived port is itself
a configured control port:

    if (!port || is_control_port(ntohs(cp->vport) - 1))
        return 0;

Could this be reworded along the lines of "reject a derived data port
(vport - 1) that is itself a configured control port"?

-- 
Sashiko AI review · https://netdev-ai.bots.linux.dev/sashiko/#/patchset/cover.1790146910.git.zihanx%40nebusec.ai
