From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT-PULL nf-next 00/15] IPVS Updates for v4.4
Date: Fri, 18 Sep 2015 22:17:48 +0200
Message-ID: <20150918201748.GA10052@salvia>
References: <1442468451-24012-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1442468451-24012-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Alex Gartrell <agartrell@fb.com>

On Thu, Sep 17, 2015 at 02:40:36PM +0900, Simon Horman wrote:
> Hi Pablo,
> 
> please consider these IPVS Updates for v4.4.
> 
> The updates include the following from Alex Gartrell:
> * Scheduling of ICMP
> * Sysctl to ignore tunneled packets; and hence some packet-looping scenarios
> 
> The following changes since commit 851345c5bbb4644911f7c351c042559a71f57d19:
> 
>   netfilter: reduce sparse warnings (2015-08-28 21:04:12 +0200)
> 
> are available in the git repository at:
> 
>   https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs-for-v4.4

Pulled, thanks Simon.

One request and one question:

Please, extend the info in the pull request a bit more, I think it's
good for the record. Alex included a short description on the ICMP
schedule use case on the original submission, will take it and include
it in the pull request for David.

And the question is, under what circunstances you may not want to
schedule ICMP? I'm telling this because of the new schedule_icmp sysctl.

Thanks.
