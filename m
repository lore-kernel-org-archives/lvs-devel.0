From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch] ipvs: provide default ip_vs_conn_{in,out}_get_proto
Date: Mon, 02 Aug 2010 17:13:06 +0200
Message-ID: <4C56E082.2090100@trash.net>
References: <20100726075632.GB11755@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20100726075632.GB11755@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On 26.07.2010 09:56, Simon Horman wrote:
> This removes duplicate code by providing a default implementation
> which is used by 3 of the 4 modules that provide these call.

Applied, thanks.
