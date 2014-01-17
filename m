From: "Ryan O'Hara" <rohara@redhat.com>
Subject: Re: [PATCH] libipvs: Initialize ipvs_service_t variable
Date: Fri, 17 Jan 2014 15:15:17 -0600
Message-ID: <20140117211517.GB7772@redhat.com>
References: <1389981226-6668-1-git-send-email-rohara@redhat.com>
 <alpine.LFD.2.11.1401172253420.2244@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1401172253420.2244@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

On Fri, Jan 17, 2014 at 11:03:43PM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Fri, 17 Jan 2014, Ryan O'Hara wrote:
> 
> > The ipvs_get_service function declares an ipvs_service_t type variable
> > and initializes some of the values, but should really start by
> > initializing the entire structure.
> > 
> > Signed-off-by: Ryan O'Hara <rohara@redhat.com>
> > ---
> >  libipvs/libipvs.c | 1 +
> >  1 file changed, 1 insertion(+)
> > 
> > diff --git a/libipvs/libipvs.c b/libipvs/libipvs.c
> > index d2fec49..8baafed 100644
> > --- a/libipvs/libipvs.c
> > +++ b/libipvs/libipvs.c
> > @@ -942,6 +942,7 @@ ipvs_get_service(__u32 fwmark, __u16 af, __u16 protocol, union nf_inet_addr addr
> >  		if (!svc)
> >  			return NULL;
> >  
> > +		memset(&tsvc, 0, sizeof(tsvc));
> >  		tsvc.fwmark = fwmark;
> >  		tsvc.af = af;
> >  		tsvc.protocol= protocol;
> > -- 
> > 1.8.1.4
> 
> 	Yes, it is a good idea. Another variant is to
> change malloc to calloc. May be ipvs_nl_fill_service_attr()
> can not crash in all cases when reading svc->pe_name[].
> As for the kernel part, ip_vs_genl_parse_service() uses just 
> the initialized fields when full_entry=0 for IPVS_CMD_GET_SERVICE
> but it is better to avoid problems in the future.

Right. This 'bug' was found while running the code through a static
analyzer, which finds all sorts of nit-picks. Since the variable in
question here is on the stack, a simple memset seems sufficient. Sorry
for trivial patches, just trying to get rid of the complaints from the
analyzer.

Ryan

> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
