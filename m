From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [v2 PATCH 0/4] IPVS: Backup Adding Ipv6 and Persistence support -> option_param skip ?
Date: Mon, 1 Nov 2010 13:16:37 +0100
Message-ID: <201011011316.37416.hans.schillstrom@ericsson.com>
References: <201010291415.35299.hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1010301741280.2294@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1010301741280.2294@ja.ssi.bg>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: LVS-Devel <lvs-devel@vger.kernel.org>, Simon Horman <horms@verge.net.au>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>


On Saturday 30 October 2010 16:55:32 Julian Anastasov wrote:
[ snip ]
>
>  	- lets drop the optional parameters from ip_vs_process_message()?
>
In case we receive optional_param from an old master,
 I can't see that we can handle it in a proper way with contrack mangling the packet.

In that case:
  if we drop it in the receive path.
  we should skip sending of it as well...
  (since noboy will listen for it)


Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
