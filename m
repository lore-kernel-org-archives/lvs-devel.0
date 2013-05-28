From: Aleksey Chudov <aleksey.chudov@gmail.com>
Subject: Re: [PATCH] Sloppy TCP, SH rebalancing, SHP scheduling
Date: Tue, 28 May 2013 16:41:01 +0300
Message-ID: <51A4B3ED.4070809@gmail.com>
References: <20130524120935.GL264@eldamar.org.uk> <alpine.LFD.2.00.1305241633430.1636@ja.ssi.bg> <20130524151408.GM264@eldamar.org.uk> <519F92EB.4080509@gmail.com> <alpine.LFD.2.00.1305280011490.1728@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=message-id:date:from:user-agent:mime-version:to:cc:subject
         :references:in-reply-to:content-type:content-transfer-encoding;
        bh=MP7vG95NJx5Vz+X8FcRiNRgYIoozzOYKRH9TKNTrtN0=;
        b=fk0pFQv39e3kaj/+53x3aex9oX052AvYeCudy+Bv6rrcwMWgsa5DGfnQ3Mb6emZiqC
         f7LIZEY4A/7A3r5rLgmM22ucNWcG9cRK5hXds6XQ7SRjCsoiWHMz8MA8HnQNVnBAE7iC
         D8GtksT0Gv8td/l1tH6zACUoitK3zdFvM7x26/jcYyc4FhwdXO75kXOXEPMXkToQrdd8
         S1+raIsO42jxoBhfM7A49hZY+0OI5UtVl5SnraoHZ7dqEC5sWDyRJ5dVxgGGo1p4inEI
         bIDtT+IDeNvT23eNxeQIYKUAeF6/Wu1q9Qfbl6+7BUGImp86G5FhIMM1bzmepRixPpSX
         Pfng==
In-Reply-To: <alpine.LFD.2.00.1305280011490.1728@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

On 28.05.2013 0:31, Julian Anastasov wrote:
> On Fri, 24 May 2013, Aleksey Chudov wrote:
>
>> May be better to modify the sync algorithm to synchronize only persistence
>> templates for these specific cases? Is it possible at all?
> 	May be, with some flag and also sloppy_tcp. Then the
> parametrized SH with netmask will do the same - we can avoid
> the sync messages. Of course, with SH there is more risk
> for imbalance and it can be exploited. Also SH requires
> equal configuration for the real servers.
>

Currently we are using multiple active / standby server pairs and 
synchronize them with each other. So half of the servers are constantly 
doing nothing. We are searching how to use all the servers in active / 
active mode while maintaining high availability and sessions persistence 
in case of failure of one of the load balancers. Unfortunately the 
proposed stateless scheme with SH scheduler and Sloppy TCP is not 
suitable for as since we are using WLC and WRR schedulers. As you 
mentioned SH scheduler has several drawbacks because of which we can not 
use it. Also, we can not synchronize all connections between all 
servers, since it would require a lot of memory and the search for such 
a huge connection table is likely to be slower.

But we can solve the sync problem in such a way as done in the 
conntrackd which allows filtering by flow state. The easiest option is 
to make the filter only for IP_VS_CONN_F_TEMPLATE state. Thus if all the 
load balancers will sync persistent templates with each other then even 
if one of the load balancers fails most users will remain on the same 
real servers. Of course without the full sync clients must reestablish 
TCP connections, but for this case we can use Sloppy TCP to create a TCP 
connection state on any TCP packet.

What do you think of this idea?



Regards,
Aleksey
