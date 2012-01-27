From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net] ipvs: fix matching of fwmark templates during
 scheduling
Date: Fri, 27 Jan 2012 10:37:33 +0900
Message-ID: <20120127013732.GC31499@verge.net.au>
References: <1327565717-1649-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1327565717-1649-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

On Thu, Jan 26, 2012 at 10:15:17AM +0200, Julian Anastasov wrote:
> 	Commit f11017ec2d1859c661f4e2b12c4a8d250e1f47cf (2.6.37)
> moved the fwmark variable in subcontext that is invalidated before
> reaching the ip_vs_ct_in_get call. As vaddr is provided as pointer
> in the param structure make sure the fwmark variable is in
> same context. As the fwmark templates can not be matched,
> more and more template connections are created and the
> controlled connections can not go to single real server.

Ouch, my bad.

I will forward on for inclusion in 3.3 and stable.
