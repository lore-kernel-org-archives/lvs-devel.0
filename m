From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] Allow override of CFLAGS
Date: Thu, 08 Aug 2013 11:05:19 +0200
Message-ID: <52035F4F.80302@redhat.com>
References: <1375937999-11660-1-git-send-email-horms@verge.net.au> <52034D12.4070100@redhat.com> <20130808090019.GA22983@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130808090019.GA22983@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Jesper Dangaard Brouer <jbrouer@redhat.com>

On 08/08/2013 11:00 AM, Simon Horman wrote:
> On Thu, Aug 08, 2013 at 09:47:30AM +0200, Daniel Borkmann wrote:
>> On 08/08/2013 06:59 AM, Simon Horman wrote:
>>> When building ipvsadm this allows make to add to CFLAGS supplied
>>> on the command line.
>>>
>>> This seems to make sense as Makefile and libipvs/Makefile
>>> add different CFLAGS but it may be desirable to supply supplementary
>>> flags when building ipvsadm.
>>>
>>> In particular the following may be useful when building ipvsadm
>>> on Debian Jessie.
>>>
>>> make CFLAGS='-I/usr/include/libnl3' LIBS='-lnl-3 -lnl-genl-3 -lnl-3 -lpopt'
>>
>> For libnl3, what about ...
>>
>> cflags: $(shell pkg-config --cflags libnl-3.0) $(shell pkg-config --cflags libnl-3.0)
>> libs:   $(shell pkg-config --libs libnl-3.0) $(shell pkg-config --libs libnl-genl-3.0)
>
> That seems reasonable to me. Is it likely to work on a variety of
> distributions?

Afaik, this should do the job at least on the major ones like Fedora/RHEL and Debian,
also Gentoo, etc. I once had people sending me patches to switch to pkg-config on
netsniff-ng.

>>> Signed-off-by: Simon Horman <horms@verge.net.au>
>>> ---
>>>   Makefile | 2 +-
>>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/Makefile b/Makefile
>>> index 6e36d79..c8c1eec 100644
>>> --- a/Makefile
>>> +++ b/Makefile
>>> @@ -48,7 +48,7 @@ STATIC_LIBS	= libipvs/libipvs.a
>>>   ifeq "${ARCH}" "sparc64"
>>>       CFLAGS = -Wall -Wunused -Wstrict-prototypes -g -m64 -pipe -mcpu=ultrasparc -mcmodel=medlow
>>>   else
>>> -    CFLAGS = -Wall -Wunused -Wstrict-prototypes -g
>>> +    CFLAGS = -I/usr/include/libnl3 -Wall -Wunused -Wstrict-prototypes -g
>>>   endif
