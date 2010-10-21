From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Fixed race condition at ip_vs.ko module init.
Date: Thu, 21 Oct 2010 10:31:43 +0200
Message-ID: <4CBFFA6F.3050106@trash.net>
References: <AANLkTinVcSK0Dqx4Pkp1dZskR8YmkGYkkrSNgDqX6psW@mail.gmail.com> <20101019152311.GJ6193@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20101019152311.GJ6193@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: Eduardo Blanco <ejblanco@google.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

Am 19.10.2010 17:23, schrieb Simon Horman:
> On Tue, Oct 19, 2010 at 10:26:47AM +0100, Eduardo Blanco wrote:
>> Lists were initialized after the module was registered.  Multiple ipvsadm
>> processes at module load triggered a race condition that resulted in a null
>> pointer dereference in do_ip_vs_get_ctl(). As a result, __ip_vs_mutex
>> was left locked preventing all further ipvsadm commands.
>>
>> Signed-off-by: Eduardo J. Blanco <ejblanco@google.com>
> 
> Thanks Eduardo.
> 
> Patrick, please consider pulling
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git for-patrick
> 
> to get this change.

Pulled, thanks.

