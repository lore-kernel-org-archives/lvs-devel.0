From: Simon Horman <horms@verge.net.au>
Subject: Re: Should we move IPVS out of net/ipv4 now?
Date: Fri, 19 Sep 2008 09:52:22 +1000
Message-ID: <20080918235220.GD13536@verge.net.au>
References: <f4845fc0809170600s28495494l128f7dd6f00e34e3@mail.gmail.com> <48D14E6D.4020407@redhat.com> <20080917.131445.19943427.davem@davemloft.net> <f4845fc0809181304y25e3df07xfde0f23406b519a2@mail.gmail.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f4845fc0809181304y25e3df07xfde0f23406b519a2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: David Miller <davem@davemloft.net>, csnook@redhat.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Thu, Sep 18, 2008 at 10:04:28PM +0200, Julius Volz wrote:
> On Wed, Sep 17, 2008 at 10:14 PM, David Miller wrote:
> > From: Chris Snook <csnook@redhat.com>
> > Date: Wed, 17 Sep 2008 14:37:33 -0400
> >
> >> Julius Volz wrote:
> >> > Since IPVS now does partial IPv6, should we finally move it from
> >> > "net/ipv4/ipvs" to "net" or to "net/netfilter"? I posted that patch a
> >> > long time ago, but that was before any of the actual v6 features, so
> >> > there was probably no interest.
> >>
> >> Whatever the netfilter people want is fine with me.
> >
> > I think, especially in the long term, putting IPVS under net/netfilter/
> > is the right thing to do.
> 
> Ok thanks, I'll send the patch for that once lvs-next-2.6 or
> net-next-2.6 builds for ARCH=um again (there seems to be some breakage
> at the moment)...

Once net-next-2.6 is working again, let me know and I'll pull it
into lvs-next-2.6.

-- 
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

