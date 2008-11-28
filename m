From: "Catalin(ux) M. BOIE" <catab@embedromix.ro>
Subject: Re: [PATCH] IPVS: Allow boot time change of hash size.
Date: Fri, 28 Nov 2008 01:49:31 -0700 (MST)
Message-ID: <55785.91.201.80.240.1227862171.squirrel@mail.embedromix.ro>
References: <1227706578-5449-1-git-send-email-catab@embedromix.ro>
    <Pine.LNX.4.64.0811260636100.26650@wm7d.net>
    <37809.91.201.80.240.1227769089.squirrel@mail.embedromix.ro>
    <Pine.LNX.4.64.0811270754290.32640@wm7d.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0811270754290.32640@wm7d.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Joseph Mack NA3T <jmack@wm7d.net>
Cc: "Catalin M. BOIE" <catab@embedromix.ro>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org


> On Wed, 26 Nov 2008, Catalin(ux) M. BOIE wrote:
>
>>> Why do you need to change the hash size? We really don't
>>> recommend anyone do this under normal circumstances
>>
>> As it is written in the help, to lower the collisions in
>> the case of a lot of concurrent connections. Or am I
>> missing something?
>
> not sure how big the collision problem is (have you measured
> an effect?) but Ratz put out the results of a back of the
> envelope calculation that the current value for the hash
> table size would work on the currect fastest machines with
> 3G of memory

Hello, Joe!

No, I did not measure it, but, I read the help text:

Note the table size must be power of 2. The table size will be the
value of 2 to the your input number power. The number to choose is
from 8 to 20, the default number is 12, which means the table size
is 4096. Don't input the number too small, otherwise you will lose
performance on it. You can adapt the table size yourself, according
to your virtual server application. It is good to set the table size
not far less than the number of connections per second multiplying
average lasting time of connection in the table.  For example, your
virtual server gets 200 connections per second, the connection lasts
for 200 seconds in average in the connection table, the table size
should be not far less than 200x200, it is good to set the table
size 32768 (2**15).

The help is wrong or I am missing something?

> Joe
>
> --
> Joseph Mack NA3T EME(B,D), FM05lw North Carolina
> jmack (at) wm7d (dot) net - azimuthal equidistant map
> generator at http://www.wm7d.net/azproj.shtml
> Homepage http://www.austintek.com/ It's GNU/Linux!
>


-- 
Catalin(ux) M. BOIE
http://kernel.embedromix.ro/

