From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 1/2] netfilter: ipvs: avoid unused variable warnings
Date: Thu, 28 Jan 2016 08:39:53 +0900
Message-ID: <20160127233953.GB5183@verge.net.au>
References: <1453902749-3422685-1-git-send-email-arnd@arndb.de>
 <alpine.LFD.2.11.1601272156590.2353@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
	t=1453937995; bh=qLuaXAE4l2egK8gnxnj4T/3eiirFGpL4ej34GX1Ly9A=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=V+IuBTC2o1QNEnlgrBKgEplq+cDsNsU+RHQzlIKx3GWsqPlEm4eg9I2WmQ97IRIDs
	 yaozuVriM4avWH3TeqvGV/fnkWByk5Chbxs96VdmdIniUZRRxEu/TO2hDGKm8d52CX
	 X5X5Dhm0GP5NNk9DBwgAwC6gksZ3qJk7bQCzoDOU=
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1601272156590.2353@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Arnd Bergmann <arnd@arndb.de>, Wensong Zhang <wensong@linux-vs.org>, linux-arm-kernel@lists.infradead.org, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

On Wed, Jan 27, 2016 at 10:01:42PM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Wed, 27 Jan 2016, Arnd Bergmann wrote:
> 
> > The proc_create() and remove_proc_entry() functions do not reference
> > their arguments when CONFIG_PROC_FS is disabled, so we get a couple
> > of warnings about unused variables in IPVS:
> > 
> > ipvs/ip_vs_app.c:608:14: warning: unused variable 'net' [-Wunused-variable]
> > ipvs/ip_vs_ctl.c:3950:14: warning: unused variable 'net' [-Wunused-variable]
> > ipvs/ip_vs_ctl.c:3994:14: warning: unused variable 'net' [-Wunused-variable]
> > 
> > This removes the local variables and instead looks them up separately
> > for each use, which obviously avoids the warning.
> > 
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > Fixes: 4c50a8ce2b63 ("netfilter: ipvs: avoid unused variable warning")
> 
> 	Looks like your previous patch for ip_vs_app_net_cleanup
> was delayed in ipvs-next tree. I guess, Simon should drop it and
> use this one instead when net-next opens:
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

Thanks, and sorry about not pushing the other patch to net-next.
I have dropped it and queued up this one in its place.
