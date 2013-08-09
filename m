From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v2] ipvsadm: detect LIBS and CFLAGS for libnl versions
Date: Fri, 09 Aug 2013 18:33:29 +0200
Message-ID: <520519D9.1070003@redhat.com>
References: <20130809160012.13223.46656.stgit@localhost> <52051400.100@redhat.com> <20130809182853.61660efe@redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130809182853.61660efe@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Cc: Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>, Thomas Graf <tgraf@redhat.com>, Ryan O'Hara <rohara@redhat.com>, Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org

On 08/09/2013 06:28 PM, Jesper Dangaard Brouer wrote:
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
> V2: Fix small bug noticed by Daniel, fall-through libs case missed a "l"
>
>   Makefile         |    8 +++++++-
>   libipvs/Makefile |    7 +++++++
>   2 files changed, 14 insertions(+), 1 deletion(-)

Acked-by: Daniel Borkmann <dborkman@redhat.com>
