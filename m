From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH ipvs 2/2] net: ipvs: sctp: do not recalc sctp checksum
 when not needed
Date: Fri, 25 Oct 2013 11:48:13 +0200
Message-ID: <20131025114813.6a227df3@redhat.com>
References: <1af1d5e1aae9df91683625f0cb120b329e8d2f10.1382689350.git.dborkman@redhat.com>
	<8390127344501c35ed3c23f3690b8a671d353870.1382689350.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <8390127344501c35ed3c23f3690b8a671d353870.1382689350.git.dborkman@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Daniel Borkmann <dborkman@redhat.com>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, linux-sctp@vger.kernel.org

On Fri, 25 Oct 2013 11:05:05 +0200
Daniel Borkmann <dborkman@redhat.com> wrote:

> Unlike UDP or TCP, we do not take the pseudo-header into account
> in SCTP checksums [1]. So in case port mapping is the very same, we
> do not need to recalculate the whole SCTP checksum in software, which
> is expensive.
> 
> Also, similarly as in IPVS/TCP, take into account when a private
> helper mangled the packet. In that case, we also need to recalculate
> the checksum even if ports might be same.
> 
>  [1] http://tools.ietf.org/html/rfc4960#section-6.8
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

Thanks Daniel, this will hopefully increase SCTP performance as we
avoid recalculating the checksum when not necessary :-)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
