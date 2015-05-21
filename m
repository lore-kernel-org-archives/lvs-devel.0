From: Edward Cree <ecree@solarflare.com>
Subject: Re: We've released a generic netlink python library -- gnlpy
Date: Thu, 21 May 2015 15:52:03 +0100
Message-ID: <555DF113.1050408@solarflare.com>
References: <555CF83B.7040706@fb.com> <CAHA+R7OKkAhmw_4YN255FW2KXJ5j4bxT_VoEs+FqrBz1yzE-Ew@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <CAHA+R7OKkAhmw_4YN255FW2KXJ5j4bxT_VoEs+FqrBz1yzE-Ew@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Cong Wang <cwang@twopensource.com>
Cc: Alex Gartrell <agartrell@fb.com>, lvs-devel@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, netdev <netdev@vger.kernel.org>, kernel-team@fb.com

On 21/05/15 00:33, Cong Wang wrote:
> On Wed, May 20, 2015 at 2:10 PM, Alex Gartrell <agartrell@fb.com> wrote:
>> Hey everyone,
>>
>> tl;dr; pure python generic netlink library with simple clients for ipvs and
>> taskstats here: https://github.com/facebook/gnlpy
> libnl should have python support for generic netlink too:
>
> $ ls python/netlink/genl/
> capi.i  __init__.py  Makefile  Makefile.am  Makefile.in
>
> but I never use its python module so not sure if it works... ;)
There is also pyroute2.netlink.generic
<https://pypi.python.org/pypi/pyroute2>
which does work but it's a bit clunky imho.
