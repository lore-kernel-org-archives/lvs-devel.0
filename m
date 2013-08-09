From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] ipvsadm: fix compiling tool on distros with only libnl-1
Date: Fri, 09 Aug 2013 08:55:52 +0200
Message-ID: <52049278.5040608@redhat.com>
References: <52034D12.4070100@redhat.com> <20130808121054.26226.26508.stgit@localhost> <20130808200017.GA3075@redhat.com> <20130809054736.GB6041@verge.net.au> <20130809084314.7da61f41@redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130809084314.7da61f41@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Cc: Simon Horman <horms@verge.net.au>, Ryan O'Hara <rohara@redhat.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Wensong Zhang <wensong@linux-vs.org>, Thomas Graf <tgraf@redhat.com>, Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org

On 08/09/2013 08:43 AM, Jesper Dangaard Brouer wrote:
> On Fri, 9 Aug 2013 14:47:36 +0900
> Simon Horman <horms@verge.net.au> wrote:
>
>> On Thu, Aug 08, 2013 at 03:00:17PM -0500, Ryan O'Hara wrote:
>>> On Thu, Aug 08, 2013 at 02:10:54PM +0200, Jesper Dangaard Brouer wrote:
>>>> Some distros have not moved to libnl3 yet.  Add a fallback option
>>>> for compiling on distro's with only libnl1.
>>>>
>>>> Using pkg-config to detect what versions of libnl is available.
>>>>
>>>> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
>>>
>>> This patch looks fine, but I think it only solves part of the
>>> problem. The Makefile still contains following code:
>
> This, patch only address making libnl1 work again.
>
>>> ifneq (0,$(HAVE_NL))
>>> LIBS            += -lnl
>>> endif
>>>
>>> First, I think the HAVE_NL conditional can be removed. But more
>>> importantly the correct netlink library should be appended to the
>>> LIBS variable. With the current code we'll always link against
>>> libnl-1.
>
> True. It seems to me that the libnl3 work have not been fully completed.
> And the reason Simon send the "Allow override of CFLAGS", which allowed
> him to compile with libnl3 via:
>
>   make CFLAGS='-I/usr/include/libnl3' LIBS='-lnl-3 -lnl-genl-3 -lpopt'
>
>>> On Fedora with both libnl and libnl-3 installed:
>>>
>>> $ pkg-config --libs libnl-3.0
>>> -lnl-3
>>> $ pkg-config --libs libnl-1
>>> -lnl
>>>
>>> Ryan
>>
>> Daniel could you amend your patch or provide a second patch
>> to use pkg-confog for LIBS too. It seems like a good idea to me.
>
> I think a second patch, to address libnl3 issues would be best.

Agreed, will do that after yours got into the tree.

>>>> ---
>>>>   libipvs/Makefile  |    5 +++++
>>>>   libipvs/libipvs.c |    5 +++++
>>>>   2 files changed, 10 insertions(+)
>>>>
>>>> diff --git a/libipvs/Makefile b/libipvs/Makefile
>>>> index a527a7f..eafc3e5 100644
>>>> --- a/libipvs/Makefile
>>>> +++ b/libipvs/Makefile
>>>> @@ -10,6 +10,11 @@ INCLUDE		+= $(shell if [ -f ../../ip_vs.h ]; then	\
>>>>   		     echo "-I../../."; fi;)
>>>>   DEFINES		= $(shell if [ ! -f ../../ip_vs.h ]; then	\
>>>>   		    echo "-DHAVE_NET_IP_VS_H"; fi;)
>>>> +DEFINES		+= $(shell if which pkg-config > /dev/null 2>&1; then \
>>>> +			 if   pkg-config --exists libnl-3.0; then :; \
>>>> +			 elif pkg-config --exists libnl-2.0; then :; \
>>>> +			 elif pkg-config --exists libnl-1; \
>>>> +			 then echo "-DFALLBACK_LIBNL1"; fi; fi)
>>>>
>>>>   .PHONY		= all clean install dist distclean rpm rpms
>>>>   STATIC_LIB	= libipvs.a
>>>> diff --git a/libipvs/libipvs.c b/libipvs/libipvs.c
>>>> index c3c3b0a..2b066d2 100644
>>>> --- a/libipvs/libipvs.c
>>>> +++ b/libipvs/libipvs.c
>>>> @@ -32,6 +32,11 @@ static void* ipvs_func = NULL;
>>>>   struct ip_vs_getinfo ipvs_info;
>>>>
>>>>   #ifdef LIBIPVS_USE_NL
>>>> +#ifdef FALLBACK_LIBNL1
>>>> +#define nl_sock         nl_handle
>>>> +#define nl_socket_alloc nl_handle_alloc
>>>> +#define nl_socket_free  nl_handle_destroy
>>>> +#endif
>>>>   static struct nl_sock *sock = NULL;
>>>>   static int family, try_nl = 1;
>>>>   #endif
>>>>
>>>
>
