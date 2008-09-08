From: Simon Horman <horms@verge.net.au>
Subject: Re: [rfc 0/3] IPVS: checksum updates
Date: Tue, 9 Sep 2008 09:40:29 +1000
Message-ID: <20080908234028.GF13048@verge.net.au>
References: <20080908020420.313463898@vergenet.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080908020420.313463898@vergenet.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Siim =?iso-8859-1?Q?P=F5der?= <siim@p6drad-teel.net>, Julian Anastasov <ja@ssi.bg>, Malcolm Turnbull <malcolm@loadbalancer.org>, Julius Volz <juliusv@google.com>, Vince Busam <vbusam@google.com>, Herbert Xu <herbert@gondor.apana.org.au>

On Mon, Sep 08, 2008 at 12:04:20PM +1000, Simon Horman wrote:
> Hi,
> 
> The impetus for this series of patches is Julian Anastasov noting
> that "load balance IPv4 connections from a local process" checks
> for 0 TCP checksums. Herbert Xu confirmed that this is not legal,
> even on loopback traffic, but that rather partial checksums are
> possible.
> 
> The first patch in this series is a proposed solution to handle
> partial checksums for both TCP and UDP.
> 
> The other two patches clean things up a bit.
> 
> I have not tested this code beyond compilation yet.

After extensive testing by Julius Volz and limited testing by myself, I
have applied the first patch, which does indeed allow packets with
PARTIAL_CHECKSUM to work, to lvs-next-2.6. I have dropped the second two
patches which produce bogus checksums.

I will revisit the second to patches at some point and try and produce
versions that work.

