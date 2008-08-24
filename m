From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: [PATCH RFC 00/24] IPVS: Add first IPv6 support to IPVS
Date: Sat, 23 Aug 2008 18:40:32 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0808231831340.23506@wm7d.net>
References: <1219248931-15064-1-git-send-email-juliusv@google.com> 
 <20080821212948.GB4407@verge.net.au>  <20080821220444.GA2758@verge.net.au>
  <f4845fc0808220256y4649f48djf8498fa8e5499dca@mail.gmail.com> 
 <1219399551.4246.10.camel@ernie.internal.graemef.net> 
 <f4845fc0808220349r6c498eddkae80eb47ed0b5a06@mail.gmail.com> 
 <alpine.LNX.1.10.0808221316530.10895@titan.stealer.net> 
 <f4845fc0808220514y64a2db11s459f4662703e6b0e@mail.gmail.com> 
 <1219483206.10379.5.camel@ernie.internal.graemef.net> 
 <Pine.LNX.4.64.0808230818480.21220@wm7d.net>
 <f4845fc0808231607j3ebc1a9el283da725783aa11a@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <f4845fc0808231607j3ebc1a9el283da725783aa11a@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: Graeme Fowler <graeme@graemef.net>, Sven Wegener <sven.wegener@stealer.net>, Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Sun, 24 Aug 2008, Julius Volz wrote:

> The other missing features are the 4 missing schedulers (DH, SH, LBLC,
> LBLCR) and the FTP application helper.

If it helps, the ipv4 ftp helper causes a lot of problems. 
People can't get it to work, because they can't follow the 
instructions. ftp is hard to secure and I think it should be 
done on a separate single machine. But if you have reasons 
to write an ipv6 ftp helper, don't let me stop you. I 
personally don't know important it is to have load balanced 
ftp. How does ftp.gnu.org and ftp.kernel.org handle their 
load? Since it's read-only, wouldn't failover handle it?

Now that I think if it. ibiblio.org, just up the street from 
me, runs on LVS. So maybe load balanced ftp is useful.

Joe

-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
