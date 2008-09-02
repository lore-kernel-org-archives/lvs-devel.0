From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCHv2 RFC 13/25] IPVS: Add IPv6 support to xmit() support
	functions
Date: Wed, 3 Sep 2008 08:28:16 +1000
Message-ID: <20080902222814.GA6035@verge.net.au>
References: <1220273782-19901-1-git-send-email-juliusv@google.com> <1220273782-19901-14-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1220273782-19901-14-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Mon, Sep 01, 2008 at 02:56:10PM +0200, Julius Volz wrote:
> Add IPv6 support to IP_VS_XMIT() and to the xmit routing cache, introducing
> a new function __ip_vs_get_out_rt_v6().

Hi,

sorry, I missed this one yesteray. Could you run checkpatch.pl over
this one also?
