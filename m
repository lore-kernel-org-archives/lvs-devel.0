From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 1/1] IPVS remove unused var from migration to netns
Date: Mon, 13 Jun 2011 17:04:37 +0900
Message-ID: <20110613080436.GC2536@verge.net.au>
References: <1307693949-22301-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1307693949-22301-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: ja@ssi.bg, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans@schillstrom.com

On Fri, Jun 10, 2011 at 10:19:09AM +0200, Hans Schillstrom wrote:
> Remove variable ctl_key from struct netns_ipvs,
> it's a leftover from early netns work.

Thanks, applied.
