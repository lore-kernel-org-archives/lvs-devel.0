From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re[2]:  kernel oops - do_ip_vs_get_ctl
Date: Tue, 24 Apr 2012 07:34:33 +0200 (CEST)
Message-ID: <0k0r53l.a5e9b66b203a0a6d9711848c7fd7d636@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>
Cc: Ryan O'Hara <rohara@redhat.com>, lvs-devel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>


Hi
>
>Hello,
>
>On Mon, 23 Apr 2012, Simon Horman wrote:
>
>> Hi,
>> 
>> sorry for not being a little more attentive to patches.
>> 
>> I have now picked up all the patches that seem to have consensus.
>> Those that seem critical I have pushed into ipvs with a CC: stable@
>> and sent a pull request to Pablo to consider them for 3.4.
>> 
>> There are two such patches and the head of the ipvs tree now looks like
>> this:
>> 
>> 0cc4789 ipvs: fix crash in ip_vs_control_net_cleanup on unload
>> bd7dc1c netfilter: ipvs: Verify that IP_VS protocol has been registered
>> 
>> Those that seemed less critical where the GFP_ATOMIC changes, one
>> from Sasha and 6 from Julian. The head of the ipvs-next tree now looks like
>> this:
>> 
>> 663f4b2 netfilter: ipvs: use GFP_KERNEL allocation where possible
>> b5cfd04 ipvs: SH scheduler does not need GFP_ATOMIC allocation
>> 5b3b290 ipvs: LBLCR scheduler does not need GFP_ATOMIC allocation on init
>> c087c6f ipvs: WRR scheduler does not need GFP_ATOMIC allocation
>> 8cfaf8d ipvs: DH scheduler does not need GFP_ATOMIC allocation
>> e7c6390 ipvs: LBLC scheduler does not need GFP_ATOMIC allocation on init
>> 8f78609 ipvs: timeout tables do not need GFP_ATOMIC allocation
>> 
>> Please let me know if there are any other patches you would like
>> merged at this time.

This one should also be included
"IPVS: take care of return value from protocol init_netns"
Do you want me to resend it with the others ?

>
>	These two patches are also fixes but may be the 2nd
>patch is too long for fix:
>
>ipvs: reset ipvs pointer in netns
>ipvs: fix app registration in netns
>
>	If it looks too long for fix we can push some
>simple check for net->ipvs in __ip_vs_ftp_init, so that
>we do not oops when IPVS core is compiled in kernel.
>Even if smaller version is sent to stable kernels,
>I prefer "ipvs: fix app registration in netns" to be
>applied at least for net-next. May be I should split
>this 2nd patch as two-line fix + additional change
>for net-next?
>
>	Hans should provide similar two-line fixes for
>LBLC and LBLCR. And one for latest crash report.

I'll send them later today

The IPv6 fragment handling is also ready, but is on hold until above is "stable"

Regards
Hans Schillstrom <hans@schillstrom.com>


