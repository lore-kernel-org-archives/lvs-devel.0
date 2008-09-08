From: juliusv@google.com (Julius Volz)
Subject: Re: [rfc 0/3] IPVS: checksum updates
Date: Mon, 8 Sep 2008 13:42:59 +0200
Message-ID: <20080908114258.GA29477@google.com>
References: <20080908020420.313463898@vergenet.net> <f4845fc0809080303s53094205kc045e6003014cd24@mail.gmail.com> <20080908104120.GB5795@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220874186; bh=Uy0eEuDC6kSEdgGsgb/BVytA/B4=;
	h=DomainKey-Signature:Date:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:
	 User-Agent:From; b=swgQxR2kXRHbvehuvQCDTZ3hRmej9nvdXH168DW0Hltef2m
	5DSuGWCxg3Ly6gTbZniWI4H3vPvAMxlGZqyuzeQ==
Content-Disposition: inline
In-Reply-To: <20080908104120.GB5795@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Siim =?iso-8859-1?Q?P=F5der?= <siim@p6drad-teel.net>, Julian Anastasov <ja@ssi.bg>, Malcolm Turnbull <malcolm@loadbalancer.org>, Vince Busam <vbusam@google.com>, Herbert Xu <herbert@gondor.apana.org.au>

On Mon, Sep 08, 2008 at 08:41:22PM +1000, Simon Horman wrote:
> On Mon, Sep 08, 2008 at 12:03:04PM +0200, Julius Volz wrote:
> > On Mon, Sep 8, 2008 at 4:04 AM, Simon Horman wrote:
> > > Hi,
> > >
> > > The impetus for this series of patches is Julian Anastasov noting
> > > that "load balance IPv4 connections from a local process" checks
> > > for 0 TCP checksums. Herbert Xu confirmed that this is not legal,
> > > even on loopback traffic, but that rather partial checksums are
> > > possible.
> > >
> > > The first patch in this series is a proposed solution to handle
> > > partial checksums for both TCP and UDP.
> > >
> > > The other two patches clean things up a bit.
> > >
> > > I have not tested this code beyond compilation yet.
> > 
> > After some first tests, remote connections are still working, but not
> > local ones from the director. The TCP handshake works and the
> > connection is established, but all following packets arriving at the
> > real server have an incorrect TCP checksum.
> > 
> > Btw., this happens both with and without this last series of patches,
> > so I can't get the local client feature working at all. Looking at it
> > further...
> 
> Ok, is this for both IPv4 & IPv6? Does it still occur with just the first
> patch in this series applied?

It's for both, although I only tested IPv4 at first. Here is a complete
test matrix of what works when:

CR = connection refused
T = connection timeout
C = connection established, but not working afterwards
OK = working

			remote client |	local client
COMMIT			v4	v6    |	v4	v6
======================================|=================
CSUM 3/3		OK	T     |	C	T
CSUM 2/3		OK	T     |	C	T
CSUM 1/3		OK	T     |	OK	T
W/O CSUM		OK	T     |	C	T
...				      |
f2428ed5		OK	T     |	CR	CR
4856c84c		OK	CR    |	CR	CR
f94fd041 (my last one)	OK	OK    |	CR	CR

So the last time that IPv6 was working _at all_ was at my last commit of
the big v6 series...

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
