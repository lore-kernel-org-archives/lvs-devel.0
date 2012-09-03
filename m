From: Dmitry Akindinov <dimak@stalker.com>
Subject: Re: Multiple load balancers problem
Date: Mon, 03 Sep 2012 11:54:52 +0400
Message-ID: <5044624C.2050502@stalker.com>
References: <qnh1578.b598d4432b1e15f21bf9beee8c3c376e@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <qnh1578.b598d4432b1e15f21bf9beee8c3c376e@obelix.schillstrom.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org

Hello,

On 2012-08-31 12:21, Hans Schillstrom wrote:
>>
>> Hello,
>>
>> On 2012-08-28 00:43, Hans Schillstrom wrote:
>>> Hello
>>>
>>> [snip]
>>>
>>>>>
>>>>> 	No loop? Because S2 will receive DR method in
>>>>> the SYNC messages for its stack. You see traffic flow
>>>>> or just that there is no reset?
>>>>
>>>> Yes, after the failover, all connections that were open on the S2 (which
>>>> now becomes the active balancer) do not reset and continue to function
>>>> just fine (traffic flow in both directions).
>>>>
>>>> We do understand (we think) your explanation about the sync table
>>>> problem  - the connections to the actual balancer are marked in a
>>>> special way, which causes problems when these connection table records
>>>> are used on a new balancer.
>>>>
>>>> It looks like updating the kernels is the only way, if (as you and Hans
>>>> Schillstrom outlines) even the latest CentOS/RedHat kernels do not
>>>> contain necessary patches. It's a pity, as the idea was to provide an
>>>> "out of the box" solution for our customers, and asking them to update
>>>> to some Linux kernel is not what they like to hear.
>>>>
>>>> But thank you very much in any case, we will update the kernels on our
>>>> test systems and will see if this (last?) problem disappears.
>>>>
>>>
>>> There is newer kernels floating around in the 3.x range
>>> Have a look at ELRepo Project there you can find a 3.5.x kernel
>>> that have all necessary changes.
>>
>> Installed CentOS 6.3 and the kernel 3.5.3 from elrepo.org
>>
>> [root@fe3 ~]# uname -a
>> Linux fe3.msk 3.5.3-1.el6.elrepo.x86_64 #1 SMP Sun Aug 26 14:05:15 EDT
>> 2012 x86_64 x86_64 x86_64 GNU/Linux
>>
>>
>> But we still see the same problem: connections to the old balancer are
>> RSET'ed when the new balancer takes over. Any idea which particular
>> kernel we need to use? Or, do we need to apply some specific patches and
>> build our own kernel?
>
> A silly question,  old and new in this case
> I hope it's a 3.5.x kernel in both cases ...

Yes, sure. :-) The kernels were upgraded on both frontends.
And in fact, that helped. My previous report that the problem was still 
observed with the new kernel - well, it was not correct. The test 
environment on virtual machines was not set up correctly.

We will do more extensive testing this week, but for now it appears that 
problems we reported initially have gone when we upgraded the kernel to 
3.5.3.

Thank you!

[]

-- 
Best regards,
Dmitry Akindinov


