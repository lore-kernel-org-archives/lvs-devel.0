From: Simon Horman <horms@verge.net.au>
Subject: Re: [v2 PATCH 0/6] IPVS: init and cleanup.
Date: Fri, 29 Apr 2011 15:42:25 +0900
Message-ID: <20110429064225.GA23958@verge.net.au>
References: <1304058334-17594-1-git-send-email-hans@schillstrom.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1304058334-17594-1-git-send-email-hans@schillstrom.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: ja@ssi.bg, ebiederm@xmission.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans.schillstrom@ericsson.com

On Fri, Apr 29, 2011 at 08:25:28AM +0200, Hans Schillstrom wrote:
> This patch series handles exit from a network name space.

Hi Hans,

thanks for your work on this.
I've looked over the patches and nothing catches my eye -
thanks for fixing up the things that I commented on previously.

I think that patches 1 and 2 should be targeted at 2.6.39,
while the remainder look like 2.6.40 material. Does that
sound reasonable to you?

Julian and Eric,

can you take a look over these?
I would appreciate your review.

