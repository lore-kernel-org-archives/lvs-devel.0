From: Simon Horman <horms@verge.net.au>
Subject: Re: [GIT 0/3] Second Round of IPVS Updates for v4.12
Date: Fri, 14 Apr 2017 08:51:19 +0900
Message-ID: <20170413235115.GA5948@verge.net.au>
References: <1491843515-1627-1-git-send-email-horms@verge.net.au>
 <20170413230134.GA5724@salvia>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1492127483; bh=IL50n7/xXQajgj3BO14EQ4EblwthftTFbpQeDjt9Q+4=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=T7CJbKMf97YOI3JErtir3wV/YyBj7YksU20p6o12VbxI5ZmTljOCE6A6MrIwJRuUs
         vsUVOg3hO9s3geF7Ncd6IefbezdPhFGmSzljt2vXy6unAt0T7dHgEd6OZGHsc4c1fr
         Bkk2MoYFICicOGQKZ2cDKFEYVPh8Ghf7uGrRAqbw=
Content-Disposition: inline
In-Reply-To: <20170413230134.GA5724@salvia>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Fri, Apr 14, 2017 at 01:01:34AM +0200, Pablo Neira Ayuso wrote:
> Hi Simon,
> 
> On Mon, Apr 10, 2017 at 09:58:32AM -0700, Simon Horman wrote:
> > Hi Pablo,
> > 
> > please consider these clean-ups and enhancements to IPVS for v4.12.
> > 
> > * Removal unused variable
> > * Use kzalloc where appropriate
> > * More efficient detection of presence of NAT extension
> > 
> > 
> > The following changes since commit 592d42ac7fd36408979e09bf2f170f2595dab7b8:
> > 
> >   Merge branch 'qed-IOV-cleanups' (2017-03-21 19:02:38 -0700)
> > 
> > are available in the git repository at:
> > 
> >   https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git ipvs2-for-v4.12
> 
> This says:
> 
> $ git pull
> https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git ipvs2-for-v4.12
> fatal: Couldn't find remote ref ipvs2-for-v4.12
> 
> I don't any tag for this name in:
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git/refs/tags

Sorry about that, it looks like I forgot to push the tag.
It should be there now.
