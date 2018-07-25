From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 1/4] treewide: convert ISO_8859-1 text comments to utf-8
Date: Wed, 25 Jul 2018 14:20:25 +1000
Message-ID: <87o9ewx7xy.fsf@concordia.ellerman.id.au>
References: <20180724111600.4158975-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20180724111600.4158975-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Joe Perches <joe@perches.com>, Arnd Bergmann <arnd@arndb.de>, Samuel Ortiz <sameo@linux.intel.com>, "David S. Miller" <davem@davemloft.net>, Rob Herring <robh+dt@kernel.org>, Jonathan Cameron <jic23@kernel.org>, linux-wireless@vger.kernel.org, netdev@vger.kernel.org, devicetree@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-crypto@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-iio@vger.kernel.org, linux-pm@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org

Arnd Bergmann <arnd@arndb.de> writes:

> Almost all files in the kernel are either plain text or UTF-8
> encoded. A couple however are ISO_8859-1, usually just a few
> characters in a C comments, for historic reasons.
>
> This converts them all to UTF-8 for consistency.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
...
>  drivers/crypto/vmx/ghashp8-ppc.pl             |  12 +-
...
> diff --git a/drivers/crypto/vmx/ghashp8-ppc.pl b/drivers/crypto/vmx/ghashp8-ppc.pl
> index f746af271460..38b06503ede0 100644
> --- a/drivers/crypto/vmx/ghashp8-ppc.pl
> +++ b/drivers/crypto/vmx/ghashp8-ppc.pl
> @@ -129,9 +129,9 @@ $code=<<___;
>  	 le?vperm	$IN,$IN,$IN,$lemask
>  	vxor		$zero,$zero,$zero
>  
> -	vpmsumd		$Xl,$IN,$Hl		# H.loXi.lo
> -	vpmsumd		$Xm,$IN,$H		# H.hiXi.lo+H.loXi.hi
> -	vpmsumd		$Xh,$IN,$Hh		# H.hiXi.hi
> +	vpmsumd		$Xl,$IN,$Hl		# H.lo·Xi.lo
> +	vpmsumd		$Xm,$IN,$H		# H.hi·Xi.lo+H.lo·Xi.hi
> +	vpmsumd		$Xh,$IN,$Hh		# H.hi·Xi.hi
>  
>  	vpmsumd		$t2,$Xl,$xC2		# 1st phase
>  
> @@ -187,11 +187,11 @@ $code=<<___;
>  .align	5
>  Loop:
>  	 subic		$len,$len,16
> -	vpmsumd		$Xl,$IN,$Hl		# H.loXi.lo
> +	vpmsumd		$Xl,$IN,$Hl		# H.lo·Xi.lo
>  	 subfe.		r0,r0,r0		# borrow?-1:0
> -	vpmsumd		$Xm,$IN,$H		# H.hiXi.lo+H.loXi.hi
> +	vpmsumd		$Xm,$IN,$H		# H.hi·Xi.lo+H.lo·Xi.hi
>  	 and		r0,r0,$len
> -	vpmsumd		$Xh,$IN,$Hh		# H.hiXi.hi
> +	vpmsumd		$Xh,$IN,$Hh		# H.hi·Xi.hi
>  	 add		$inp,$inp,r0
>  
>  	vpmsumd		$t2,$Xl,$xC2		# 1st phase

Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)

cheers
