From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Fri, 13 Jun 2008 16:26:23 +1000
Message-ID: <20080613062621.GA10474@verge.net.au>
References: <f4845fc0806111314r41e7736ay54d22cf28efa2d27@mail.gmail.com> <48503BBD.6000307@google.com> <485043E6.5030105@candelatech.com> <485050FE.6030209@google.com> <20080612014548.GE22358@verge.net.au> <f4845fc0806120631g511c7dbag365a8483134943fd@mail.gmail.com> <485126BD.7030109@trash.net> <f4845fc0806120834xd904f45x19e100c832d3417@mail.gmail.com> <485144DF.3030102@trash.net> <f4845fc0806121233i54099a18k9104eb34359b923f@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f4845fc0806121233i54099a18k9104eb34359b923f@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: Patrick McHardy <kaber@trash.net>, Vince Busam <vbusam@google.com>, Ben Greear <greearb@candelatech.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Thu, Jun 12, 2008 at 09:33:27PM +0200, Julius Volz wrote:
> On Thu, Jun 12, 2008, Patrick McHardy <kaber@trash.net> wrote:
> > Julius Volz wrote:
> >> Ah, that's what I thought... Are there any simple kernel examples with
> >> userspace counterparts to look at? I know iproute2 uses netlink, but
> >> it seems like a rather complicated example.
> >
> > For nfnetlink: net/netfilter/nf_conntrack_netlink.c and
> > libnfnetlink_conntrack from git.netfilter.org.
> 
> Thanks!
> 
> >> Genetlink seems especially nice, although I couldn't find a general
> >> explanation of it other than in git history.
> >
> > I don't have an example for genetlink, but I guess you should
> > find some in libnl. In this case I guess both would be fine
> > since ipvs is only loosely tied to the rest of netfilter.
> 
> Ok, my first impression is that genetlink is aimed at being simple to
> use (and has a nice howto).
> 
> So we'll work on a genetlink interface and some of the other v6 patch
> issues and then post again in a while. Thanks for the feedback!
> 
> Horms: ping if you're interested or have some good ideas for this.

Julius: pong

The main two problems that I see in the existing interface are
a) lack of extendibility (which is why we are here) and;
b) non-idempotent actions, especially adding and deleting
   real servers, which mean that user-space programs that
   manipulate ipvsadm have have extra (racy) logic.
   (ok, perhaps that is more a pet peeve than a problem).

I don't really have any concrete ideas about what a better
interface would look like. But I am more than happy to hash our ideas.

-- 
Horms

