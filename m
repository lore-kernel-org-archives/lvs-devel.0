From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] Allow override of CFLAGS
Date: Thu, 8 Aug 2013 16:34:44 +0900
Message-ID: <20130808073444.GB2655@verge.net.au>
References: <1375937999-11660-1-git-send-email-horms@verge.net.au>
 <alpine.LFD.2.00.1308080846500.1650@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1308080846500.1650@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Jesper Dangaard Brouer <jbrouer@redhat.com>

On Thu, Aug 08, 2013 at 09:13:38AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 8 Aug 2013, Simon Horman wrote:
> 
> > When building ipvsadm this allows make to add to CFLAGS supplied
> > on the command line.
> 
> 	Hm, the change below simply adds -I, variable
> override is already possible before the change. Is the
> commit correct?

The commit is completely wrong, sorry!

> > This seems to make sense as Makefile and libipvs/Makefile
> > add different CFLAGS but it may be desirable to supply supplementary
> > flags when building ipvsadm.
> > 
> > In particular the following may be useful when building ipvsadm
> > on Debian Jessie.
> > 
> > make CFLAGS='-I/usr/include/libnl3' LIBS='-lnl-3 -lnl-genl-3 -lnl-3 -lpopt'
> 
> 	Hm, such command line vars override the
> vars in Makefiles, they do not add to them. So, it is
> not good for libipvs where -fPIC is the difference.
> 
> 	make has such rules for vars:
> 
> Order of variables:
> - command line
> - makefile
> - environment
> 
> For example: var=env make var=command_line
> If -e is provided order is: command line, environment, makefile
> Sub-make: only command line and environment vars are inherited,
> 	use 'export' to provide variables defined in makefile
> 
> 	As result, we can support EXTRA_CFLAGS when
> we want to add -Idir or other options, for example:
> 
> Makefile:
> CFLAGS = $(EXTRA_CFLAGS) -Wall -Wunused -Wstrict-prototypes -g
> 
> libipvs/Makefile:
> CFLAGS = $(EXTRA_CFLAGS) -Wall -Wunused -Wstrict-prototypes -g -fPIC
> 
> 	Then:
> 
> 1. Add to CFLAGS by providing EXTRA_CFLAGS, override LIBS:
> 
> 	make EXTRA_CFLAGS='-I/usr/include/libnl3' \
> 		LIBS='-lnl-3 -lnl-genl-3 -lnl-3 -lpopt'
> 
> 2. Override CFLAGS for both Makefiles because CFLAGS from
> command line is inherited in sub-make
> 
> 	make CFLAGS='-I/usr/include/libnl3 -fPIC' \
> 		LIBS='-lnl-3 -lnl-genl-3 -lnl-3 -lpopt'
> 
> 	We can add EXTRA_LIBS if needed to complement
> EXTRA_CFLAGS.
> 
> 	Also, this is NOT an alternative:
> 
> Makefile:
> CFLAGS+=-Wall -Wunused -Wstrict-prototypes -g
> 
> Makefile:
> CFLAGS+=-Wall -Wunused -Wstrict-prototypes -g -fPIC
> 
> 	because make CFLAGS=... will override the var,
> makefile can override command line vars in such way but
> it is ugly:
> 
> override var=DEFERRED
> override var:=IMMEDIATE
> override var+=APPEND

I was planning to use override but somehow I sent the wrong version of the patch.

However, I like your EXTRA_CFLAGS and EXTRA_LIBS idea better.
Should I send a patch or would you like to?

> 
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> > ---
> >  Makefile | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/Makefile b/Makefile
> > index 6e36d79..c8c1eec 100644
> > --- a/Makefile
> > +++ b/Makefile
> > @@ -48,7 +48,7 @@ STATIC_LIBS	= libipvs/libipvs.a
> >  ifeq "${ARCH}" "sparc64"
> >      CFLAGS = -Wall -Wunused -Wstrict-prototypes -g -m64 -pipe -mcpu=ultrasparc -mcmodel=medlow
> >  else
> > -    CFLAGS = -Wall -Wunused -Wstrict-prototypes -g
> > +    CFLAGS = -I/usr/include/libnl3 -Wall -Wunused -Wstrict-prototypes -g
> >  endif
> >  
> >  
> > -- 
> > 1.8.3.2
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 
