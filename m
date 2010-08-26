From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch][enhancement] ldirectord: IPv6: new directives:
 virtual6, real6, fallback6
Date: Thu, 26 Aug 2010 23:16:49 +0900
Message-ID: <20100826141646.GA12934@verge.net.au>
References: <20100804010034.GD4469@verge.net.au>
 <20100805.001330.59655583.sohgo@sohgo.dyndns.org>
 <20100807.195010.226787800.sohgo@sohgo.dyndns.org>
 <20100826.224213.260099549.sohgo@sohgo.dyndns.org>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100826.224213.260099549.sohgo@sohgo.dyndns.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sohgo Takeuchi <sohgo@sohgo.dyndns.org>
Cc: lvs-devel@vger.kernel.org

On Thu, Aug 26, 2010 at 10:42:13PM +0900, Sohgo Takeuchi wrote:
> From: Sohgo Takeuchi <sohgo@sohgo.dyndns.org>
> > 
> > I attached a patch to enhance an IPv6 support of ldirectord.
> > 
> > - Added new directives: virtual6, real6, fallback6.
> >   These are used to specify IPv6 as addresses or hostnames.
> >   Now cannot specify an IPv6 address in a "virtual" and "real"
> >   line (This breaks backwards compatibility).
> > - Supported following checktypes and services.
> >   checktype: connect, external, external-perl, negotiate, off,
> >              on, checktimeoutN
> >   service: dns, nntp, none, simpletcp, sip
> > - firewall-mark + IPv6 works.
> 
> Any comments and any refinement of my code are appreciated.

Sorry for not getting to this earlier.

The patch looks good, I have pushed as
http://hg.linux-ha.org/agents/rev/6e8b562f5414
