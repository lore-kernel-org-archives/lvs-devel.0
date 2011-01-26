From: Patrick McHardy <kaber@trash.net>
Subject: Re: [GIT PULL nf-next-2.6] IPVS changes for 2.6.38-rc3
Date: Wed, 26 Jan 2011 16:27:58 +0100
Message-ID: <4D403D7E.2050902@trash.net>
References: <1295961426-7402-1-git-send-email-horms@verge.net.au> <4D3ED7BF.1080202@trash.net> <20110125235744.GA11026@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20110125235744.GA11026@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>, Julian Anastasov <ja@ssi.bg>

On 26.01.2011 00:57, Simon Horman wrote:
> On Tue, Jan 25, 2011 at 03:01:35PM +0100, Patrick McHardy wrote:
>> On 25.01.2011 14:17, Simon Horman wrote:
>>> Hi Patrick,
>>>
>>> please consider pulling
>>>   git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git for-patrick
>>>
>>> Which includes the following changes, both of which I believe 2.6.38 material.
>>>
>>> Changli Gao (1):
>>>       netfilter: ipvs: fix compiler warnings
>>>
>>> Hans Schillstrom (1):
>>>       IPVS netns BUG, register sysctl for root ns
>>
>> That tree is based on nf-next-2.6, so I can't pull this into my nf-2.6
>> tree.
> 
> Hi Patrick,
> 
> Sorry about this.
> 
> As it turns out I was mistaken in assuming that the IPVS netns changes
> had been merged into nf-2.6. They haven't, they only exist in net-next-2.6.
> 
> All of the recent patches that I have passed on to you relate to the IPVS
> netns changes so nf-next-2.6 is the right place for these fixes. So could
> you please pull the above tree into nf-next-2.6? I do not believe there are
> any nf-2.6 changes at this time.

Thanks, I've pulled it into nf-next-2.6.git.
