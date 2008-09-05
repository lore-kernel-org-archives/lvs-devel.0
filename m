From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCHv3 00/24] Add first IPv6 support to IPVS
Date: Fri, 5 Sep 2008 13:05:12 +0200
Message-ID: <f4845fc0809050405q650b66b3j266b9429476eb3bb@mail.gmail.com>
References: <1220363755-9854-1-git-send-email-juliusv@google.com>
	 <20080905012554.GC14128@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220612716; bh=w99/5LWnmty9H4gbAQDLVSn64Ik=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=az3byOBiXXUqMoo1HNXsFnhPGmhtZbV2
	8kG2bSdv/gnB2LwTpZtau+FyHq9Cxz3OezO5SyuHXdR0w2TfPJtiZA==
In-Reply-To: <20080905012554.GC14128@verge.net.au>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Fri, Sep 5, 2008 at 3:25 AM, Simon Horman <horms@verge.net.au> wrote:
> On Tue, Sep 02, 2008 at 03:55:31PM +0200, Julius Volz wrote:
>> Hi Horms,
>>
>> Here comes the whole batch again! I've fixed almost all style issues
>> reported by checkpatch.pl, except for some little things which look like
>> they could stay like they are for now (down to 3 warnings and 2 errors).
>> I also integrated your other comments and removed the patch that
>> adds the changelog information (not needed anymore, according to
>> Stephen).
>>
>> These patches are based on lvs-2.6:
>>
>> git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-2.6.git
>>
>> - Full kernel patch in one file:
>>   http://www-user.tu-chemnitz.de/~volz/ipvs_ipv6/ipvs_ipv6_v3.patch
>>
>> While not all IPv6 features are working or tested, existing IPv4 features
>> should still work as before. However, to use any of the new features, you
>> will need a new ipvsadm with support for genetlink and IPv6:
>>
>>   http://sixpak.org/vince/google/ipvsadm/
>>   (by Vince Busam)
>>
>> To enable IPv6 support in IPVS, set CONFIG_IP_VS_IPV6=y.
>>
>> Short overview:
>>
>> What works with IPv6:
>> - forwarding mechanisms: NAT, DR, maybe Tunnel (not fully tested yet)
>> - protocols: TCP, UDP, ESP, AH (last two not tested)
>> - manipulation and inspection of both IPv4 and IPv6 entries with ipvsadm
>> - 6 out of 10 schedulers
>>
>> What is not supported with IPv6:
>> - handling fragmentation or other extension headers
>> - FTP application helper (can be loaded, but only operates on v4)
>> - sync daemon (can be started, but only operates on v4)
>> - probably some incorrect handling of ICMPv6 or other corner cases
>>
>> Since fragmentation and extension headers should not occur very often,
>> things should "mostly" work. I tested HTTP and DNS over NAT and DR
>> with various supported schedulers without encountering any problems.
>> But we didn't test any exotic situations. Also, there are some TODOs
>> in the code for things that haven't been tested or implemented yet.
>>
>> Thanks for any comments!
>
> Hi Julius, Hi Vince,
>
> I have applied all of these patches to the lvs-next-2.6 branch
> of the lvs-2.6 tree and I will ask Dave to pull these into
> net-next-2.6 shortly.

Great, many thanks!

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
