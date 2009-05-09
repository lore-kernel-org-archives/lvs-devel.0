From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ldirectord: Allow sending email via external SMTP
	server
Date: Sat, 9 May 2009 12:05:01 +1000
Message-ID: <20090509020458.GA11404@verge.net.au>
References: <33afbbe70904271254j17e1896fqdb51e88ebd71b2b7@mail.gmail.com> <20090428062636.GB19369@verge.net.au> <33afbbe70904280647x33fafef1w258303ebe4eec313@mail.gmail.com> <20090428151120.GB8377@verge.net.au> <33afbbe70905011242m2423ff3eg4606d7d0ef287387@mail.gmail.com> <20090505124718.GC19402@verge.net.au> <33afbbe70905071309m3cd9e124u95169563460397ce@mail.gmail.com> <20090508002852.GL10892@verge.net.au> <33afbbe70905080638u4d6959fdoa4770e86b876c924@mail.gmail.com> <20090508152657.GB17812@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090508152657.GB17812@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Caleb Anthony <caleb.anthony@gmail.com>
Cc: lvs-devel@vger.kernel.org

On Sat, May 09, 2009 at 01:26:57AM +1000, Simon Horman wrote:
> On Fri, May 08, 2009 at 07:38:34AM -0600, Caleb Anthony wrote:
> > It's fairly well tested. I tried to break it as much as I could -
> > setting an unreachable SMTP server, setting an invalid SMTP server
> > address, sending a ton of e-mails with the code by starting, stopping,
> > adding and removing real servers, etc. I'm going to put it into
> > production on a few IPVS directors I have here. I can report back in
> > about a week if you would like.
> > 
> > Also, there needs to be one addition to the ld_emailalert_net_smtp
> > sub. The ld_emailalert_mail_send sub logs a message in ldirectord.log
> > once an email is sent: &ld_log("emailalert: $subject");. I meant to
> > include that same line in ld_emailalert_net_smtp so that each sub
> > would be as similar as possible.
> > 
> > Could you add that line to ld_emailalert_net_smtp before you commit?

I have moved the &ld_log() call to the parent function applied the change.

http://hg.linux-ha.org/dev/rev/fdd0e04fb520

If any further changes/fixes are needed please make them
as an additional patch.

Thanks

