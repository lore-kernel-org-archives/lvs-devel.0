From: Patrick McHardy <kaber@trash.net>
Subject: Re: [GIT PULL nf-2.6] IPVS
Date: Thu, 03 Mar 2011 07:53:06 +0100
Message-ID: <4D6F3AD2.30502@trash.net>
References: <1299020375-11362-1-git-send-email-horms@verge.net.au> <4D6E22CA.2020305@trash.net> <20110302220637.GD8193@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110302220637.GD8193@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, Hans Schillstrom <hans@schillstrom.com>, Julian Anastasov <ja@ssi.bg>

On 02.03.2011 23:06, Simon Horman wrote:
> On Wed, Mar 02, 2011 at 11:58:18AM +0100, Patrick McHardy wrote:
>> Am 01.03.2011 23:59, schrieb Simon Horman:
>>> Hi Patrick,
>>>
>>> please consider pulling
>>> git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git for-patrick
>>> to get the following change from Julian. Please note that it is an nf-2.6
>>> (that is 2.6.38-rc) change.
>>>
>>> Julian Anastasov (1):
>>>       ipvs: fix dst_lock locking on dest update
>>
>> Pulled, thanks Simon.
> 
> Thanks Patrick.
> 
> This change is also needed in nf-next-2.6 but I assume that
> will automatically happen when nf-2.6 is merged into nf-next-2.6,
> possibly via a merge of net-2.6 into net-next-2.6.

Yes. If you need it as base for further work, the fastest way
is to ask Dave to pull net-2.6 into net-next-2.6, I can then
pull it into nf-next.

