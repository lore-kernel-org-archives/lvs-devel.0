From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re[2]:  Multiple load balancers problem
Date: Mon, 27 Aug 2012 22:43:41 +0200 (CEST)
Message-ID: <thl3856.36e267c5beb1d7b35e7e87b807e0b5f4@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Dmitry Akindinov <dimak@stalker.com>
Cc: Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org

Hello

[snip]

>>
>> 	No loop? Because S2 will receive DR method in
>> the SYNC messages for its stack. You see traffic flow
>> or just that there is no reset?
>
>Yes, after the failover, all connections that were open on the S2 (which 
>now becomes the active balancer) do not reset and continue to function 
>just fine (traffic flow in both directions).
>
>We do understand (we think) your explanation about the sync table 
>problem  - the connections to the actual balancer are marked in a 
>special way, which causes problems when these connection table records 
>are used on a new balancer.
>
>It looks like updating the kernels is the only way, if (as you and Hans 
>Schillstrom outlines) even the latest CentOS/RedHat kernels do not 
>contain necessary patches. It's a pity, as the idea was to provide an 
>"out of the box" solution for our customers, and asking them to update 
>to some Linux kernel is not what they like to hear.
>
>But thank you very much in any case, we will update the kernels on our 
>test systems and will see if this (last?) problem disappears.
>

There is newer kernels floating around in the 3.x range
Have a look at ELRepo Project there you can find a 3.5.x kernel
that have all necessary changes.

BR
Hans 

