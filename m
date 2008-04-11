From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: moving ipvs() to POST/PREROUTING
Date: Fri, 11 Apr 2008 07:38:30 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0804110729030.3476@wm7d.net>
References: <200804111400.12331.j.stubbs@linkthink.co.jp>
 <Pine.LNX.4.64.0804110530590.22135@wm7d.net> <200804112213.32476.j.stubbs@linkthink.co.jp>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <200804112213.32476.j.stubbs@linkthink.co.jp>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: LVS Devel <lvs-devel@vger.kernel.org>

On Fri, 11 Apr 2008, Jason Stubbs wrote:

>>> Is there any problem with essentially hiding the real
>>> servers from netfilter?
>>
>> I don't know what this means (I didn't know that netfilter
>> knew about the realservers).
>
> I mean that it'd be nice for rules to go something like:
> * Allow from external to VIP
> * Allow anything established
> * Drop everything else
>
> Depending on where LVS translations are placed in the netfilter path, rules
> allowing traffic from external to RIPs may also be needed.

I would hope people don't do this. RIPs should be private, 
for security reasons and to preserve the fiction that the 
LVS setup is one machine. The LVS'ed application running on 
the realserver might start a client process that needs to 
contact 0/0, but that can be nat'ed out, possibly through 
the VIP on the director, or maybe some other public IP 
available to the realserver. Is this what you want to do?

see

http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.LVS-DR.html#Pearthree

>> Will your setup handle the F5-SNAT situation?
>>
>> http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.non-modified_realser
>> vers.html#F5_snat
>
> Yep, this is just SNAT as far as I can tell. I tested SNAT on both sides of
> the director and there weren't any problems.

neato. Some people will be very happy about this.

I take it that you're working late at night on this :-)

Joe

-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
