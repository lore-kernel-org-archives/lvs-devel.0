From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [v2 PATCH 1/1] ipvs: kernel oops - do_ip_vs_get_ctl
Date: Thu, 26 Apr 2012 10:10:41 +0200
Message-ID: <1335427841.3131.28.camel@t520>
References: <1335419264-1225-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1335419264-1225-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org, rohara@redhat.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans@schillstrom.com

On Thu, 2012-04-26 at 07:47 +0200, Hans Schillstrom wrote:
> Change order of init so netns init is ready
> when register ioctl and netlink.
> 
> Ver2 
> 	Whitespace fixes and __init added.
> 
> Reported-by: "Ryan O'Hara" <rohara@redhat.com>
> Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>

Looks good, interdiff says you fixed up things, and I have tested it
against the net tree, good work :-)

Is this a stable tree candidate?

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

