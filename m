From: Simon Horman <horms@verge.net.au>
Subject: Re: [v4 PATCH 1/6] IPVS: Change of socket usage to enable name
 space exit.
Date: Mon, 2 May 2011 20:03:15 +0900
Message-ID: <20110502110315.GB32576@verge.net.au>
References: <1304268618-18103-1-git-send-email-hans@schillstrom.com>
 <1304268618-18103-2-git-send-email-hans@schillstrom.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1304268618-18103-2-git-send-email-hans@schillstrom.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: ja@ssi.bg, ebiederm@xmission.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans.schillstrom@ericsson.com

On Sun, May 01, 2011 at 06:50:13PM +0200, Hans Schillstrom wrote:
> To work this patch also needs the other patches in this series.

Hi Hans,

could you explain the implications statement above?
What kind of behaviour might I expect if only this patch is applied?

I'm planning to push this and 2/6 for 2.6.39, and as we have
discussed (offline) that combination works. But from a bisection
point of view, this patch needs to not "blow up" if used by itself.
