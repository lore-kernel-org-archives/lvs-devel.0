From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH ipvsadm] ipvsadm: new attributes for sync daemon
Date: Thu, 20 Aug 2015 08:32:10 +0200
Message-ID: <20150820083210.3d4bf423@redhat.com>
References: <1437912734-30108-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1437912734-30108-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, lvs-users@linuxvirtualserver.org, brouer@redhat.com

On Sun, 26 Jul 2015 15:12:14 +0300
Julian Anastasov <ja@ssi.bg> wrote:

> Add support for --sync-maxlen, --mcast-group, --mcast-port and
> --mcast-ttl options for the --start-daemon command.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>  ipvsadm.8                 |  55 ++++++++++++++-----
>  ipvsadm.c                 | 137 +++++++++++++++++++++++++++++++++++++---------
>  libipvs/ip_vs.h           |  31 +++++++++++
>  libipvs/ip_vs_nl_policy.c |   6 ++
>  libipvs/libipvs.c         |  71 ++++++++++++++++++++++--
>  5 files changed, 256 insertions(+), 44 deletions(-)
> 
>  It is related to the kernel patches for new parameters for
> the sync daemon. If needed I'll post it again later for
> inclusion after the kernel patches are included.

Applied - I took this patch now... else we end up waiting too long, as
with the previous patch I just applied.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
