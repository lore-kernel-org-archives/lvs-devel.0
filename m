From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/3] ipvs: extend connection flags to 32 bits
Date: Fri, 17 Sep 2010 14:20:48 +0200
Message-ID: <4C935D20.2020901@trash.net>
References: <Pine.LNX.4.58.1009162339520.6976@u.domain.uli>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.58.1009162339520.6976@u.domain.uli>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

Am 16.09.2010 22:42, schrieb Julian Anastasov:
> 
> 	Extend connection flags to 32 bits:
> 
> - the sync protocol supports 16 bits only, so bits 0..15 should be
> used only for flags that should go to backup server, bits 16 and
> above should be allocated for flags not sent to backup.
> 
> - use IP_VS_CONN_F_DEST_MASK as mask of connection flags in
> destination that can be changed by user space
> 
> - allow IP_VS_CONN_F_ONE_PACKET to be set in destination

Applied, thanks.
