From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH ipvs 2/2] net: ipvs: sctp: do not recalc sctp checksum
 when not needed
Date: Mon, 28 Oct 2013 17:50:25 +0900
Message-ID: <20131028085024.GA26154@verge.net.au>
References: <1af1d5e1aae9df91683625f0cb120b329e8d2f10.1382689350.git.dborkman@redhat.com>
 <8390127344501c35ed3c23f3690b8a671d353870.1382689350.git.dborkman@redhat.com>
 <alpine.LFD.2.03.1310252306230.1600@ssi.bg>
 <526C102C.9040306@redhat.com>
 <20131028013920.GO849@verge.net.au>
 <526E1C3D.1080800@redhat.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <526E1C3D.1080800@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Daniel Borkmann <dborkman@redhat.com>
Cc: Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, linux-sctp@vger.kernel.org

On Mon, Oct 28, 2013 at 09:11:41AM +0100, Daniel Borkmann wrote:
> On 10/28/2013 02:39 AM, Simon Horman wrote:
> 
> >I am happy to take the 1st patch of the series as-is.
> >Let me know if that works for you.
> 
> Yes, sure. Then, I'll only resend the 2nd one today.

Thanks, I have pushed it to ipvs-next.

I will hold off on sending a pull-request to Pablo until you send
the 2nd patch.
