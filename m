From: Simon Horman <horms@verge.net.au>
Subject: Re: [Linux-HA] UDP / DHCP / LDIRECTORD
Date: Fri, 16 Apr 2010 08:52:45 +1000
Message-ID: <20100415225245.GJ12674@verge.net.au>
References: <20100412020447.GB10826@verge.net.au>
 <20100413025551.GA25064@verge.net.au>
 <131ECB70A13234449BBD551EC5022B6868E7205F84@VA3DIAXVS061.RED001.local>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <131ECB70A13234449BBD551EC5022B6868E7205F84@VA3DIAXVS061.RED001.local>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Brian Carpio <bcarpio@broadhop.com>
Cc: "linux-ha@lists.linux-ha.org" <linux-ha@lists.linux-ha.org>, lvs-devel <lvs-devel@vger.kernel.org>, Julian Anastasov <ja@ssi.bg>

On Thu, Apr 15, 2010 at 12:57:29PM -0700, Brian Carpio wrote:
> Simon,
> 
> Thanks again for all of your hard work, I have sent over a million UDP DHCP packets at the new kernel/ipvsadm with the patches applied and currently the only issue (which you know about already) is that ldirectord doesn't know about the -o option which causes a slight issue with heartbeat (but I just put in a cheap fix in my ldirectord start script to edit the services created by ldirectord).. 
> 
> So not only have I sent over 1,000,000 packets to this setup but I have also sent them as fast as 10 packets every 3 milliseconds, I plan to do a long term week long test but I don't foresee any issues.. 
> 
> Let me know if there is any other testing you would like us to do.. or if you would like me to send out the kernel-2.6.18-128 with the patch and the ipvsadm-1.24-10 rpm with the patch.. 
> 
> Thanks again Simon you are the man!!

Hi Brian,

thanks for your testing, it is very valuable.  I'm very glad that the code
is working,  though the real credit should go to Julian Anastasov, I just
up-ported the code.

I will try and make another up-port to 2.6.33, which is likely to be a bit
more involved than the port to 2.6.18, as quite a lot of changes have
passed under the bridge between 2.6.18 and 2.6.33.

On a personal note, I'm in the process of moving at the moment.
Unfortunately that is likely to impact on my time for the next month or so.
