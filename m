From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2] ipvsadm: Fix svc->pe_name conditional
Date: Tue, 20 Aug 2013 10:23:45 +1000
Message-ID: <20130820002345.GC7506@verge.net.au>
References: <1376924188-14556-1-git-send-email-rohara@redhat.com>
 <alpine.LFD.2.00.1308191816010.1606@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1308191816010.1606@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Ryan O'Hara <rohara@redhat.com>, lvs-devel@vger.kernel.org

On Mon, Aug 19, 2013 at 06:17:11PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 19 Aug 2013, Ryan O'Hara wrote:
> 
> > The pe_name in ipvs_service_t is an array, so comparing it NULL has no
> > effect. Check first byte of pe_name.
> > 
> > Signed-off-by: Ryan O'Hara <rohara@redhat.com>
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

Thanks, applied.
