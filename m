From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] netfilter/ipvs: clear ipvs_property flag when SKB net
 namespace changed
Date: Thu, 2 Nov 2017 15:46:50 +0100
Message-ID: <20171102144650.zqbfbv7lprrwpjl5@verge.net.au>
References: <1509008225-19614-1-git-send-email-hustcat@gmail.com>
 <alpine.LFD.2.20.1710281301090.1835@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1509634012; bh=Wyo7Z5keaJIfV6g7MNcL2ZzZVleJKAdGkQutvX24R7c=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=A8IQmQ6SqGI1JwF7YUii3wSY9nStyaFyyKE4Pt4ta75Pa4JorUtc9F2q9QbbhOX7B
         cG71Yj2/u05DbLasM89RbketPTfTpKooHyJU3OCv7cuzeTRQlx9wlYgIDe8EsBO4SA
         TKV/584AdZdo8TuPGrSYqMamMEufboO48U2GmPZM=
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.20.1710281301090.1835@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Ye Yin <hustcat@gmail.com>, "David S. Miller" <davem@davemloft.net>, willemb@google.com, edumazet@google.com, johannes.berg@intel.com, dcaratti@redhat.com, pabeni@redhat.com, f.fainelli@gmail.com, fw@strlen.de, soheil@google.com, dwindsor@gmail.com, elena.reshetova@intel.com, tom@quantonium.net, Jason@zx2c4.com, linux-kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org, Wei Zhou <chouryzhou@gmail.com>, Wensong Zhang <wensong@linux-vs.org>, lvs-devel@vger.kernel.org

On Sat, Oct 28, 2017 at 01:33:09PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 26 Oct 2017, Ye Yin wrote:
> 
> > When run ipvs in two different network namespace at the same host, and one
> > ipvs transport network traffic to the other network namespace ipvs.
> > 'ipvs_property' flag will make the second ipvs take no effect. So we should
> > clear 'ipvs_property' when SKB network namespace changed.
> > 
> > Signed-off-by: Ye Yin <hustcat@gmail.com>
> > Signed-off-by: Wei Zhou <chouryzhou@gmail.com>
> 
> 	Patch looks good to me. ipvs_property was added long ago
> but skb_scrub_packet() is more recent (3.11), so:
> 
> Fixes: 621e84d6f373 ("dev: introduce skb_scrub_packet()")
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> 
> 	I guess, DaveM can apply it directly as a bugfix
> to the net tree.

Sounds like a good plan to me, Dave?

Signed-off-by: Simon Horman <horms@verge.net.au>

