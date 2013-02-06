From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] ipvs: sctp: fix checksumming on snat and dnat handlers
Date: Wed, 6 Feb 2013 09:18:53 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7137@saturn3.aculab.com>
References: <1360113878-31051-1-git-send-email-horms@verge.net.au> <1360113878-31051-2-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <1360113878-31051-2-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Daniel Borkmann <dborkman@redhat.com>

> From: Daniel Borkmann <dborkman@redhat.com>
> 
> In our test lab, we have a simple SCTP client connecting to a SCTP
> server via an IPVS load balancer. On some machines, load balancing
> works, but on others the initial handshake just fails, thus no
> SCTP connection whatsoever can be established!
> 
> We observed that the SCTP INIT-ACK handshake reply from the IPVS
> machine to the client had a correct IP checksum, but corrupt SCTP
> checksum when forwarded, thus on the client-side the packet was
> dropped and an intial handshake retriggered until all attempts
> run into the void.
> 
> To fix this issue, this patch i) adds a missing CHECKSUM_UNNECESSARY
> after the full checksum (re-)calculation (as done in IPVS TCP and UDP
> code as well), ii) calculates the checksum in little-endian format
> (as fixed with the SCTP code in commit 4458f04c: sctp: Clean up sctp
> checksumming code) and iii) refactors duplicate checksum code into a
> common function. Tested by myself.

If the NAT code has only modified a few bytes inside one of the SCTP
chunks, then the crc can be modified by knowing the changed bits and
the number of bytes to the end of the chunk (without looking at
any other data bytes).
That would (probably) be faster (may not really matter for INIT-ACK.

	David



