From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] ipvsadm: support 64-bit stats and rates
Date: Thu, 20 Aug 2015 08:27:34 +0200
Message-ID: <20150820082734.69581bc0@redhat.com>
References: <1423208704-11918-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1423208704-11918-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, lvs-users@linuxvirtualserver.org, Chris Caputo <ccaputo@alt.net>, brouer@redhat.com

On Fri,  6 Feb 2015 09:45:04 +0200
Julian Anastasov <ja@ssi.bg> wrote:

> Prefer the new netlink attributes IPVS_SVC_ATTR_STATS64 and
> IPVS_DEST_ATTR_STATS64 for 64-bit conn/packet/bps/cps/pps stats.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
> 
> Nothing is changed from previous RFC version.
> Should be applied after the kernel patch is accepted.

Finally applied.

Corresponding kernel commit cd67cd5eb25 ("ipvs: use 64-bit rates
in stats"), is avail in kernel 4.1.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
