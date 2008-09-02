From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCHv2 RFC 14/25] IPVS: Add and bind IPv6 xmit functions
Date: Tue, 2 Sep 2008 17:32:18 +1000
Message-ID: <20080902073216.GG13730@verge.net.au>
References: <1220273782-19901-1-git-send-email-juliusv@google.com> <1220273782-19901-15-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1220273782-19901-15-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Mon, Sep 01, 2008 at 02:56:11PM +0200, Julius Volz wrote:
> Add xmit functions for IPv6. Also add the already needed __ip_vs_get_out_rt_v6()
> to ip_vs_core.c. Bind the new xmit functions to v6 connections.

./scripts/checkpatch.pl seems unhappy about a number of things here.
I relise this is because you are following the existing style
in the file. But in this new code it might make sense
to follow checkpatch.pl's advice.
