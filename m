From: Simon Horman <horms@verge.net.au>
Subject: Re: [ipvsadm PATCH 0/2] trivial compile warning fixes for ipvsadm
Date: Thu, 4 Dec 2014 21:23:15 +0900
Message-ID: <20141204122314.GD21778@verge.net.au>
References: <20141204093757.20470.92421.stgit@localhost>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141204093757.20470.92421.stgit@localhost>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: lvs-devel@vger.kernel.org, Daniel Borkmann <dborkman@redhat.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Ryan O'Hara <rohara@redhat.com>

On Thu, Dec 04, 2014 at 10:38:50AM +0100, Jesper Dangaard Brouer wrote:
> Some trivial compile warning fixes from Daniel Borkmann to the ipvsadm tool.
> 
> I'll apply these to the git repo[1] if nobody objects.
> 
> [1] git://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git

Acked-by: Simon Horman <horms@verge.net.au>

> 
> ---
> 
> Daniel Borkmann (2):
>       ipvsadm: fix compile warning in print_largenum
>       ipvsadm: fix compile warning in modprobe_ipvs
> 
> 
>  ipvsadm.c |   10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Sr. Network Kernel Developer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer
> 
> --
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
