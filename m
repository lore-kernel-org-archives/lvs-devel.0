From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: Transport support in LVS
Date: Tue, 3 Apr 2012 11:43:05 +0200
Message-ID: <201204031143.06587.hans.schillstrom@ericsson.com>
References: <4F5F4CFFAA985C4AB0BF413F3081D9B47D2C90FA@blr-exch-1.sandvine.com> <201204030844.25074.hans.schillstrom@ericsson.com>  <4F5F4CFFAA985C4AB0BF413F3081D9B47D2C9174@blr-exch-1.sandvine.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <4F5F4CFFAA985C4AB0BF413F3081D9B47D2C9174@blr-exch-1.sandvine.com>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Abhijit Chaudhary <achaudhary@sandvine.com>
Cc: "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>

On Tuesday 03 April 2012 09:12:21 Abhijit Chaudhary wrote:
> Thanks Hans.
> My requirement for IPSEC is little different, I want to offload the IPSEC or reassembly processing in the LVS node itself.
> I plan to use a VIP address in the LVS node and do the IPSEC decryption/IP reassembly on the VIP address before the LVS load-balancing as I may use L4-ports to load-balance.
> Is this possible in the current LVS.

In theory it wold be possibly, 
First do not have any ESP/AH services in ipvs, so the xfrm will take care of the packet.
Next turn when the packet is decrypted it will go into the prerouting chain again.
However it will be forced into the input chain later since skb_dst is set because it is transport mode.
 (see xtrm_input at the end,  decaps=0 so xfrm4_transport_finish() will be called by x->inner_mode->afinfo->transport_finish() .)

Now you have the decrypted packet in the INPUT chain and ipvs will take care of it.
I don't think the output chain will cause any problems here, but you never know.

Give it a try, it might work :-)

> 
> -----Original Message-----
> From: Hans Schillstrom [mailto:hans.schillstrom@ericsson.com] 
> Sent: Tuesday, April 03, 2012 12:14 PM
> To: Abhijit Chaudhary
> Cc: lvs-devel@vger.kernel.org
> Subject: Re: Transport support in LVS
> 
> Hello
> On Tuesday 03 April 2012 07:45:03 Abhijit Chaudhary wrote:
> > Hi,
> > I am new to LVS and wanted to understand its transport-level support. Am using RHEL 6.2 (kernel 2.6.32-220) and had couple of questions on it:
> > Did not find support for SCTP as a LVS transport protocol (no ip_vs_protocol). But LVS website mentions about SCTP support in ipvsadm-1.26. 
> > Am I missing something, was SCTP supported in older kernel release?
> 
> SCTP was introduced in 2.6.34 
> 
> > 
> > Other question is whether LVS supports load-balancing of IPSEC-packet (for ESP in transport mode with authentication and encryption enabled).  
> > My understanding:  ip_vs_in() is hooked to NF_INET_LOCAL_IN. But, ip_local_deliver() calls NF_INET_LOCAL_IN before decryption (esp_input). 
> > So, IPSEC with encryption enabled should not be load-balanced unless there is a repeat call to ip_local_deliver() after decryption.
> > My knowledge on xfrm framework and IPSEC is not good, so I may be missing something.
> 
> If you don't have the VIP address in your LVS node (just force the VIP to loopback by routing),
> then you should be able to send the ESP (or AH) packets through IPVS to a RS for decryption.
> 
> > 
> > Thanks,
> > -Abhijit
> > --
> > To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> 

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
