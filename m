From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re: Re: [v4 PATCH 1/6] IPVS: Change of socket usage to 
	enable name space exit.
Date: Mon, 2 May 2011 13:40:04 +0200 (CEST)
Message-ID: <kqgtk9j.d83e4dced2edb2820c7e6329f634bb3f@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: ja@ssi.bg, ebiederm@xmission.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans.schillstrom@ericsson.com

>Sent: Mon, May 2, 2011, 13:03 PM
>Subject: Re: [v4 PATCH 1/6] IPVS: Change of socket usage to enable name space exit.
>
>On Sun, May 01, 2011 at 06:50:13PM +0200, Hans Schillstrom wrote:
>> To work this patch also needs the other patches in this series.
>
>Hi Hans,
>
>could you explain the implications statement above?
>What kind of behaviour might I expect if only this patch is applied?

Oops, left there by misstake.
Can you remove that line before pushing it ?

>I'm planning to push this and 2/6 for 2.6.39, and as we have
>discussed (offline) that combination works. But from a bisection
>point of view, this patch needs to not "blow up" if used by itself.

It should not be any bisect. problems from what I can see.

Regards
Hans

