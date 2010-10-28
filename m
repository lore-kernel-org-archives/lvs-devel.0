From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] IPVS: ip_vs_pe.c, use strncmp to be safe.
Date: Thu, 28 Oct 2010 12:33:27 +0200
Message-ID: <4CC95177.1060008@trash.net>
References: <1288191900-24613-1-git-send-email-hans.schillstrom@ericsson.com> <20101028075650.GC5305@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20101028075650.GC5305@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, lvs-devel@vger.kernel.org, ja@ssi.bg, wensong@linux-vs.org

On 28.10.2010 09:56, Simon Horman wrote:
> On Wed, Oct 27, 2010 at 05:05:00PM +0200, Hans Schillstrom wrote:
>> With pe data traveling between master and backup,
>> strcmp should not be used. 
>> How knows what size it will have in future.
>>
>> To be safe use strncmp.
> 
> Hi Hans,
> 
> I'm not entirely convinced this is necessary, but
> its better to be safe than sorry.
> 
>> Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
> 
> Patrick, I assume that nf-next-2.6 is currently closed.
> I'll push this to you once it opens again.

Thanks, I'll open up nf-next once Dave opens net-next.
