From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: [RFC PATCH 0/4] IPVS: Backup Adding Ipv6 and Persistence support
Date: Thu, 28 Oct 2010 23:50:15 +0200
Message-ID: <201010282350.15911.hans@schillstrom.com>
References: <201010261300.09827.hans.schillstrom@ericsson.com> <20101028113511.GA13986@verge.net.au> <alpine.LFD.2.00.1010282349030.1744@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1010282349030.1744@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, Hans Schillstrom <hans.schillstrom@ericsson.com>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, Daniel Lezcano <daniel.lezcano@free.fr>

Hello

On Thursday, October 28, 2010 23:07:30 Julian Anastasov wrote:
> 
>  	Hello,
> 
> On Thu, 28 Oct 2010, Simon Horman wrote:
> 
> > As it stands a little more than 256 bytes may be needed for
> > pe_data (+ pe_name_length + pe_name). This could be resolved by
> > shortening the maximum pe_data length. Or perhaps we could use 16 bytes for
> > Option length, which should ensure its never too small.
> >
> > The 256 byte limit that I made for pe_data was arbitrarily chosen.
> 
>  	Yes, this is a problem.
> 
> >>> We can have a better fine tuning of options in this way.
> >>
> >> 	Yes, that is exactly my idea. I more like the name
> >> "Parameter" instead of "Option", i.e. we have additional
> >> parameters that can be mandatory (usually) but also can be
> >> optional. For now I don't have idea for any optional
> >> parameters but allocating 1 bit for this does not look
> >> fatal.
> >
> > I'm not sure I understand the motivation for optional parameters.
> > I think its important to allow for backwards compatibility. But
> > I don't see that there will be multiple independent implementations
> > of the synchronisation daemon in the near future. So the use-case
> > isn't clear to me.
> 
>  	If we want to support optional parameters they
> must have some known length field, 16 bits if needed.
> But if we don't want such optional parameters then
> we can just use single octet for parameter type
> which can imply the length of the following data. 
> Types that have data with variable length should provide
> 1 or 2 octets after the parameter type for their length.
> So, the parsing should be per-type. If one day
> we need optional parameters we can just add 1 octet for
> type and 2 for length before data.
> 
>  	For example, ip_vs_sync_conn_options if implemented
> as parameter can be coded with 1 octet for type and the
> following data structure. OTOH, PE params can use 1 octet
> for type, 2 for length (read with get_unaligned_be16) and
> then data.

OK, a minor change in length check only.
For todays known types one byte is ok, since pe data willbe splitted.

> 
> > That said, I agree that allocating 1 bit isn't a show-stopper.
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>

Regars 
Hans Schillstrom <hans@schillstrom.com>

