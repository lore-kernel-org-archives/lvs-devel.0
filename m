From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH -stable 0/3] ipvs: patches for stable
Date: Thu, 4 May 2017 21:48:08 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1705042140230.2123@ja.home.ssi.bg>
References: <20170501134537.4715-1-ja@ssi.bg> <20170504140920.GA6629@salvia>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20170504140920.GA6629@salvia>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org


	Hello,

On Thu, 4 May 2017, Pablo Neira Ayuso wrote:

> On Mon, May 01, 2017 at 04:45:34PM +0300, Julian Anastasov wrote:
> > 	Hello,
> > 
> > The following patches are rediffs for "ipvs: SNAT packet replies
> > only for NATed connections" for different stable kernels:
> > 
> > The official patch for the net tree (will come from Simon) works for:
> > 4.9.25, 4.10.13, 4.11, net tree
> > 
> > Patch 1: 3.2.88, 3.4.113
> > Patch 2: 3.10.105, 3.12.73, 3.16.43, 4.1.39
> > Patch 3: 4.4.65
> 
> Thanks Julian.
> 
> Could you indicate what upstream commit these patches refer to? stable
> maintainer need this.
> 
> These are backports, right?

	Yes. Simon added the official patch to the ipvs tree and
the next step is to post it to you. May be you have to defer
these backports. If needed, I can send them again later.

Regards

--
Julian Anastasov <ja@ssi.bg>
