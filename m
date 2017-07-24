From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [4.4.y,netfilter/ipvs] please, apply 3c5ab3f395d6
Date: Mon, 24 Jul 2017 16:36:15 -0700
Message-ID: <20170724233615.GB4315@kroah.com>
References: <20170724095940.GA3853@salvia>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170724095940.GA3853@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: stable@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org

On Mon, Jul 24, 2017 at 11:59:40AM +0200, Pablo Neira Ayuso wrote:
> Hi Greg,
> 
> Please, apply this commit:
> 
> commit 3c5ab3f395d66a9e4e937fcfdf6ebc63894f028b
> Author: Julian Anastasov <ja@ssi.bg>
> Date:   Sat Apr 29 20:33:09 2017 +0300
> 
>     ipvs: SNAT packet replies only for NATed connections
> 
> to stable 4.4.y.
> 
> Julian made a backport for you, in case cherry-pick doesn't work, that
> is available at Netfilter's patchwork:
> 
>         http://patchwork.ozlabs.org/patch/789260/

Thanks for that, I've also applied the original to the 4.9-stable tree.

greg k-h
