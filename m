From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] Allow override of CFLAGS
Date: Thu, 8 Aug 2013 11:30:19 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1308081125330.1650@ja.ssi.bg>
References: <1375937999-11660-1-git-send-email-horms@verge.net.au> <alpine.LFD.2.00.1308080846500.1650@ja.ssi.bg> <20130808073444.GB2655@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130808073444.GB2655@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Jesper Dangaard Brouer <jbrouer@redhat.com>


	Hello,

On Thu, 8 Aug 2013, Simon Horman wrote:

> On Thu, Aug 08, 2013 at 09:13:38AM +0300, Julian Anastasov wrote:

> > 	As result, we can support EXTRA_CFLAGS when
> > we want to add -Idir or other options, for example:
> > 
> > Makefile:
> > CFLAGS = $(EXTRA_CFLAGS) -Wall -Wunused -Wstrict-prototypes -g
> > 
> > libipvs/Makefile:
> > CFLAGS = $(EXTRA_CFLAGS) -Wall -Wunused -Wstrict-prototypes -g -fPIC
> > 
> > 	Then:
> > 
> > 1. Add to CFLAGS by providing EXTRA_CFLAGS, override LIBS:
> > 
> > 	make EXTRA_CFLAGS='-I/usr/include/libnl3' \
> > 		LIBS='-lnl-3 -lnl-genl-3 -lnl-3 -lpopt'
> > 
> > 2. Override CFLAGS for both Makefiles because CFLAGS from
> > command line is inherited in sub-make
> > 
> > 	make CFLAGS='-I/usr/include/libnl3 -fPIC' \
> > 		LIBS='-lnl-3 -lnl-genl-3 -lnl-3 -lpopt'
> > 
> > 	We can add EXTRA_LIBS if needed to complement
> > EXTRA_CFLAGS.
> > 
> > 	Also, this is NOT an alternative:
> > 
> > Makefile:
> > CFLAGS+=-Wall -Wunused -Wstrict-prototypes -g
> > 
> > Makefile:
> > CFLAGS+=-Wall -Wunused -Wstrict-prototypes -g -fPIC
> > 
> > 	because make CFLAGS=... will override the var,
> > makefile can override command line vars in such way but
> > it is ugly:
> > 
> > override var=DEFERRED
> > override var:=IMMEDIATE
> > override var+=APPEND
> 
> I was planning to use override but somehow I sent the wrong version of the patch.
> 
> However, I like your EXTRA_CFLAGS and EXTRA_LIBS idea better.
> Should I send a patch or would you like to?

	You can try it, hope it works.

Regards

--
Julian Anastasov <ja@ssi.bg>
