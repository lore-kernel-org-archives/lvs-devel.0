From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH ipvs] ipvs: Add selftests for ipvs
Date: Thu, 14 Aug 2014 10:02:32 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1408140939240.1752@ja.home.ssi.bg>
References: <1407982349-9080-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1407982349-9080-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, kernel-team@fb.com


	Hello,

On Wed, 13 Aug 2014, Alex Gartrell wrote:

> Here's a basic python framework for doing selftests on ipvs.

	This is interesting work. I, personally, didn't
played with such kind of tools, so if you don't get other
response here feel free to contact netdev, DaveM,
Andrew Morton or even Linus for applying the patch.
I don't know if some part of the code (IPv4/IPv6 headers)
can be useful for other future tests, so CC-ing netdev
would be a good idea.

> Signed-off-by: Alex Gartrell <agartrell@fb.com>
> ---
>  tools/testing/selftests/ipvs/.gitignore            |   1 +
>  tools/testing/selftests/ipvs/Makefile              |  14 +
>  tools/testing/selftests/ipvs/general_ipvs_tests.py |  87 ++++++
>  tools/testing/selftests/ipvs/network_headers.py    | 315 +++++++++++++++++++++
>  tools/testing/selftests/ipvs/network_test_utils.py |  93 ++++++
>  tools/testing/selftests/ipvs/test-ipvs.py          |  17 ++
>  6 files changed, 527 insertions(+)
>  create mode 100644 tools/testing/selftests/ipvs/.gitignore
>  create mode 100644 tools/testing/selftests/ipvs/Makefile
>  create mode 100644 tools/testing/selftests/ipvs/general_ipvs_tests.py
>  create mode 100644 tools/testing/selftests/ipvs/network_headers.py
>  create mode 100644 tools/testing/selftests/ipvs/network_test_utils.py
>  create mode 100644 tools/testing/selftests/ipvs/test-ipvs.py

Regards

--
Julian Anastasov <ja@ssi.bg>
