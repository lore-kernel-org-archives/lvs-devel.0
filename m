From: "Ryan O'Hara" <rohara@redhat.com>
Subject: Re: [PATCH] ipvsadm: Fix svc->pe_name conditional
Date: Mon, 19 Aug 2013 09:52:17 -0500
Message-ID: <20130819145217.GA12716@redhat.com>
References: <1376844063-4298-1-git-send-email-rohara@redhat.com>
 <alpine.LFD.2.00.1308182035550.3222@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1308182035550.3222@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org

On Sun, Aug 18, 2013 at 09:13:39PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Sun, 18 Aug 2013, Ryan O'Hara wrote:
> 
> > The pe_name in ipvs_service_t is an array, so comparing it NULL has no
> > effect. Use strlen to see if pe_name is set.
> > 
> > Signed-off-by: Ryan O'Hara <rohara@redhat.com>
> 
> 	Looks good to me.
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> 	Or may be we can avoid strlen? Eg. svc->pe_name[0] ?

Agree. I'll resend the patch without strlen.

> 	It looks like CHECK_PE has similar problem and more:
> 
> - Do we really work without NL support if CHECK_PE
> always succeeds in 'if (s->pe_name)'? I have a doubt.

Not sure about this. I've always been under the impression that NL is
absolutely required.

> - CHECK_PE and CHECK_IPV4 as part of CHECK_COMPAT_SVC use
> 'return' and we can leak svc in ipvs_get_service()
>
> - in ipvs_get_service() CHECK_PE does not need to be called,
> it is already part of CHECK_COMPAT_SVC

Yes. I'm tempted to remove these macros due to the 'return'
issue. Thoughts?

> - ipvs_get_service uses malloc but later calls CHECK_PE, may be
> malloc should be changed with calloc

Aside from the fact that CHECK_PE could return without freeing memory,
I don't see the problem here.

Ryan


> > ---
> >  libipvs/libipvs.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/libipvs/libipvs.c b/libipvs/libipvs.c
> > index c3c3b0a..ebc46e9 100644
> > --- a/libipvs/libipvs.c
> > +++ b/libipvs/libipvs.c
> > @@ -229,7 +229,7 @@ static int ipvs_nl_fill_service_attr(struct nl_msg *msg, ipvs_service_t *svc)
> >  	}
> >  
> >  	NLA_PUT_STRING(msg, IPVS_SVC_ATTR_SCHED_NAME, svc->sched_name);
> > -	if (svc->pe_name)
> > +	if (strlen(svc->pe_name))
> >  		NLA_PUT_STRING(msg, IPVS_SVC_ATTR_PE_NAME, svc->pe_name);
> >  	NLA_PUT(msg, IPVS_SVC_ATTR_FLAGS, sizeof(flags), &flags);
> >  	NLA_PUT_U32(msg, IPVS_SVC_ATTR_TIMEOUT, svc->timeout);
> > -- 
> > 1.8.1.4
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
