From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] net: netfilter: Replace explicit NULL comparison with !
 operator
Date: Tue, 4 Apr 2017 19:56:00 +0200
Message-ID: <20170404175600.GB1154@salvia>
References: <20170329101406.GA29770@arushi-HP-Pavilion-Notebook>
 <20170404174111.GB7257@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170404174111.GB7257@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arushi Singhal <arushisinghal19971997@gmail.com>
Cc: wensong@linux-vs.org, Simon Horman <horms@verge.net.au>, outreachy-kernel@googlegroups.com, Julian Anastasov <ja@ssi.bg>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, davem@davemloft.net, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

On Tue, Apr 04, 2017 at 01:41:11PM -0400, Simon Horman wrote:
> On Wed, Mar 29, 2017 at 03:45:01PM +0530, Arushi Singhal wrote:
> > Replace explicit NULL comparison with ! operator to simplify code.
> > 
> > Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>
> > ---
> >  net/netfilter/ipvs/ip_vs_ctl.c         |  8 ++---
> >  net/netfilter/ipvs/ip_vs_proto.c       |  8 ++---
> 
> I count 18 instances of "!= NULL in net/netfilter/ipvs/ip_vs_proto but this
> patch only seems to update 8 of them. I would prefer to fix all or none of
> them.

Agreed.

Please address all instances and resubmit.
