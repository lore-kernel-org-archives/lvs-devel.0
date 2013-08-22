From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 2/2] libipvs: CHECK_IPV4 and CHECK_PE macros should not
 call return
Date: Thu, 22 Aug 2013 14:06:16 +0900
Message-ID: <20130822050615.GC26682@verge.net.au>
References: <1377008991-23950-1-git-send-email-rohara@redhat.com>
 <alpine.LFD.2.00.1308201754140.1698@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1308201754140.1698@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Ryan O'Hara <rohara@redhat.com>, lvs-devel@vger.kernel.org

On Tue, Aug 20, 2013 at 05:57:33PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Tue, 20 Aug 2013, Ryan O'Hara wrote:
> 
> > The CHECK_IPV4 and CHECK_PE macros will call return if a conditional
> > is true. This is a problem for any caller that has allocated memory
> > and needs to do cleanup before returning. This patch replaces the
> > return in both macros with a goto statement. As a result, each caller
> > needs a out_err label.
> > 
> > Signed-off-by: Ryan O'Hara <rohara@redhat.com>
> 
> 	Thanks for fixing this problem!
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

Thanks, applied.
