From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: IPVS: sync_options needed (removal of some code...)?
Date: Thu, 28 Oct 2010 23:45:50 +0200
Message-ID: <201010282345.51335.hans@schillstrom.com>
References: <201010281118.56983.hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1010282319570.1744@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1010282319570.1744@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, Simon Horman <horms@verge.net.au>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>


On Thursday, October 28, 2010 22:29:14 Julian Anastasov wrote:
> 
>  	Hello,
> 
> On Thu, 28 Oct 2010, Hans Schillstrom wrote:
> 
> > Hello
> > do we really need sync_options any more ?
> > (tcp seq re-calc)
> >
> > I might be blid, but I can't see anyone use it.
> > ip_vs_ftp_in() and ip_vs_ftp_out() do set diff=0 and never change them.
> 
>  	Yes, sync for FTP is not supported anymore
> starting from 2.6.36 :( But I'm not sure if any third party
> IPVS modules exists, it is possible other apps to use
> sync and sync_options.

OK, we leave it for now

> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>

Regards
Hans Schillstrom <hans@schillstrom.com>
