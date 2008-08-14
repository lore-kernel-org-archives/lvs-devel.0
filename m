From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCHv3 2/2] IPVS: Add genetlink interface implementation
Date: Fri, 15 Aug 2008 08:53:56 +1000
Message-ID: <20080814225354.GB15825@verge.net.au>
References: <1218120219-1117-1-git-send-email-juliusv@google.com> <1218120219-1117-3-git-send-email-juliusv@google.com> <20080808112937.GA32458@google.com> <alpine.LNX.1.10.0808132326310.12259@titan.stealer.net> <20080814093201.GA8046@google.com> <alpine.LNX.1.10.0808141144240.12259@titan.stealer.net> <20080814102719.GB8046@google.com> <20080814120843.GC8046@google.com> <alpine.LNX.1.10.0808141508370.12259@titan.stealer.net> <f4845fc0808140722j78698483wcf8d7a4b6bc5cc5a@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f4845fc0808140722j78698483wcf8d7a4b6bc5cc5a@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: Sven Wegener <sven.wegener@stealer.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, davem@davemloft.net, tgraf@suug.ch, vbusam@google.com

On Thu, Aug 14, 2008 at 04:22:33PM +0200, Julius Volz wrote:
> On Thu, Aug 14, 2008 at 3:32 PM, Sven Wegener <sven.wegener@stealer.net> wrote:
> > On Thu, 14 Aug 2008, Julius Volz wrote:
> >> Ok, fixed this up. The mutex is not completely moved down to make the
> >> code look a bit nicer (nla_put_failure assumes locked mutex). There
> >> should not be much concurrency anyways since this mutex only locks the
> >> userspace interface, which is mainly used by ipvsadm.
> >
> > True, it was just a hint for an optimization. Looks good to me.
> >
> > Acked-by: Sven Wegener <sven.wegener@stealer.net>
> 
> Thanks for the help with this!
> 
> > Should we get this into 2.6.27? It's a new interface, currently unused, so
> > the chance of breaking anything is marginal.
> 
> Yeah, it shouldn't break anything existing and that would be great!

Fine by me.
