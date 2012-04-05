From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] netfilter: ipvs: Verify that IP_VS protocol has been
 registered
Date: Fri, 6 Apr 2012 08:19:42 +0900
Message-ID: <20120405231942.GB7715@verge.net.au>
References: <1333668273-8873-1-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1333668273-8873-1-git-send-email-levinsasha928@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sasha Levin <levinsasha928@gmail.com>
Cc: wensong@linux-vs.org, ja@ssi.bg, kaber@trash.net, davem@davemloft.net, davej@redhat.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Apr 05, 2012 at 07:24:33PM -0400, Sasha Levin wrote:
> The registration of a protocol might fail, there were no checks
> and all registrations were assumed to be correct. This lead to
> NULL ptr dereferences when apps tried registering.

Thanks, I will queue up this fix.

Do you have a real-world example of this failing, if so it
might be worth pushing your change into stable.
