From: Moahn Reddy <mohanreddykv@gmail.com>
Subject: Re: [patch] ipvs: off by one in set_sctp_state()
Date: Mon, 22 Apr 2013 14:47:10 +0530
Message-ID: <51750016.5080600@gmail.com>
References: <20130420112455.GA30198@elgon.mountain> <alpine.LFD.2.00.1304201504510.1593@ja.ssi.bg> <20130422041151.GM15680@verge.net.au> <alpine.LFD.2.00.1304220843560.1626@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=x-received:message-id:date:from:user-agent:mime-version:to:cc
         :subject:references:in-reply-to:content-type
         :content-transfer-encoding;
        bh=jwRwxvIvcRb86RA1rfFkJ7gWADqqRtgCiwLMlgZ0dAA=;
        b=ZFMHlUTYIEcfmrBvbdk+LL+2f3DFzGbcdDPQNsrjmMzm+fEElfNnJMILVCSyMdmwNv
         eSNNpd713yI4aOoUdbtcO3WZJZVqrczxfSKyno1y5bQH8G31gpgJDA64NGiRerLY2MkG
         5R4JvduJnrtxkww+GhvorFdyxfkBQ1EoF+HGRadaoXS+/72RlmnjLrPeHhLToMdZhDjj
         B4X6QgLwBN0ojZ3a6GI1HjqUSkGKCOPpo+8lorM9arK9+cIq1rKiCQ8vy55jJP2VWBik
         NEJn7oi7zgqEquqPc3DU0zpNXoYvCn8A56dUopyTOW6Y4TLN/p9RHX/8VfOhuZ5a7wOP
         hZHw==
In-Reply-To: <alpine.LFD.2.00.1304220843560.1626@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, Dan Carpenter <dan.carpenter@oracle.com>, Wensong Zhang <wensong@linux-vs.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org

Hi,

I see there is no problem in the code regarding the state change. And 
the thing why I took 255 in the sctp_events array is that as per the 
sctp specification, the 255 message is reserved, so I thought 0 to 254 
messages are enough.

Do you see any problem with the ipvs sctp code in the field?. Please let 
me know if you see any such, I will try to fix.

Thanks,
Mohan

On Monday 22 April 2013 11:33 AM, Julian Anastasov wrote:
> 	Hello,
>
> On Mon, 22 Apr 2013, Simon Horman wrote:
>
>>> 	There are more confusing (still, non-fatal)
>>> problems in this IPVS-SCTP support, eg.
>>>
>>>          if (direction == IP_VS_DIR_OUTPUT)
>>> -               event++;
>>> +               event *= 2;
>>>
>>> 	I guess we are running with wrong timeouts.
>> IMHO there seem to be many problems with SCTP, but it is good to
>> fix the ones we find as we find them.
> 	At the time I found it (during IPVS optimizations
> development), it didn't looked fatal, I preferred to
> allocate more time for SCTP for debugging.
>
>> Would you like to make a patch for the above change or should I?
> 	May be the code is correct, my mistake. I was
> confused from the order in sctp_events[] but ipvs_sctp_event_t
> allocates values for _SER states.
>
>>> 	Also, I'm not sure we support properly the
>>> one-way states as done for TCP (IP_VS_DIR_INPUT_ONLY).
>>> May be this code deserves more serious review, for example,
>>> net/netfilter/nf_conntrack_proto_sctp.c looks as good
>>> source for comparison.
>> I believe it does need a more serious review.
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
> --
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

