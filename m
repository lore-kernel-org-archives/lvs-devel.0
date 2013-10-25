From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH ipvs 1/2] net: ipvs: sctp: add missing verdict
 assignments in sctp_conn_schedule
Date: Fri, 25 Oct 2013 10:55:35 +0100
Message-ID: <20131025095534.GI17127@verge.net.au>
References: <cover.1382689350.git.dborkman@redhat.com>
 <1af1d5e1aae9df91683625f0cb120b329e8d2f10.1382689350.git.dborkman@redhat.com>
 <20131025113902.2d8dd9d0@redhat.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131025113902.2d8dd9d0@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Daniel Borkmann <dborkman@redhat.com>, lvs-devel@vger.kernel.org, linux-sctp@vger.kernel.org

On Fri, Oct 25, 2013 at 11:39:02AM +0200, Jesper Dangaard Brouer wrote:
> On Fri, 25 Oct 2013 11:05:04 +0200
> Daniel Borkmann <dborkman@redhat.com> wrote:
> 
> > If skb_header_pointer() fails, we need to assign a verdict, that is
> > NF_DROP in this case, otherwise, we would leave the verdict from
> > conn_schedule() uninitialized when returning.
> > 
> > Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> > ---
> 
> Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
> 
> It looks like a good ide, and resembles how we handle these situations
> else were in the IPVS code (e.g. for TCP and UDP).

Likeiwse.

I am wondering if this resolves a but and if so how severe it is.
