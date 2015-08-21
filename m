From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next 0/2] ipvs: new sync parameters
Date: Fri, 21 Aug 2015 09:10:57 -0700
Message-ID: <20150821161057.GC24370@verge.net.au>
References: <1437912208-29538-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1437912208-29538-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

On Sun, Jul 26, 2015 at 03:03:26PM +0300, Julian Anastasov wrote:
> Add new parameters for the sync damon:
> sync_maxlen, mcast_group, mcast_port, mcast_ttl.
> 
> Stop sending the sync packets with DF=1 to allow
> fragmentation, eg. on possible MTU changes, reported
> by Dan Carpenter.
> 
> This patchset is based on net-next but requires also the
> "ipvs: call rtnl_lock early" change.

Thanks, I have queued this up.
