From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH nf-next] ipvs: remove unused function
 ip_vs_set_state_timeout
Date: Mon, 17 Apr 2017 07:34:59 +0900
Message-ID: <20170416223457.GA18680@verge.net.au>
References: <20170410195044.19646-1-aconole@bytheb.org>
 <20170414001309.GA28870@salvia>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1492382104; bh=vwFbpEgTf+9rwEORMzbU3qpzp4OyBj850M2x9PHzEV0=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=r6JpTaDPX08RCjxLHkbJj/YudtRk9IrCkJUZTbLl0RvPJdVY+UFqSg3ofvUoAQw3T
         0cpNyQVdcfPF3yCnMYSv79WAF/X26GX+EKN4gBBmPluWurMfZ0t8E4j9LGljPWlDHg
         Nz40BrbF+GxJgsjH86R79fq1GFqsABtEUJzzEdcE=
Content-Disposition: inline
In-Reply-To: <20170414001309.GA28870@salvia>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Aaron Conole <aconole@bytheb.org>, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org

On vr, apr 14, 2017 at 02:13:09 +0200, Pablo Neira Ayuso wrote:
> On Mon, Apr 10, 2017 at 03:50:44PM -0400, Aaron Conole wrote:
> > There are no in-tree callers of this function and it isn't exported.
> 
> Simon, let me know if you want to take this, or just add your
> Signed-off-by.

Hi Pablo,

I will take this.
