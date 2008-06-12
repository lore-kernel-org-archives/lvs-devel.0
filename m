From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Thu, 12 Jun 2008 11:45:48 +1000
Message-ID: <20080612014548.GE22358@verge.net.au>
References: <48501C81.6010800@trash.net> <f4845fc0806111205j36c912d3vf1b632a3d0777a1c@mail.gmail.com> <4850233E.7090501@trash.net> <f4845fc0806111229l6666161fu9d3bc5e432668485@mail.gmail.com> <48502826.9060502@trash.net> <f4845fc0806111253l4f1fea4fyef05cdc41ca45911@mail.gmail.com> <f4845fc0806111314r41e7736ay54d22cf28efa2d27@mail.gmail.com> <48503BBD.6000307@google.com> <485043E6.5030105@candelatech.com> <485050FE.6030209@google.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <485050FE.6030209@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vince Busam <vbusam@google.com>
Cc: Ben Greear <greearb@candelatech.com>, Julius Volz <juliusv@google.com>, Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Wed, Jun 11, 2008 at 03:26:06PM -0700, Vince Busam wrote:
> Ben Greear wrote:
>> You can have the kernel ignore any data it doesn't understand (ie, if  
>> struct is 24 bytes,
>> but the kernel expects 20 bytes, just ignore the last 4).  This way it  
>> should
>> work with newer binaries.
>
> Currently, the IPVS code specifically checks that length, so all kernels  
> up to now won't play well with any changes to the structs.

Adding new features to IPVS that require ipvsadm to be extended
has always been problematic due to the set/getsockopt interface
that is used.

A long time ago, before this code was merged into the kernel, the
interface changed quite a lot and this was painful. There was an
assumption that ipvsadm and kernel versions needed to match,
and the version checking code was added basically to stop people
shooting themselves in the foot. It was quite successful at that.

Eventially the changes settled down, and for the past few years they
have been very infrequent.  But the problem that the interface isn't
really extendable and that when changes are made kernel and ipvsadm
versions need to be incremented together remains. For instance, the
Debian package of ipvsadm actually shipps three different ipvsadm
binaries, and a wrapper works out which one to use based on the kernel
version.

I wonder if now would be a good time to bite the bullet and design
a new interface that is extendable.


-- 
Horms

