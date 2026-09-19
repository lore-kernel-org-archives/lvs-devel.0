Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B37FE4570FD;
	Sat, 19 Sep 2026 10:08:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789812539; cv=none; b=o2jyWTd1rbVXf+uV6dBiJdJxnYx9IApbiP2YTcJm2yrhWLCUCQVKcW/3PIdIJ4BhQH39Pp1QkqfLxX/t82vZEjApFvOiV9QBP9B1ojNqNAhTIQimB3bfAOTIPjHUuICH2yYF2jHM0rx0YHvEVjGFWP3RD2yvGeZhY5m25bs8Mpk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789812539; c=relaxed/simple;
	bh=ZNGeOz9pirAsmGnWAM9RSJw/qC/AipJAd0mOKwCHW20=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=fjE3558n0bMqwOKSUo3H4FdDdLwQnFU5PZwr5gkkvzeCNijOk0lIaDVl8yfGi2e0YsdS67pER2gCiacGqMotS8jF2Ajsbzn4Ff9c6tx69sqx6hLRS1bbZ5WfE117kXuZc/N5Dgi7NsUssQcsvTYnu9hA9F02N+I5aVby+uR4VuA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=soqZO3df; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="soqZO3df"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 04592213A5;
	Sat, 19 Sep 2026 13:08:48 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=O2QTtBcrc3GL+6k/leZ9pC0nG6fhn7UZg6e0bwmdEUU=; b=soqZO3dfMYzA
	sYWuQNkyosnZ4MCLi5oT3nDqxylHU2cRRO0Ti/SVTUuYuGTGWueocYYpcuFh/aB/
	2dJu62xq/7ZExTJ0mOfmk/tox3lA+sYeExTJTXMmLKJIXJDIUz3rBKnrwquY3BgZ
	AJQ68SUVPr/DO8mXbmwh5NUIpMlNhVpR9/ViUFEhv2ZHM8rKKxo0MdJZ3uWWlaoP
	mWXoSzNsi1hU2EOlBPsn1rEC2uP3yPSXmtDhpAAW2LFIiz0ERgVt5olA91BEAZ5h
	WXjj43e2jrg+cLb0ScjkNnTnrsu3/Pp5eMeZWwg8PKmQJ8Q6jdaHnGM8ZlvryQfU
	RZ46+3dAMPkT1pR3YL6RMMjIueYpvktto1dWnEDQTSFgsfmy2M0p5IgzzYmzHtgd
	nav/9iClNV0V+gFY5GaDXBCZ7pgCuHc6Hm94r8/L8//iRU3S4lDU9N5M5wTiBLTV
	T5TU5pOMYWR7zGzDOTDEDxIs6LJcGkKe8VHCEdfqHvEHAWIqTFm4wcvtwz55TDys
	loUSmInE6qjHP+tZTPNwy4IfsaO/3r4Ej15Wy27GvSlghz6TeaqlcVWYb+NYHD5O
	z/qXMn7eFZhuPz5oa+dBRzxyRGz0gWa4U0YGJ0BdI4pxMyIYocKKIYaSB5IOrYgH
	3K343kILpChrbzBvT46N+0GoIo61XGE=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sat, 19 Sep 2026 13:08:47 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id B427F61E26;
	Sat, 19 Sep 2026 13:08:49 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68JA8m5t021687;
	Sat, 19 Sep 2026 13:08:48 +0300
Date: Sat, 19 Sep 2026 13:08:48 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Zihan Xi <zihanx@nebusec.ai>
cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH net v2 2/2] ipvs: reject FTP control ports as data
 ports
In-Reply-To: <7b561a02-461d-2320-75e4-241dd213d9f0@ssi.bg>
Message-ID: <a1ba4cd8-6e18-1ae9-fd96-8bb87f434f99@ssi.bg>
References: <cover.1789435989.git.zihanx@nebusec.ai> <20260917030301.5502-2-zihanx@nebusec.ai> <7b561a02-461d-2320-75e4-241dd213d9f0@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Fri, 18 Sep 2026, Julian Anastasov wrote:

> On Thu, 17 Sep 2026, Zihan Xi wrote:
> 
> > ip_vs_ftp_out() creates a wildcard data connection from the
> > server-advertised passive port. If that port is one of the configured FTP
> > control ports, ip_vs_conn_new() binds the FTP helper to the new connection
> > again. A subsequent wildcard lookup can then extend a controlled-connection
> > chain.
> > 
> > Reject zero and configured control ports before creating passive
> > connections. For active mode, reject a zero client port and a data port
> > derived from a configured control port.
> > 
> > Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
> > Cc: stable@vger.kernel.org
> > Reported-by: Vega <vega@nebusec.ai>
> > Assisted-by: LLM
> > Co-developed-by: Luxing Yin <root@tr0jan.top>
> > Signed-off-by: Luxing Yin <root@tr0jan.top>
> > Signed-off-by: Zihan Xi <zihanx@nebusec.ai>
> 
> 	Patch looks good to me for the nf tree, thanks!
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

	Patch is ok but needs to be resent with
the other patch:

pw-bot: changes-requested

> > changes in v2:
> >   - Reject the data port derived from a configured control port in
> >     ip_vs_ftp_in() to cover the active-mode bypass.
> >   - v1 Link:
> >     https://lore.kernel.org/all/cover.1789110326.git.zihanx@nebusec.ai/
> > 
> >  net/netfilter/ipvs/ip_vs_ftp.c | 18 ++++++++++++++++++
> >  1 file changed, 18 insertions(+)
> > 
> > diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
> > index 9e3e005a82635..4822a1a75212d 100644
> > --- a/net/netfilter/ipvs/ip_vs_ftp.c
> > +++ b/net/netfilter/ipvs/ip_vs_ftp.c
> > @@ -62,6 +62,17 @@ static unsigned short ports[IP_VS_APP_MAX_PORTS] = {21, 0};
> >  module_param_array(ports, ushort, &ports_count, 0444);
> >  MODULE_PARM_DESC(ports, "Ports to monitor for FTP control commands");
> >  
> > +static bool is_control_port(u16 port)
> > +{
> > +	unsigned int i;
> > +
> > +	for (i = 0; i < ports_count; i++) {
> > +		if (ports[i] == port)
> > +			return true;
> > +	}
> > +	return false;
> > +}
> > +
> >  
> >  static char *ip_vs_ftp_data_ptr(struct sk_buff *skb, struct ip_vs_iphdr *ipvsh)
> >  {
> > @@ -319,6 +330,10 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
> >  		return 1;
> >  	}
> >  
> > +	/* Do not redirect data to control ports */
> > +	if (!port || is_control_port(ntohs(port)))
> > +		return 0;
> > +
> >  	/* Now update or create a connection entry for it */
> >  	{
> >  		struct ip_vs_conn_param p;
> > @@ -529,6 +544,9 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
> >  		return 1;
> >  	}
> >  
> > +	if (!port || is_control_port(ntohs(cp->vport) - 1))
> > +		return 0;
> > +
> >  	/* Passive mode off */
> >  	cp->app_data = (void *) IP_VS_FTP_ACTIVE;
> >  
> > -- 
> > 2.43.0

Regards

--
Julian Anastasov <ja@ssi.bg>

