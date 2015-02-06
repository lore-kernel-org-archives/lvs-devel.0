From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] ipvsadm: add SCTP support
Date: Fri, 6 Feb 2015 01:09:38 +0100
Message-ID: <20150206010938.37119163@redhat.com>
References: <1422693668-25736-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1422693668-25736-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, lvs-users@linuxvirtualserver.org, overcastsky.zhao@gmail.com, brouer@redhat.com

On Sat, 31 Jan 2015 10:41:08 +0200
Julian Anastasov <ja@ssi.bg> wrote:

> SCTP support in kernel is from 2.6.34 but ipvsadm
> restricts users to fwmark-based virtual services.
> 
> * Add option --sctp-service to specify the virtual service
> 
> * Update man page to use virtual-service and the new option
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Applied and pushed:
 https://git.kernel.org/cgit/utils/kernel/ipvsadm/ipvsadm.git/commit/?id=2ce22dc8818

Thanks!
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
