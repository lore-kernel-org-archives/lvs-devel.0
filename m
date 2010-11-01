From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [v2 PATCH 0/4] IPVS: Backup Adding Ipv6 and Persistence support
Date: Mon, 1 Nov 2010 16:30:56 +0100
Message-ID: <201011011630.57467.hans.schillstrom@ericsson.com>
References: <201010291415.35299.hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1010301741280.2294@ja.ssi.bg> <20101030231601.GA5908@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20101030231601.GA5908@verge.net.au>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>
Cc: LVS-Devel <lvs-devel@vger.kernel.org>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>


On Sunday 31 October 2010 01:16:02 Simon Horman wrote:
> On Sat, Oct 30, 2010 at 05:55:32PM +0300, Julian Anastasov wrote:
> >
> > 	Hello,
> >
> > On Fri, 29 Oct 2010, Hans Schillstrom wrote:
[ snip ]
> >
> > 	Simon should tell what happens if some PE updates
> > 	ct->pe_data, may be we should replace it too for the
> > 	case when ip_vs_proc_conn works with existing template?
>
> 	At this stage there is no facility for updating PE data.
> 	But I think replacing it should be fine, so long as
> 	the appropriate locking is in place.

Julian,
I can't see where this could happen,
 but I might be out of sync :-)

IF this an issue that we must take care of,
  (Then I'm a little bit lost)
  could you please explain it for me or pass a code example of how to do it.
ENDIF
--
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
