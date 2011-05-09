From: Patrick McHardy <kaber@trash.net>
Subject: Re: [GIT PULL nf-2.6] IPVS (take III)
Date: Mon, 09 May 2011 11:29:57 +0200
Message-ID: <4DC7B415.1070709@trash.net>
References: <1304896671-29384-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1304896671-29384-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans@schillstrom.com>, Hans Schillstrom <hans.schillstrom@ericsson.com>, "Eric W. Biederman" <ebiederm@xmission.com>

Am 09.05.2011 01:17, schrieb Simon Horman:
> please consider pulling
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-2.6.git for-nf-2.6
> 
> to get the following fix from Hans. They resolve some problems related
> to his netns for IPVS work which was incorporated into 2.6.39-rc1.
> 
> The pull request is based on nf-2.6/master.
> 
> There are other less-pressing changes from Hans which
> I plan to get you to pull into nf-next-2.6 once these
> changes make it there (presumably via net-2.6 and then net-next-2.6).
> 
> There are minor changes since take II.
> 
> Hans Schillstrom (2):
>       IPVS: Change of socket usage to enable name space exit.
>       IPVS: init and cleanup restructuring

Pulled, thanks Simon.
