From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re[2]:  [PATCH 2/2] ipvs: fix app registration in netns
Date: Fri, 13 Apr 2012 22:22:10 +0200 (CEST)
Message-ID: <6dfqp4f.13413aadaead24bb8e0685fc27648dc7@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, Simon Horman <horms@verge.net.au>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>

Hello Julian
>
>Hello,
>
>On Fri, 13 Apr 2012, Hans Schillstrom wrote:
>
>> Hello Julian
>> On Friday 13 April 2012 10:44:02 Julian Anastasov wrote:
>> > 	Avoid crash when registering applications (ftp) when
>> > the IPVS core initialization for netns fails. Do this by
>> > checking for present core (net->ipvs) when registering apps.
>> > 
>> > 	As result this gets rid of the ftp_app pointer and allows
>> > applications to be registered without adding fields in the
>> > netns_ipvs structure.
>> > 
>> > 	Also, make sure applications are unregistered from the
>> > core automatically, should not be needed in theory.
>> > 
>> 
>> I think we can do this much simpler,
>> remove the auto init of ftp (ip_vs_ftp_init and ip_vs_ftp_exit) 
>> and let ip_vs_app call __ip_vs_ftp_init() as a we do with the protocols.
>> 
>> If the init fails before ip_vs_app_net_init() ftp init will not be called
>> and if it fails after a proper cleanup will be performed.
>> 
>> i.e. same design every where.
>> 
>> ex remove the
>>  ip_vs_ftp_init(void)
>>  ip_vs_ftp_exit(void)
>
>	OK, go ahead. But also change init_netns for
>proto (and now for apps) to return int error. Now
>__ip_vs_tcp_init does not return error if the
>pd->timeout_table allocation fails. This is fatal.
>
>	May be you can do this change on top of these
>two patches because init_netns for ftp should be NULL,
>we do not need to allocate anything for netns. Only
>&ip_vs_ftp should go in some new global list to be cloned
>for every netns as my 2nd patch:

OK I can take care of this, but not before Sunday evening 

>- new: global list for registered apps
>- present: app per netns: to hold incs_list
>- present: inc (app instance for port) per netns: to hold the
>instance in the per-netns context of proto
>
>Regards
>
>--
>Julian Anastasov <ja@ssi.bg>
>--
>To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

