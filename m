From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next] ipvs: fix ipv6 route unreach panic
Date: Mon, 29 Jun 2015 10:06:04 +0900
Message-ID: <20150629010604.GB13676@verge.net.au>
References: <1435313925-107850-1-git-send-email-agartrell@fb.com>
 <alpine.LFD.2.11.1506271431530.19527@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1506271431530.19527@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Alex Gartrell <agartrell@fb.com>, lvs-devel@vger.kernel.org, kernel-team@fb.com

On Sat, Jun 27, 2015 at 02:35:00PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Fri, 26 Jun 2015, Alex Gartrell wrote:
> 
> > Previously there was a trivial panic
> > 
> > unshare -n /bin/bash <<EOF
> > ip addr add dev lo face::1/128
> > ipvsadm -A -t [face::1]:15213
> > ipvsadm -a -t [face::1]:15213 -r b00c::1
> > echo boom | nc face::1 15213
> > EOF
> > 
> > This patch allows us to replicate the net logic above and simply capture
> > the skb_dst(skb)->dev and use that for the purpose of the invocation.
> > 
> > Signed-off-by: Alex Gartrell <agartrell@fb.com>
> 
> 	Looks good to me, thanks! Simon, patch looks suitable
> for ipvs (net) tree.
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

Thanks, I have applied this to to the ipvs tree.
