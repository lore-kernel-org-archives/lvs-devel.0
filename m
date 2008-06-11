From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Wed, 11 Jun 2008 21:31:50 +0200
Message-ID: <48502826.9060502@trash.net>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>	 <48500A0D.5020304@trash.net>	 <f4845fc0806111123r108348d3s6906bf2b7145bdea@mail.gmail.com>	 <48501C81.6010800@trash.net>	 <f4845fc0806111205j36c912d3vf1b632a3d0777a1c@mail.gmail.com>	 <4850233E.7090501@trash.net> <f4845fc0806111229l6666161fu9d3bc5e432668485@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <f4845fc0806111229l6666161fu9d3bc5e432668485@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julius Volz <juliusv@google.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org

Julius Volz wrote:
> On Wed, Jun 11, 2008 at 9:10 PM, Patrick McHardy <kaber@trash.net> wrote:
>   
>> Julius Volz wrote:
>>     
>>> ipvsadm uses get/set-sockopts on a raw socket to pass commands and
>>> structs (as defined in include/net/ip_vs.h) to the kernel. So the
>>> passed structs have to match exactly between userspace and kernel. The
>>> kernel ip_vs.h also includes a version number that is used to verify
>>> that ipvsadm matches your kernel version.
>>>       
>> So they define an ABI, which means they must not be changed in
>> incompabtible ways. The question is whether they are actually
>> changed in incomaptible ways.
>>     
>
> It is clearly laid out to be able to be changed over time, hence the
> ipvsadm version check... 

The usual way is to add new members at the end. The history shows no
changes at all to these structs though.

