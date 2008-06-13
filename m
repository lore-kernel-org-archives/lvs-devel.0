From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Fri, 13 Jun 2008 09:00:07 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0806130855380.24266@wm7d.net>
References: <f4845fc0806111314r41e7736ay54d22cf28efa2d27@mail.gmail.com> 
 <20080612014548.GE22358@verge.net.au>  <f4845fc0806120631g511c7dbag365a8483134943fd@mail.gmail.com>
  <485126BD.7030109@trash.net>  <f4845fc0806120834xd904f45x19e100c832d3417@mail.gmail.com>
  <485144DF.3030102@trash.net>  <f4845fc0806121233i54099a18k9104eb34359b923f@mail.gmail.com>
  <20080613062621.GA10474@verge.net.au>  <f4845fc0806130717v2e892707tee1e401b39dbab81@mail.gmail.com>
  <Pine.LNX.4.64.0806130719590.17809@wm7d.net>
 <f4845fc0806130801m4cfc9a90ifc7ab11abb6b509a@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <f4845fc0806130801m4cfc9a90ifc7ab11abb6b509a@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: Simon Horman <horms@verge.net.au>, Graeme Fowler <graeme@graemef.net>, Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, Vince Busam <vbusam@google.com>

On Fri, 13 Jun 2008, Julius Volz wrote:

> Not sure if I understood completely what you wanted to have compatible
> with what. My opinion is that we should only worry about not breaking
> the kernel interface:

yes yours is a different concern.

at some point (eg now) decide that from here on, only one 
ipvsadm source file will exist (rather than one for each 
kernel). As new kernels come along, ipvsadm will detect the 
kernel on compile and produce the correct binary. The 
ipvsadm will accumulate code for different kernel versions

Joe
-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
