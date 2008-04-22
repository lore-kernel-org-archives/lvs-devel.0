From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: [lvs-users] TUN setup problem (fwd)
Date: Tue, 22 Apr 2008 08:05:19 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0804220758270.31166@wm7d.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Jason Stubbs <j.stubbs@linkthink.co.jp>
Cc: LVS Devel <lvs-devel@vger.kernel.org>


> for LVS-Tun you don't setup a tunnel. LVS makes its own ipip
> packet and forwards it through the regular ethernet device
> on the inside of the director to the tunl0 device on the
> realserver.

Hi Jason,

 	Don't know if you're up for messing with LVS-Tun or 
not. The poster this morning couldn't get LVS-Tun to work 
because he'd set up a tunnel between the director and the 
realserver. He didn't need to do this because LVS creates 
its own ipip packet. If you hadn't read the HOWTO, it would 
have been reasonable to do what the poster did. It occurs to 
me that LVS should be letting the kernel do as much as 
possible, and ip_vs() should let the kernel handle the 
tunnelling and we should have the users set up a tunl0 
device on the director. I think this would allow PMTU 
packets to come back from the realserver to the director 
too.

Anyhow just a thought

Joe

_______________________________________________
LinuxVirtualServer.org mailing list - lvs-users@LinuxVirtualServer.org
Send requests to lvs-users-request@LinuxVirtualServer.org
or go to http://lists.graemef.net/mailman/listinfo/lvs-users
