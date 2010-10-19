From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [patch v5 04/12] IPVS: Add struct ip_vs_conn_param, IPv6 forgotten No
Date: Tue, 19 Oct 2010 11:56:43 +0200
Message-ID: <201010191156.44757.hans.schillstrom@ericsson.com>
References: <20101004134624.963907470@akiko.akashicho.tokyo.vergenet.net> <20101004134825.963640441@akiko.akashicho.tokyo.vergenet.net> <201010191141.22496.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <201010191141.22496.hans.schillstrom@ericsson.com>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "netfilter@vger.kernel.org" <netfilter@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, Jan Engelhardt <jengelh@medozas.de>, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

Hi Simon
I'm sorry it's not a bug it works perfectly OK.
(I didn't see that it was a pointer, It was another bug in my test code...)
so forget about the last mail

On Tuesday 19 October 2010 11:41:21 Hans Schillstrom wrote:
> Hi Simon,
> There is a show stopper for IPv6 in this patch.
> ip_vs_conn_fill_param() doesn't handle IPv6.
>
> On Monday 04 October 2010 15:46:28 Simon Horman wrote:
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> > Acked-by: Julian Anastasov <ja@ssi.bg>
> >
> > ---
> >
> > The motivation for this is to allow persistence engine modules to
> > fill in the parameters.


--
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
