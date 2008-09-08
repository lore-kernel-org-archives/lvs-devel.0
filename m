From: Simon Horman <horms@verge.net.au>
Subject: Re: [rfc 0/3] IPVS: checksum updates
Date: Mon, 8 Sep 2008 20:41:22 +1000
Message-ID: <20080908104120.GB5795@verge.net.au>
References: <20080908020420.313463898@vergenet.net> <f4845fc0809080303s53094205kc045e6003014cd24@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f4845fc0809080303s53094205kc045e6003014cd24@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Siim =?iso-8859-1?Q?P=F5der?= <siim@p6drad-teel.net>, Julian Anastasov <ja@ssi.bg>, Malcolm Turnbull <malcolm@loadbalancer.org>, Vince Busam <vbusam@google.com>, Herbert Xu <herbert@gondor.apana.org.au>

On Mon, Sep 08, 2008 at 12:03:04PM +0200, Julius Volz wrote:
> On Mon, Sep 8, 2008 at 4:04 AM, Simon Horman wrote:
> > Hi,
> >
> > The impetus for this series of patches is Julian Anastasov noting
> > that "load balance IPv4 connections from a local process" checks
> > for 0 TCP checksums. Herbert Xu confirmed that this is not legal,
> > even on loopback traffic, but that rather partial checksums are
> > possible.
> >
> > The first patch in this series is a proposed solution to handle
> > partial checksums for both TCP and UDP.
> >
> > The other two patches clean things up a bit.
> >
> > I have not tested this code beyond compilation yet.
> 
> After some first tests, remote connections are still working, but not
> local ones from the director. The TCP handshake works and the
> connection is established, but all following packets arriving at the
> real server have an incorrect TCP checksum.
> 
> Btw., this happens both with and without this last series of patches,
> so I can't get the local client feature working at all. Looking at it
> further...

Ok, is this for both IPv4 & IPv6? Does it still occur with just the first
patch in this series applied?
