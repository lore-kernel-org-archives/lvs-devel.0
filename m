From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH ipvs] ipvs: Add selftests for ipvs
Date: Thu, 14 Aug 2014 09:09:59 +0200
Message-ID: <53EC60C7.6020602@redhat.com>
References: <1407982349-9080-1-git-send-email-agartrell@fb.com> <alpine.LFD.2.11.1408140939240.1752@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.11.1408140939240.1752@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julian Anastasov <ja@ssi.bg>
Cc: Alex Gartrell <agartrell@fb.com>, horms@verge.net.au, lvs-devel@vger.kernel.org, kernel-team@fb.com

On 08/14/2014 09:02 AM, Julian Anastasov wrote:
>
> 	Hello,
>
> On Wed, 13 Aug 2014, Alex Gartrell wrote:
>
>> Here's a basic python framework for doing selftests on ipvs.
>
> 	This is interesting work. I, personally, didn't
> played with such kind of tools, so if you don't get other
> response here feel free to contact netdev, DaveM,
> Andrew Morton or even Linus for applying the patch.
> I don't know if some part of the code (IPv4/IPv6 headers)
> can be useful for other future tests, so CC-ing netdev
> would be a good idea.

Agreed, that's great to have a selftest suite for ipvs!

One minor note, for networking there is so far a small set
of tests under tools/testing/selftests/net/ .

You might want to consider adding it there and reorganizing
the structure as follows, for example:

tools/testing/selftests/net/ipvs/    -- your code
tools/testing/selftests/net/packet/  -- for existing psock* tests
tools/testing/selftests/net/misc/    -- general socket tests

net-next is currently closed due to the merge window, but
development should open very soon again, Dave always announces
this on netdev.

>> Signed-off-by: Alex Gartrell <agartrell@fb.com>
>> ---
>>   tools/testing/selftests/ipvs/.gitignore            |   1 +
>>   tools/testing/selftests/ipvs/Makefile              |  14 +
>>   tools/testing/selftests/ipvs/general_ipvs_tests.py |  87 ++++++
>>   tools/testing/selftests/ipvs/network_headers.py    | 315 +++++++++++++++++++++
>>   tools/testing/selftests/ipvs/network_test_utils.py |  93 ++++++
>>   tools/testing/selftests/ipvs/test-ipvs.py          |  17 ++
>>   6 files changed, 527 insertions(+)
>>   create mode 100644 tools/testing/selftests/ipvs/.gitignore
>>   create mode 100644 tools/testing/selftests/ipvs/Makefile
>>   create mode 100644 tools/testing/selftests/ipvs/general_ipvs_tests.py
>>   create mode 100644 tools/testing/selftests/ipvs/network_headers.py
>>   create mode 100644 tools/testing/selftests/ipvs/network_test_utils.py
>>   create mode 100644 tools/testing/selftests/ipvs/test-ipvs.py
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
> --
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
