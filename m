From: Willy Tarreau <w@1wt.eu>
Subject: Re: [3.10.y,3.16.y,4.1.y,netfilter/ipvs] please, apply 3c5ab3f395d6
Date: Mon, 24 Jul 2017 13:51:37 +0200
Message-ID: <20170724115137.GB31085@1wt.eu>
References: <20170724095805.GA3807@salvia>
Mime-Version: 1.0
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170724095805.GA3807@salvia>
Sender: stable-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Ben Hutchings <ben@decadent.org.uk>, "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>, stable@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org

Hi Pablo!

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
> 
> Julian made a backport for you, that is available at Netfilter's
> patchwork:
> 
>         http://patchwork.ozlabs.org/patch/789258/

Now queued for 3.10.107, thanks!
Willy
