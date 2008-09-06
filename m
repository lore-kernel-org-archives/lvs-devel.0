From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: Use pointer to address from sync message
Date: Sat, 6 Sep 2008 14:26:11 +1000
Message-ID: <20080906042610.GC21521@verge.net.au>
References: <1220363755-9854-1-git-send-email-juliusv@google.com> <1220363755-9854-13-git-send-email-juliusv@google.com> <alpine.LNX.2.00.0809051342360.18192@titan.stealer.net> <f4845fc0809050528q253789fbi60ca6c229a08d8ab@mail.gmail.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f4845fc0809050528q253789fbi60ca6c229a08d8ab@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: Sven Wegener <sven.wegener@stealer.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Fri, Sep 05, 2008 at 02:28:48PM +0200, Julius Volz wrote:
> On Fri, Sep 5, 2008 at 1:46 PM, Sven Wegener <sven.wegener@stealer.net> wrote:
> > We want a pointer to it, not the value casted to a pointer.
> 
> Ouch, right!
> 
> > Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
> > ---
> >  net/ipv4/ipvs/ip_vs_sync.c |    6 +++---
> >  1 files changed, 3 insertions(+), 3 deletions(-)
> >
> > I've been too late with having a look at these patches. I'm going to
> > send follow-up patches for the issues I find.

Sven, as always thanks very much for your patches.

> Thanks! There are probably still lots of these easy-to-miss (but bad)
> bugs in this big new bunch of code...
> 
> > Simon, please apply onto lvs-next-2.6.
> 
> Yes!

Julius, can I take that as an Acked-by for the follwing changes?

[PATCH] ipvs: Use pointer to address from sync message
[PATCH] ipvs: Return negative error values from
[PATCH] ipvs: Mark tcp/udp v4 and v6 debug functions static
[PATCH] ipvs: Reject ipv6 link-local addresses for destinations

