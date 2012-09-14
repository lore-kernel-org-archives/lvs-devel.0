From: Julian Anastasov <ja@ssi.bg>
Subject: Re[2]:  [PATCH V3 0/8] ipvs: IPv6 fragment handling for  IPVS
Date: Fri, 14 Sep 2012 11:23:50 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1209141121260.1551@ja.ssi.bg>
References: <ee5vnhe.0891bc4ff9e38f64c4c5c0da6c50af1c@obelix.schillstrom.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <ee5vnhe.0891bc4ff9e38f64c4c5c0da6c50af1c@obelix.schillstrom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Hans Schillstrom <hans.schillstrom@ericsson.com>, netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>, Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, Thomas Graf <tgraf@suug.ch>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>


	Hello,

On Thu, 13 Sep 2012, Hans Schillstrom wrote:

> >	I also see that we should not send ICMP
> >errors (FRAG NEEDED/TOO BIG) in response to large
> >ICMP error packets but it is not related to your changes,
> >it needs separate change to all transmitters.
> 
> Just a curious question, have you seen such big ICMP packets in real life ?
> (if you have normal MTU:s) 

	No, may be it can happen when PMTU reaches minimum.

Regards

--
Julian Anastasov <ja@ssi.bg>
