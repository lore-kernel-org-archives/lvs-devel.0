From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvsadm: init svc in ipvs_get_service
Date: Mon, 26 Aug 2013 16:14:07 +0900
Message-ID: <20130826071407.GI26682@verge.net.au>
References: <1377340853-2391-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1377340853-2391-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

On Sat, Aug 24, 2013 at 01:40:53PM +0300, Julian Anastasov wrote:
> ipvs_get_service() needs to init the allocated svc
> for the non-netlink case due to the used CHECK_COMPAT_SVC
> macro that includes pe_name[0] check in CHECK_PE. Use
> calloc to avoid reading random data.
> 
> For the netlink case use malloc as before.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Thanks, applied.
