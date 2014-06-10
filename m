From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: [PATCH] ipvsadm: Fix list daemon to show backup daemon
Date: Tue, 10 Jun 2014 09:43:50 +0200
Message-ID: <20140610094350.1e2d3a43@redhat.com>
References: <1400642071-10408-1-git-send-email-rohara@redhat.com>
	<alpine.LFD.2.11.1406061018180.12067@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.11.1406061018180.12067@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Ryan O'Hara <rohara@redhat.com>, lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>

On Fri, 6 Jun 2014 10:24:09 +0300 (EEST) Julian Anastasov <ja@ssi.bg> wrote:

> On Tue, 20 May 2014, Ryan O'Hara wrote:
> 
> > The list_daemon function in ipvsadm.c will show the master daemon
> > twice, but never the backup daemon. This patch replaces the redundant
> > check for IP_VS_STATE_MASTER with a check for IP_VS_STATE_BACKUP, then
> > prints the appropriate message.
> > 
> > Signed-off-by: Ryan O'Hara <rohara@redhat.com>
> 
> 	In case you still wait for ack:
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

Applied and pushed:
 https://git.kernel.org/cgit/utils/kernel/ipvsadm/ipvsadm.git/commit/?id=4cebeb8ea66

Thank you!
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
