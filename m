From: Wensong Zhang <wensong@linux-vs.org>
Subject: Re: [rfc 0/3] IPVS: checksum updates
Date: Thu, 11 Sep 2008 21:07:22 +0800
Message-ID: <48C9180A.10103@linux-vs.org>
References: <20080908020420.313463898@vergenet.net> <20080908234028.GF13048@verge.net.au> <f4845fc0809090230h1cbc01ev45c6ab4bdba61955@mail.gmail.com> <20080909113131.GA3605@verge.net.au> <f4845fc0809101030u2bd4dec4jb478ecc65240ea74@mail.gmail.com> <20080910232904.GD12291@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20080910232904.GD12291@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Simon Horman <horms@verge.net.au>
Cc: Julius Volz <juliusv@google.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Vince Busam <vbusam@google.com>

Simon Horman wrote:
> On Wed, Sep 10, 2008 at 07:30:52PM +0200, Julius Volz wrote:
>   
>> On Tue, Sep 9, 2008 at 1:31 PM, Simon Horman <horms@verge.net.au> wrote:
>>     
>>> On Tue, Sep 09, 2008 at 11:30:29AM +0200, Julius Volz wrote:
>>>       
>>>> Great, thanks! I have tested TCP+UDP, local+remote clients, v4+v6,
>>>> NAT+DSR+TUN in all combinations that are expected to be working and
>>>> found no problems.
>>>>         
>>> Thanks once again for your testing. I'll send a pull request to Dave in
>>> the morning.
>>>       
>> Thanks very much!
>>
>> (CC: Wensong)
>> I guess it would make sense to start hosting the new ipvsadm version
>> somewhere on http://www.linuxvirtualserver.org/ soon. It could still
>> be marked as unstable and saying, "If you intend to use the
>> experimental IPv6 support for IPVS introduced in kernel 2.6.XX, you
>> will need this new version of ipvsadm: ...". Also, we can then point
>> to it in the Kconfig help text in CONFIG_IP_VS_IPV6. What do you
>> think?
>>     
>
> Yes I agree. It would be good to start hosting tarballs of the
> new/unstable/experimental version of ipvsadm on www.linuxvirtualserver.org.
>
> Wensong, can we also host some sort of repository for ipvsadm on
> linuxvirtualserver.org? If not, I guess the next most logical choice
> would be to use kernel.org.
>
>   
Hi Horms and Julius,

I have created a svn repository for ipvsadm at 
http://svn.linuxvirtualserver.org/repos/ipvsadm/ before, will create the 
check-in accounts for you right now.

Thanks,

Wensong


