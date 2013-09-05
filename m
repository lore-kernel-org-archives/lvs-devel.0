From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [ipvsadm PATCH 0/3] Patchset in preparation for ipvsadm release
 v1.27
Date: Thu, 5 Sep 2013 22:33:10 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1309052231370.1774@ja.ssi.bg>
References: <20130905112303.5071.14612.stgit@localhost>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130905112303.5071.14612.stgit@localhost>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Ryan O'Hara <rohara@redhat.com>


	Hello,

On Thu, 5 Sep 2013, Jesper Dangaard Brouer wrote:

> Here are some patches in preparation for the upcomming ipvsadm release
> v1.27.  No real coded changes to ipvsadm, just maintainer related
> updates and changes.
> 
> If nobody objects and when Simon ACKs, I'm going to apply this
> patchset myself to the ipvsadm git tree:
> 
>   https://git.kernel.org/cgit/utils/kernel/ipvsadm/ipvsadm.git

	Patchset looks ok to me.

> ---
> 
> Jesper Dangaard Brouer (3):
>       Make README more generic and reference new kernel.org location
>       Add MAINTAINERS style file
>       Maintainer script for releasing tarballs
> 
> 
>  MAINTAINERS        |   33 ++++++++++++++
>  README             |   26 ++++++++---
>  release-tarball.sh |  123 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 174 insertions(+), 8 deletions(-)
>  create mode 100644 MAINTAINERS
>  create mode 100755 release-tarball.sh

Regards

--
Julian Anastasov <ja@ssi.bg>
