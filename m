From: Patrick McHardy <kaber@trash.net>
Subject: Re: [IPVS] SCTP Trasport Loadbalancing Support
Date: Thu, 18 Feb 2010 12:31:46 +0100
Message-ID: <4B7D2522.6070101@trash.net>
References: <20100218010642.GD16530@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20100218010642.GD16530@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Venkata Mohan Reddy <mohanreddykv@gmail.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

Simon Horman wrote:
> From: Venkata Mohan Reddy <mohanreddykv@gmail.com>
> 
> Enhance IPVS to load balance SCTP transport protocol packets. This is done
> based on the SCTP rfc 4960. All possible control chunks have been taken
> care. The state machine used in this code looks some what lengthy. I tried
> to make the state machine easy to understand.

Applied, thanks.
