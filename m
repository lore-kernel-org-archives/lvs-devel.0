From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 4/5] IPVS: Allow compilation with CONFIG_SYSCTL 	disabled
Date: Tue, 01 Feb 2011 18:30:11 +0100
Message-ID: <4D484323.1060404@trash.net>
References: <7j2t3lt.112d3171f5f31f2acb18786b51a8e1ac@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7j2t3lt.112d3171f5f31f2acb18786b51a8e1ac@obelix.schillstrom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, Randy Dunlap <randy.dunlap@oracle.com>, Stephen Rothwell <sfr@canb.auug.org.au>

Am 01.02.2011 18:11, schrieb Hans Schillstrom:
>> [PATCH 4/5] IPVS: Allow compilation with CONFIG_SYSCTL disabled
>> >
>> >This is a rather naieve approach to allowing PVS to compile with
>> >CONFIG_SYSCTL disabled.  I am working on a more comprehensive patch which
>> >will remove compilation of all sysctl-related IPVS code when CONFIG_SYSCTL
>> >is disabled.
>> >
>> >Cc: Hans Schillstrom <hans@schillstrom.com>
>> >Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
>> >Signed-off-by: Simon Horman <horms@verge.net.au>
> Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
> Tested-by: Hans Schillstrom <hans@schillstrom.com>

Applied, thanks.
