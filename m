From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: moving ipvs() to POST/PREROUTING- was: Real servers
 as LVS clients
Date: Thu, 10 Apr 2008 07:09:45 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0804100658460.22622@wm7d.net>
References: <200804091658.43490.j.stubbs@linkthink.co.jp>
 <Pine.LNX.4.64.0804090725590.11500@wm7d.net> <200804101700.49942.j.stubbs@linkthink.co.jp>
 <200804101720.33657.j.stubbs@linkthink.co.jp>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <200804101720.33657.j.stubbs@linkthink.co.jp>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Jason Stubbs <j.stubbs@linkthink.co.jp>
Cc: lvs-devel@vger.kernel.org

On Thu, 10 Apr 2008, Jason Stubbs wrote:

Hi Jason,

 	I'm moving this thread to the lvs-devel list.

(http://lists.graemef.net/mailman/listinfo/lvs-devel, in 
case you aren't subscribed)

>> Moving ip_vs_in to the end of POSTROUTING and moving 
>> ip_vs_out to the start of PREROUTING as in the attached 
>> patch seems to work and lets me do what I want. LVS-NAT 
>> and SNAT are working both independently and in 
>> conjunction to allow connections to VIPs from anywhere.

There's an effort to move ipvs() out of LOCAL_IN. Horms is 
coordinating the patches, but he's just moved from Japan to 
Sydney and will be even busier than he's been previously.

> Well, SNAT works independently and LVS-NAT works in 
> conjuction with SNAT but LVS-NAT isn't working on its own. 
> I'll look into this and try and fix it, but the questions 
> below still stand. :)
>
>> I haven't tested LVS-DR, LVS-TUN or localnode (although I 
>> think localnode should still work) and am not so worried 
>> if they don't work. Are there any other issues likely to 
>> arise with this patch? Is there any reason why LVS didn't 
>> hook into (or near) those places in the first place?
>>
>> I understand that it'll likely never be accepted because 
>> it'd break pretty much every existing installation (VIP 
>> on an interface would not make it to IPVS)...

We're going to do it whether it breaks everything or not. It 
needs to be done.

Joe
-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
