From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2] ipvsadm: fix compiling tool on distros with only
 libnl-1
Date: Fri, 9 Aug 2013 17:32:10 +0900
Message-ID: <20130809083210.GB29046@verge.net.au>
References: <52034D12.4070100@redhat.com>
 <20130808121054.26226.26508.stgit@localhost>
 <20130808200017.GA3075@redhat.com>
 <20130809054736.GB6041@verge.net.au>
 <20130809082714.6a5b5cc2@redhat.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130809082714.6a5b5cc2@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Ryan O'Hara <rohara@redhat.com>, Wensong Zhang <wensong@linux-vs.org>, Thomas Graf <tgraf@redhat.com>, Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, Daniel Borkmann <dborkman@redhat.com>

On Fri, Aug 09, 2013 at 08:27:14AM +0200, Jesper Dangaard Brouer wrote:
> 
> Some distros have not moved to libnl3 yet.  Add a fallback option
> for compiling on distro's with only libnl1.
> 
> Using pkg-config to detect what versions of libnl is available.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Acked-by: Daniel Borkmann <dborkman@redhat.com>
> ---
> V2: My git mail config were wrongly configured, and the orig
>     patch only reached RedHat recipients, thus I'm resending
>     hoping my email client does not screw the patches...
> 
>  libipvs/Makefile  |    5 +++++
>  libipvs/libipvs.c |    5 +++++
>  2 files changed, 10 insertions(+)

Thanks, applied.
