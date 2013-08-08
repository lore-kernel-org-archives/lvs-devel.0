From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: ipvsadm git head not compiling on RHEL6
Date: Thu, 08 Aug 2013 11:23:12 +0200
Message-ID: <52036380.9020806@redhat.com>
References: <1375937999-11660-1-git-send-email-horms@verge.net.au> <52034D12.4070100@redhat.com> <20130808101924.7b363a4e@redhat.com> <52035659.8080503@redhat.com> <20130808111722.6f092b89@redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130808111722.6f092b89@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Cc: Ryan O'Hara <rohara@redhat.com>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Thomas Graf <tgraf@redhat.com>

On 08/08/2013 11:17 AM, Jesper Dangaard Brouer wrote:
> On Thu, 08 Aug 2013 10:27:05 +0200
> Daniel Borkmann <dborkman@redhat.com> wrote:
>> On 08/08/2013 10:19 AM, Jesper Dangaard Brouer wrote:
>>>
>>> I noticed that I get an compile error, when compiling ipvsadm
>>> git HEAD 1ea1f41f4 on RHEL6.4.
>>>
>>> Compile Error:
>>>
>>> gcc -Wall -Wunused -Wstrict-prototypes -g -o ipvsadm ipvsadm.o config_stream.o dynamic_array.o libipvs/libipvs.a -lpopt -lnl
>>> libipvs/libipvs.a(libipvs.o): In function `ipvs_nl_send_message':
>>> /home/jbrouer/git/ipvsadm/libipvs/libipvs.c:76: undefined reference to `nl_socket_alloc'
>>> /home/jbrouer/git/ipvsadm/libipvs/libipvs.c:91: undefined reference to `nl_socket_free'
>>> /home/jbrouer/git/ipvsadm/libipvs/libipvs.c:107: undefined reference to `nl_socket_free'
>>> /home/jbrouer/git/ipvsadm/libipvs/libipvs.c:112: undefined reference to `nl_socket_free'
>>> collect2: ld returned 1 exit status
>>> make: *** [ipvsadm] Error 1
>>>
>>> I'll investigate, but hints would be appreciated ;-)
>>
>> Did you try using libnl3? (Migrating to libnl3 would be better anyway as
>> distributions try to get rid of supporting libnl.)
>
> Nope, I'm using the default libnl coming with RHEL6.4.
>
> Its not really an option to import/change to libnl3 for RHEL6. But you
> could try poking Thomas Graf ;-)
>
>> I think sometime in libnl*, nl_handle_{alloc,free} was changed to
>> nl_socket_{alloc,free}.
>
> Yes, I can see that your libnl3 commit f48e93c1 (libipvs: libnl3: fix
> compilation error) caused this issue.

Well, because it broke the build when using libnl3 which should be the
way to go for most users. ;-)

You could add a fall-back define for libnl1 users, so that there's just
a textual replacement to the old name.

>> Maybe try changing include locations and libs that are linked against
>> to libnl3.
>
> We officially support ipvsadm for RHEL6, so its not an option to link
> against libnl3, as we need to supply an official package... else we/I
> would need to have an adaption patch in the RPM (I were looking to
> rebase RHEL6 to use the upcoming ipvsadm release).
