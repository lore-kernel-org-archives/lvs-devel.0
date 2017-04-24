From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: explicitly forbid ipv6 service/dest creation if
 ipv6 mod is disabled
Date: Mon, 24 Apr 2017 11:54:44 +0200
Message-ID: <20170424095444.GF2047@verge.net.au>
References: <2a5c88ca5670baade900e2b1f05a0dcc9927a29d.1492681122.git.pabeni@redhat.com>
 <alpine.LFD.2.20.1704221355290.1974@ja.home.ssi.bg>
 <1493016651.5744.1.camel@redhat.com>
 <alpine.LFD.2.20.1704241017030.2492@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1493027688; bh=s+5U6LA69YTlKiP7iEhcWdWtoLoXGGMs2/Q8ouisneg=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=nNYQL0r2K1EVmZ4x1iq/u7gD3b5fq5mMWzQFOOCD2LaPMJja8CMbVs1R2UCw9MYru
         EijxHvkIEgew3lRu0zt4W7vdGm6wpabfgfEm8IFuwSqqH/ihxgVrOl1Bn7loBQnGUh
         RVSJDVZz+Fs2TzZddjTWpfrTvvbAv40++kfDKD2M=
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.20.1704241017030.2492@ja.home.ssi.bg>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Paolo Abeni <pabeni@redhat.com>, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, netdev@vger.kernel.org

On Mon, Apr 24, 2017 at 10:21:30AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 24 Apr 2017, Paolo Abeni wrote:
> 
> > Hi,
> > 
> > The problem with the patched code is that it tries to resolve ipv6
> > addresses that are not created/validated by the kernel.
> 
> 	OK. Simon, please apply to ipvs tree.
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

Thanks, done.
