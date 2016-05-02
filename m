From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: make drop_entry protection effective for SIP-pe
Date: Mon, 2 May 2016 16:43:57 +1000
Message-ID: <20160502064357.GC9210@verge.net.au>
References: <571fbf76.2SIflQ7gFAmOpH7S%marcoangaroni@gmail.com>
 <alpine.LFD.2.11.1604271025140.1661@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
	t=1462171437; bh=r4Ol7Iv6s9WzLWubouIbBGUxajwPsAN8jWGdZCxIRj0=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=If3mZS4NSY6NLkL1kSsi50QC7oTiVQfTwj5aWwy8Wa69ssntDecZzESVL9+0bKe4l
	 wtscUjFahlA5RAubHEnmiEKiOaqHGgj6NEMzgVvUsGk3rHeVKBkVidfHZeesDXi5QQ
	 HhPNtQmtXeSCqz69iQRX6R9eqYYUMBaEhuVVbu/s=
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1604271025140.1661@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Marco Angaroni <marcoangaroni@gmail.com>, lvs-devel@vger.kernel.org

On Wed, Apr 27, 2016 at 10:27:41AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Tue, 26 Apr 2016, Marco Angaroni wrote:
> 
> > DoS protection policy that deletes connections to avoid out of memory is
> > currently not effective for SIP-pe plus OPS-mode for two reasons:
> >   1) connection templates (holding SIP call-id) are always skipped in
> >      ip_vs_random_dropentry()
> >   2) in_pkts counter (used by drop_entry algorithm) is not incremented
> >      for connection templates
> > 
> > This patch addresses such problems with the following changes:
> >   a) connection templates associated (via their dest) to virtual-services 
> >      configured in OPS mode are included in ip_vs_random_dropentry()
> >      monitoring. This applies to SIP-pe over UDP (which requires OPS mode),
> >      but is more general principle: when OPS is controlled by templates
> >      memory can be used only by templates themselves, since OPS conns are
> >      deleted after packet is forwarded.
> >   b) OPS connections, if controlled by a template, cause increment of 
> >      in_pkts counter of their template. This is already happening but only
> >      in case director is in master-slave mode (see ip_vs_sync_conn()).
> > 
> > Signed-off-by: Marco Angaroni <marcoangaroni@gmail.com>
> 
> 	Looks good to me. Simon, please apply to -next.
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

Thanks, applied.
