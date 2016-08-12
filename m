From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH nf-next v2] ipvs: use nf_ct_kill helper
Date: Fri, 12 Aug 2016 13:21:10 +0200
Message-ID: <20160812112108.GA4464@verge.net.au>
References: <1470230488-302-1-git-send-email-fw@strlen.de>
 <20160812102443.GA3086@salvia>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
	t=1471000875; bh=9ljB0F3BK3/O0O65k5lgzBKYbw3U6W+eAw4Oe5kJgoQ=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=l1Yvz4wr0eHXgeoWeA01/SJ7goF0M25Ql5tsVzkj6QT8TTrL16kogTA6W/C61FXLq
	 RB7wEbOiJ7DRvwlgq7IB7msWoOy68cGjmgpK3bLY3fLGiP59/V5v148lYd6Ap40ePG
	 dY6oauuMoKvptD7mqgvS7d/uXXEFkCiahcmIS808=
Content-Disposition: inline
In-Reply-To: <20160812102443.GA3086@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org

Hi Pablo,

On Fri, Aug 12, 2016 at 12:24:43PM +0200, Pablo Neira Ayuso wrote:
> On Wed, Aug 03, 2016 at 03:21:28PM +0200, Florian Westphal wrote:
> > Once timer is removed from nf_conn struct we cannot open-code
> > the removal sequence anymore.
> 
> @Simon and other IPVS folks: I'm going to take this patch since
> Florian needs this merged for follow up patches.
> 
> So I'm dealing with this small one.

Sure, please do.
