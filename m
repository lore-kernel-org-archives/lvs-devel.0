From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] libipvs: Fix memory leak
Date: Tue, 20 Aug 2013 10:28:33 +1000
Message-ID: <20130820002832.GB13751@verge.net.au>
References: <1376844182-4437-1-git-send-email-rohara@redhat.com>
 <alpine.LFD.2.00.1308182115551.3222@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1308182115551.3222@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Ryan O'Hara <rohara@redhat.com>, lvs-devel@vger.kernel.org, Henrique Mecking <henriquemecking@gmail.com>

On Sun, Aug 18, 2013 at 09:18:24PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Sun, 18 Aug 2013, Ryan O'Hara wrote:
> 
> > From: Henrique Mecking <henriquemecking@gmail.com>
> > 
> > If malloc fails, free allocated memory before returning NULL.
> > 
> > Signed-off-by: Ryan O'Hara <rohara@redhat.com>
> 
> 	Looks good to me.
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

Thanks, applied.
