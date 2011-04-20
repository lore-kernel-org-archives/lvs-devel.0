From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/3] IPVS: Change of socket usage to enable name space exit.
Date: Wed, 20 Apr 2011 03:00:01 -0700
Message-ID: <m1aafltf8e.fsf@fess.ebiederm.org>
References: <1303226705-29178-1-git-send-email-hans@schillstrom.com>
	<20110419221145.GC12922@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110419221145.GC12922@verge.net.au> (Simon Horman's message of
	"Wed, 20 Apr 2011 07:11:46 +0900")
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Hans Schillstrom <hans@schillstrom.com>, ja@ssi.bg, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans.schillstrom@ericsson.com

Simon Horman <horms@verge.net.au> writes:

> On Tue, Apr 19, 2011 at 05:25:03PM +0200, Hans Schillstrom wrote:
>> This is the first patch in a series of three.
>> The cleanup doesn't work when not exit in a clean way by using ipvsadm.
>> Killing of a namespace causes a hanging ipvs, this series will cure that.
>> 
>> If the sync daemons run in a namespace while it crashes
>> or get killed, there is no way to stop them except for a reboot.
>> 
>> Kernel threads should not increment the use count of a socket.
>> By calling sk_change_net() after creating a socket this is avoided.
>> sock_release cant be used, instead sk_release_kernel() should be used.
>> 
>> Thanks to Eric W Biederman.
>> 
>> This patch is based on net-next-2.6  ver 2.6.39-rc2
>
> Thanks Hans and Eric.
>
> Is it only this 1st patch that is intended for 2.6.39?
> The entire series feels a bit long to be applied
> this late in the rc series.

Hans was tracking two bugs that I gave him some advice on.
The first was the threads keeping namespaces from exiting
at the proper time, which the first patch appears to almost
fix.  I didn't see the code in that to ensure the threads
were gone.

The second was a something that sounded like packets flying
around during network namespace subsys cleanup.  Simply
not having network devices and sockets open in the namespace
should be enough to guarantee you don't have packets flying
around.

My feeling is that the patches are in the right neighbourhood
but not quite there yet.

Eric
