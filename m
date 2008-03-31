From: Simon Horman <horms@verge.net.au>
Subject: Re: Making IPVS work with IPv6
Date: Mon, 31 Mar 2008 22:36:38 +0900
Message-ID: <20080331133634.GC3690@verge.net.au>
References: <f4845fc0803280845n6a4d8683gffe95c8d64572971@mail.gmail.com> <Pine.LNX.4.64.0803280853110.28825@wm7d.net> <20080331030715.GH31306@verge.net.au> <Pine.LNX.4.64.0803310441440.9996@wm7d.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803310441440.9996@wm7d.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joseph Mack NA3T <jmack@wm7d.net>
Cc: Julius Volz <juliusv@google.com>, lvs-devel@vger.kernel.org

On Mon, Mar 31, 2008 at 04:43:35AM -0700, Joseph Mack NA3T wrote:
> On Mon, 31 Mar 2008, Simon Horman wrote:
>
>> [ Joe, I'm not sure that the LOCAL_IN stuff is really related
>>  specifically to IPv6. But you do remind me that those patches
>>  need to be revisited. ]
>
> Agree, but we don't want Julius writing code for LOCAL_IN at the same 
> time we're moving the hook elsewhere.

IIRC the current change that is being talked about is to allow
switching from one hook to another. I think it will be a long
while before LOCAL_IN is removed because I think there will be
a lot of subtle differences between LVS-LOCAL_IN and LVS-FORWRD.
The kind of differences that will break things for some people.
So I think LOCAL_IN will have to remain as an option even if
FORWARD ends up working well for most people most of the time.

-- 
Horms

