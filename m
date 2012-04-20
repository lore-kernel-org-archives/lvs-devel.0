From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re[2]:  kernel oops - do_ip_vs_get_ctl
Date: Fri, 20 Apr 2012 13:21:38 +0200 (CEST)
Message-ID: <856i5i0.e5408dddd2df5f816664bc9bb1e6ab60@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Ryan O'Hara <rohara@redhat.com>, lvs-devel@vger.kernel.org

Hello Julian
>
>Hello,
>
>On Fri, 20 Apr 2012, Ryan O'Hara wrote:
>
>> 
>> I frequently get a kernel oops in do_ip_vs_get_ctl when starting keepalived on
>> a 3.3.0 kernel. I'm attaching the trace from /var/log/messages. Has anyone
>> encountered this problem and if so is there a patch available? Much
>> appreciated.
>
>	Is it happening while ip_vs module is loading?
>nf_register_sockopt is one of the first thing that is
>initialized, may be the GET operation accesses something
>from net->ipvs that is not initialized yet. As I can not
>see properly the exact place from the oops, I'll try to
>analyze do_ip_vs_get_ctl for such problem. May be other
>folks will be faster in tracking the right command and
>position in the source code.
>

It's a NULL ptr in  ipvs->num_services; at line 2649

2644            case IP_VS_SO_GET_INFO:
2645            {
2646                    struct ip_vs_getinfo info;
2647                    info.version = IP_VS_VERSION_CODE;
   0x00000000000086a9 <+1481>:  movl   $0x10201,-0x180(%rbp)

2648                    info.size = ip_vs_conn_tab_size;
   0x00000000000086a3 <+1475>:  mov    0x0(%rip),%eax        # 0x86a9 <do_ip_vs_get_ctl+1481>
   0x00000000000086b3 <+1491>:  mov    %eax,-0x17c(%rbp)

2649                    info.num_services = ipvs->num_services;
   0x00000000000086b9 <+1497>:  mov    0x5f8(%r12),%eax
   0x00000000000086c1 <+1505>:  mov    %eax,-0x178(%rbp)
   0x00000000000086c7 <+1511>:  jmpq   0x835d <do_ip_vs_get_ctl+637>

2650                    if (copy_to_user(user, &info, sizeof(info)) != 0)
2651                            ret = -EFAULT;
2652            }
2653            break;
2654
2655            case IP_VS_SO_GET_SERVICES:


>	May be we have to split ip_vs_control_init to
>two parts so that sockopts are the last thing to register
>on init.

I think that is a good idea i.e. add it after nf_register_hooks()

Do you prepare a patch or should I do it  ?

>
>Regards
>
>--
>Julian Anastasov <ja@ssi.bg>
>--

Regards 
Hans Schillstrom
+46 70 699 7150


