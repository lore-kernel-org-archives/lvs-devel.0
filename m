From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 1/2] libipvs: Remove redundant CHECK_PE
Date: Thu, 22 Aug 2013 14:04:56 +0900
Message-ID: <20130822050456.GB26682@verge.net.au>
References: <1377008983-23901-1-git-send-email-rohara@redhat.com>
 <alpine.LFD.2.00.1308201752370.1698@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1308201752370.1698@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Ryan O'Hara <rohara@redhat.com>, lvs-devel@vger.kernel.org

On Tue, Aug 20, 2013 at 05:54:09PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Tue, 20 Aug 2013, Ryan O'Hara wrote:
> 
> > Since the CHECK_COMPAT_SVC macro calls CHECK_PE, remove the extra
> > CHECK_PE call from ipvs_get_service().
> > 
> > Signed-off-by: Ryan O'Hara <rohara@redhat.com>
> 
> 	Thanks, looks good,
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

Thanks, applied.

> 
> > ---
> >  libipvs/libipvs.c | 1 -
> >  1 file changed, 1 deletion(-)
> > 
> > diff --git a/libipvs/libipvs.c b/libipvs/libipvs.c
> > index ef242db..309ccce 100644
> > --- a/libipvs/libipvs.c
> > +++ b/libipvs/libipvs.c
> > @@ -965,7 +965,6 @@ ipvs_get_service_err2:
> >  #endif
> >  
> >  	CHECK_COMPAT_SVC(svc, NULL);
> > -	CHECK_PE(svc, NULL);
> >  	if (getsockopt(sockfd, IPPROTO_IP, IP_VS_SO_GET_SERVICE,
> >  		       (char *)svc, &len)) {
> >  		free(svc);
> > -- 
> > 1.8.1.4
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 
