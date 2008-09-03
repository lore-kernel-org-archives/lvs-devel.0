From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCHv2 RFC 13/25] IPVS: Add IPv6 support to xmit() support
	functions
Date: Wed, 3 Sep 2008 18:48:26 +1000
Message-ID: <20080903084824.GC7748@verge.net.au>
References: <1220273782-19901-1-git-send-email-juliusv@google.com> <1220273782-19901-14-git-send-email-juliusv@google.com> <20080902222814.GA6035@verge.net.au> <f4845fc0809030143k8126654k7d1c8e3d4c5d28a9@mail.gmail.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f4845fc0809030143k8126654k7d1c8e3d4c5d28a9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Wed, Sep 03, 2008 at 10:43:13AM +0200, Julius Volz wrote:
> On Wed, Sep 3, 2008 at 12:28 AM, Simon Horman <horms@verge.net.au> wrote:
> > On Mon, Sep 01, 2008 at 02:56:10PM +0200, Julius Volz wrote:
> >> Add IPv6 support to IP_VS_XMIT() and to the xmit routing cache, introducing
> >> a new function __ip_vs_get_out_rt_v6().
> >
> > Hi,
> >
> > sorry, I missed this one yesteray. Could you run checkpatch.pl over
> > this one also?
> 
> Yes, already cleaned up in the latest posted version (I ran
> checkpatch.pl over all patches yesterday).

Thanks. Sorry for not checking my inbox before posting.
