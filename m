From: Julian Anastasov <ja@ssi.bg>
Subject: Re: 3.12.33 - BUG xfrm_selector_match+0x25/0x2f6
Date: Fri, 5 Dec 2014 11:55:23 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1412051126090.2522@ja.home.ssi.bg>
References: <547F2462.6040405@smart-weblications.de> <20141204075627.GE6390@secunet.com> <alpine.LFD.2.11.1412042338370.4841@ja.home.ssi.bg> <5481173A.9060308@smart-weblications.de>
Mime-Version: 1.0
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <5481173A.9060308@smart-weblications.de>
Sender: stable-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Smart Weblications GmbH - Florian Wiessner <f.wiessner@smart-weblications.de>
Cc: Steffen Klassert <steffen.klassert@secunet.com>, netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, stable@vger.kernel.org, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org


	Hello,

	Adding Simon to CC...

On Fri, 5 Dec 2014, Smart Weblications GmbH - Florian Wiessner wrote:

> i tried with 3.12.33 without any XFRM and now got this one (which is reproducable):
> 
> [  233.956012] BUG: unable to handle kernel NULL pointer dereference at 00000000
>                                    00000014
> [  233.956218] IP: [<ffffffffa013a470>] nf_ct_seqadj_set+0x60/0x90 [nf_conntrack

	It seems fix from 3.13 was not sent to 3.12 stable:

commit b25adce1606427fd8 ("ipvs: correct usage/allocation of seqadj ext in 
ipvs")

	There was related change but it is not needed
for stable kernels:

commit db12cf27435356017e ("netfilter: WARN about wrong usage of sequence 
number adjustments"

	Simon, can we try commit b25adce1606427fd8 for 3.12?

> setup is like this:
> 
> 
> #virtual=<myVIP>:21
> #       real=10.10.1.20:21 masq
> #       real=10.10.1.21:21 masq
> #       real=10.10.1.22:21 masq
> #       real=10.10.1.23:21 masq
> #       persistent=600
> #       service=ftp
> #       scheduler=rr
> #       protocol=tcp
> #       checktype=connect
> 
> ( i remarked it to prevent fruther crashes...)
> 
> when ip_vs_ftp is loaded and someone trying to make a ftp connection, the system
> panics instantly.
> 
> 10.10.1.20 - 10.10.1.23 are lxc-containers using veth connected to the bridge
> running on 4 different nodes. The node running ldirector/ipvsadm has also one of
> those containers running (don't know if that matters)

	It is always good to know the setup. Do you access VIP
from local clients (from director)?

> brctl show
> bridge name     bridge id               STP enabled     interfaces
> br0             8000.00259052bbf4       no              bond0
>                                                         vethMKELUc
>                                                         vethXdWGqf
>                                                         vethgJMmEb
>                                                         vethmKNqFc
> 
> 
> I disabled the ftp server lxc container on the node doing ip_vs, so that the
> endpoint of the connection is not on the same node and tried again but with the
> same result.
> 
> Unfortunatelly i cannot test with newer kernels than 3.12, because ocfs2 is
> somehow broken in >= 3.14

	Before I create patch to avoid rerouting for
LOCAL_IN you can try to set IPVS sysctl var "snat_reroute" to 0
or even to change ip_vs_route_me_harder() function just to return 0.
snat_reroute=1 (a default value) is needed if you have
multiple links to clients and use ip rules to select
correct route by src ip (after SNAT). If you have single
uplink snat_reroute can be 0.

Regards

--
Julian Anastasov <ja@ssi.bg>
