From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL net-next v2] IPVS
Date: Sun, 6 May 2012 23:56:32 +0200
Message-ID: <20120506215632.GA22852@1984>
References: <1335939762-1912-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1335939762-1912-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>

Hi Simon,

On Wed, May 02, 2012 at 03:22:24PM +0900, Simon Horman wrote:
> Hi Pablo,
> 
> please consider the following 18 changes for 3.5.
> 
> This replaces a 17 patch pull request that I sent earlier today by adding a
> patch from Hans patch to the head of the request.  You should be able to
> just pull again if you have already pulled the original series and not
> applied anything else on top.
> 
> Please note that there will be a conflict with the following when merged
> with net-next due to the following change which is already present in
> David's tree. It should be a trivial merge but please let me know if you
> want to handle this another way.
> 
> 	4a17fd5 sock: Introduce named constants for sk_reuse
> 
> The following changes since commit c3dc836d807a9b9855eefe535fdcbcf7cbb7a574:
> 
>   netfilter: bridge: optionally set indev to vlan (2012-04-24 01:22:44 +0200)
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git master

Pulled, thanks.

I have fixed some minor glitches, see below.

> for you to fetch changes up to 3de4b8ca4ffa3dafaeef985fabe152a1717a8ea0:
> 
>   export sysctl symbols needed by ip_vs_sync (2012-05-02 14:48:55 +0900)
> 
> ----------------------------------------------------------------
> H Hartley Sweeten (2):
>       IPVS: ip_vs_ftp.c: local functions should not be exposed globally
>       IPVS: ip_vs_proto.c: local functions should not be exposed globally
        ^^^^
Please, use consistent tagging across patches (sometimes this is in
uppercase, sometimes lowercase).

I think using the same tagging is good for grepping for changes.

I have also removed the CC tag to David Miller in those two patches
above from H. Hartely, they are not useful anymore.

> Hans Schillstrom (1):
>       export sysctl symbols needed by ip_vs_sync
     ^^^

This one missed "net: " or "sock: " tag in the beginnging. I added
"net: " here.

I have manually fixed this, but you'll have to rebase your tree, sorry.
