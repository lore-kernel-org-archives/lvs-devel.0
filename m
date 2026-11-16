Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=217.70.190.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827866;
	b=aph5rXPoYw4TEUA7xqlgzsrHE2wawQXz6khcd7eSspm2JfWvfFYRIoWu2z0KOIhDCeVG
	 369xYGGBQD1+xP16WmDzjAHW98OQaA/IMl0CFmiPUNdmUtqVKWMElEcbbY1ggMGYC/osF
	 WUZuPG7YoWGaVKheOh6dDqwOBjNhOJ5Z2ZkddCAd371mY3UNs+ChkjD0uFJ4gaLjCkutt
	 ITKJLn+5PZaAAMbfRI9Q9PoOxPAVQSIKs7rc/m4uTrTNjk6or1ftHqppOzvjZICst7O/z
	 xTGtffOP5ebRf+kX7ZZSybOhEnpKIVgobw0HvlBRwfJVcCxi1oJ1WLySXfrCM1EKYEg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827866;
	h=DMARC-Filter:DKIM-Signature:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 Content-Transfer-Encoding:In-Reply-To:X-Spam-Status:
	 X-Spam-Checker-Version;
	bh=1X+DI2EYVTamjMZdv5D2oa41wuSOtsC9pXWb3oBSzOU=;
	b=L+JM3UGyYnXqULAtmu5K1yAtbUXxeCEF1t/1rCFSwoRLk1up5FJnJ6Bnkd3kAFPwCbak
	 yr59V7gJvTA2WOzVh6dAJLbDXKhtNcEtKIIoVej5BVIxu5GRkPx+AQvUFu/f/JxeWnw4C
	 8bjrZNxZRP6ZGAKFzDt7+PsjMuOCO7cCX/uDdDuYjY3cK+mIYQkKe4Lgt3pZucIi1wonE
	 8h8VaIO7RK9gPQGWBJt2a96rpZxRw1zjXig9YxvG043f3vcwsEg1sR33LMnQaDvTB+LOz
	 8vqq2tpnHvwf1OCjQrUX9mnJbtp7gUBpF7m7w9ZvzWVYcOm4ymQ55RaWA48Xo28WTlA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=netfilter.org;
	spf=pass smtp.mailfrom=netfilter.org;
	dkim=pass header.d=netfilter.org header.i=@netfilter.org header.a=rsa-sha256 header.s=2025 header.b=NkTkPDOG;
	arc=none smtp.remote-ip=217.70.190.124
Received: from mail.netfilter.org (mail.netfilter.org [217.70.190.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id 211C3606F355;
	Mon, 16 Nov 2026 11:17:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 211C3606F355
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netfilter.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=netfilter.org header.i=@netfilter.org header.a=rsa-sha256 header.s=2025 header.b=NkTkPDOG
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netfilter.org;
	s=2025; t=1794827863;
	bh=1X+DI2EYVTamjMZdv5D2oa41wuSOtsC9pXWb3oBSzOU=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=NkTkPDOGqxXpa+EH9pZvGIv3d61Wd6nr/8W5+6uEIJ+pdn1LRULuSsv8tpxb+2962
	 HH0gN9wOSt7JrhWxJjvLQzu+0ceVz0uezpwpUv8HT7cnULwNpiuxnMgJ8s7D9auucr
	 8T0nay59r7bVFnc5deKt0dvjeATq4r9PY9+ssJ8Smw00ABDnp1PG2eXPzR+0OBcIgB
	 dYV4J8Qv8aWdZdQbD9N5Y78SPlDbojz88CIp8BMdU4jETUrMpCVviYwm8lQGTdexuh
	 GrJROKVCtDxahS7kBTzB0X5Sntfj0S87UZTmdx0eRz2LPnGBgiM0d7kIY7I+7e5oUk
	 VwD8Bp0IAdpsg==
Received: from netfilter.org (mail-agni [217.70.190.124])
	by mail.netfilter.org (Postfix) with UTF8SMTPSA id 88A126005B;
	Mon, 16 Nov 2026 12:17:43 +0100 (CET)
Date: Mon, 16 Nov 2026 12:17:40 +0100
From: Pablo Neira Ayuso <pablo@netfilter.org>
To: Theodor Arsenij Larionov-Trichkine <theodorlarionov@gmail.com>
Cc: Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>,
	Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, coreteam@netfilter.org
Subject: Re: [PATCH nf v3] ipvs: ftp: do not link expectations to unconfirmed
 conntracks
Message-ID: <avrmVAE_onAH-_VK@chamomile>
References: <20261116101506.98853-1-theodorlarionov@gmail.com>
 <avrgKSO8nfTnv4iL@chamomile>
 <CAEZyMPB+oNBrnxV09Ji-Ao7Bcs93Qg=qx0B_b=3ULFx3nEFo+Q@mail.gmail.com>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAEZyMPB+oNBrnxV09Ji-Ao7Bcs93Qg=qx0B_b=3ULFx3nEFo+Q@mail.gmail.com>

On Mon, Nov 16, 2026 at 02:05:52PM +0300, Theodor Arsenij Larionov-Trichkine wrote:
> On Mon, Nov 16, 2026 at 1:51 PM Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> > I think this is coming a bit late?
> >
> > Maybe it is possible to check this earlier in this path?
> 
> You mean returning at the top of ip_vs_ftp_out() if the ct is not
> confirmed, and letting the packet through untouched? Or even before
> ip_vs_ftp_out() gets called?

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 9e3e005a8263..5d7b572961f9 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -368,7 +368,7 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
        buf_len = strlen(buf);
 
        ct = nf_ct_get(skb, &ctinfo);
-       if (ct) {
+       if (ct && !nf_ct_unconfirmed(ct)) {
                bool mangled;
 
                /* If mangling fails this function will return 0

IIRC, there is a recent fix here to ignore template conntracks too
here.

@Julian, is it worth all the pattern matching before getting here
worth if the ct is unconfirmed? Otherwise, this can be short-circuit
earlier.
