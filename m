From: Jason Stubbs <j.stubbs@linkthink.co.jp>
Subject: Re: [PATCH] Move IPVS from net/ipv4/ipvs to net/netfilter/ipvs in preparation for IPv6 support
Date: Fri, 11 Apr 2008 19:24:16 +0900
Message-ID: <200804111924.16263.j.stubbs@linkthink.co.jp>
References: <f4845fc0804040340x5e93754crcd680d26fd8982f7@mail.gmail.com> <20080405010707.GB27827@verge.net.au> <f4845fc0804110254s79eb6889sa654fc5d019db030@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <f4845fc0804110254s79eb6889sa654fc5d019db030@mail.gmail.com>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Julius Volz <juliusv@google.com>
Cc: lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>

On Friday 11 April 2008 18:54:44 Julius Volz wrote:
> Hi Horms,
>
> On Sat, Apr 5, 2008, Simon Horman wrote:
> > On Fri, Apr 04, 2008 at 12:40:36PM +0200, Julius Volz wrote:
> >  > Hi,
> >  >
> >  > This patch moves IPVS from net/ipv4/ipvs to net/netfilter/ipvs, =
as
> >  > discussed earlier with Horms and Patrick McHardy. This is done a=
s a
> >  > preparation for later adding IPv6 functionality to IPVS. The pat=
ch is
> >  > 600kb, so I uploaded it here:
> >  >
> >  > http://www-user.tu-chemnitz.de/~volz/move_ipvs_to_netfilter.patc=
h
> >  >
> >  > [...]
> >
> >  Thanks, I've grabbed the patch and will review it ASAP.
> >  I am going to be mostly offline for about 5 days as I am moving.
> >  So I apologise in advance for being a bit undresponsive during tha=
t
> > time.
>
> Hope your move went ok!
>
> Any news on this? Should I redo the patch on top of Jason's
> POST/PREROUTING patch or should that go in later? Would be cool to ge=
t
> this directory move out of the way...

I'd suggest not waiting on my patch as there's still a few things that =
need to=20
be sorted out, tested and cleaned up. Not even certain that POST/PRE ar=
e the=20
best places yet... But thanks for the thought! :)

--=20
Jason Stubbs <j.stubbs@linkthink.co.jp>
LINKTHINK INC.
=E6=9D=B1=E4=BA=AC=E9=83=BD=E6=B8=8B=E8=B0=B7=E5=8C=BA=E6=A1=9C=E3=83=B6=
=E4=B8=98=E7=94=BA22-14 N.E.S S=E6=A3=9F 3F
TEL 03-5728-4772  FAX 03-5728-4773
