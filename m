From: Alex Gartrell <agartrell@fb.com>
Subject: Re: [PATCH ipvs,v4 19/20] ipvs: use the new dest addr family field
Date: Fri, 29 Aug 2014 14:19:04 -0700
Message-ID: <5400EE48.5060007@fb.com>
References: <1409301549-5284-1-git-send-email-agartrell@fb.com> <1409301549-5284-20-git-send-email-agartrell@fb.com> <alpine.LFD.2.11.1408291259510.4876@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=message-id : date : from :
 mime-version : to : cc : subject : references : in-reply-to : content-type
 : content-transfer-encoding; s=facebook;
 bh=aE7lV4k5OH0+Rja3EFX4wgTR7K1AVnhUH8JidkfCoEQ=;
 b=gJTYUjRlg/3kOabwgE05x1vXTJQjzGztV7bkj5GJLXoF7DN32uLeBf5meRrT1k95WLhJ
 OugxBtnxXCaVH3fy575+3MkMmWZ5GxUDavsqYsonrDoHo2Ka8CLyuIo+eYkMueFiudfE
 5vRQaacGhd8MUDYaT/4G4NaqpudG37qJng4= 
In-Reply-To: <alpine.LFD.2.11.1408291259510.4876@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julian Anastasov <ja@ssi.bg>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, kernel-team@fb.com

Hey

On 8/29/14 3:32 AM, Julian Anastasov wrote:
>
> 	Hello,
>
> On Fri, 29 Aug 2014, Alex Gartrell wrote:
>
>> From: Julian Anastasov <ja@ssi.bg>
>>
>> Use the new address family field cp->daf when printing
>> cp->daddr in logs or connection listing.
>>
>> Signed-off-by: Julian Anastasov <ja@ssi.bg>
>> Signed-off-by: Alex Gartrell <agartrell@fb.com>
>
> ...
>
>> --- a/net/netfilter/ipvs/ip_vs_conn.c
>> +++ b/net/netfilter/ipvs/ip_vs_conn.c
>> @@ -27,6 +27,7 @@
>>
>>   #include <linux/interrupt.h>
>>   #include <linux/in.h>
>> +#include <linux/inet.h>
>>   #include <linux/net.h>
>>   #include <linux/kernel.h>
>>   #include <linux/module.h>
>> @@ -77,6 +78,13 @@ static unsigned int ip_vs_conn_rnd __read_mostly;
>>   #define CT_LOCKARRAY_SIZE  (1<<CT_LOCKARRAY_BITS)
>>   #define CT_LOCKARRAY_MASK  (CT_LOCKARRAY_SIZE-1)
>>
>> +/* We need an addrstrlen that works with or without v6 */
>> +#ifdef CONFIG_IP_VS_IPV6
>> +#define IP_VS_ADDRSTRLEN INET6_ADDRSTRLEN
>> +#else
>> +#define IP_VS_ADDRSTRLEN INET_ADDRSTRLEN
>> +#endif
>
> 	Thanks! Note that for v4 we use 8+1 (hex).
> All other patches look ok. It is early to ack them,
> right? We need to post them again at the right time.
> I hope "ipvs: properly declare tunnel encapsulation"
> will be moved further soon.

I updated this patch

-#define IP_VS_ADDRSTRLEN INET_ADDRSTRLEN
+#define IP_VS_ADDRSTRLEN (8+1)

I'll spare the mailing list another 20 emails though.

So, if I understand correctly, we'll wait until it lands in net-next and 
then I'll submit these patches to netdev?


>
> 	For now we have to find a way to support sync
> protocol and to update ipvsadm.

I'll mail the ipvsadm change right away.  I haven't begun to think about 
sync protocol though :)

Thanks,
Alex
