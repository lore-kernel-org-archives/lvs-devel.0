From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 2/2] ipvs: load balance ipv6 connections from a local
	process
Date: Mon, 8 Sep 2008 19:50:33 +1000
Message-ID: <20080908095032.GA5795@verge.net.au>
References: <20080905013609.GD14128@verge.net.au> <20080905013755.GE14128@verge.net.au> <f4845fc0809050440g24f304d9xec7982e984830c6e@mail.gmail.com> <20080906041436.GB21521@verge.net.au> <f4845fc0809060226g4ee00f4fs210ba76309130be7@mail.gmail.com> <20080908014806.GB16096@verge.net.au> <f4845fc0809080230o653cd743ib26544f2ccf6d36a@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f4845fc0809080230o653cd743ib26544f2ccf6d36a@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Malcolm Turnbull <malcolm@loadbalancer.org>, Siim =?iso-8859-1?Q?P=F5der?= <siim@p6drad-teel.net>, Vince Busam <vbusam@google.com>

On Mon, Sep 08, 2008 at 11:30:08AM +0200, Julius Volz wrote:
> On Mon, Sep 8, 2008 at 3:48 AM, Simon Horman <horms@verge.net.au> wrote:
> > On Sat, Sep 06, 2008 at 11:26:29AM +0200, Julius Volz wrote:
> >> On Sat, Sep 6, 2008 at 6:14 AM, Simon Horman <horms@verge.net.au> wrote:
> >> > On Fri, Sep 05, 2008 at 01:40:31PM +0200, Julius Volz wrote:
> >> >> Hi,
> >> >>
> >> >> Just some minor things:
> >> >
> >> > Hi Julius,
> >> >
> >> > thanks for pointing these out. I will send patches to fix these problems ASAP.
> >>
> >> Thanks, looking good!
> >
> > I took the liberty of taking that response as an Acked-by.
> > I've applied these minor changes now.
> >
> 
> Thanks! I'll remember to add an explicit Acked-by in the future.
> 
> I'll try out your new checksumming patches now and see if everything
> works for me (for both remote connections and ones from the
> director)...

Thanks, much appericated.

I'm also a little concerned about the handling of IPv6 ICMP in
this patch. In particular, we need to ensure that the pseudo-header
is included in the checksum. Which it may not be, as I based
the code on the IPv4 version.

http://rfc-ref.org/RFC-TEXTS/1883/chapter8.html#d4e447886
