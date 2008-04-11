From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: moving ipvs() to POST/PREROUTING
Date: Fri, 11 Apr 2008 05:37:03 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0804110530590.22135@wm7d.net>
References: <200804111400.12331.j.stubbs@linkthink.co.jp>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <200804111400.12331.j.stubbs@linkthink.co.jp>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Jason Stubbs <j.stubbs@linkthink.co.jp>
Cc: LVS Devel <lvs-devel@vger.kernel.org>

On Fri, 11 Apr 2008, Jason Stubbs wrote:

> With local node, 127.0.0.1 doesn't work but an IP address on a local interface
> does.

that will do.

Local node isn't real important. It was there because it 
could be done, rather than because it was needed. If you can 
do it, we'll take it, but otherwise don't worry a whole lot 
about it.

> LVS-TUN should work as LVS-DR didn't require any direct 
> modification, but it's a little bit of a pain to set up 
> for testing at this stage.

have the same physical setup as LVS-DR and just change the 
if on the realservers to tunl0 and change the 
appropriated ipvsadm lines.

> Is there any problem with essentially hiding the real 
> servers from netfilter?

I don't know what this means (I didn't know that netfilter 
knew about the realservers).

Will your setup handle the F5-SNAT situation?

http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.non-modified_realservers.html#F5_snat

Joe

-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
