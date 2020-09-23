From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] ipvs: adjust the debug order of src and dst
Date: Wed, 23 Sep 2020 14:07:08 +0200
Message-ID: <20200923120708.GD3770354@lunn.ch>
References: <CAPaK2r921GtJVhwGKnZyCcQ1qkcWA=8TBWwNkW03R_=7TKzo6g@mail.gmail.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAPaK2r921GtJVhwGKnZyCcQ1qkcWA=8TBWwNkW03R_=7TKzo6g@mail.gmail.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: yue longguang <yuelongguang@gmail.com>
Cc: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kadlec@netfilter.org, fw@strlen.de, David Miller <davem@davemloft.net>, kuba@kernel.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Sep 23, 2020 at 02:06:25PM +0800, yue longguang wrote:
> From: ylg <bigclouds@163.com>
> 
> adjust the debug order of src and dst when tcp state changes

Hi Yue

You need to explain why you are doing something, not what you are
doing, in the commit message.

	Andrew
