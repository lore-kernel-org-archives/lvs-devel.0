From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] Linking against libpopt is always requited
Date: Wed, 19 Sep 2012 09:21:43 +0900
Message-ID: <20120919002140.GA22707@verge.net.au>
References: <1347845083-32449-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1347845083-32449-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org

On Mon, Sep 17, 2012 at 10:24:43AM +0900, Simon Horman wrote:
> It used to be the case that ipvsadm could be compiled to use
> getopt_long rather than libpopt. However, this is no longer the case
> and linking against libpopt is always requited.
> 
> Signed-off-by: Simon Horman <horms@verge.net.au>

Applied
