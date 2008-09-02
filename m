From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCHv2 RFC 02/25] IPVS: Change IPVS data structures to
	support IPv6 addresses
Date: Tue, 2 Sep 2008 16:08:40 +1000
Message-ID: <20080902060839.GD13730@verge.net.au>
References: <1220273782-19901-1-git-send-email-juliusv@google.com> <1220273782-19901-3-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1220273782-19901-3-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Mon, Sep 01, 2008 at 02:55:59PM +0200, Julius Volz wrote:
> Introduce new 'af' fields into IPVS data structures for specifying an
> entry's address family. Convert IP addresses to be of type union
> nf_inet_addr.

Could you please run this patch through ./scripts/checkpatch.pl,
it has flaged some whitespace issues for me.
