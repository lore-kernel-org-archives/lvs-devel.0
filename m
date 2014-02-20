From: Art -kwaak- van Breemen <ard@telegraafnet.nl>
Subject: Re: [PATCH] ipvs: fix ipv6 icmp forwarding in natted services
Date: Thu, 20 Feb 2014 09:51:55 +0100
Message-ID: <20140220085154.GN20771@telegraafnet.nl>
References: <20140217161601.GD18029@telegraafnet.nl>
 <alpine.LFD.2.11.1402172321200.2420@ja.home.ssi.bg>
 <20140218100533.GE18029@telegraafnet.nl>
 <20140218133725.GA20771@telegraafnet.nl>
 <20140218135439.GB20771@telegraafnet.nl>
 <alpine.LFD.2.11.1402182225560.2011@ja.home.ssi.bg>
 <20140219102751.GD20771@telegraafnet.nl>
 <1392825857.5821.422.camel@hawk.mlab.se>
 <20140219170505.GI20771@telegraafnet.nl>
 <1392841718.5821.437.camel@hawk.mlab.se>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1392841718.5821.437.camel@hawk.mlab.se>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Ansis Atteka <aatteka@nicira.com>, Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>

Hi,

On Wed, Feb 19, 2014 at 09:28:38PM +0100, Hans Schillstrom wrote:
> That didn't happen  why ?
>  - Just a check did you rebuild ipv6 or if not a module the kernel ? 

Ah, f**k me :-(. I was so caught up in reloading ipvs that I
forgot to reload wherever that function is in, but I guess that's
static :-(. So tests like that will take me some longer to
perform.

Sorry about that noise, good catch!

Regards,
Ard van Breemen



