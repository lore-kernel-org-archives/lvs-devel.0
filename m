From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [RFC PATCH 0/4] IPVS: Backup Adding Ipv6 and Persistence support
Date: Wed, 27 Oct 2010 14:33:06 +0200
Message-ID: <201010271433.06982.hans.schillstrom@ericsson.com>
References: <201010261300.09827.hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1010262331200.1928@ja.ssi.bg> <201010271119.21590.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <201010271119.21590.hans.schillstrom@ericsson.com>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, Daniel Lezcano <daniel.lezcano@free.fr>

Hello
Some small changes, ...

On Wednesday 27 October 2010 11:19:20 Hans Schillstrom wrote:
> Hello
>
> On Tuesday 26 October 2010 23:25:10 Julian Anastasov wrote:
> >
> >  	Hello,
[snip]
>
> /* Option types */
> #define IPVS_OPT_SEQ_DATA    1
> #define IPVS_OPT_PE_DATA     2
> #define IPVS_OPT_PE_NAME     3
>
>
> >  	By this way later we can add more parameters. If we
> > want master to specify that some parameter is optional
> > we can allocate 1 bit (bit 7) in 'type' for this. Most
> > of the parameters must be supported by backup server.
> > If backup does not recognize some type it will skip the
> > connection entry if bit 7 is not set.
> >
> A New Spec of Type field:
>
> Bit    7        6        . . .      2         1           0
>   +----------+--------------------------+-------------+-------+
>   | Opt.Data |          Spare           | Packed IPv6 |  IPv6 |
>   +----------+--------------------------+-------------+-------+

I can see a better usage of it in Option Type so Type will look like this
    +-------------------------------------+-------------+-------+
    |                     Spare           | Packed IPv6 |  IPv6 |
    +-------------------------------------+-------------+-------+

And "Option Type" in option field would look like this

 Bit    7        6        . . .    0    7                      0
   +----------+----------------------+---------------------------+
   | Optional |      Option type     |    Option length          |
   +----------+----------------------+---------------------------+

We can have a better fine tuning of options in this way.

I.e. as Julian wrote but transferd to Option Type:

" If backup does not recognize some type it will skip the
  connection entry if bit 7 is not set."

--
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
