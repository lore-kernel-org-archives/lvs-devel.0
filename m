From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH RFC 00/24] IPVS: Add first IPv6 support to IPVS
Date: Fri, 22 Aug 2008 07:29:50 +1000
Message-ID: <20080821212948.GB4407@verge.net.au>
References: <1219248931-15064-1-git-send-email-juliusv@google.com> <20080821011715.GG19235@verge.net.au> <f4845fc0808210259n2b4bbd41tb0a93c49592a2029@mail.gmail.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f4845fc0808210259n2b4bbd41tb0a93c49592a2029@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com, Sven Wegener <sven.wegener@stealer.net>

On Thu, Aug 21, 2008 at 11:59:44AM +0200, Julius Volz wrote:
> On Thu, Aug 21, 2008 at 3:17 AM, Simon Horman <horms@verge.net.au> wrote:
> > On Wed, Aug 20, 2008 at 06:15:07PM +0200, Julius Volz wrote:
> >> What is not supported with IPv6:
> >> - handling fragmentation or other extension headers
> >> - FTP application helper (can be loaded, but only operates on v4)
> >> - sync daemon (can be started, but only operates on v4)
> >
> > Other than the packet format of the sync deamon, are there any
> > fundamental restrictions here? If we extended the sync daemon,
> > could it work? If so, perhaps we could rev the sync deamon protocol
> > and fix a few other kinks, like the handling of timeouts and the
> > general lack of extendability, at the same time.
> 
> There shouldn't be any fundamental restrictions, it's just a piece of
> the puzzle that I could easily leave out of the picture for now.
> 
> I haven't studied the sync daemon closely yet, but one thing I was
> briefly wondering about was whether we should just blow up the
> addresses in struct ip_vs_sync_conn to be of type union nf_inet_addr
> (probably not acceptable, wasting too much bandwidth for v4 entries)
> or how to send differently sized entries based on the IP version in a
> clean way. But it sounds like you'd want to redesign a lot of that
> anyways? I'm glad to help with anything, I just don't know this code
> as well as you or Sven, but I'll study it more. Maybe you can share
> some ideas on the extensibility you want to see?

What I was thinking is that any change 
> 
> >> Thanks for any comments!
> >
> > Unfortunately (or fortunately depending on how you look at it),
> > I'm going to be away skiing for the next couple of days. Apologies
> > for the slow responses that will lead to.
> 
> Have fun! And be careful, we need you to come back healthy :)

Thanks.

Here are a few thoughts I have had in my breif overview of the code so far
- mainly just simple style things. If any of my comments are obviously
stupid, please just say so as I haven't got to the end of the series yet
and I'm sure some of my questions are answered in the code.

[PATCH RFC 01/24] IPVS: Add genetlink interface definitions to ip_vs.h
[PATCH RFC 02/24] IPVS: Add genetlink interface implementation

* Already in lvs-2.6. Are there any changes?

[PATCH RFC 02/24] IPVS: Add genetlink interface implementation

* What is IP_VS = IPV6 ?

[PATCH RFC 04/24] IPVS: Change IPVS data structures to support IPv6 addresses

* Indentation of af in struct ip_vs_conn seems inconsistent with other
  elements.

[PATCH RFC 05/24] IPVS: Add general v4/v6 helper functions / data structures

* Use of p ? a : b construct in ip_vs_addr_equal() seems a bit aquard.
  How about

static inline int ip_vs_addr_equal(int af, const union nf_inet_addr *a,
				   const union nf_inet_addr *b)
{
#ifdef CONFIG_IP_VS_IPV6
	if (af == AF_INET)
		return ipv6_addr_equal(&a->in6, &b->in6);
#endif
	return a->ip == b->ip;
}


