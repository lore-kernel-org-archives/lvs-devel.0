From: Aleksey Chudov <aleksey.chudov@gmail.com>
Subject: Re: [PATCH] ipvs: add sync_persist_mode flag
Date: Sat, 22 Jun 2013 14:20:26 +0300
Message-ID: <51C5887A.1070301@gmail.com>
References: <20130524120935.GL264@eldamar.org.uk> <alpine.LFD.2.00.1305241633430.1636@ja.ssi.bg> <20130524151408.GM264@eldamar.org.uk> <519F92EB.4080509@gmail.com> <alpine.LFD.2.00.1305280011490.1728@ja.ssi.bg> <51A4B3ED.4070809@gmail.com> <alpine.LFD.2.00.1306191153590.2077@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=message-id:date:from:user-agent:mime-version:to:cc:subject
         :references:in-reply-to:content-type:content-transfer-encoding;
        bh=D9ehBYSNAQkLFg/q8Jk8Q6W2OV3uWKosjTtyNHg97hw=;
        b=AcFn71L3o+FfA12Kpggdtu0QqbzPOlPgHhpB3Q85rcljaov2Un9wiIzjkoIi8Ngjto
         1UxYZ3yGM/e53r+vRZrUU+y+CJbu3GZfpQwc53/P3aMAQQxWyandT4Q0TOjhQw2SvYSf
         lS3SpW3pTngwRSzD1xza3MRk8ecRr4UWV8ata6oUfDX49Cp53uw6LgDbN106YhgtLRVi
         9QUKHFi4lhTL0gMIOS8PDrKP7fU1ttm9IGWXLa5Mg20euhKFJBDJ70yltkMQa2N89r+a
         pN6dvNQNzoQYP1i+IRdIF8bfwqxEyK2rK4DIrPplt/qNqtL2mQbzwdmQ8mgIcL09amxR
         Npsw==
In-Reply-To: <alpine.LFD.2.00.1306191153590.2077@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

On 19.06.2013 12:03, Julian Anastasov wrote:
> On Tue, 28 May 2013, Aleksey Chudov wrote:
>
>> Currently we are using multiple active / standby server pairs and synchronize
>> them with each other. So half of the servers are constantly doing nothing. We
>> are searching how to use all the servers in active / active mode while
>> maintaining high availability and sessions persistence in case of failure of
>> one of the load balancers. Unfortunately the proposed stateless scheme with SH
>> scheduler and Sloppy TCP is not suitable for as since we are using WLC and WRR
>> schedulers. As you mentioned SH scheduler has several drawbacks because of
>> which we can not use it. Also, we can not synchronize all connections between
>> all servers, since it would require a lot of memory and the search for such a
>> huge connection table is likely to be slower.
>>
>> But we can solve the sync problem in such a way as done in the conntrackd
>> which allows filtering by flow state. The easiest option is to make the filter
>> only for IP_VS_CONN_F_TEMPLATE state. Thus if all the load balancers will sync
>> persistent templates with each other then even if one of the load balancers
>> fails most users will remain on the same real servers. Of course without the
>> full sync clients must reestablish TCP connections, but for this case we can
>> use Sloppy TCP to create a TCP connection state on any TCP packet.
>>
>> What do you think of this idea?
> 	Here is something that is compile-tested. You
> will need the "ipvs: sloppy TCP and SCTP" patch by
> Alexander Frolkin posted on 13 Jun. Let me know if
> you need more help in applying and testing such patches,
> so that we can be more confident when releasing such
> optimization officially.
>
> From: Julian Anastasov <ja@ssi.bg>
> [PATCH] ipvs: add sync_persist_mode flag
>
> Add sync_persist_mode flag to reduce sync traffic
> by syncing only persistent templates.
>
>

I tested the changes on one pair of LAN servers. After turning on 
sync_persist_mode synchronization traffic decreased by 4 times! Also on 
LVS Backup I can see only persist connections.

First of all the Kernel on both servers have been updated. Then LVS 
Backup has been rebooted to drop all connections. After the reboot sync 
was disabled and all connections counters was zero. When I enabled sync 
again almost all persist connections from LVS Master have been synced to 
LVS Backup. But also I can see 0.04% of the connections in ESTABLISHED 
state, although they should not be there! After disabling sync all 
connections on LVS Backup completely disappear after about 5 minutes.

After turning on sloppy_tcp IP address have been moved from LVS Master 
to LVS Backup. According to our statistics, most on clients remained on 
the same real servers. I don't see any problems with sloppy_tcp.

Aleksey
