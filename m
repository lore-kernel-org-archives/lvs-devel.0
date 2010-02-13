From: Simon Horman <horms@verge.net.au>
Subject: Re: SCTP Trasport Loadbalancing Support for IPVS
Date: Sun, 14 Feb 2010 10:51:36 +1100
Message-ID: <20100213235136.GF16999@verge.net.au>
References: <20100212122301.GA4376@mohan-laptop>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100212122301.GA4376@mohan-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mohan Reddy <mohanreddykv@gmail.com>
Cc: wensong@linux-vs.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, ja@ssi.bg, kvmrdy@gmail.com

On Fri, Feb 12, 2010 at 05:53:04PM +0530, Mohan Reddy wrote:
> Hi Simon&Wensong,
> 
> Please some review this code and let me know your comments. I am re-posting this
> as there is no response from any one. You are welcome for any type of comments.
> 
> This patch enhances IPVS to load balance SCTP transport protocol packets. This
> is done based on the SCTP rfc 4960. All possible control chunks have been 
> taken care. The state machine used in this code looks some what lengthy. I
> tried to make the state machine easy to understand. 
> 
> This patch is against nf-next.2.6 tree.

Hi Mohan,

sorry for not reviewing your earlier posting.
I've been insanely busy over the past few weeks.
I will try to make time in the next few days.
