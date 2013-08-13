From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2] ipvsadm: detect LIBS and CFLAGS for libnl versions
Date: Tue, 13 Aug 2013 12:17:34 +1000
Message-ID: <20130813021734.GI4885@verge.net.au>
References: <20130809160012.13223.46656.stgit@localhost>
 <52051400.100@redhat.com>
 <20130809182853.61660efe@redhat.com>
 <520519D9.1070003@redhat.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <520519D9.1070003@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Daniel Borkmann <dborkman@redhat.com>
Cc: Jesper Dangaard Brouer <jbrouer@redhat.com>, Wensong Zhang <wensong@linux-vs.org>, Thomas Graf <tgraf@redhat.com>, Ryan O'Hara <rohara@redhat.com>, Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org

On Fri, Aug 09, 2013 at 06:33:29PM +0200, Daniel Borkmann wrote:
> On 08/09/2013 06:28 PM, Jesper Dangaard Brouer wrote:
> >Automated detecting of LIBS and CFLAGS for different versions
> >of libnl via using pkg-config, in the Makefiles.  This should
> >make it easier to compile on different distributions.
> >
> >Detecting in prioritized order from the most recent version, and only
> >the first detected lib is used. Thus, supporting several libnl version
> >being installed on the same system.
> >
> >Only tested with libnl-1 and libnl-3.0, but also adding support for
> >libnl-2.0.
> >
> >Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> >---
> >V2: Fix small bug noticed by Daniel, fall-through libs case missed a "l"
> >
> >  Makefile         |    8 +++++++-
> >  libipvs/Makefile |    7 +++++++
> >  2 files changed, 14 insertions(+), 1 deletion(-)
> 
> Acked-by: Daniel Borkmann <dborkman@redhat.com>

Thanks, I will queue this up.
