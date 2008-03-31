From: Simon Horman <horms@verge.net.au>
Subject: Re: Making IPVS work with IPv6
Date: Mon, 31 Mar 2008 22:28:13 +0900
Message-ID: <20080331132810.GA3690@verge.net.au>
References: <f4845fc0803280845n6a4d8683gffe95c8d64572971@mail.gmail.com> <Pine.LNX.4.64.0803280853110.28825@wm7d.net> <20080331030715.GH31306@verge.net.au> <Pine.LNX.4.64.0803310441440.9996@wm7d.net> <f4845fc0803310549m73294fb7u68e2a1655960b135@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f4845fc0803310549m73294fb7u68e2a1655960b135@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: Joseph Mack NA3T <jmack@wm7d.net>, lvs-devel@vger.kernel.org

On Mon, Mar 31, 2008 at 02:49:33PM +0200, Julius Volz wrote:
> On Mon, Mar 31, 2008, Joseph Mack NA3T <jmack@wm7d.net> wrote:
> > On Mon, 31 Mar 2008, Simon Horman wrote:
> >
> >  > [ Joe, I'm not sure that the LOCAL_IN stuff is really related
> >  >  specifically to IPv6. But you do remind me that those patches
> >  >  need to be revisited. ]
> >
> >  Agree, but we don't want Julius writing code for LOCAL_IN at
> >  the same time we're moving the hook elsewhere.
> 
> Horms, when you take the mentioned patch, in which repository will it
> go to first? In other words, which tree should I be using as my base
> to always be up to date? Some netdev git repo or just Linus' main one
> (git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git)?

IPVS patches almost always go through netdev and Dave Miller.
Dave has a two tree system that works as follows (as far as I
understand):

Suppose that the current version that Linus's tree is working towards
is 2.6.24. Then Dave's net-2.6.24 tree would be for bug fixes and
his net-2.6.25 tree would be for new features.

Once Linus releases 2.6.24 then his merge window for will 2.6.25 open
and likely stay open for a couple of weeks. I think that at that
time Dave's net-2.6.24 will be removed and net-2.6.25 will be merged
into Linus's tree. Once the merge window is closed and Linus's tree
is working towards 2.6.25 then net-2.6.25 will become the bugfixes
tree for netdev and net-2.6.26 will be creted to accept new work.

Repeat...


So with a bit of luck the LOCAL_IN stuff might go into net-2.6.26
(I think it would be pushing it to get it into net-2.6.25). In any
case, if you subscribe to this list (which is rather low volume),
then you will probably see any discussions that are going on.

-- 
Horms

