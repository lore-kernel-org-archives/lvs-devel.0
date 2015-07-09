From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH ipvs] ipvs: call skb_sender_cpu_clear
Date: Thu, 9 Jul 2015 17:50:39 +0900
Message-ID: <20150709085037.GA31426@verge.net.au>
References: <1436429727-6527-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1436429727-6527-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

On Thu, Jul 09, 2015 at 11:15:27AM +0300, Julian Anastasov wrote:
> Reset XPS's sender_cpu on forwarding.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>  net/netfilter/ipvs/ip_vs_xmit.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
>  I see similar patches for other forwarding places...
> that is the reason for this patch.

Am I right in thinking this is not a bug fix?
