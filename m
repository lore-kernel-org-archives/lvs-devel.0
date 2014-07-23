From: Alex Gartrell <agartrell@fb.com>
Subject: RE: [PATCH ipvs 1/2] ipvs: Do tcp/udp checksumming prior to tunnel
 xmit
Date: Wed, 23 Jul 2014 19:16:07 +0000
Message-ID: <B3481EE3D901EA4983A2D2CFBA42F3AA700E2782@PRN-MBX01-3.TheFacebook.com>
References: <1406097465-8180-1-git-send-email-agartrell@fb.com>,<alpine.LFD.2.11.1407231054180.5114@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : references : in-reply-to : content-type :
 content-transfer-encoding : mime-version; s=facebook;
 bh=bGknzQAyQ98sPoNBHOVTbo0MX7ZhUfnez4Jp1I9o4j8=;
 b=eSpChZPwXFYcwv2l+T/UEt58ilDNYCMk8SLONt5Gft7F0cvw/+tftxveFQODhfrm3Cqe
 ccvJO4luM/CuK1oD/NvdxQuyn5mgPUetGM1ZWYIXCyObYvbdHnsbLUvV9KQ9EzSm2B5+
 oIVjS/vK3C4wbmcFvaXuNDdMf+biNK8MnJU= 
In-Reply-To: <alpine.LFD.2.11.1407231054180.5114@ja.home.ssi.bg>
Content-Language: en-US
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: "horms@verge.net.au" <horms@verge.net.au>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, kernel-team <Kernel-team@fb.com>

Thank you for the review!

> 
> 	Hello,
> 
> On Tue, 22 Jul 2014, Alex Gartrell wrote:
> 
> > The combination of NF_INET_LOCAL_OUT and hardware checksum offload
> > results in picking the packet out of the send path before it gets
> > proper checksums. Our NICs (most NICs?) cannot do the checksumming
> > in ipip packets, so these faulty tcp/udp headers arrive at their
> > destination and are discarded.
> > 
> > Instead, checksum the tcp/udp packets in the tunnel transmit path.
> > Right now we do this for all packets, but a subsequent patch will
> > limit this to the NF_INET_LOCAL_OUT hook.
> 
> 	After the support for hardware-offloaded encapsulation
> went in we may lack some support, like playing with
> skb->encapsulation, etc. I'm not sure calculating the checksums in all
> cases (ip_summed) is the right thing to do.
> 
> 	For DR and TUN we tried to avoid checking and
> calculating checksum because we do not mangle the payload.
> But CHECKSUM_PARTIAL in ip_summed is a special case.
> We call skb_forward_csum() from ip_vs_tunnel_xmit_prepare
> but may be it is not enough. Such interesting case is
> local TCP client (CHECKSUM_PARTIAL) forwarded via TUN.

Yes, it appears that skb_checksum_help was the magic function I was hoping
for.  I'll put up a new patch that invokes this function, as it seems to
fix the problem by itself (and by checking the ip_summed field, it .

> 	Can you give more information, eg. what
> value you see in ip_summed, leading to these problems?
> And whether packet to IPVS comes from local stack or
> from remote client. Is TCP/UDP checksum offload running?
> 

Three tests:
* From a remote server: CHECKSUM_UNNECESSARY
* From the local server with hardware checksum offload enabled:
  CHECKSUM_PARTIAL
* From the local server with hardware checksum offload disabled:
  CHECKSUM_PARTIAL

I was mildly surprised by the last one.  In general I think that ip_summed
is a better way to figure out whether or not we should checksum though.



In any event, given that the skb_checksum_helper function is way more
likely to "just work," I'll put out a patch that adds this invocation
instead.


Thanks,
Alex