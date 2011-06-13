From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: support more FTP PASV responses
Date: Mon, 13 Jun 2011 17:30:42 +0900
Message-ID: <20110613083041.GG2536@verge.net.au>
References: <alpine.LFD.2.00.1105292354390.1429@ja.ssi.bg>
 <20110531132722.GI22140@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110531132722.GI22140@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

On Tue, May 31, 2011 at 10:27:23PM +0900, Simon Horman wrote:
> On Mon, May 30, 2011 at 12:02:23AM +0300, Julian Anastasov wrote:
> > 
> > 	Change the parsing of FTP commands and responses to
> > support skip character. It allows to detect variations in
> > the 227 PASV response.
> > 
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > ---
> > 
> > 	As this is not exactly a fix, it can be applied to
> > ipvs-next-2.6 after the merge window.
> 
> Thanks, will do.

I have now done so.
