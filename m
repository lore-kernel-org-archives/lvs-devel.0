From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re: Re: [v2 PATCH 0/6] IPVS: init and cleanup.
Date: Fri, 29 Apr 2011 10:17:06 +0200 (CEST)
Message-ID: <r17gk8q.3093bdc5574395547ee5937d82a3241c@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: horms@verge.net.au, ebiederm@xmission.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans.schillstrom@ericsson.com

Hello
>
>Hello,
>
>On Fri, 29 Apr 2011, Hans Schillstrom wrote:
>
>> This patch series handles exit from a network name space.
>> 
>> REVISION
>> 
>> This is version 3
>
>	Great! Only one missing lock:

Ooops..

>
>Patch 3:
>	Missing write_[un]lock_bh(&__ip_vs_svc_lock) in ip_vs_flush,
>	now we use ip_vs_unlink_service_nolock.
>
>As you are going to create new version you can look also at these:
>
>Patch 5:
>	Can you rename 'goto exit;' to 'goto cleanup;' or
>	'goto out;'
>
>Patch 6:
>	Add at least one comma after 'enabled' here:
>	netns(%d) enabled first service added
>
I'll send a new set.

Thanks
Hans


