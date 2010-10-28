From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: IPVS: sync_options needed (removal of some code...)?
Date: Thu, 28 Oct 2010 11:18:56 +0200
Message-ID: <201010281118.56983.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>

Hello
do we really need sync_options any more ?
(tcp seq re-calc)

I might be blid, but I can't see anyone use it.
ip_vs_ftp_in() and ip_vs_ftp_out() do set diff=0 and never change them.

Less code makes Linus happy :-)
--
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
