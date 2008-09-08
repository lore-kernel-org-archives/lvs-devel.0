From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] IPVS: Remove incorrect ip_route_me_harder(), fix IPv6
Date: Tue, 9 Sep 2008 09:44:10 +1000
Message-ID: <20080908234409.GG13048@verge.net.au>
References: <1220878542-1864-1-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1220878542-1864-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, siim@p6drad-teel.net, ja@ssi.bg, malcolm@loadbalancer.org, vbusam@google.com, herbert@gondor.apana.org.au

On Mon, Sep 08, 2008 at 02:55:42PM +0200, Julius Volz wrote:
> Remove an incorrect ip_route_me_harder() that was probably a result of
> merging my IPv6 patches with the local client patches. With this, IPv6+NAT
> are working again.

Hi Julius,

I have applied this to lvs-next-2.6, along with my first CSUM patch,
as we discussed.
