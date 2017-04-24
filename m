From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: explicitly forbid ipv6 service/dest creation if
 ipv6 mod is disabled
Date: Mon, 24 Apr 2017 10:21:30 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1704241017030.2492@ja.home.ssi.bg>
References: <2a5c88ca5670baade900e2b1f05a0dcc9927a29d.1492681122.git.pabeni@redhat.com>  <alpine.LFD.2.20.1704221355290.1974@ja.home.ssi.bg> <1493016651.5744.1.camel@redhat.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1493016651.5744.1.camel@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Paolo Abeni <pabeni@redhat.com>
Cc: netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org


	Hello,

On Mon, 24 Apr 2017, Paolo Abeni wrote:

> Hi,
> 
> The problem with the patched code is that it tries to resolve ipv6
> addresses that are not created/validated by the kernel.

	OK. Simon, please apply to ipvs tree.

Acked-by: Julian Anastasov <ja@ssi.bg>

Regards

--
Julian Anastasov <ja@ssi.bg>
