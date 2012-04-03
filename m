From: Abhijit Chaudhary <achaudhary@sandvine.com>
Subject: Transport support in LVS
Date: Tue, 3 Apr 2012 05:45:03 +0000
Message-ID: <4F5F4CFFAA985C4AB0BF413F3081D9B47D2C90FA@blr-exch-1.sandvine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Language: en-US
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>

Hi,
I am new to LVS and wanted to understand its transport-level support. Am using RHEL 6.2 (kernel 2.6.32-220) and had couple of questions on it:
Did not find support for SCTP as a LVS transport protocol (no ip_vs_protocol). But LVS website mentions about SCTP support in ipvsadm-1.26. 
Am I missing something, was SCTP supported in older kernel release?

Other question is whether LVS supports load-balancing of IPSEC-packet (for ESP in transport mode with authentication and encryption enabled).  
My understanding:  ip_vs_in() is hooked to NF_INET_LOCAL_IN. But, ip_local_deliver() calls NF_INET_LOCAL_IN before decryption (esp_input). 
So, IPSEC with encryption enabled should not be load-balanced unless there is a repeat call to ip_local_deliver() after decryption.
My knowledge on xfrm framework and IPSEC is not good, so I may be missing something.

Thanks,
-Abhijit
