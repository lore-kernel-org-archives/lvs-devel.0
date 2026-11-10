Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794290005;
	b=qOr9y5Y6E9Yxgd01PkjJPz/2O0Rz2E3USy4PiCmW2S1QVKfUKtjWPft5o3CzJZO9ZnVA
	 /JVwi4a/G8RLs0HwWfW/J0I09FZ0oK7dih224q/j4z2VTgfn3r5Z8L/7rsMN/2nvQUxel
	 VDg5nU/MgJEIE6PK+7+VOIqTRirea6CvZb8/L9XK4D6t2VmQOdMbaz5O/JPJ6V7Nmj8KU
	 TxYAxCJDSYv6by+Q8WQ3vibNPYDRyvTa9PDw0do+Xfo25NMNiEvC4pmp+Chik0p3NwnNa
	 SyA9ubFoQOK9ceJjPJFwkml30l8juwO0Wt4PV7dZ2l/rAAlr4b+vWwUpAOEW0xmFBWA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794290005;
	h=Received:DKIM-Signature:Subject:From:To:Cc:Date:Message-ID:
	 In-Reply-To:References:X-sashiko-severity:Content-Type:
	 Content-Transfer-Encoding:MIME-Version;
	bh=IEvI2+HGRQSQwwXEoUXz61hyv+7ERi7ROzclaXDj8MY=;
	b=kExT4zhN+mKwF25OXi8P9FKwNOeAfd6mkV++5AiIRlcZNtJo+sNJAPh+5zEP5v8TW7p6
	 T2vS63TY5n8CF78HPHHsyj3FCCnmBw3gHKIXF9DpEYDRfbWQ3p2s1B88UWGaFfv7Tby8I
	 QzZebI2HdagCiHDYlc8EyfVLPHBzThH1rcmaV2h2PKLvh2NZjGxkI1jp66l1UJlXMuAzk
	 U0I802fwVLbS+N5w5YW4t8lGnGNLjZhIENo/FnRpkUeoErqdZ859RPDF5U8hV0OBvOdNw
	 csWkFVfbNgQY+nujMYX3bBm1RHcsgEK2M5QrpVMU3E7GDdSGkvFvPNHfqSekCXVGi5Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CoUQzSEQ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B6681606A335;
	Tue, 10 Nov 2026 05:53:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CoUQzSEQ
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 778821F008A7;
	Tue, 10 Nov 2026 05:53:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794290004;
	bh=IEvI2+HGRQSQwwXEoUXz61hyv+7ERi7ROzclaXDj8MY=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=CoUQzSEQTFsiUFEBrAu/IGmQWrGWSXQdQx6L/DIXwh6UsasCpoFiwKCJ1CMZsCwPN
	 iZV5M9wDhTuxQaWHfH9/RM3cElzIof2L5D7wNDrVeKmH4se53TNqXby7JG3WchTGuf
	 p2R2u3kphTsDbhYbkr9uMI03M/qt5jUQP6WeRgYhS23RGWXexWptFzhwPT0VZlIpSi
	 gMhcCjEL7UcgYtpYn9DIU2QRQLq2xHJht5PhVgUix2seAdqnRbzH03M9aVASDDr/BN
	 zuq02UKTINXLwCMu/NIPbTFwFM+kCT4bACV/MmuLHzOolDFtpSHzGyrMfa+AjnnSUj
	 BvsDVcv2VnzmQ==
Subject:
 Re: [PATCH net-next 06/14] sctp: annotate data-races around sctp sysctls
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
Date: Tue, 10 Nov 2026 05:53:22 +0000
Message-ID: <179429000207.994134.10637780638316929795@kernel.org>
In-Reply-To: <20261109025425.328445-7-jiayuan.chen@linux.dev>
References: <20261109025425.328445-7-jiayuan.chen@linux.dev>
X-sashiko-severity: High
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

Thank you for your contribution! Sashiko AI review found 1 potential
issue(s) to consider.

Critical: 0 · High: 1 · Medium: 0 · Low: 0

If you believe none of the issues are legitimate, please reply to each
issue of Medium severity or higher and explain why the AI is wrong.
If any of them are legitimate and you plan to respin, please let patchwork
know by including "pw-bot: cr" as a separate line at the end of your reply
(one such reply per series is enough).

- [High] The fix is incomplete inside the same sysctl handlers it
  changes.

--

sctp: annotate data-races around sctp sysctls

This commit adds READ_ONCE() to readers of many per-netns sctp sysctl
fields. It also converts the plain stores in the rto_min, rto_max,
udp_port, probe_interval, auth_enable and cookie_hmac_alg handlers to
WRITE_ONCE().

> diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
> index 2b94c211427de..8a84ae3272d24 100644
> --- a/net/sctp/sysctl.c
> +++ b/net/sctp/sysctl.c
> @@ -402,11 +402,11 @@ static int proc_sctp_do_hmac_alg(const struct ctl_table *ctl, int write,
>  		if (ret)
>  			return ret;
>  		if (!strcmp(tmp, "sha256")) {
> -			net->sctp.cookie_auth_enable = 1;
> +			WRITE_ONCE(net->sctp.cookie_auth_enable, 1);
>  			return 0;
>  		}
>  		if (!strcmp(tmp, "none")) {
> -			net->sctp.cookie_auth_enable = 0;
> +			WRITE_ONCE(net->sctp.cookie_auth_enable, 0);
>  			return 0;
>  		}
>  		return -EINVAL;
> @@ -441,7 +441,7 @@ static int proc_sctp_do_rto_min(const struct ctl_table *ctl, int write,
>  		if (new_value > max || new_value < min)
>  			return -EINVAL;
>  
> -		net->sctp.rto_min = new_value;
> +		WRITE_ONCE(net->sctp.rto_min, new_value);
>  	}
>  
>  	return ret;
> @@ -469,7 +469,7 @@ static int proc_sctp_do_rto_max(const struct ctl_table *ctl, int write,
>  		if (new_value > max || new_value < min)
>  			return -EINVAL;
>  
> -		net->sctp.rto_max = new_value;
> +		WRITE_ONCE(net->sctp.rto_max, new_value);
>  	}
>  
>  	return ret;

[Severity: High]
Do the handlers this patch edits still contain plain loads of these same
fields?

proc_sctp_do_rto_min() reads rto_max through extra2 to bound the new
value. proc_sctp_do_rto_max() reads rto_min through extra1 in the same
way:

net/sctp/sysctl.c:proc_sctp_do_rto_min() {
	...
	unsigned int min = *(unsigned int *) ctl->extra1;
	unsigned int max = *(unsigned int *) ctl->extra2;
	...
}

sctp_sysctl_net_register() points these at the live per-netns fields. The
static sctp_net_table does the same for init_net:

	table[SCTP_RTO_MIN_IDX].extra2 = &net->sctp.rto_max;
	table[SCTP_RTO_MAX_IDX].extra1 = &net->sctp.rto_min;

So when writes to /proc/sys/net/sctp/rto_min and rto_max run at the same
time, proc_sctp_do_rto_min() does a plain read of rto_max while
proc_sctp_do_rto_max() does WRITE_ONCE(net->sctp.rto_max, ...). The same
thing happens in the other direction for rto_min. Nothing serializes
these two handlers against each other.

The read branch of proc_sctp_do_hmac_alg() also still loads
cookie_auth_enable without READ_ONCE():

	if (net->sctp.cookie_auth_enable)
		tbl.data = (char *)"sha256";
	else
		tbl.data = (char *)"none";

This can race with the WRITE_ONCE() stores above when cookie_hmac_alg is
read and written at the same time.

The commit message lists rto_min, rto_max and the cookie_hmac_alg handler
among the races being closed. The readers of these fields in
sctp_init_sock() now use READ_ONCE().

Should these three loads in the handlers use READ_ONCE() too? Otherwise
KCSAN can still report a marked write racing with a plain read on these
fields.

-- 
Sashiko AI review · https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20261109025425.328445-1-jiayuan.chen%40linux.dev
