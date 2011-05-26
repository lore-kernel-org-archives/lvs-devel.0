From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/1] IPVS : bug in ip_vs_ftp, same list heaad used in
 all netns.
Date: Thu, 26 May 2011 19:17:50 +0200
Message-ID: <4DDE8B3E.30009@netfilter.org>
References: <1306239065-17271-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1306239065-17271-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans@schillstrom.com

On 24/05/11 14:11, Hans Schillstrom wrote:
> When ip_vs was adapted to netns the ftp application was not adapted
> in a correct way.
> However this is a fix to avoid kernel errors. In the long term another solution
> might be chosen.  I.e the ports that the ftp appl, uses should be per netns.

applied, thanks.
