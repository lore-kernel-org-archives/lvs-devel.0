From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Forwarding method in backup server
Date: Tue, 5 Oct 2010 01:53:53 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1010050152050.1856@ja.ssi.bg>
References: <alpine.LFD.2.00.1009282343130.2049@ja.ssi.bg> <20101002083026.GD2248@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20101002083026.GD2248@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Wensong Zhang <wensong@linux-vs.org>, lvs-devel@vger.kernel.org


 	Hello,

On Sat, 2 Oct 2010, Simon Horman wrote:

>> 	Simon, may be now ip_vs_nat_xmit should see
>> RTCF_LOCAL flag and we should check all NAT handlers
>> to support the LOCALNODE fallback where the port can
>> be changed too.
>
> I'm not quite sure what you are describing there.
>
> Is the idea that if the forwarding mechanism is NAT
> then packets will always go via ip_vs_nat_xmit, even if
> the IP is local (at config time). And that ip_vs_nat_xmit()
> will use local xmit if RTCF_LOCAL is set?

 	Yes, that is what I implemented in last patch.

Regards

--
Julian Anastasov <ja@ssi.bg>
