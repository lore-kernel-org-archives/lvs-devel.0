From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 25/26] net: pass a sockptr_t into ->setsockopt
Date: Fri, 7 Aug 2020 11:29:19 -0700
Message-ID: <90f626a4-d9e5-91a5-b71d-498e3b125da1@gmail.com>
References: <20200723060908.50081-1-hch@lst.de>
 <20200723060908.50081-26-hch@lst.de>
 <6357942b-0b6e-1901-7dce-e308c9fac347@gmail.com>
 <f21589f1262640b09ca27ed20f8e6790@AcuMS.aculab.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <bridge-bounces@lists.linux-foundation.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=subject:to:cc:references:from:message-id:date:user-agent
 :mime-version:in-reply-to:content-language:content-transfer-encoding;
 bh=Z120/2fGgMoMEJFP3y/UN7XiDtbeEapazuzyhr8LDZE=;
 b=QBJVGJ0GG4JwOGjOXDhn/ptRbCpViFRSryd/D1uD/PPByb8ofXHghQtBL4zAWGT9Xe
 QK/cUuMjhxG0m1Hgc9zv3PWjG85dcSZ3U99MdqgrJZlSJ7yNitbrWEKj0pKrpQ5j4U2+
 mYi6rg0gFPqzK2WTohJzzlVFs9f88hQH3fpr0BAInmFjUAgk2jPvQt5YPhc+dRklJCLA
 1PiMOZ7kUlZdKKqrhoSbKIrPYqUmIDmxZL7Nhpp4CbVKZHsjBzyt1SbkbQp0snfBQJX6
 D0ebWljTdKFZBlaqVyAN81FA6P/pxFRTidd7EBz+FBfE/yEz78eEPIzn3SALlg9BIULK
 bJSQ==
In-Reply-To: <f21589f1262640b09ca27ed20f8e6790@AcuMS.aculab.com>
Content-Language: en-US
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>, 
 <mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
 <mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Errors-To: bridge-bounces@lists.linux-foundation.org
Sender: "Bridge" <bridge-bounces@lists.linux-foundation.org>
Content-Type: text/plain; charset="us-ascii"
To: David Laight <David.Laight@ACULAB.COM>, 'Eric Dumazet' <eric.dumazet@gmail.com>, Christoph Hellwig <hch@lst.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Eric Dumazet <edumazet@google.com>
Cc: "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>, "linux-afs@lists.infradead.org" <linux-afs@lists.infradead.org>, Stefan Schmidt <stefan@datenfreihafen.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "rds-devel@oss.oracle.com" <rds-devel@oss.oracle.com>, "linux-x25@vger.kernel.org" <linux-x25@vger.kernel.org>, "dccp@vger.kernel.org" <dccp@vger.kernel.org>, "bridge@lists.linux-foundation.org" <bridge@lists.linux-foundation.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "coreteam@netfilter.org" <coreteam@netfilter.org>, "mptcp@lists.01.org" <mptcp@lists.01.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>, "linux-hams@vger.kernel.org" <linux-hams@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, linux-decnet-user@lists.sourceforg



On 8/7/20 2:18 AM, David Laight wrote:
> From: Eric Dumazet
>> Sent: 06 August 2020 23:21
>>
>> On 7/22/20 11:09 PM, Christoph Hellwig wrote:
>>> Rework the remaining setsockopt code to pass a sockptr_t instead of a
>>> plain user pointer.  This removes the last remaining set_fs(KERNEL_DS)
>>> outside of architecture specific code.
>>>
>>> Signed-off-by: Christoph Hellwig <hch@lst.de>
>>> Acked-by: Stefan Schmidt <stefan@datenfreihafen.org> [ieee802154]
>>> ---
>>
>>
>> ...
>>
>>> diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
>>> index 594e01ad670aa6..874f01cd7aec42 100644
>>> --- a/net/ipv6/raw.c
>>> +++ b/net/ipv6/raw.c
>>> @@ -972,13 +972,13 @@ static int rawv6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
>>>  }
>>>
>>
>> ...
>>
>>>  static int do_rawv6_setsockopt(struct sock *sk, int level, int optname,
>>> -			    char __user *optval, unsigned int optlen)
>>> +			       sockptr_t optval, unsigned int optlen)
>>>  {
>>>  	struct raw6_sock *rp = raw6_sk(sk);
>>>  	int val;
>>>
>>> -	if (get_user(val, (int __user *)optval))
>>> +	if (copy_from_sockptr(&val, optval, sizeof(val)))
>>>  		return -EFAULT;
>>>
>>
>> converting get_user(...)   to  copy_from_sockptr(...) really assumed the optlen
>> has been validated to be >= sizeof(int) earlier.
>>
>> Which is not always the case, for example here.
>>
>> User application can fool us passing optlen=0, and a user pointer of exactly TASK_SIZE-1
> 
> Won't the user pointer force copy_from_sockptr() to call
> copy_from_user() which will then do access_ok() on the entire
> range and so return -EFAULT.
> 
> The only problems arise if the kernel code adds an offset to the
> user address.
> And the later patch added an offset to the copy functions.

I dunno, I definitely got the following syzbot crash 

No repro found by syzbot yet, but I suspect a 32bit binary program
did :

setsockopt(fd, 0x29, 0x24, 0xffffffffffffffff, 0x0)


BUG: KASAN: wild-memory-access in memcpy include/linux/string.h:406 [inline]
BUG: KASAN: wild-memory-access in copy_from_sockptr_offset include/linux/sockptr.h:71 [inline]
BUG: KASAN: wild-memory-access in copy_from_sockptr include/linux/sockptr.h:77 [inline]
BUG: KASAN: wild-memory-access in do_rawv6_setsockopt net/ipv6/raw.c:1023 [inline]
BUG: KASAN: wild-memory-access in rawv6_setsockopt+0x1a1/0x6f0 net/ipv6/raw.c:1084
Read of size 4 at addr 00000000ffffffff by task syz-executor.0/28251

CPU: 3 PID: 28251 Comm: syz-executor.0 Not tainted 5.8.0-syzkaller #0
Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS rel-1.12.0-59-gc9ba5276e321-prebuilt.qemu.org 04/01/2014
Call Trace:
 __dump_stack lib/dump_stack.c:77 [inline]
 dump_stack+0x18f/0x20d lib/dump_stack.c:118
 __kasan_report mm/kasan/report.c:517 [inline]
 kasan_report.cold+0x5/0x37 mm/kasan/report.c:530
 check_memory_region_inline mm/kasan/generic.c:186 [inline]
 check_memory_region+0x13d/0x180 mm/kasan/generic.c:192
 memcpy+0x20/0x60 mm/kasan/common.c:105
 memcpy include/linux/string.h:406 [inline]
 copy_from_sockptr_offset include/linux/sockptr.h:71 [inline]
 copy_from_sockptr include/linux/sockptr.h:77 [inline]
 do_rawv6_setsockopt net/ipv6/raw.c:1023 [inline]
 rawv6_setsockopt+0x1a1/0x6f0 net/ipv6/raw.c:1084
 __sys_setsockopt+0x2ad/0x6d0 net/socket.c:2138
 __do_sys_setsockopt net/socket.c:2149 [inline]
 __se_sys_setsockopt net/socket.c:2146 [inline]
 __ia32_sys_setsockopt+0xb9/0x150 net/socket.c:2146
 do_syscall_32_irqs_on arch/x86/entry/common.c:84 [inline]
 __do_fast_syscall_32+0x57/0x80 arch/x86/entry/common.c:126
 do_fast_syscall_32+0x2f/0x70 arch/x86/entry/common.c:149
 entry_SYSENTER_compat_after_hwframe+0x4d/0x5c
RIP: 0023:0xf7f22569
Code: c4 01 10 03 03 74 c0 01 10 05 03 74 b8 01 10 06 03 74 b4 01 10 07 03 74 b0 01 10 08 03 74 d8 01 00 51 52 55 89 e5 0f 34 cd 80 <5d> 5a 59 c3 90 90 90 90 eb 0d 90 90 90 90 90 90 90 90 90 90 90 90
RSP: 002b:00000000f551c0bc EFLAGS: 00000296 ORIG_RAX: 000000000000016e
RAX: ffffffffffffffda RBX: 0000000000000003 RCX: 0000000000000029
RDX: 0000000000000024 RSI: 00000000ffffffff RDI: 0000000000000000
RBP: 0000000000000000 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
==================================================================

