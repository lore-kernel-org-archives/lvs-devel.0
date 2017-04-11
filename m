From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH nf-next] ipvs: remove unused function
 ip_vs_set_state_timeout
Date: Wed, 12 Apr 2017 05:55:50 +0900
Message-ID: <20170411205550.GC32569@verge.net.au>
References: <20170410195044.19646-1-aconole@bytheb.org>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1491944153; bh=VI/lj/KCccjMAlQGw6t2AesWfKi0SflAJWODfd+gucs=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=QKWy/4+308Zfylie2LI567v5b7SQ1QDVbFW8RdBTjDdJxJU1dA9+/1dsxKjw5zvd/
         OoqUGE1e4GG8D3Hnmy7ARFfbL7xsbiDOvjKImP4kot/wqC9s3+2xF47heakkbwS+hM
         VEdQEbFG3EBWfXvaJoPwCVpa/AmPsuTe1TiNpt3o=
Content-Disposition: inline
In-Reply-To: <20170410195044.19646-1-aconole@bytheb.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Aaron Conole <aconole@bytheb.org>
Cc: netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Apr 10, 2017 at 03:50:44PM -0400, Aaron Conole wrote:
> There are no in-tree callers of this function and it isn't exported.
> 
> Signed-off-by: Aaron Conole <aconole@bytheb.org>

Thanks, applied to ipvs-next.
