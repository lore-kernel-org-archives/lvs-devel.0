From: Alex Gartrell <agartrell@fb.com>
Subject: Re: ipvs: Pull out crosses_local_route_boundary logic
Date: Sun, 5 Oct 2014 16:47:02 -0700
Message-ID: <5431D876.5020002@fb.com>
References: <20141001174526.GA16206@mwanda> <alpine.LFD.2.11.1410012225530.3494@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=message-id : date : from :
 mime-version : to : cc : subject : references : in-reply-to : content-type
 : content-transfer-encoding; s=facebook;
 bh=+p3YMAiA8f5NVOfN74bHInOU+g7d8IGse7pj4EHx3o8=;
 b=lHI8s370o6LZlTTDPiPAGkfI1+8KcNFDIaD3XvfdEyelv0lynN7AReker++wVoBfhLeA
 uoCMTzzyCm9JWlZF9JW6BHoJj8LoRZTwY6e5FC3uwng2NCanw/enOg7ZwynuHxO4p5PE
 8/fuJ9uMFyr7KaeJXdHs5PYQ6LbTTrqojKY= 
In-Reply-To: <alpine.LFD.2.11.1410012225530.3494@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julian Anastasov <ja@ssi.bg>, Dan Carpenter <dan.carpenter@oracle.com>
Cc: lvs-devel@vger.kernel.org

Hey everyone,

On 10/1/14 12:37 PM, Julian Anastasov wrote:
>>     312				*ret_saddr = saddr;
>>     313		}
>>     314	
>>     315		local = (rt->rt_flags & RTCF_LOCAL) ? 1 : 0;
>>     316		if (unlikely(crosses_local_route_boundary(skb_af, skb, rt_mode,
>>     317							  local))) {
>>     318			IP_VS_DBG_RL("We are crossing local and non-local addresses"
>>     319				     " daddr=%pI4\n", &dest->addr.ip);
>>                                                         ^^^^^^^^^^^^^
>
> 	Good catch. In fact, I requested Alex to print
> daddr in this case but then we both missed this dest here...
> Alex, both v4 (&daddr) and v6 (daddr) should be fixed.

It doesn't appear to me that there's been a patch for this yet.  I'll 
write one and send it out right away.  Please LMK if there's anyone else 
I should send it to.

Thanks,
-- 
Alex Gartrell <agartrell@fb.com>

