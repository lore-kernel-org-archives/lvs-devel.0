From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL 0/5] IPVS Updates for v4.18
Date: Fri, 27 Apr 2018 00:19:16 +0200
Message-ID: <20180426221916.chkysif3sp46gdxk@salvia>
References: <20180419085614.7437-1-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20180419085614.7437-1-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Thu, Apr 19, 2018 at 10:56:09AM +0200, Simon Horman wrote:
> Hi Pablo,
> 
> please consider these IPVS enhancements for v4.18.
> 
> * Whitepace cleanup
> 
> * Add Maglev hashing algorithm as a IPVS scheduler
> 
>   Inju Song says "Implements the Google's Maglev hashing algorithm as a
>   IPVS scheduler.  Basically it provides consistent hashing but offers some
>   special features about disruption and load balancing.
> 
>   1) minimal disruption: when the set of destinations changes,
>      a connection will likely be sent to the same destination
>      as it was before.
> 
>   2) load balancing: each destination will receive an almost
>      equal number of connections.
> 
>  Seel also: [3.4 Consistent Hasing] in
>  https://www.usenix.org/system/files/conference/nsdi16/nsdi16-paper-eisenbud.pdf
>  "
> 
> * Fix to correct implementation of Knuth's multiplicative hashing
>   which is used in sh/dh/lblc/lblcr algorithms. Instead the
>   implementation provided by the hash_32() macro is used.

Pulled, thanks Simon.
