From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: try also real server with port 0 in backup server
Date: Fri, 30 Dec 2011 12:24:38 +0900
Message-ID: <20111230032437.GA8119@verge.net.au>
References: <1325191602-1772-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1325191602-1772-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

On Thu, Dec 29, 2011 at 10:46:42PM +0200, Julian Anastasov wrote:
> 	We should not forget to try for real server with port 0
> in the backup server when processing the sync message. We should
> do it in all cases because the backup server can use different
> forwarding method.

Thanks Julian,

I have queued this up for 3.3.
