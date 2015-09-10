From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH ipvs-next] ipvs: add sysctl to ignore tunneled packets
Date: Thu, 10 Sep 2015 21:30:11 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1509102128220.1751@ja.home.ssi.bg>
References: <1441907665-1703876-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1441907665-1703876-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, kernel-team@fb.com


	Hello,

On Thu, 10 Sep 2015, Alex Gartrell wrote:

> This is a way to avoid nasty routing loops when multiple ipvs instances can
> forward to eachother.

	More details? Do we set the flag for IPIP packets
and what happens otherwise?

Regards

--
Julian Anastasov <ja@ssi.bg>
