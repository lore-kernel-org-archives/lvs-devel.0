From: Alex Gartrell <agartrell@fb.com>
Subject: Re: ipvs: Pull out crosses_local_route_boundary logic
Date: Mon, 6 Oct 2014 08:45:38 -0700
Message-ID: <5432B922.2030708@fb.com>
References: <20141001174526.GA16206@mwanda> <alpine.LFD.2.11.1410012225530.3494@ja.home.ssi.bg> <5431D876.5020002@fb.com> <20141006073232.GA10073@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=message-id : date : from :
 mime-version : to : cc : subject : references : in-reply-to : content-type
 : content-transfer-encoding; s=facebook;
 bh=Zs4iq13iNEo8wtZN9enlLXU9fxp/Lng7KjJAMX0CEME=;
 b=eSkFtOpPFL9rtc/URa+IxvHGuxACA3WFaE3PzN2T014UCpLVKilniYSuJ/RIe2YHLNw9
 4vfW67e2Q0QFDzfSk7vBX20MfEp3gAYGjkGfq/sq3sOIaxI7lJEWdwF3u+mCkcvQC8xp
 9fVDvnRK4poP4yKfUgRGUF/OKHbELL2jTZY= 
In-Reply-To: <20141006073232.GA10073@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>, Dan Carpenter <dan.carpenter@oracle.com>, lvs-devel@vger.kernel.org

Hey Simon,

On 10/06/2014 12:32 AM, Simon Horman wrote:

> I am following this thread so its not a big deal but in general please CC
> me as well as Julian and lvs-devel on any patches you want considered for
> inclusion in IPVS kernel code.
>

Just double checking (due to previous mail-related issues), did you get 
the patch I sent last night?  You were to'ed there.

I've just mailed another patch using daddr that should address this issue.


Thanks,
-- 
Alex Gartrell <agartrell@fb.com>
