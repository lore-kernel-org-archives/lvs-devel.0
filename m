From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH stable] ipvs: sctp: fix checksumming on snat and dnat
 handlers
Date: Mon, 25 Feb 2013 16:40:25 +0100
Message-ID: <20130225154025.GC20561@localhost>
References: <cover.1361451476.git.dborkman@redhat.com>
 <f904dab20914b562ad9c0baf0727971dc5a4b549.1361451476.git.dborkman@redhat.com>
 <20130221151451.GB2730@shamino.rdu.redhat.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130221151451.GB2730@shamino.rdu.redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Neil Horman <nhorman@tuxdriver.com>
Cc: Daniel Borkmann <dborkman@redhat.com>, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, linux-sctp@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

On Thu, Feb 21, 2013 at 10:14:51AM -0500, Neil Horman wrote:
> On Thu, Feb 21, 2013 at 02:05:39PM +0100, Daniel Borkmann wrote:
> > In our test lab, we have a simple SCTP client connecting to a SCTP
> > server via an IPVS load balancer. On some machines, load balancing
> > works, but on others the initial handshake just fails, thus no
> > SCTP connection whatsoever can be established!
> > 
> > We observed that the SCTP INIT-ACK handshake reply from the IPVS
> > machine to the client had a correct IP checksum, but corrupt SCTP
> > checksum when forwarded, thus on the client-side the packet was
> > dropped and an intial handshake retriggered until all attempts
> > run into the void.
> > 
> > To fix this issue, this patch i) adds a missing CHECKSUM_UNNECESSARY
> > after the full checksum (re-)calculation (as done in IPVS TCP and UDP
> > code as well), and ii) calculates the checksum in little-endian format
> > (as fixed with the SCTP code in commit 4458f04c: sctp: Clean up sctp
> > checksumming code). Stable backport of upstream commit 4b47bc9a.
> > 
> > Cc: Julian Anastasov <ja@ssi.bg>
> > Cc: Simon Horman <horms@verge.net.au>
> > Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> > Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
[...]
> Acked-by: Neil Horman <nhorman@tuxdriver.com>

Enqueued to -stable. Thanks.
