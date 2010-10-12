From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [RFC PATCH 2/9] ipvs network name space aware
Date: Tue, 12 Oct 2010 16:30:20 +0200
Message-ID: <4CB470FC.7070500@free.fr>
References: <201010081316.54676.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <201010081316.54676.hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org

On 10/08/2010 01:16 PM, Hans Schillstrom wrote:
> This part contains the include files
> where include/net/netns/ip_vs.h is new and contains all moved vars.
>
> SUMMARY
>
>   include/net/ip_vs.h                     |  136 ++++---
>   include/net/net_namespace.h             |    2 +
>   include/net/netns/ip_vs.h               |  112 +++++
>
> Signed-off-by:Hans Schillstrom<hans.schillstrom@ericsson.com>
> ---
>    

Why are patch 1 and 2 the same ?

