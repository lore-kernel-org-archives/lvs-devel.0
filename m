From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH -stable 0/3] ipvs: patches for stable
Date: Mon, 8 May 2017 11:50:26 +0200
Message-ID: <20170508095026.GC4569@verge.net.au>
References: <20170501134537.4715-1-ja@ssi.bg>
 <20170504140920.GA6629@salvia>
 <alpine.LFD.2.20.1705042140230.2123@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1494237029; bh=RoJUiWnVTzeoVKJbYKMZJPqqCN5J9x8mDYOiDCpqvCY=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=Qxj0apPp9wyaeH0VvvmsqIdcjRoShd24dDbyd3tB5v8P8t3kLv6BewtNxx1WGwPKG
         rD3dgRwNSqP4r6EotU39ZFBO3XgZsLicy2fgeMIv0nQU9mnyixz9mpJaIycP4aOsC2
         R/Vyr+VYcMncyOTwqtO2+7I9z40Myu/q/2nRmawU=
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.20.1705042140230.2123@ja.home.ssi.bg>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org

On Thu, May 04, 2017 at 09:48:08PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 4 May 2017, Pablo Neira Ayuso wrote:
> 
> > On Mon, May 01, 2017 at 04:45:34PM +0300, Julian Anastasov wrote:
> > > 	Hello,
> > > 
> > > The following patches are rediffs for "ipvs: SNAT packet replies
> > > only for NATed connections" for different stable kernels:
> > > 
> > > The official patch for the net tree (will come from Simon) works for:
> > > 4.9.25, 4.10.13, 4.11, net tree
> > > 
> > > Patch 1: 3.2.88, 3.4.113
> > > Patch 2: 3.10.105, 3.12.73, 3.16.43, 4.1.39
> > > Patch 3: 4.4.65
> > 
> > Thanks Julian.
> > 
> > Could you indicate what upstream commit these patches refer to? stable
> > maintainer need this.
> > 
> > These are backports, right?
> 
> 	Yes. Simon added the official patch to the ipvs tree and
> the next step is to post it to you. May be you have to defer
> these backports. If needed, I can send them again later.

Hi Pablo,

sorry for the confusion. I have now posted the fix for you to consider for
mainline. Please see "[GIT PULL 0/1] IPVS Fixes for v4.12".
