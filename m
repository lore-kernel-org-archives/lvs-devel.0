From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 1/1] IPVS netns BUG, register sysctl for root ns
Date: Tue, 25 Jan 2011 12:15:17 +1000
Message-ID: <20110125021516.GC7420@verge.net.au>
References: <1295878481-13623-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1295878481-13623-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: ja@ssi.bg, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans@schillstrom.com

On Mon, Jan 24, 2011 at 03:14:41PM +0100, Hans Schillstrom wrote:
> The newly created table was not used when register sysctl for a new namespace.
> I.e. sysctl doesn't work for other than root namespace (init_net)
> 
> Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>

Thanks Hans.

Patrick, please pull this change from

git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git for-patrick
