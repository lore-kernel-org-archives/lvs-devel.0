From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH RFC 19/24] IPVS: Add IPv6 support flag to schedulers
Date: Thu, 21 Aug 2008 23:23:11 +1000
Message-ID: <20080821132309.GA13563@verge.net.au>
References: <1219248931-15064-1-git-send-email-juliusv@google.com> <1219248931-15064-20-git-send-email-juliusv@google.com> <20080821014813.GH19235@verge.net.au> <f4845fc0808210321m342f2504i69d01c6b33298fc7@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f4845fc0808210321m342f2504i69d01c6b33298fc7@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Thu, Aug 21, 2008 at 12:21:39PM +0200, Julius Volz wrote:
> On Thu, Aug 21, 2008 at 3:48 AM, Simon Horman wrote:
> > On Wed, Aug 20, 2008 at 06:15:26PM +0200, Julius Volz wrote:
> >> Add 'supports_ipv6' flag to struct ip_vs_scheduler to indicate whether a
> >> scheduler supports IPv6. Set the flag to 1 in schedulers that work with
> >> IPv6, 0 otherwise. This flag is checked in a later patch while trying to
> >> add a service with a specific scheduler.
> >
> > I wonder if there are some spare bits inside the flags
> > member of ip_vs_scheduler that could be used for this purpose?
> 
> Hm, there isn't any 'flags' member or similar in that struct...
> 
> > Otherwise, I'm fine with this, we can juggle things around
> > later to use the other bits in supports_ipv6 for other things
> > if and when the need arises.
> 
> Yes, then we could also rename it to 'flags' once needed.
> 
> > Here is a version that applies against lvs-2.6
> 
> Thanks, I guess I should start basing all of my IPVS patches on this
> tree rather than net-2.6?

That would make things slightly more convenient for me.
But I'm not the only fish in the sea :-)

