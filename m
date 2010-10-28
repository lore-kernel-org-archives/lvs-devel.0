From: Julian Anastasov <ja@ssi.bg>
Subject: Re: IPVS: sync_options needed (removal of some code...)?
Date: Thu, 28 Oct 2010 23:29:14 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1010282319570.1744@ja.ssi.bg>
References: <201010281118.56983.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <201010281118.56983.hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: Simon Horman <horms@verge.net.au>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>


 	Hello,

On Thu, 28 Oct 2010, Hans Schillstrom wrote:

> Hello
> do we really need sync_options any more ?
> (tcp seq re-calc)
>
> I might be blid, but I can't see anyone use it.
> ip_vs_ftp_in() and ip_vs_ftp_out() do set diff=0 and never change them.

 	Yes, sync for FTP is not supported anymore
starting from 2.6.36 :( But I'm not sure if any third party
IPVS modules exists, it is possible other apps to use
sync and sync_options.

Regards

--
Julian Anastasov <ja@ssi.bg>
