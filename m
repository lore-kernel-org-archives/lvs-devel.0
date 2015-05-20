From: Cong Wang <cwang@twopensource.com>
Subject: Re: We've released a generic netlink python library -- gnlpy
Date: Wed, 20 May 2015 16:33:10 -0700
Message-ID: <CAHA+R7OKkAhmw_4YN255FW2KXJ5j4bxT_VoEs+FqrBz1yzE-Ew@mail.gmail.com>
References: <555CF83B.7040706@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <555CF83B.7040706@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: lvs-devel@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, netdev <netdev@vger.kernel.org>, kernel-team@fb.com

On Wed, May 20, 2015 at 2:10 PM, Alex Gartrell <agartrell@fb.com> wrote:
> Hey everyone,
>
> tl;dr; pure python generic netlink library with simple clients for ipvs and
> taskstats here: https://github.com/facebook/gnlpy

libnl should have python support for generic netlink too:

$ ls python/netlink/genl/
capi.i  __init__.py  Makefile  Makefile.am  Makefile.in

but I never use its python module so not sure if it works... ;)
