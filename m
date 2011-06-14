From: Simon Horman <horms@verge.net.au>
Subject: Re: [GIT PULL next-2.6] IPVS
Date: Wed, 15 Jun 2011 08:42:20 +0900
Message-ID: <20110614234218.GA19636@verge.net.au>
References: <1307953569-15429-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1307953569-15429-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, Pablo Neira Ayuso <pablo@netfilter.org>

On Mon, Jun 13, 2011 at 05:26:06PM +0900, Simon Horman wrote:
> Hi Patrick, Hi Pablo,
> 
> please consider pulling
> git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next-2.6.git master
> 
> It includes two clean-ups by Hans
> and an enhancement of the FTP helper by Julian.

I have two more clean-ups from Hans,
I will send a fresh pull request.

> 
> I have based the pull request on next-2.6 as
> nf-next-2.6 seems to be a little old. Please let me
> know if a different base would suit you better.
> 
> Hans Schillstrom (2):
>       IPVS remove unused var from migration to netns
>       IPVS: rename of netns init and cleanup functions.
> 
> Julian Anastasov (1):
>       ipvs: support more FTP PASV responses
> 
>  include/net/ip_vs.h              |   28 +++++++++-----------
>  net/netfilter/ipvs/ip_vs_app.c   |    4 +-
>  net/netfilter/ipvs/ip_vs_conn.c  |    4 +-
>  net/netfilter/ipvs/ip_vs_core.c  |   36 +++++++++++++-------------
>  net/netfilter/ipvs/ip_vs_ctl.c   |   20 +++++++-------
>  net/netfilter/ipvs/ip_vs_est.c   |    4 +-
>  net/netfilter/ipvs/ip_vs_ftp.c   |   52 +++++++++++++++++++++++++++----------
>  net/netfilter/ipvs/ip_vs_proto.c |    4 +-
>  net/netfilter/ipvs/ip_vs_sync.c  |    4 +-
>  9 files changed, 89 insertions(+), 67 deletions(-)
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
