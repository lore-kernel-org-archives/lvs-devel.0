From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH ipvs,v4 19/20] ipvs: use the new dest addr family field
Date: Tue, 9 Sep 2014 22:41:11 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1409092229380.4943@ja.home.ssi.bg>
References: <1409301549-5284-1-git-send-email-agartrell@fb.com> <1409301549-5284-20-git-send-email-agartrell@fb.com> <alpine.LFD.2.11.1408291259510.4876@ja.home.ssi.bg> <5400EE48.5060007@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <5400EE48.5060007@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, kernel-team@fb.com


	Hello Alex,

On Fri, 29 Aug 2014, Alex Gartrell wrote:

> So, if I understand correctly, we'll wait until it lands in net-next and then
> I'll submit these patches to netdev?

	I think, you can now submit the patchset, net was
merged to net-next, so you need a fresh net-next copy.

	Also, can you try my ipvsadm patches to check for
possible problems in the connection listing, so that we
can safely apply them to the ipvsadm tree.

Regards

--
Julian Anastasov <ja@ssi.bg>
