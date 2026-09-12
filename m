Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 68D8935F184;
	Sat, 12 Sep 2026 17:50:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789235453; cv=none; b=H+4eEwc0/LeC648t8KGxF7d5Rvr9D5nZlPfJtUi7ZgiI5a+8aDDaJ/mRGg0XrwT3sPsizcOw8ejn/ZiKJTFOLC5nd1XPE1sJ3be6s2RlzGGltupcYqHB2RspxsgXS19oaQJeQaa62RtW0JG/cg6bCHc0/Hz4Y2A0ZyQg+yIc+ik=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789235453; c=relaxed/simple;
	bh=52mxefBNL18TSW0EPrMFo62pk6fFfbgczGcDISCects=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=FMTSJ6FVGGTgsCwSfvvJax92gQlCDLk8ub6Jv+EwHS2JfgobJWz5ereAGsgZxJdsIZD94Ib5Zba/ratuHsQUeTLqtbq1B/xPqFEX640YUbXmm/rVxk77HS/dRNgHCbA+oJpwnpDQGrVq3cVXHusgU/uK4VWQnIrCjjWwzuxCiU8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=OJGID+qA; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="OJGID+qA"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 55DB222741;
	Sat, 12 Sep 2026 20:50:31 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=7r8oFDAgjy8muNhyo4CeqelFFPqnHlw5fWun4gzb8Z4=; b=OJGID+qAQy2Y
	3zRJitxMU8ygncW89pWOrD56ChopmCF9pL6S2/KCzTmVuwkoAl8tB7gOHfwfIPvV
	Tz8PH7mliLoxvSJznImrkM+WH7tIJNHQZqDDvELTwvRJjU1cLAXdGR1Bqx5AEtUa
	Ibnq+7AJTu3dNqv98Yf/1WoPFQUcLVs4v1Xt9cCZZC5B7y+NjdXMJir96VlEz3/F
	0GrS2tymlWH2o8RrFKmWIAsPxalOU+u0cF1ooah0+PCfqKkM0BklZq3TSPFAfWHQ
	4ZAAC+09kyIs5Xf+jSI4Emm8RSqFi8EVMK6GJqBz2bnSjC28c2FD4wUDYp76AldX
	/qQ9AR+IGV2Ocow5r3H+vwe7KIVa4X3IFwAiaSyPgWQAsQAbPuI0GMIKFfK0E18Z
	YYdBWmSZXWZX+sfXk0Zz1u6wiW9/9YK6zuM0ByBEFZ8AJHOH8GGweuhkjIQJfwZi
	Sv+sBJAVHnCNh0ONZkfqOY2djeMThUkVf0YVZb9SDq+fN28ycGKm55/0ex67ISZC
	4X+ydQQJNiBeWps5Y5ZURX0/brPsoCYRdNGAT2DbaCtU2X4ju6P02wY+wnvyYxHM
	JD9IdVmKfnBwb6AcFQQxPTb/jxHfnddP25B2i2SzeLNDr+0MsH+Z4oseuBq9oHpi
	iOkSdgK97iKT9ky1uDlvnEY4t/FwNIA=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sat, 12 Sep 2026 20:50:31 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id E2A0360898;
	Sat, 12 Sep 2026 20:50:32 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68CHoTkT030622;
	Sat, 12 Sep 2026 20:50:29 +0300
Date: Sat, 12 Sep 2026 20:50:29 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Zihan Xi <zihanx@nebusec.ai>
cc: horms@verge.net.au, pablo@netfilter.org, fw@strlen.de, davem@davemloft.net,
        edumazet@google.com, kuba@kernel.org, pabeni@redhat.com, phil@nwl.cc,
        netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH nf 0/1] ipvs: avoid stack overflow from recursive connection
 expiration
In-Reply-To: <cover.1789110326.git.zihanx@nebusec.ai>
Message-ID: <d99cb205-24fc-7446-55ad-4ec9d79aac1d@ssi.bg>
References: <cover.1789110326.git.zihanx@nebusec.ai>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Sat, 12 Sep 2026, Zihan Xi wrote:

> Hi Linux kernel maintainers,
> 
> We found and validated an issue triggered through
> net/netfilter/ipvs/ip_vs_ftp.c. An unprivileged user can trigger it by
> creating a user namespace and a network namespace. We tested the fix with
> the same trigger. The change applies to the generic
> ip_vs_conn_expire() control-chain cleanup path. For the reported trigger,
> it only defers recursive controller expiration; testing showed no change to
> other IPVS behavior.
> 
> We will provide detailed information about the bug
> in this email, along with a PoC to trigger it.
> 
> ---- details below ----
> 
> Bug details:
> 
> The trigger entry point is ip_vs_ftp_out() in
> net/netfilter/ipvs/ip_vs_ftp.c. It parses an EPSV reply and creates a
> wildcard data connection using the advertised port. If that port is 21,
> ip_vs_conn_new() binds the new connection to the FTP helper a second time,
> because 21 is the helper's control port. The connection has
> IP_VS_CONN_F_NO_CPORT, so the next connection from the same client to the
> VIP on port 21 matches the wildcard entry instead of creating a new
> top-level entry. Repeating EPSV builds a chain of controlled connections.

	Hm, may be we should also avoid such long chains.
Probably in separate patch, for example:

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 9e3e005a8263..0622169b5970 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -237,6 +237,17 @@ static int ip_vs_ftp_get_addrport(char *data, char *data_limit,
 	return 1;
 }
 
+static bool is_control_port(u16 port)
+{
+	int i;
+
+	for (i = 0; i < ports_count; i++) {
+		if (ports[i] == port)
+			return true;
+	}
+	return false;
+}
+
 /* Look at outgoing ftp packets to catch the response to a PASV/EPSV command
  * from the server (inside-to-outside).
  * When we see one, we build a connection entry with the client address,
@@ -293,6 +304,9 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 
 		IP_VS_DBG(7, "PASV response (%pI4:%u) -> %pI4:%u detected\n",
 			  &from.ip, ntohs(port), &cp->caddr.ip, 0);
+		/* Do not redirect data to control ports */
+		if (!port || is_control_port(ntohs(port)))
+			return 0;
 	} else if (cp->app_data == (void *) IP_VS_FTP_EPSV) {
 		data = ip_vs_ftp_data_ptr(skb, ipvsh);
 		data_limit = skb_tail_pointer(skb);
@@ -529,6 +543,9 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
 		return 1;
 	}
 
+	if (!port)
+		return 0;
+
 	/* Passive mode off */
 	cp->app_data = (void *) IP_VS_FTP_ACTIVE;

	The only problem I see with your proposed change is
that we may need 2-3 timer ticks to expire a DATA->CTL->TPL
chain. Or it expires on the same tick?

	Alternative would be to jump to the beginnig of the
function after successful timer_delete() for our cp->control,
i.e. to use loop instead of recursion. I.e. ip_vs_conn_del_put()
can be converted to function that returns bool instead of
calling ip_vs_conn_expire(), so that we can know if to loop.

	If ip_vs_conn_flush() demands faster expiring, a
loop will work faster. What do you think?

Regards

--
Julian Anastasov <ja@ssi.bg>

