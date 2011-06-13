From: Simon Horman <horms@verge.net.au>
Subject: Re: [v2 PATCH 0/6] IPVS: init and cleanup.
Date: Mon, 13 Jun 2011 17:18:34 +0900
Message-ID: <20110613081834.GE2536@verge.net.au>
References: <1304268618-18103-1-git-send-email-hans@schillstrom.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1304268618-18103-1-git-send-email-hans@schillstrom.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: ja@ssi.bg, ebiederm@xmission.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans.schillstrom@ericsson.com

Hi Hans,

this series consisted of the following patches:

[v4 PATCH 1/6] IPVS: Change of socket usage to enable name space exit.
[v4 PATCH 2/6] IPVS: labels at pos 0
[v4 PATCH 3/6] IPVS: init and cleanup restructuring.
[v4 PATCH 4/6] IPVS: rename of netns init and cleanup functions.
[v4 PATCH 5/6] IPVS: remove unused init and cleanup functions.
[v4 PATCH 6/6] IPVS: add debug functions

Variants of 1/6 and 3/6 were included in 2.6.39.
I have applied 4/6 to ipvs-next-2.6 [1]
The remaining patches no longer apply cleanly,
could you send fresh versions?

[1] git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next-2.6.git
