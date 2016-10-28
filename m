From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH V3] ipvs does not decrement IP ttl
Date: Fri, 28 Oct 2016 13:49:54 +0200
Message-ID: <20161028114954.GC4041@verge.net.au>
References: <1477502082-24852-1-git-send-email-dwip@linux.vnet.ibm.com>
 <alpine.LFD.2.11.1610262131150.1829@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1477655400; bh=DVvemaMHPuD01IFiq7s9o6dcRbgEG8D8X7IPcpo0i24=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=b73jGa9w3pQ/Nql2vnt+RCKh7POWco+0lfSt4QKvrg/u0IEFLd7DcaeSHuglsw4ow
         iOcEhX9cC5ubjWy+/d/dauU0Fm8LhMc6wN4AbNY1Qq7Sc+VPn8vFW85+FHeGEZPFmM
         P6w8t/R6Ie42cp2tp434VZfTVai5mUFPXFQ96GwA=
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1610262131150.1829@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Dwip Banerjee <dwip@linux.vnet.ibm.com>, lvs-devel@vger.kernel.org

On Wed, Oct 26, 2016 at 09:35:18PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Wed, 26 Oct 2016, Dwip Banerjee wrote:
> 
> > We decrement the IP ttl in all the modes in order to prevent infinite
> > route loops. The changes were done based on Julian Anastasov's
> > suggestions in a prior thread.
> > 
> > The ttl based check/discard and the actual decrement are done in
> > __ip_vs_get_out_rt() and in __ip_vs_get_out_rt_v6(), for the IPv6
> > case. decrement_ttl() implements the actual functionality for the
> > two cases.
> > 
> > 
> > Signed-off-by: Dwip Banerjee <dwip@linux.vnet.ibm.com>
> 
> 	Looks good to me, thanks!
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> 	Simon, please apply to ipvs-next tree, may be
> after fixing the Subject line to contains ipvs: prefix.

Sure, done.
