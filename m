From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] nf_nat: restrict ICMP translation for embedded header
Date: Thu, 21 Oct 2010 13:15:15 +0200
Message-ID: <4CC020C3.9090104@trash.net>
References: <alpine.LFD.2.00.1010111103470.3743@ja.ssi.bg> <4CB606AF.4040207@trash.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <4CB606AF.4040207@trash.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org

Am 13.10.2010 21:21, schrieb Patrick McHardy:
> Am 11.10.2010 10:23, schrieb Julian Anastasov:
>>
>>     Skip ICMP translation of embedded protocol header
>> if NAT bits are not set. Needed for IPVS to see the original
>> embedded addresses because for IPVS traffic the IPS_SRC_NAT_BIT
>> and IPS_DST_NAT_BIT bits are not set. It happens when IPVS performs
>> DNAT for client packets after using nf_conntrack_alter_reply
>> to expect replies from real server.
>>
>> Signed-off-by: Julian Anastasov <ja@ssi.bg>
>> ---
>>
>>     I'm not very familiar with this code, so this change
>> must not be considered as trivial. May be there was a
>> reason the embedded header to be translated before the NAT
>> bits are set?
> 
> This seems OK to me, but I need to think about it a bit more,
> this code is subtle.

I think this change is fine, it does not apply to the current tree
anymore however. Could you please send me an updated version
against the nf-next-2.6.git tree? Thanks!
