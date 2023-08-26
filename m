From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH -stable,4.14.y,4.19.y 0/1] ipvs: backport 1b90af292e71
 and 5310760af1d4
Date: Sat, 26 Aug 2023 18:36:46 +0200
Message-ID: <2023082639-hacking-yoga-85c0@gregkh>
References: <2023082114-remix-cable-0852@gregkh>
 <20230824115354.61669-1-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <stable-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=linuxfoundation.org;
        s=korg; t=1693067809;
        bh=Bw8aXWJjlayr4JFwZwbqJJnYZJRH6/I9kF9alThINnM=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=FJbwLHRQkJCvnOxlkzE9v6BH95R2CNXEOUcB/mcsoMILwR6DOZ5srlpeE4XL6gY0e
         YZo+icE1dGDIcER8Mt0x8OWQm53yacn4zkB963DnVkydBrLG5F+22or4UmjMASnWpD
         HcaUdYBCw5M39/ZsnPJD6yp3pXkbVOIBT63nl5xo=
Content-Disposition: inline
In-Reply-To: <20230824115354.61669-1-ja@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: stable@vger.kernel.org, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, netfilter-devel@vger.kernel.org, Junwei Hu <hujunwei4@huawei.com>, Sishuai Gong <sishuai.system@gmail.com>

On Thu, Aug 24, 2023 at 02:53:53PM +0300, Julian Anastasov wrote:
> 	Hello,
> 
> 	This patchset contains backport for
> commit 1b90af292e71b20d03b837d39406acfbdc5d4b2a. It applies
> to linux-4.14.y and linux-4.19.y and differs from original commit
> for the zero/one values used for extra1/extra2.
> 
> 	When applied, the concerned commit
> 5310760af1d4fbea1452bfc77db5f9a680f7ae47 can be cherry-picked and
> it will apply cleanly on top of 1b90af292e71.
> 
> Junwei Hu (1):
>   ipvs: Improve robustness to the ipvs sysctl
> 
>  net/netfilter/ipvs/ip_vs_ctl.c | 70 +++++++++++++++++-----------------
>  1 file changed, 36 insertions(+), 34 deletions(-)
> 
> -- 
> 2.41.0
> 
> 

Now queued up, thanks.

greg k-h
