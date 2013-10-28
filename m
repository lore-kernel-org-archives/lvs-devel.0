From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH ipvs 2/2] net: ipvs: sctp: do not recalc sctp checksum
 when not needed
Date: Mon, 28 Oct 2013 11:00:37 +0200 (EET)
Message-ID: <alpine.LFD.2.03.1310281058410.1490@ssi.bg>
References: <1af1d5e1aae9df91683625f0cb120b329e8d2f10.1382689350.git.dborkman@redhat.com> <8390127344501c35ed3c23f3690b8a671d353870.1382689350.git.dborkman@redhat.com> <alpine.LFD.2.03.1310252306230.1600@ssi.bg> <526C102C.9040306@redhat.com>
 <20131028013920.GO849@verge.net.au> <526E1C3D.1080800@redhat.com> <20131028085024.GA26154@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20131028085024.GA26154@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Daniel Borkmann <dborkman@redhat.com>, lvs-devel@vger.kernel.org, linux-sctp@vger.kernel.org


	Hello,

On Mon, 28 Oct 2013, Simon Horman wrote:

> Thanks, I have pushed it to ipvs-next.
> 
> I will hold off on sending a pull-request to Pablo until you send
> the 2nd patch.

	First patch is a bugfix, it should go to stable
kernels. The second patch looks like an optimization.

Regards

--
Julian Anastasov <ja@ssi.bg>
