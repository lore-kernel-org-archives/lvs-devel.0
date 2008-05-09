From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: [PATCH] Move IPVS from net/ipv4/ipvs to net/netfilter/ipvs in
 preparation for IPv6 support
Date: Fri, 9 May 2008 05:49:52 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0805090536120.22107@wm7d.net>
References: <f4845fc0805070732v516fc8c6y2cdddfd4f99c8f96@mail.gmail.com> 
 <Pine.LNX.4.64.0805070734580.6164@wm7d.net> <f4845fc0805070851y7f1f00d0xd2dfcc7feb79c173@mail.gmail.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <f4845fc0805070851y7f1f00d0xd2dfcc7feb79c173@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Horms <horms@vergenet.net>

On Wed, 7 May 2008, Julius Volz wrote:

> Hm, ok. This patch doesn't touch any functionality though. It only
> moves files from one directory to another, so it's merely cosmetics,
> no IPv6 knowledge required.

are you at a stage where it's all split up, after which 
you'll only be working on the ipv6 part and leaving the ipv4 
untouched? Have you tested the ipv4 part to make sure it's 
still OK. ie the code is reorthogonalised but with no change 
in functionality?

If so then this might be a good point to submit to the 
kernel. Also Jason might be interested in the new version of 
the code (hopefully working in different parts of the code, 
you two won't be having many collisions).

One of the things I worry about (from personal experience) 
is people working on projects and getting stuck for time and 
later having to drop the work. If you can submit the 
reorthogonalised code, and have to stop sometime later, at 
least we've got that far down the road.

Horms,
 	Do you want ipvs() reorthogonalised into ipv4/ipv6 
blocks, presumably with the ipv4 functionality untouched, 
and with ipv6 stubs, for submission to the kernel, or do you 
want to wait for the finished product?

Joe

-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
