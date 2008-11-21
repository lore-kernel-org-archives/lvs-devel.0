From: James Zheng <jameswork66@gmail.com>
Subject: Re: Unable to handle kernel paging request at virtual address f8c7a7e8
Date: Fri, 21 Nov 2008 09:33:26 +0800
Message-ID: <49260FE6.7080800@gmail.com>
References: <S1756639AbYKTOrH/20081120144708Z+1723@vger.kernel.org> <49257CE2.4050608@gmail.com> <49257EA0.4000905@gmail.com> <49260B77.7040203@gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:received:received:message-id:date:from
         :user-agent:mime-version:to:subject:references:in-reply-to
         :content-type:content-transfer-encoding;
        bh=OciLSTm3OAzWsgzMx66G202kzJYm43YoAT3oUrO49+o=;
        b=HlkEZtcoKaav6x3vOvBvrs+PuBGkYlUcDGop40UsFL3SgBsOacx+HLizJkI4fzhNEz
         p+OIuH0p1jQiJUEYIMq3JDzU61xPBeTkDkZ871DM/jEbZ1JFIq985WG0t4hjorm56plP
         AM4VZ7XgcU9hPyQ7MF+85RoBC1yvlvkgocmxc=
In-Reply-To: <49260B77.7040203@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"; format="flowed"
To: lvs-devel@vger.kernel.org

I got the error in "/var/log/message" after I installed the ipvsadmin=20
under the Centos 4.7,  and the server is down.


Do you know  how to fix the bug?


Many thanks.


Kernel=EF=BC=9A2.6.9-78.0.5.ELsmp

Ipvadmin: 1.24-6


This is LOG:

Nov 20 22:24:50 cd03 iptables: succeeded
Nov 20 22:24:50 cd03 iptables: succeeded
Nov 20 22:24:52 cd03 kernel: Unable to handle kernel paging request at=20
virtual address f8c7a7e8
Nov 20 22:24:52 cd03 kernel: printing eip:
Nov 20 22:24:52 cd03 kernel: c0294afa
Nov 20 22:24:52 cd03 kernel: *pde =3D f5e93558
Nov 20 22:24:52 cd03 kernel: Oops: 0000 [#1]
Nov 20 22:24:52 cd03 kernel: SMP
Nov 20 22:24:52 cd03 kernel: Modules linked in: ip_vs_rr ip_vs ip_table=
s=20
parport_pc lp parport autofs4 i2c_dev i2c_core sunrpc md5 ipv6=20
cpufreq_powersave loo
p button battery ac ohci_hcd tg3 floppy sg dm_snapshot dm_zero dm_mirro=
r=20
ext3 jbd dm_mod mptscsih mptsas mptspi mptscsi mptbase sd_mod scsi_mod
Nov 20 22:24:52 cd03 kernel: CPU: 3
Nov 20 22:24:52 cd03 kernel: EIP: 0060:[] Not tainted VLI
Nov 20 22:24:52 cd03 kernel: EFLAGS: 00010212 (2.6.9-78.0.5.ELsmp)
Nov 20 22:24:52 cd03 kernel: EIP is at nf_unregister_sockopt+0x48/0x83
Nov 20 22:24:52 cd03 kernel: eax: 00000002 ebx: c035e784 ecx: f6c2a540=20
edx: f8c7a7e0
Nov 20 22:24:52 cd03 kernel: esi: f89355e0 edi: 00000000 ebp: f6382000=20
esp: f6382f5c
Nov 20 22:24:52 cd03 kernel: ds: 007b es: 007b ss: 0068
Nov 20 22:24:52 cd03 kernel: Process modprobe (pid: 18385,=20
threadinfo=3Df6382000 task=3De4e413b0)
Nov 20 22:24:52 cd03 kernel: Stack: 00000000 c0337ba8 f8933865 f8935700=
=20
c01373ce 00000000 745f7069 656c6261
Nov 20 22:24:52 cd03 kernel: f5250073 c0151ec2 f525c6c4 d53bfa6c=20
c01521f2 b7fad000 b7fae000 b7fae000
Nov 20 22:24:52 cd03 kernel: b7fae000 d27bc4ec f525c680 f525c6b0=20
00000000 f6382000 082ac828 00000000
Nov 20 22:24:52 cd03 kernel: Call Trace:
Nov 20 22:24:52 cd03 kernel: [] fini+0xd/0x35 [ip_tables]
Nov 20 22:24:52 cd03 kernel: [] sys_delete_module+0x13b/0x184
Nov 20 22:24:52 cd03 kernel: [] unmap_vma_list+0xe/0x17
Nov 20 22:24:52 cd03 kernel: [] do_munmap+0x108/0x116
Nov 20 22:24:52 cd03 kernel: [] syscall_call+0x7/0xb
Nov 20 22:24:52 cd03 kernel: Code: 04 00 89 d9 f0 ff 0d 84 e7 35 c0 0f=20
88 93 0c 00 00 8b 0d 9c e7 35 c0 8b 01 0f 18 00 90 81 f9 9c e7 35 c0 74=
=20
2f 8b 51 08 8b
46 08 42 08 8b 11 75 1e 8b 41 04 89 42 04 89 10 89 c8 c7 01 00 01
Nov 20 22:24:52 cd03 kernel: Fatal exception: panic in 5 seconds

CPU: Intel(R) Xeon(TM) CPU 2.80GHz *2
Mem=EF=BC=9A 4G

Thanks.
