From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next v2] ipvs: fix multiplicative hashing in
 sh/dh/lblc/lblcr algorithms
Date: Mon, 9 Apr 2018 10:16:23 +0300
Message-ID: <20180409071623.mh6jk37timaiykyi@verge.net.au>
References: <alpine.LFD.2.20.1804011037200.1933@ja.home.ssi.bg>
 <20180401102711.20862-1-vincent@bernat.im>
 <alpine.LFD.2.20.1804011407500.9304@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1523258185; bh=Q7csWt6Oy0lXFnC6UoQ/tu2C7DOB87EZBpEU/sUdZCo=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=q0xOTM6BRjY8DmrTeMuq0cobrkrs1BJE+gyYWYZHnR6TVsttzTTZ4bU24gSvSa5UX
         xs9Cm+lWptS7UL6Pm6j7WPoiai+tGHfbT0u3ugNGu7Y9U2Ebkg3+xqHE0OSvYCupeq
         1ymJw8jY1uNM6mEJ+uRGrhS5l+HUbbhP+8sFJgpw=
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.20.1804011407500.9304@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Vincent Bernat <vincent@bernat.im>, Wensong Zhang <wensong@linux-vs.org>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org

On Sun, Apr 01, 2018 at 02:11:51PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Sun, 1 Apr 2018, Vincent Bernat wrote:
> 
> > The sh/dh/lblc/lblcr algorithms are using Knuth's multiplicative
> > hashing incorrectly. Replace its use by the hash_32() macro, which
> > correctly implements this algorithm. It doesn't use the same constant,
> > but it shouldn't matter.
> > 
> > Signed-off-by: Vincent Bernat <vincent@bernat.im>
> 
> 	Looks good to me, thanks! Simon, please apply, if possible
> with the extra space removed, see below...
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

Thanks, I have applied this with the extra space removed.
I will submit it for inclusion in v4.18.
