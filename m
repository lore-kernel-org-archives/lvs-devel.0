From: Simon Horman <horms@verge.net.au>
Subject: Re: [rfc v2 03/10] ipvs network name space aware: conn
Date: Wed, 27 Oct 2010 07:35:26 +0900
Message-ID: <20101026223525.GB2270@verge.net.au>
References: <20101022200934.822223308@joe.akashicho.tokyo.vergenet.net>
 <20101022202357.344354364@joe.akashicho.tokyo.vergenet.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101022202357.344354364@joe.akashicho.tokyo.vergenet.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, Julian Anastasov <ja@ssi.bg>, Daniel Lezcano <daniel.lezcano@free.fr>, Wensong Zhang <wensong@linux-vs.org>

On Fri, Oct 22, 2010 at 10:09:37PM +0200, Simon Horman wrote:
> 
> This patch just contains ip_vs_conn.c
> and does the normal
>  - moving to vars to struct ipvs
>  - adding per netns init and exit
> 
> proc_fs required some extra work with adding/chaning private data to get the net ptr.
> 
> Signed-off-by:Hans Schillstrom <hans.schillstrom@ericsson.com>

Sorry, I messed this patch up a bit and will repost.

* I still have not addressed any of the problems beyond the
  original scope of my post, which was to rebase Hans's changes.
  In particular I have not addressed any of the issues that
  Julian raised in response to my patches. Hans, are you planning
  to look into that or should I take another stab at things?

