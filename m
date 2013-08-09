From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] ipvsadm: detect LIBS and CFLAGS for libnl versions
Date: Fri, 09 Aug 2013 18:08:32 +0200
Message-ID: <52051400.100@redhat.com>
References: <20130809160012.13223.46656.stgit@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130809160012.13223.46656.stgit@localhost>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>, Thomas Graf <tgraf@redhat.com>, Ryan O'Hara <rohara@redhat.com>, Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org

On 08/09/2013 06:00 PM, Jesper Dangaard Brouer wrote:
> Automated detecting of LIBS and CFLAGS for different versions
> of libnl via using pkg-config, in the Makefiles.  This should
> make it easier to compile on different distributions.
>
> Detecting in prioritized order from the most recent version, and only
> the first detected lib is used. Thus, supporting several libnl version
> being installed on the same system.
>
> Only tested with libnl-1 and libnl-3.0, but also adding support for
> libnl-2.0.
>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
>   Makefile         |    8 +++++++-
>   libipvs/Makefile |    7 +++++++
>   2 files changed, 14 insertions(+), 1 deletion(-)
>
> diff --git a/Makefile b/Makefile
> index 6e36d79..4cd59f5 100644
> --- a/Makefile
> +++ b/Makefile
> @@ -65,7 +65,13 @@ RPMBUILD = $(shell				\
>   OBJS		= ipvsadm.o config_stream.o dynamic_array.o
>   LIBS		= -lpopt
>   ifneq (0,$(HAVE_NL))
> -LIBS		+= -lnl
> +LIBS		+= $(shell \
> +		if which pkg-config > /dev/null 2>&1; then \
> +		  if   pkg-config --libs libnl-genl-3.0  2> /dev/null; then :;\
> +		  elif pkg-config --libs libnl-2.0       2> /dev/null; then :;\
> +		  elif pkg-config --libs libnl-1         2> /dev/null; then :;\
> +		  fi; \
> +		else echo "-ln"; fi)

-lnl

Otherwise looks good. Thanks Jesper!

>   endif
>   DEFINES		= -DVERSION=\"$(VERSION)\" -DSCHEDULERS=\"$(SCHEDULERS)\" \
>   		  -DPE_LIST=\"$(PE_LIST)\" $(POPT_DEFINE)
> diff --git a/libipvs/Makefile b/libipvs/Makefile
> index eafc3e5..f845c8b 100644
> --- a/libipvs/Makefile
> +++ b/libipvs/Makefile
> @@ -4,6 +4,13 @@ CC		= gcc
>   CFLAGS		= -Wall -Wunused -Wstrict-prototypes -g -fPIC
>   ifneq (0,$(HAVE_NL))
>   CFLAGS		+= -DLIBIPVS_USE_NL
> +CFLAGS		+= $(shell \
> +		if which pkg-config > /dev/null 2>&1; then \
> +		  if   pkg-config --cflags libnl-3.0  2> /dev/null; then :; \
> +		  elif pkg-config --cflags libnl-2.0  2> /dev/null; then :; \
> +		  elif pkg-config --cflags libnl-1    2> /dev/null; then :; \
> +		  fi; \
> +		fi)
>   endif
>
>   INCLUDE		+= $(shell if [ -f ../../ip_vs.h ]; then	\
>
