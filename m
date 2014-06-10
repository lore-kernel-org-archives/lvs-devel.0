From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvsadm: Fix list daemon to show backup daemon
Date: Wed, 11 Jun 2014 08:48:42 +0900
Message-ID: <20140610234841.GD20738@verge.net.au>
References: <1400642071-10408-1-git-send-email-rohara@redhat.com>
 <alpine.LFD.2.11.1406061018180.12067@ja.home.ssi.bg>
 <20140610094350.1e2d3a43@redhat.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140610094350.1e2d3a43@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Cc: Julian Anastasov <ja@ssi.bg>, Ryan O'Hara <rohara@redhat.com>, lvs-devel@vger.kernel.org

On Tue, Jun 10, 2014 at 09:43:50AM +0200, Jesper Dangaard Brouer wrote:
> On Fri, 6 Jun 2014 10:24:09 +0300 (EEST) Julian Anastasov <ja@ssi.bg> wrote:
> 
> > On Tue, 20 May 2014, Ryan O'Hara wrote:
> > 
> > > The list_daemon function in ipvsadm.c will show the master daemon
> > > twice, but never the backup daemon. This patch replaces the redundant
> > > check for IP_VS_STATE_MASTER with a check for IP_VS_STATE_BACKUP, then
> > > prints the appropriate message.
> > > 
> > > Signed-off-by: Ryan O'Hara <rohara@redhat.com>
> > 
> > 	In case you still wait for ack:
> > 
> > Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> Applied and pushed:
>  https://git.kernel.org/cgit/utils/kernel/ipvsadm/ipvsadm.git/commit/?id=4cebeb8ea66

Thanks Jesper,

I wonder if we should consider making a bugfix release in the
not to distant future.
