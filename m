Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 643E63655E9;
	Mon, 21 Sep 2026 05:50:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789969805; cv=none; b=Q5KG8U/3ZRXk3tkKnA8XkIbKdnga9gOMZmoDTLwYR1t2dd8SN6YCyVbjmxiLN1TIxqlizF2c7JOR0lyY/N9sj89d4vLSdAGfuDfhTKBV+giDY0gWLbj2lbQFtuv1ywePoV2Ow4F5zvMi6LB7XlXyyVZg6fOgsaUjOTaO1WzPOWc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789969805; c=relaxed/simple;
	bh=M8vP0e6jFrNQCY7SNUtNMcaQSrU6r/iDwwM514yzC1E=;
	h=Subject:From:To:Cc:Date:Message-ID:In-Reply-To:References:
	 Content-Type:MIME-Version; b=r7bzqzAhWqvTTT1huF/SnIAtUuYyOzytZeTCtQh7H2TH6E9pLGxqCQCCtztuh357+bbsSMqAIS+Y3SxsvEfRUOyWrrCZuSdJOpJPmcvjVClBDlFlw3NpLYeAofu8OiDLeLx+ukLkir7RGNi50UTDjqi0WqQlBR9JqVFz9XIpuwc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=GBD4Sedw; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="GBD4Sedw"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6CD981F00893;
	Mon, 21 Sep 2026 05:50:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789969804;
	bh=UUtxW/zPSah/AqlIGJsrV1W7Qm344eXeJyEKPwetRrg=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=GBD4Sedwu9hhKQjAq+DKR1/OIOBcfRrSVns8KDSJ5nJ/zechHT3UmUUJnKtVEvPIp
	 g5/evDWWvLjp3hQGK0gCrpuD4Pm9Xw3UthEvfDkkUI8V4kxnAySQfs27HoN4NprXYW
	 DqiViRv8XCHo8fMj2SfR5Cct7cIQqpOJHh6tNgsPjM6pwolNBxh4yoIhkeNgTpY+MM
	 33xjkmPwM7qpikePEBLVVKmRvLK3Y6bfbp+SqQw9y1+t/xPcrWrLNWFIMNXE1l9OMR
	 OBQzOrwTSVxniwUip9/pWYCavjkEC48f66lW1gYdkmruxzB7IFcRW9y/lvRrVJ9Lem
	 W2trdBFICERxg==
Subject: Re: [PATCH v4 nf-next 3/3] selftests: netfilter: ipvs: add
 per-service secure_tcp test
From: netdev-bot+sashiko@kernel.org
To: adrianox@gmail.com
Cc: horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, fw@strlen.de,
 netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kuba@kernel.org
Date: Mon, 21 Sep 2026 05:50:02 +0000
Message-ID: <178996980298.2160803.13730440636881546701@kernel.org>
In-Reply-To: <20260920054708.988867-4-adrianox@gmail.com>
References: <20260920054708.988867-4-adrianox@gmail.com>
X-sashiko-severity: Medium
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

Thank you for your contribution! Sashiko AI review found 3 potential
issue(s) to consider.

Critical: 0 · High: 0 · Medium: 2 · Low: 1

If you believe none of the issues are legitimate, please reply to each
issue of Medium severity or higher and explain why the AI is wrong.
If any of them are legitimate and you plan to respin, please let patchwork
know by including "pw-bot: cr" as a separate line at the end of your reply
(one such reply per series is enough).

- [Medium] tools/testing/selftests/net/netfilter/ipvs_secure_tcp.sh has
  no kernel-side prerequisite check and no $ksft_skip path.
- [Medium] The secure-service assertion cannot distinguish 'per-service
  secure_tcp worked' from 'the ACK probe never arrived'.
- [Low] The commit message states "A bare SYN+ACK suffices to test the
  state machine: the normal service reaches ESTABLISHED, but the secure…

--

selftests: netfilter: ipvs: add per-service secure_tcp test

This adds a new netfilter selftest that creates two IPVS TCP services on
the same VIP, one with IP_VS_SVC_F_SECURE_TCP, and checks the resulting
connection states with ipvsadm -Lnc.  Two helpers are added: a libmnl
program to set/query the per-service flag and a raw-socket probe that
sends a bare SYN followed by a bare ACK.

>     Two services share a VIP, one carrying IP_VS_SVC_F_SECURE_TCP.
>     A bare SYN+ACK suffices to test the state machine: the normal
>     service reaches ESTABLISHED, but the secure one stays in SYN_RECV.

[Severity: Low]
Does the changelog wording match what gen_tcp_probe.c actually sends?

main() transmits two separate bare segments, a SYN and then a pure ACK:

	if (send_seg(fd, &sip, sport, &dip, dport, seq, 1, 0) < 0) {
	...
	usleep(100000);
	if (send_seg(fd, &sip, sport, &dip, dport, seq + 1, 0, 1) < 0) {

A single segment with both bits set would not show anything, since
tcp_state_idx() in net/netfilter/ipvs/ip_vs_proto_tcp.c tests rst, then
syn, then fin, then ack:

	if (th->rst)
		return 3;
	if (th->syn)
		return 0;
	if (th->fin)
		return 1;
	if (th->ack)
		return 2;

so SYN|ACK is classified as syn, and the INPUT syn row of both tcp_states
and tcp_states_dos maps sNO -> sSR, i.e. no difference between the secure
and the plain service.

Would "a bare SYN followed by a bare ACK" (the wording already used in the
gen_tcp_probe.c header comment) be more accurate here?

> diff --git a/tools/testing/selftests/net/netfilter/ipvs_secure_tcp.sh b/tools/testing/selftests/net/netfilter/ipvs_secure_tcp.sh
> new file mode 100755
> index 000000000000..4d250bcbb2cf
> --- /dev/null
> +++ b/tools/testing/selftests/net/netfilter/ipvs_secure_tcp.sh
> @@ -0,0 +1,153 @@

[ ... ]

> +source lib.sh
> +
> +ret=0

[ ... ]

> +checktool "ipvsadm -v" "run test without ipvsadm"
> +
> +setup() {
> +	setup_ns ns0 ns1 ns2

[ ... ]

> +	# load ipvs, then the rr scheduler (separate calls: modprobe treats
> +	# the second name as a module parameter, not a second module)
> +	ip netns exec "${ns1}" modprobe ip_vs
> +	ip netns exec "${ns1}" modprobe ip_vs_rr

[Severity: Medium]
What happens on a kernel built without CONFIG_IP_VS or without the rr
scheduler?

The only pre-flight gate is checktool "ipvsadm -v", which validates the
userspace binary only.  Both modprobe calls in setup() have their exit
status discarded (no set -e, no ||), so a missing ip_vs goes unnoticed:
ipvs_secure_tcp_mln add fails, the connection table stays empty, both
assert_state() calls set ret=1, and the script exits 1.

$ksft_skip is never used anywhere in this script even though lib.sh is
sourced.  The pre-existing ipvs.sh in the same directory guards this:

	if [ ! -d $sysipvsnet ]; then
		if ! modprobe -q ip_vs; then
			echo "skip: could not run test without ipvs module"
			exit $ksft_skip
		fi
	fi

Could the same skip be added here, so unsupported configurations are
reported as skipped rather than failed?

Note that the helper's get readback cannot be used for feature detection
either: ip_vs_genl_parse_service() stores the requested bits without
rejecting unknown ones,

		usvc->flags = (usvc->flags & ~flags.mask) |
			      (flags.flags & flags.mask);

so a kernel lacking per-service secure_tcp still echoes secure_tcp=1.

> +
> +	sleep 1
> +}

[ ... ]

> +assert_state() {
> +	local port=$1 want=$2
> +	local got
> +	got="$(conn_state "$port")"
> +	echo "  vip ${vip}:${port}: state=${got:-?}"
> +	if [ "${got:-}" != "$want" ]; then
> +		echo -e "${RED}FAIL${NC}: vip ${vip}:${port} expected state" \
> +			"${want}, got ${got:-none}"
> +		ret=1
> +	fi
> +}

[ ... ]

> +	# Push SYN then ACK to each service from the client
> +	ip netns exec "${ns0}" "$probe" "${cip}" 40000 "${vip}" "${port_secure}"
> +	ip netns exec "${ns0}" "$probe" "${cip}" 40001 "${vip}" "${port_plain}"
> +	sleep 1

[ ... ]

> +	assert_state "${port_plain}" ESTABLISHED
> +	assert_state "${port_secure}" SYN_RECV
> +}

[Severity: Medium]
Can assert_state "${port_secure}" SYN_RECV pass without the ACK ever
being processed?

SYN_RECV is exactly the state the first SYN alone produces.  In
net/netfilter/ipvs/ip_vs_proto_tcp.c the INPUT syn row is sNO -> sSR in
both tables, and only the following input ACK differs:

/*syn*/ {{sSR, sES, sES, sSR, sSR, sSR, sSR, sSR, sSR, sSR, sSR }}, /* tcp_states */
/*syn*/ {{sSR, sES, sES, sSR, sSR, sSR, sSR, sSR, sSR, sSR, sSA }}, /* tcp_states_dos */

The probe exit status is discarded here:

	ip netns exec "${ns0}" "$probe" "${cip}" 40000 "${vip}" "${port_secure}"

There is no || and no set -e, while gen_tcp_probe.c main() returns 1 when
the second send_seg() fails:

	usleep(100000);
	if (send_seg(fd, &sip, sport, &dip, dport, seq + 1, 0, 1) < 0) {
		close(fd);
		return 1;
	}

So a probe run that dies after the SYN (sendto failure, or the helper
being killed during the usleep) leaves the connection in SYN_RECV and the
secure-side assertion still succeeds.  The plain-service assertion is only
a partial control, since it is a separate invocation with a different
source port.

Would checking the probe exit status, or asserting something that only the
processed ACK can produce, make this assertion distinguish the two cases?

> +
> +trap cleanup EXIT
> +
> +setup
> +test_secure
> +
> +if [ "$ret" -ne 0 ]; then
> +	echo -e "$(basename $0): ${RED}FAIL${NC}"
> +	exit 1
> +fi
> +echo -e "$(basename $0): ${GREEN}PASS${NC}"
> +exit 0

[ ... ]

-- 
Sashiko AI review · https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20260920054708.988867-1-adrianox%40gmail.com
