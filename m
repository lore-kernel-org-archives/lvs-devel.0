From: =?iso-8859-1?Q?Hans_Schillstr=F6m?= <hans.schillstrom@ericsson.com>
Subject: RE: [v2 PATCH 0/6] IPVS: init and cleanup.
Date: Fri, 29 Apr 2011 11:48:39 +0200
Message-ID: <C8A6796DE7C66C4ABCBC18106CB6C1CC08232F0887@ESESSCMS0356.eemea.ericsson.se>
References: <1304058334-17594-1-git-send-email-hans@schillstrom.com>,<20110429064225.GA23958@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7BIT
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110429064225.GA23958@verge.net.au>
Content-Language: en-US
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>, Hans Schillstrom <hans@schillstrom.com>
Cc: "ja@ssi.bg" <ja@ssi.bg>, "ebiederm@xmission.com" <ebiederm@xmission.com>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>


>Subject: Re: [v2 PATCH 0/6] IPVS: init and cleanup.
>
>On Fri, Apr 29, 2011 at 08:25:28AM +0200, Hans Schillstrom wrote:
> This patch series handles exit from a network name space.
>
>Hi Hans,
>
>thanks for your work on this.
>I've looked over the patches and nothing catches my eye -
>thanks for fixing up the things that I commented on previously.
>
>I think that patches 1 and 2 should be targeted at 2.6.39,
>while the remainder look like 2.6.40 material. Does that
>sound reasonable to you?

I do prefer to keep them together, 
but if you want it in that way it's OK for me.

We are doing a lot of tests right now with this patch set.
If we found any issues I'll let you know.

Regards
Hans
