From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/1] IPVS: seq_release_net should be used.
Date: Sun, 15 May 2011 17:12:51 +0200
Message-ID: <4DCFED73.3050904@netfilter.org>
References: <1305266600-21507-1-git-send-email-hans.schillstrom@ericsson.com> <20110514005025.GD4862@verge.net.au> <201105141205.41912.hans@schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <201105141205.41912.hans@schillstrom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Simon Horman <horms@verge.net.au>, Hans Schillstrom <hans.schillstrom@ericsson.com>, ja@ssi.bg, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org

On 14/05/11 12:05, Hans Schillstrom wrote:
> On Saturday, May 14, 2011 02:50:26 Simon Horman wrote:
>> On Fri, May 13, 2011 at 08:03:20AM +0200, Hans Schillstrom wrote:
>>> Without this patch every access to ip_vs in procfs will increase
>>> the netns count i.e. an unbalanced get_net()/put_net().
>>> (ipvsadm commands also use procfs.)
>>> The result is you can't exit a netns if reading ip_vs_* procfs entries.
>>
>> Hi Hans,
>>
>> we should try and get this into 2.6.39, right?
> 
> Yes, this is a trivial bug fix

I'll pass it to davem.
