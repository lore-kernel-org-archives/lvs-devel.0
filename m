Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 014EC262A6;
	Fri,  4 Jul 2025 10:00:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1751623262; cv=none; b=TBVPwyVozIJrpMsAWF0yXv8uCSxIs3vFGu6z+oKMtbJ5XNuX2BZjzknyrT0Bn5x2HrwuNgoWG6ga/n8mcsj/re4T0DzBN7o3ucUw+cwZ8PFbQUgb5zlEEYU7+saaemV9kTkKW4KyqTQbJ/uP+wT/Sc1lWGy/JEYt74E5LSZ0sKs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1751623262; c=relaxed/simple;
	bh=UDwLdN9+Ws+1t2BdqtB8v0310FnUQKl1SthOpC5EQhs=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=BWT5I5vDQjJGFHzrHn+6U6PsZiQvAEtzs3Gh8HDWk+OEu0N0iroJ5DY53Fs4XyioA8AwKbTQf6S/qkPOwRr4IJ2VZro6Yhhj+gPKtA62NzERtuByxJFfcP2G/QSpO7/uj8+VeGR2IUVWhSJie2bB2tqxjIljb+VHDdqVLZS9Zuo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=hD5BeEK/; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="hD5BeEK/"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id D59B323554;
	Fri,  4 Jul 2025 12:53:06 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=CI21Vkd6rz8iL5QUwk0CI7L4tOktsE0+upPgppWiPgc=; b=hD5BeEK/Rn3H
	iWAQ38MngKYxsD96rpyvcK6MHUgbtbw1cp+80nwsjBGLhTZiKT5KVKbtXBdZg76Z
	yAFmrsden6bCwbnNcMVRXZk9Vd8dXtuum73fdpq+/ayXuNuYW/eKKqiNPFpL2Fdc
	2hLVXB+7nSGSnuXsIvDIRUa7Q1Sb65rgj/KvTv9YrGtjzw3MRJybKcZtvsYoSEM4
	myc6ou7HFHI791DIjV0uPFHOBU2ekW6v8A3W2OCi4BUd+UMxT2XqNMV1zh9w5YeB
	CYlZpUZ9KiCD+7XZtpie2PJCnrDHJNAEcEuKgYQ6KqXnkD5yY9BGMC69utZtycOq
	Ph47x3qI2cIIUXcX7+hQK3zxJJGj3DcG8ZsKyErG7lvoybNF/hB6Z4N9dLh9kAQ2
	PLuvBwC7p59bXeH+0SmvgeWtmbHpdoIPX0e9AX+fWGg6jvJ9mQ4xpkie0wPrrU5G
	w7/vZwnxf/xVnKlZNTaP4O+enRcvzVftRYLT87BtzvU+KSy9zcEfaOoKuZ4D6Eb5
	cRFUXLnfQLDzRpf8lVCEaNaOQSSHjwtnP+41fUxZaqrk5zplVK3uiG1XFEieVV7l
	/WZxqyVeGsJ4EITuJ6/kjfUXBRosqtjymV6BeL0tsE40TZ3QYlaTYWs+aMb/G2oS
	o2mQEwKpRrhm/jkw5p2MpBsutjM5JVI=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Fri,  4 Jul 2025 12:53:06 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 1F7A264A13;
	Fri,  4 Jul 2025 12:53:05 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 5649qvsn007449;
	Fri, 4 Jul 2025 12:52:57 +0300
Date: Fri, 4 Jul 2025 12:52:57 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: WangYuli <wangyuli@uniontech.com>
cc: Simon Horman <horms@verge.net.au>, pablo@netfilter.org,
        kadlec@netfilter.org, netdev@vger.kernel.org,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, linux-kernel <linux-kernel@vger.kernel.org>,
        zhanjun@uniontech.com, niecheng1@uniontech.com,
        guanwentao@uniontech.com, wangyuli@cloudflare.getdeepin.org
Subject: Re: [PATCH RESEND] ipvs: ip_vs_conn_expire_now: Rename del_timer in
 comment
In-Reply-To: <E5403EE80920424D+20250704083553.313144-1-wangyuli@uniontech.com>
Message-ID: <3dbee3f4-8670-b72c-e5b0-3a108b5ded04@ssi.bg>
References: <E5403EE80920424D+20250704083553.313144-1-wangyuli@uniontech.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Fri, 4 Jul 2025, WangYuli wrote:

> Commit 8fa7292fee5c ("treewide: Switch/rename to timer_delete[_sync]()")
> switched del_timer to timer_delete, but did not modify the comment for
> ip_vs_conn_expire_now(). Now fix it.
> 
> Signed-off-by: WangYuli <wangyuli@uniontech.com>

	Looks good to me for nf-next, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  net/netfilter/ipvs/ip_vs_conn.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 44b2ad695c15..965f3c8e5089 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -926,7 +926,7 @@ static void ip_vs_conn_expire(struct timer_list *t)
>  void ip_vs_conn_expire_now(struct ip_vs_conn *cp)
>  {
>  	/* Using mod_timer_pending will ensure the timer is not
> -	 * modified after the final del_timer in ip_vs_conn_expire.
> +	 * modified after the final timer_delete in ip_vs_conn_expire.
>  	 */
>  	if (timer_pending(&cp->timer) &&
>  	    time_after(cp->timer.expires, jiffies))
> -- 
> 2.50.0

Regards

--
Julian Anastasov <ja@ssi.bg>

