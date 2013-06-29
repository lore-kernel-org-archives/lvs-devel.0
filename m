From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL 0/8] IPVS updates for v3.11 #2
Date: Sat, 29 Jun 2013 12:15:31 +0200
Message-ID: <20130629101531.GA5478@localhost>
References: <1372237890-28211-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1372237890-28211-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Wed, Jun 26, 2013 at 06:11:22PM +0900, Simon Horman wrote:
> Hi Pablo,
> 
> please consider the following changes for IPVS for v3.11.
> 
> The following changes since commit 681f130f39e10087475383e6771b9366e26bab0c:
> 
>   netfilter: xt_socket: add XT_SOCKET_NOWILDCARD flag (2013-06-20 20:28:49 +0200)
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs2-for-v3.11
> 
> for you to fetch changes up to 8b4d14d8eb36874daf159d33dcccd4746a6f3189:
> 
>   netns: exclude ipvs from struct net when IPVS disabled (2013-06-26 18:01:46 +0900)
>
> ----------------------------------------------------------------
> IPVS updates for v3.11
> 
> * Exclude IPVS from struct net when IPVS disabled
> * Remove unnecessary head file
> * Add sync_persist_mode flag to reduce sync traffic in the presence
>   of persistence
> * SH scheduler fallback and L4 hashing
> * SCTP cleanup so that its implementation more closely resembles
>   that of other protocols supported by IPVS
> * Add sloppy TCP and SCTP modes to allow connections to
>   fail from one IPVS director to another regardless of their state

Pulled, thanks Simon!
