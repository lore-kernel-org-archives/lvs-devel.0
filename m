From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [3.10.y,3.16.y,4.1.y,netfilter/ipvs] please, apply 3c5ab3f395d6
Date: Mon, 24 Jul 2017 12:00:35 +0200
Message-ID: <20170724100035.GA3879@salvia>
References: <20170724095805.GA3807@salvia>
Mime-Version: 1.0
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170724095805.GA3807@salvia>
Sender: stable-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Willy Tarreau <w@1wt.eu>, Ben Hutchings <ben@decadent.org.uk>, "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
Cc: stable@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org

On Mon, Jul 24, 2017 at 11:58:05AM +0200, Pablo Neira Ayuso wrote:
> Hi Willy, Ben & Sasha,
> 
> Please, apply this commit:
> 
> commit 3c5ab3f395d66a9e4e937fcfdf6ebc63894f028b
> Author: Julian Anastasov <ja@ssi.bg>
> Date:   Sat Apr 29 20:33:09 2017 +0300
> 
>     ipvs: SNAT packet replies only for NATed connections
> 
> to stable 3.2.y.
            ^^^^^
This is obviously wrong, this should be instead: 3.10.y, 3.16.y and
4.1.y.

> Julian made a backport for you, that is available at Netfilter's
> patchwork:
> 
>         http://patchwork.ozlabs.org/patch/789258/
> 
> Thanks!
