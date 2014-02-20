From: Art -kwaak- van Breemen <ard@telegraafnet.nl>
Subject: Re: [PATCH] ipvs: fix ipv6 icmp forwarding in natted services
Date: Thu, 20 Feb 2014 14:10:44 +0100
Message-ID: <20140220131044.GP20771@telegraafnet.nl>
References: <20140217161601.GD18029@telegraafnet.nl>
 <alpine.LFD.2.11.1402172321200.2420@ja.home.ssi.bg>
 <20140218100533.GE18029@telegraafnet.nl>
 <20140218133725.GA20771@telegraafnet.nl>
 <20140218135439.GB20771@telegraafnet.nl>
 <alpine.LFD.2.11.1402182225560.2011@ja.home.ssi.bg>
 <20140219102751.GD20771@telegraafnet.nl>
 <1392825857.5821.422.camel@hawk.mlab.se>
 <alpine.LFD.2.11.1402192254040.1889@ja.home.ssi.bg>
 <1392847723.5821.474.camel@hawk.mlab.se>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1392847723.5821.474.camel@hawk.mlab.se>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Julian Anastasov <ja@ssi.bg>, Ansis Atteka <aatteka@nicira.com>, lvs-devel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, Patrick McHardy <kaber@trash.net>

Hi,

On Wed, Feb 19, 2014 at 11:08:43PM +0100, Hans Schillstrom wrote:
> > 	May be above check should be:
> > 
> > 	if (target < 0 || found)
> > 		break;
> 
> It will work for hmark and it looks like it will work for others,
> with -1 
> 
> Maybe Patrick have another opinion...

It will be on my next desktop reboot test round :-).
I think I will test 2 hours before EOD, that's around 18:00+0100

