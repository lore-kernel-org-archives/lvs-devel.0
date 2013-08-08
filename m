From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] ipvsadm: fix compiling tool on distros with only libnl-1
Date: Thu, 08 Aug 2013 14:23:44 +0200
Message-ID: <52038DD0.4080500@redhat.com>
References: <52034D12.4070100@redhat.com> <20130808121054.26226.26508.stgit@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130808121054.26226.26508.stgit@localhost>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>, Thomas Graf <tgraf@redhat.com>, Ryan O'Hara <rohara@redhat.com>, Julian Anastasov <ja@ssi.bg>, Jesper Dangaard Brouer <jbrouer@redhat.com>, lvs-devel@vger.kernel.org

On 08/08/2013 02:10 PM, Jesper Dangaard Brouer wrote:
> Some distros have not moved to libnl3 yet.  Add a fallback option
> for compiling on distro's with only libnl1.
>
> Using pkg-config to detect what versions of libnl is available.
>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Acked-by: Daniel Borkmann <dborkman@redhat.com>

> ---
>   libipvs/Makefile  |    5 +++++
>   libipvs/libipvs.c |    5 +++++
>   2 files changed, 10 insertions(+)
>
> diff --git a/libipvs/Makefile b/libipvs/Makefile
> index a527a7f..eafc3e5 100644
> --- a/libipvs/Makefile
> +++ b/libipvs/Makefile
> @@ -10,6 +10,11 @@ INCLUDE		+= $(shell if [ -f ../../ip_vs.h ]; then	\
>   		     echo "-I../../."; fi;)
>   DEFINES		= $(shell if [ ! -f ../../ip_vs.h ]; then	\
>   		    echo "-DHAVE_NET_IP_VS_H"; fi;)
> +DEFINES		+= $(shell if which pkg-config > /dev/null 2>&1; then \
> +			 if   pkg-config --exists libnl-3.0; then :; \
> +			 elif pkg-config --exists libnl-2.0; then :; \
> +			 elif pkg-config --exists libnl-1; \
> +			 then echo "-DFALLBACK_LIBNL1"; fi; fi)
>
>   .PHONY		= all clean install dist distclean rpm rpms
>   STATIC_LIB	= libipvs.a
> diff --git a/libipvs/libipvs.c b/libipvs/libipvs.c
> index c3c3b0a..2b066d2 100644
> --- a/libipvs/libipvs.c
> +++ b/libipvs/libipvs.c
> @@ -32,6 +32,11 @@ static void* ipvs_func = NULL;
>   struct ip_vs_getinfo ipvs_info;
>
>   #ifdef LIBIPVS_USE_NL
> +#ifdef FALLBACK_LIBNL1
> +#define nl_sock         nl_handle
> +#define nl_socket_alloc nl_handle_alloc
> +#define nl_socket_free  nl_handle_destroy
> +#endif
>   static struct nl_sock *sock = NULL;
>   static int family, try_nl = 1;
>   #endif
>
