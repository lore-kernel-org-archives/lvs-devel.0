From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re[2]:  Multiple load balancers problem
Date: Mon, 27 Aug 2012 19:31:45 +0200 (CEST)
Message-ID: <thl3856.dd827b285dcdea1d2c6d8bf62a9a55f0@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Dmitry Akindinov <dimak@stalker.com>, lvs-devel@vger.kernel.org

>
>On Mon, 27 Aug 2012, Dmitry Akindinov wrote:
>
>> Hello,
>> 
>> Sorry for top posting: doing this to avoid clutter below.
>> 
>> Thank you for your assistance. Let me to summarize the current situation,
>> after all the changes and testing.
>> 
>> 1. The test system consists of two servers, S1 and S2. Both running CentOS
>> 6.0:
>> 
>>  [root@fm1 ~]# uname -a
>>  Linux fm1.***.com 2.6.32-71.el6.x86_64 #1 SMP Fri May 20 03:51:51 BST 2011
>>  x86_64 x86_64 x86_64 GNU/Linux
>> 
>> We are now setting up new boxes (CentOS 6.3) to re-test with newer kernels

Centos still have very old kernels 2.6.32-279.5.2 which only featute/bugfix compared to vanilla is sctp.
i.e. no bufixes after dec 3 2009....

>	The last bug fixes that can be needed for sync
>are from April 2012.
>
>	This is fixed by the mentioned change:
>"ipvs: changes for local real server"
>
>	Before this change the SYNC messages indicate
>LOCALNODE as forwarding method. So, S2 thinks that the
>conns for S1 stack are LOCALNODE, S2 deliver them locally
>and they are reset.
>

Regards
Hans Schillstrom

