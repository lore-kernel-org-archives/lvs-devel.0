From: Dmitry Akindinov <dimak@stalker.com>
Subject: Re: Multiple load balancers problem
Date: Thu, 30 Aug 2012 21:24:04 +0400
Message-ID: <503FA1B4.6090600@stalker.com>
References: <thl3856.36e267c5beb1d7b35e7e87b807e0b5f4@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <thl3856.36e267c5beb1d7b35e7e87b807e0b5f4@obelix.schillstrom.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org

Hello,

On 2012-08-28 00:43, Hans Schillstrom wrote:
> Hello
>
> [snip]
>
>>>
>>> 	No loop? Because S2 will receive DR method in
>>> the SYNC messages for its stack. You see traffic flow
>>> or just that there is no reset?
>>
>> Yes, after the failover, all connections that were open on the S2 (which
>> now becomes the active balancer) do not reset and continue to function
>> just fine (traffic flow in both directions).
>>
>> We do understand (we think) your explanation about the sync table
>> problem  - the connections to the actual balancer are marked in a
>> special way, which causes problems when these connection table records
>> are used on a new balancer.
>>
>> It looks like updating the kernels is the only way, if (as you and Hans
>> Schillstrom outlines) even the latest CentOS/RedHat kernels do not
>> contain necessary patches. It's a pity, as the idea was to provide an
>> "out of the box" solution for our customers, and asking them to update
>> to some Linux kernel is not what they like to hear.
>>
>> But thank you very much in any case, we will update the kernels on our
>> test systems and will see if this (last?) problem disappears.
>>
>
> There is newer kernels floating around in the 3.x range
> Have a look at ELRepo Project there you can find a 3.5.x kernel
> that have all necessary changes.

Installed CentOS 6.3 and the kernel 3.5.3 from elrepo.org

[root@fe3 ~]# uname -a
Linux fe3.msk 3.5.3-1.el6.elrepo.x86_64 #1 SMP Sun Aug 26 14:05:15 EDT 
2012 x86_64 x86_64 x86_64 GNU/Linux


But we still see the same problem: connections to the old balancer are 
RSET'ed when the new balancer takes over. Any idea which particular 
kernel we need to use? Or, do we need to apply some specific patches and 
build our own kernel?

Thank you for all your help so far!

> BR
> Hans
>

-- 
Best regards,
Dmitry Akindinov


