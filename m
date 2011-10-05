From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: [PATCH 1/2] fix lockdep warning
Date: Wed, 5 Oct 2011 08:31:26 +0200
Message-ID: <201110050831.26652.hans@schillstrom.com>
References: <1317639399-4522-1-git-send-email-hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1110050133290.2388@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1110050133290.2388@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, horms@verge.net.au, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org

On Wednesday, October 05, 2011 00:51:31 Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 3 Oct 2011, Hans Schillstrom wrote:
> 
[snip]
> 
> 	ip_vs_rs_key remains unused without debugging. I don't
> remember the reason why IPVS is the only place that calls
> __rwlock_init instead of rwlock_init. Can we use rwlock_init?

I'm Sorry, this was not meant to go to the list :-(
It should be rwlock_init() as you say 
I'll send a new one row patch...


Thanks
Hans
