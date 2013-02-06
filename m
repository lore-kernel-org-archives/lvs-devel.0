From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] ipvs: sctp: fix checksumming on snat and dnat handlers
Date: Wed, 06 Feb 2013 12:20:57 +0100
Message-ID: <51123C99.6010402@redhat.com>
References: <1360113878-31051-1-git-send-email-horms@verge.net.au> <1360113878-31051-2-git-send-email-horms@verge.net.au> <AE90C24D6B3A694183C094C60CF0A2F6026B7137@saturn3.aculab.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7137@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: David Laight <David.Laight@ACULAB.COM>
Cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On 02/06/2013 10:18 AM, David Laight wrote:
> If the NAT code has only modified a few bytes inside one of the SCTP
> chunks, then the crc can be modified by knowing the changed bits and
> the number of bytes to the end of the chunk (without looking at
> any other data bytes).
> That would (probably) be faster (may not really matter for INIT-ACK.

If applicable, this could be a follow-up optimization after the bug fix.
