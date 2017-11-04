From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter/ipvs: clear ipvs_property flag when SKB net
 namespace changed
Date: Sat, 04 Nov 2017 22:38:22 +0900 (KST)
Message-ID: <20171104.223822.848425746136000220.davem@davemloft.net>
References: <1509008225-19614-1-git-send-email-hustcat@gmail.com>
        <alpine.LFD.2.20.1710281301090.1835@ja.home.ssi.bg>
        <20171102144650.zqbfbv7lprrwpjl5@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171102144650.zqbfbv7lprrwpjl5@verge.net.au>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: horms@verge.net.au
Cc: ja@ssi.bg, hustcat@gmail.com, willemb@google.com, edumazet@google.com, johannes.berg@intel.com, dcaratti@redhat.com, pabeni@redhat.com, f.fainelli@gmail.com, fw@strlen.de, soheil@google.com, dwindsor@gmail.com, elena.reshetova@intel.com, tom@quantonium.net, Jason@zx2c4.com, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, chouryzhou@gmail.com, wensong@linux-vs.org, lvs-devel@vger.kernel.org

From: Simon Horman <horms@verge.net.au>
Date: Thu, 2 Nov 2017 15:46:50 +0100

> On Sat, Oct 28, 2017 at 01:33:09PM +0300, Julian Anastasov wrote:
>> 
>> 	Hello,
>> 
>> On Thu, 26 Oct 2017, Ye Yin wrote:
>> 
>> > When run ipvs in two different network namespace at the same host, and one
>> > ipvs transport network traffic to the other network namespace ipvs.
>> > 'ipvs_property' flag will make the second ipvs take no effect. So we should
>> > clear 'ipvs_property' when SKB network namespace changed.
>> > 
>> > Signed-off-by: Ye Yin <hustcat@gmail.com>
>> > Signed-off-by: Wei Zhou <chouryzhou@gmail.com>
>> 
>> 	Patch looks good to me. ipvs_property was added long ago
>> but skb_scrub_packet() is more recent (3.11), so:
>> 
>> Fixes: 621e84d6f373 ("dev: introduce skb_scrub_packet()")
>> Signed-off-by: Julian Anastasov <ja@ssi.bg>
>> 
>> 	I guess, DaveM can apply it directly as a bugfix
>> to the net tree.
> 
> Sounds like a good plan to me, Dave?
> 
> Signed-off-by: Simon Horman <horms@verge.net.au>

Sure, applied and queued up for -stable, thanks!
