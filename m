From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 1/6] ipvs: timeout tables do not need GFP_ATOMIC
 allocation
Date: Mon, 23 Apr 2012 21:32:32 +0900
Message-ID: <20120423123232.GA20296@verge.net.au>
References: <6dfqp4f.b2278bba6d7c32d57e4d73422014448c@obelix.schillstrom.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6dfqp4f.b2278bba6d7c32d57e4d73422014448c@obelix.schillstrom.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org

On Fri, Apr 13, 2012 at 10:14:19PM +0200, Hans Schillstrom wrote:
> Hello
> All 6 patches look fine to me, and are all called from process context
> 
> >---- Original Message ----
> >From: Julian Anastasov <ja@ssi.bg>
> >To: "Simon Horman" <horms@verge.net.au>
> >Cc: lvs-devel@vger.kernel.org
> >Sent: Fri, Apr 13, 2012, 3:49 PM
> >Subject: [PATCH 1/6] ipvs: timeout tables do not need GFP_ATOMIC allocation
> >
> >They are called only on initialization.
> >
> >Signed-off-by: Julian Anastasov <ja@ssi.bg>
> 
> Signed-off-by: Hans Schillstrom <hans@schillstrom.com>

Thanks, I have applied these to my ipvs-next tree which I will push
to kernel.org shortly.
