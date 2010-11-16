From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [*v4 PATCH 0/3] IPVS: Backup Adding Ipv6 and Persistence
 support
Date: Tue, 16 Nov 2010 23:15:23 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1011162300300.1627@ja.ssi.bg>
References: <201011151931.26789.hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1011152346120.1987@ja.ssi.bg> <201011161551.52744.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <201011161551.52744.hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: Simon Horms <horms@verge.net.au>, LVS-Devel <lvs-devel@vger.kernel.org>, Daniel Lezcano <daniel.lezcano@free.fr>


 	Hello,

On Tue, 16 Nov 2010, Hans Schillstrom wrote:

>> v4 PATCH 1/3
>>  	- still the case for pe_data_len=0 and pe_name_len!=0 is
>>  	not handled properly as error because we now ignore
>>  	pe_name silently
>
> Do you mean that IP_VS_DBG should be replaced ?
>
> 	if (pe_data_len) {
> 		if (pe_name_len) {
> ...
> 		} else {
> 			IP_VS_DBG(3, "BACKUP, Invalid PE parameters\n");
> 			return 1;
> 		}
> to this ?
> 	...
> 			IP_VS_ERR_RL("BACKUP, Invalid PE parameters\n");
>    ...

 	No, I'm talking about one missing case:

 	/* Handle pe data */
 	if (pe_data_len) {
 		if (pe_name_len) {
 		} else {
 			IP_VS_DBG(3, "BACKUP, Invalid PE parameters\n");
 			return 1;
 		}
 		... kmalloc ...

 	THIS CASE IS MISSING:

+	} else if (pe_name_len) {
+		IP_VS_DBG(3, "BACKUP, Invalid PE parameters\n");
+		return 1;
 	}

 	That is why my first example was a sort of XOR operation:

 	/* Handle pe data */
 	if ((pe_data_len != 0) != (pe_name_len != 0)) {
 		IP_VS_DBG(3, "BACKUP, Invalid PE parameters\n");
 		return 1;
 	}
 	if (!pe_name_len)
 		return 0;

 	it means: PE DATA and PE NAME must come together.

 	because we have 4 possible cases:

1. pe_name_len==0 && pe_data_len==0 => VALID, return 0
2. pe_name_len!=0 && pe_data_len==0 => INVALID, return 1
3. pe_name_len==0 && pe_data_len!=0 => INVALID, return 1
4. pe_name_len!=0 && pe_data_len!=0 => VALID, kmalloc, return 0

Regards

--
Julian Anastasov <ja@ssi.bg>
