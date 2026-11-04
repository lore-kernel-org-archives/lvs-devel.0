Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793803361;
	b=oe3Mn+9HrAWa1qrpbAbuTPzSMAPOgaIFS4GZIb1SoUTlZ3uZpJn1GxXhaMQr/+piCZ3H
	 uVylV8zQvYkbWw/Ab4tgMA/7poS12+ccBYJIuLeimw3ShKM5MeN97AbZMZv4sKrB/g+EJ
	 +6y4Ub+fHGfU9XPxMqiTOZtxJ5TqtEe1ohYr9IvsyGceb9q+3IT2FJE1xqGRbySjMU/kK
	 pHM93GBcHqAYPuqFmMLAdoDbvC/ilWipvwIEKNOQ3rTk5gqI3ZZ3O/shS8zo48lT7HJjm
	 CEbsa8tX9iuB0/onnl9EOw0Mc/Fh+1j7maB4Er93GT1ySG4tU8XUrr3EqsBvkNWI0wQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793803361;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:Date:
	 From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:
	 Content-Type;
	bh=794K7AZbxC/RoZCY0ZDGowg+t1WslBWQGqIQBsO3AKs=;
	b=q0JAkp97NMPXBBME6va8AALOjh5sL7S82a96ZxCeLJfEtu4iAmrfj8/kju2dUaWSikgQ
	 hiT2ryEwmkBP5CPwOTic5/WbaHhGS6JTwxbRPUnqYiP9srcYfUNvu3c/vQDZ6XftvBX7q
	 5KEwQ+5v075qU0loJWjqoqRZJbOA3o5e6jfIn5QGQAVbc79S5lbvslFvvaPRDGr1WNVr2
	 wiBo+QKL+w87bzAKn3R3ojaem30wdYEeOUTonLf5skj4HWmhKGOPbliWhHRcgmapN1iPq
	 O9ZwGrrrGZYGGmWdRWR+B+f9RZR75ybvVJmhBeFyyihracEeWTDZInbQy79vyaXh8eQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=eIU3f7qO;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0D6C3606A326;
	Wed,  4 Nov 2026 14:42:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 0D6C3606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=eIU3f7qO
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 62AF721DB9;
	Wed, 04 Nov 2026 16:42:29 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=794K7AZbxC/RoZCY0ZDGowg+t1WslBWQGqIQBsO3AKs=; b=eIU3f7qOTHDF
	WcnBA7EHWCz3SWVAvXt8cB9LTrWnigm4E6ynJqdQTXSZJheoYWTO02nSbIseaqbE
	oT2biFcZG2j3Do6ROj+PtRGGr5WKfWSflcUrlYX15mIt9ClXYKkEcCC2i5sSJot2
	5wBkbixmKLVYslCrZWuEo6H/RoHMXqzOZCeMCCf6i3iyLJJ+GgtbkphFoxyHCrz2
	K7I5WNWEE8oJMV5Sbtw0o9Q4t9DATt4QI3paiyYQvN0JsVaDfaehmL2SMCc1O1qE
	RXlXAFLX+Rx3j0xblPc6q9D2Va3LVXm7UywlJrEAVqXXRa3BDz6CTlchoOj7HivC
	LnZ2I7JgDdEddZDmhoZI9i2DXNJfqd6m1od9VmAArHl9QDo+suX16jFVW9ZLdSrm
	/Z86T+RMYF7WBFmlc5O3AOCCpRNjnQRnw2xhn1heW8xfTaBL6wjqQ7u/TCNnccXW
	FU8n1cH6urmEs5Fvh4RFQDj6ISA5A7onZCSeFCnsnyj6roHGEgjqrIi7UqBb+uZZ
	5jevAt9RDoNoDZPLFSx0TBlX72opoQ+Dhh98nmQsxNfJxK2Ph7kcDw5qyTWcOBWD
	KVToifrjtHZHE7FXnbLUDPczX9oc8pEAY95kpubNVhfCl6nxWPlXTaD09HonKLaB
	YRpqobS7JFYazMoVRginUy4RtlRqrEY=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 04 Nov 2026 16:42:29 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 05332604D4;
	Wed,  4 Nov 2026 16:42:29 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6A4EgGvk103845;
	Wed, 4 Nov 2026 16:42:16 +0200
Date: Wed, 4 Nov 2026 16:42:16 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: netdev-bot+sashiko@kernel.org
cc: axel.mierczuk@1password.com, horms@verge.net.au, pablo@netfilter.org,
        fw@strlen.de, phil@nwl.cc, dsahern@kernel.org, idosch@nvidia.com,
        edumazet@google.com, netfilter-devel@vger.kernel.org,
        lvs-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, w@1wt.eu, keith.hoodlet@1password.com,
        kuba@kernel.org
Subject: Re: [PATCH nf 1/2] ipvs: avoid out-of-bounds write in
 ip_vs_nat_icmp_v6
In-Reply-To: <179069742680.434549.10138453724847288168@kernel.org>
Message-ID: <15cb7120-96bc-9292-b10d-a89f363afbe4@ssi.bg>
References: <20260925141155.17603-2-axel.mierczuk@1password.com> <179069742680.434549.10138453724847288168@kernel.org>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="-1463811672-2122261230-1793803341=:94418"

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-2122261230-1793803341=:94418
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hi Axel,

On Tue, 29 Sep 2026, netdev-bot+sashiko@kernel.org wrote:

> Thank you for your contribution! Sashiko AI review found more severe
> issue(s) in other patches of this series. This mail is only an FYI, in case
> you want to address the nit picks below when you respin.
> 
> Low priority / nit picks for your consideration:
> 
> - [Low] Three problems with the comment and commit message; the code
>   change itself is correct.
> 
> --

	May be you should improve the commit message, so
that Sashiko and the users can understand it better :) Some
tips below...

> 
> ipvs: avoid out-of-bounds write in ip_vs_nat_icmp_v6
> 
> When ipv6_find_hdr() stops at a non-first fragment and leaves len equal
> to off, this patch adds sizeof(struct ipv6hdr) to ciph.len in both
> ip_vs_out_icmp_v6() and ip_vs_in_icmp_v6(). With that, the
> skb_ensure_writable() calls in the ICMPv6 NAT paths cover the embedded

	... calls in handle_response_icmp() and ip_vs_icmp_xmit_v6() 
cover...

> addresses that ip_vs_nat_icmp_v6() rewrites.
> 
> > diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> > index fd503f0efb578..cfd193196a5bc 100644
> > --- a/net/netfilter/ipvs/ip_vs_core.c
> > +++ b/net/netfilter/ipvs/ip_vs_core.c
> > @@ -1206,6 +1206,13 @@ static int ip_vs_out_icmp_v6(struct netns_ipvs *ipvs, struct sk_buff *skb,
> >  				     true, &ciph))
> >  		return NF_ACCEPT; /* The packet looks wrong, ignore */
> >  
> > +	/* ipv6_find_hdr() does not include the embedded header for
> > +	 * non-first fragments, add it so that ESP can pass and the
> > +	 * NAT writable checks cover the rewritten addresses
> > +	 */
> 
> [Severity: Low]
> The code change looks correct. Is the "so that ESP can pass" part of
> this comment accurate, though?
> 
> I couldn't find anything that blocks an embedded IPv6 ESP fragment based
> on ciph.len:

	For ESP may be we should mention the pp->dont_defrag flag that 
implicitly ignores the payload and reads only the IP header.

> 
>   - Neither ip_vs_out_icmp_v6() nor ip_vs_in_icmp_v6() compares ciph.len
>     with ciph.off.
>   - The only such check is the "ciph->len - ciph->off" ihl check, and it
>     exists only on the IPv4 path.
>   - The ESP lookup reads only the addresses:
> 
> net/netfilter/ipvs/ip_vs_proto_ah_esp.c:ah_esp_conn_fill_param_proto() {
> 	if (likely(!ip_vs_iph_inverse(iph)))
> 		ip_vs_conn_fill_param(ipvs, af, IPPROTO_UDP,
> 				      &iph->saddr, htons(PORT_ISAKMP),
> 				      &iph->daddr, htons(PORT_ISAKMP), p);
> 	...
> }
> 
> So non-first ESP fragments already reached connection lookup and NAT
> before this patch. That is how the out-of-bounds write happened.
> 
> The new value seems to be used only as ctoff in handle_response_icmp()
> and as wlen in ip_vs_icmp_xmit_v6():
> 
> net/netfilter/ipvs/ip_vs_xmit.c:ip_vs_icmp_xmit_v6() {
> 	...
> 	wlen = ciph->len;
> 	...
> }
> 
> Would the comment be clearer if it said that len must cover the embedded
> IPv6 header that ip_vs_nat_icmp_v6() rewrites? The same comment appears
> again in ip_vs_in_icmp_v6().
> 
> The commit message also says:
> 
>     This fix does not depend on patch 2.
> 
> Once this is applied, "patch 2" has no meaning in the git history. Could
> the message name the companion commit instead: "ipv6: update *offset for
> non-first fragments in ipv6_find_hdr()"?
> 
> That companion commit makes ipv6_find_hdr() set
> *offset = start + sizeof(struct frag_hdr) on the non-first-fragment
> early return. After it lands, can ciph.len == ciph.off still be true in
> either function?
> 
> If not, the new branch can never be reached in mainline. The comment's
> premise, "ipv6_find_hdr() does not include the embedded header for
> non-first fragments", would then be false. Should the comment say it
> applies only to kernels where ipv6_find_hdr() leaves *offset unchanged?
> 
> > +	if (ciph.len == ciph.off)
> > +		ciph.len += sizeof(struct ipv6hdr);
> > +
> >  	pp = ip_vs_proto_get(ciph.protocol);
> >  	if (!pp)
> >  		return NF_ACCEPT;
> 
> [ ... ]
> 
> -- 
> Sashiko AI review · https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20260925141155.17603-1-axel.mierczuk%401password.com

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-2122261230-1793803341=:94418--

