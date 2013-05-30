From: "Jan Beulich" <jbeulich@suse.com>
Subject: Re: [PATCH] ip_vs_sh: fix build
Date: Thu, 30 May 2013 06:48:34 +0100
Message-ID: <51A6F642020000780009B66A@nat28.tlf.novell.com>
References: <51A611CF02000078000D99A6@nat28.tlf.novell.com>
 <alpine.LFD.2.00.1305292219170.1951@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1305292219170.1951@ja.ssi.bg>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: ja@ssi.bg
Cc: wensong@linux-vs.org, pablo@netfilter.org, horms@verge.net.au, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

>>> Julian Anastasov <ja@ssi.bg> 05/29/13 9:28 PM >>>
>On Wed, 29 May 2013, Jan Beulich wrote:
>> --- 3.10-rc3/net/netfilter/ipvs/ip_vs_sh.c
>> +++ 3.10-rc3-ip_vs_sh-build/net/netfilter/ipvs/ip_vs_sh.c
>> @@ -67,8 +67,8 @@ struct ip_vs_sh_bucket {
>>  #define IP_VS_SH_TAB_MASK               (IP_VS_SH_TAB_SIZE - 1)
>>  
>>  struct ip_vs_sh_state {
>> -    struct ip_vs_sh_bucket        buckets[IP_VS_SH_TAB_SIZE];
>>      struct rcu_head            rcu_head;
>> +    struct ip_vs_sh_bucket        buckets[IP_VS_SH_TAB_SIZE];
>
>    Your fix reminds me about the same problem
>I noticed for LBLC (may be due to 10 bits) during development
>but forgot to check the other schedulers. The same solution
>is needed also for DH. OTOH, LBLC and LBLCR are correct.
>Do you prefer to provide similar fix for ip_vs_dh.c or
>I have to take care?

CONFIG_IP_VS_DH_TAB_BITS is always 8 (due to not coming from any
Kconfig setting), and hence not a problem at this point. If it is being planned
to make configurable, then that change should at once flip the structure
members.

Jan

