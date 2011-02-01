From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 5/5] IPVS: Remove ip_vs_sync_cleanup from section 	__exit
Date: Tue, 01 Feb 2011 18:31:20 +0100
Message-ID: <4D484368.9060904@trash.net>
References: <7j2t3lt.e4ea73185e9c52a3d68dc337ed04b422@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <7j2t3lt.e4ea73185e9c52a3d68dc337ed04b422@obelix.schillstrom.com>
Sender: linux-next-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, Randy Dunlap <randy.dunlap@oracle.com>, Stephen Rothwell <sfr@canb.auug.org.au>

Am 01.02.2011 18:12, schrieb Hans Schillstrom:
>> [PATCH 5/5] IPVS: Remove ip_vs_sync_cleanup from section __exit
>> >
>> >ip_vs_sync_cleanup() may be called from ip_vs_init() on error
>> >and thus needs to be accesible from section __init
>> >
>> >Reporte-by: Randy Dunlap <randy.dunlap@oracle.com>
>> >Signed-off-by: Simon Horman <horms@verge.net.au>
> Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
> Tested-by: Hans Schillstrom <hans@schillstrom.com>
> 

Applied, thanks.
