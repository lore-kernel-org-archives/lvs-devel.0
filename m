From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 10/26] IPVS: Add IPv6 handler functions to UDP protocol
 handler.
Date: Wed, 11 Jun 2008 19:18:58 +0200
Message-ID: <48500902.9080006@trash.net>
References: <1213204329-10973-1-git-send-email-juliusv@google.com> <1213204329-10973-11-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1213204329-10973-11-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: "Julius R. Volz" <juliusv@google.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, horms@verge.net.au, davem@davemloft.net, vbusam@google.com

Julius R. Volz wrote:
> Define new IPv6-specific handler functions in UDP protocol handler. Set new
> function pointers in ip_vs_protocol struct to point to these functions.

The last four or five patches could save a lot of duplication
by taking advantage of the fact that only address length and
protocol offset differ. Why don't you move the af-specific logic
to the layer above these handlers and pass the offset to them?


