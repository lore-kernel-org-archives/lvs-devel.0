From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: Transport support in LVS
Date: Tue, 3 Apr 2012 08:44:24 +0200
Message-ID: <201204030844.25074.hans.schillstrom@ericsson.com>
References: <4F5F4CFFAA985C4AB0BF413F3081D9B47D2C90FA@blr-exch-1.sandvine.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <4F5F4CFFAA985C4AB0BF413F3081D9B47D2C90FA@blr-exch-1.sandvine.com>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Abhijit Chaudhary <achaudhary@sandvine.com>
Cc: "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>

Hello
On Tuesday 03 April 2012 07:45:03 Abhijit Chaudhary wrote:
> Hi,
> I am new to LVS and wanted to understand its transport-level support. Am using RHEL 6.2 (kernel 2.6.32-220) and had couple of questions on it:
> Did not find support for SCTP as a LVS transport protocol (no ip_vs_protocol). But LVS website mentions about SCTP support in ipvsadm-1.26. 
> Am I missing something, was SCTP supported in older kernel release?

SCTP was introduced in 2.6.34 

> 
> Other question is whether LVS supports load-balancing of IPSEC-packet (for ESP in transport mode with authentication and encryption enabled).  
> My understanding:  ip_vs_in() is hooked to NF_INET_LOCAL_IN. But, ip_local_deliver() calls NF_INET_LOCAL_IN before decryption (esp_input). 
> So, IPSEC with encryption enabled should not be load-balanced unless there is a repeat call to ip_local_deliver() after decryption.
> My knowledge on xfrm framework and IPSEC is not good, so I may be missing something.

If you don't have the VIP address in your LVS node (just force the VIP to loopback by routing),
then you should be able to send the ESP (or AH) packets through IPVS to a RS for decryption.

> 
> Thanks,
> -Abhijit
> --
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
