From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH RFC 00/24] IPVS: Add first IPv6 support to IPVS
Date: Fri, 22 Aug 2008 08:05:19 +1000
Message-ID: <20080821220444.GA2758@verge.net.au>
References: <1219248931-15064-1-git-send-email-juliusv@google.com> <20080821011715.GG19235@verge.net.au> <f4845fc0808210259n2b4bbd41tb0a93c49592a2029@mail.gmail.com> <20080821212948.GB4407@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080821212948.GB4407@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com, Sven Wegener <sven.wegener@stealer.net>

On 金,  8月 22, 2008 at 07:29:50午前 +1000, Simon Horman wrote:
> On Thu, Aug 21, 2008 at 11:59:44AM +0200, Julius Volz wrote:
> > On Thu, Aug 21, 2008 at 3:17 AM, Simon Horman <horms@verge.net.au> wrote:
> > > On Wed, Aug 20, 2008 at 06:15:07PM +0200, Julius Volz wrote:
> > >> What is not supported with IPv6:
> > >> - handling fragmentation or other extension headers
> > >> - FTP application helper (can be loaded, but only operates on v4)
> > >> - sync daemon (can be started, but only operates on v4)
> > >
> > > Other than the packet format of the sync deamon, are there any
> > > fundamental restrictions here? If we extended the sync daemon,
> > > could it work? If so, perhaps we could rev the sync deamon protocol
> > > and fix a few other kinks, like the handling of timeouts and the
> > > general lack of extendability, at the same time.
> > 
> > There shouldn't be any fundamental restrictions, it's just a piece of
> > the puzzle that I could easily leave out of the picture for now.
> > 
> > I haven't studied the sync daemon closely yet, but one thing I was
> > briefly wondering about was whether we should just blow up the
> > addresses in struct ip_vs_sync_conn to be of type union nf_inet_addr
> > (probably not acceptable, wasting too much bandwidth for v4 entries)
> > or how to send differently sized entries based on the IP version in a
> > clean way. But it sounds like you'd want to redesign a lot of that
> > anyways? I'm glad to help with anything, I just don't know this code
> > as well as you or Sven, but I'll study it more. Maybe you can share
> > some ideas on the extensibility you want to see?
> 
> What I was thinking is that any change 

Sorry, I forgot to finish this sentance :-(

What I was thinking was that any change would introduce a
protocol incompatibility. However I think that there is
some room for small changes to be added using currently unsued
bits in ip_vs_sync_conn.flags. This could also be used to
allow syncryonising of timeouts (which is unrelated to IPv6).

So while my general feeling that the synchronisation protocol
is not as extendable as it should be stands. We can probably
work with the current protocol for now.



