From: Nick Moriarty <nick.moriarty@york.ac.uk>
Subject: PROBLEM: IPVS incorrectly reverse-NATs traffic to LVS host
Date: Wed, 12 Apr 2017 15:28:02 +0100
Message-ID: <CAEo=OUnG+Bn04XaEkwHpL2bt6bEZXP_F6RSa9HDN=VjXdOxpoQ@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=york.ac.uk; s=20160523.google;
        h=mime-version:from:date:message-id:subject:to:cc;
        bh=1Qw42UiwsSmTQzUGlS1+yDd2cDOfRlG5LSmVf3vQNZs=;
        b=RVhR/g1iuovGofrgwgA8JklwNgFqxzBdI7e4an2O02642i87xOzy4MZhKm8voMB8gD
         nnGms/Niig4uPvrCLgyxeboRpHFJLo2VUGcl8eyMzgxtfwbq6DNb7jDnc9HOPm5dFCmK
         sBLYgTdjCiG2lFuQRqnRSM6yY4+9woQY8M89/RnGNpAVeUnamDkg4LYZ0uUUZ/sQ7MDi
         MaL0H8BouAz3pUK468gG0ewsmiJFZJG2ncwjq8qitLuldKcXwUHFkwyAnphmO1eKdjUa
         22TvwH7OVwte/aHR/+X+uI5g7r+Ncuv4h+ykOShMeo66+IiLoE0TeCapSkUHNMg/VaWU
         y89A==
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org

Hi,

I've experienced a problem in how traffic returning to an LVS host is
handled in certain circumstances.  Please find a bug report below - if
there's any further information you'd like, please let me know.

[1.] One line summary of the problem:
IPVS incorrectly reverse-NATs traffic to LVS host

[2.] Full description of the problem/report:
When using IPVS in direct-routing mode, normal traffic from the LVS
host to a back-end server is sometimes incorrectly NATed on the way
back into the LVS host.  Using tcpdump shows that the return packets
have the correct source IP, but by the time it makes it back to the
application, it's been changed.

To reproduce this, a configuration such as the following will work:
- Set up an LVS system with a VIP serving UDP to a backend DNS server
using the direct-routing method in IPVS
- Make an outgoing UDP request to the VIP from the LVS system itself
(this causes a connection to be added to the IPVS connection table)
- The request should succeed as normal
- Note the UDP source port used
- Within 5 minutes (before the UDP connection entry expires), make an
outgoing UDP request directly to the backend DNS server
- The request will fail as the reply is incorrectly modified on its
way back and appears to return from the VIP

Monitoring the above sequence with tcpdump verifies that the returned
packet (as it enters the host) is from the DNS IP, even though the
application sees the VIP.

If an outgoing request direct to the DNS server is made from a port
not in the connection table, everything is fine.

[3.] Keywords (i.e., modules, networking, kernel):

[4.] Kernel version (from /proc/version):
Linux version 4.11.0-041100rc6-generic (kernel@gloin) (gcc version
6.2.0 20161005 (Ubuntu 6.2.0-5ubuntu12) ) #201704091331 SMP Sun Apr 9
17:32:54 UTC 2017

(Note that another system seeing this problem is running the following version)
Linux version 3.13.0-100-generic (buildd@lgw01-52) (gcc version 4.8.4
(Ubuntu 4.8.4-2ubuntu1~14.04.3) ) #147-Ubuntu SMP Tue Oct 18 16:48:51
UTC 2016

[5.] Output of Oops.. message (if applicable) with symbolic information
     resolved (see Documentation/oops-tracing.txt)
N/A

[6.] A small shell script or example program which triggers the
     problem (if possible)

[7.] Environment
Description:    Ubuntu 14.04.5 LTS
Release:    14.04

[7.1.] Software (add the output of the ver_linux script here)
If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.

Linux lvs5 4.11.0-041100rc6-generic #201704091331 SMP Sun Apr 9
17:32:54 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux

GNU C                   4.8
GNU Make                3.81
Binutils                2.24
Util-linux              2.20.1
Mount                   2.20.1
Module-init-tools       15
E2fsprogs               1.42.9
Nfs-utils               1.2.8
Linux C Library         2.19
Dynamic linker (ldd)    2.19
Linux C++ Library       6.0.19
Procps                  3.3.9
Net-tools               1.60
Kbd                     1.15.5
Console-tools           1.15.5
Sh-utils                8.21
Udev                    204
Modules Loaded          acpi_pad acpi_power_meter aesni_intel
aes_x86_64 ahci auth_rpcgss autofs4 be2net coretemp crc32_pclmul
crct10dif_pclmul cryptd crypto_simd dcdbas edac_core fscache
ghash_clmulni_intel glue_helper grace hid hid_generic input_leds
intel_cstate intel_powerclamp intel_rapl intel_rapl_perf
ipmi_msghandler ipmi_si ipmi_ssif ip_vs ip_vs_rr ip_vs_wlc irqbypass
joydev kvm kvm_intel libahci libcrc32c lockd lp lpc_ich mac_hid
megaraid_sas mei mei_me nf_conntrack nfs nfs_acl nfsd nfsv3 parport
pcbc pps_core ptp rpcsec_gss_krb5 sb_edac shpchp sunrpc tg3 usbhid wmi
x86_pkg_temp_thermal

[7.2.] Processor information (from /proc/cpuinfo):
processor    : 0
vendor_id    : GenuineIntel
cpu family    : 6
model        : 62
model name    : Intel(R) Xeon(R) CPU E5-2407 v2 @ 2.40GHz
stepping    : 4
microcode    : 0x428
cpu MHz        : 1204.394
cache size    : 10240 KB
physical id    : 0
siblings    : 4
core id        : 0
cpu cores    : 4
apicid        : 0
initial apicid    : 0
fpu        : yes
fpu_exception    : yes
cpuid level    : 13
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe
syscall nx pdpe1gb rdtscp lm constant_tsc arch_perfmon pebs bts
rep_good nopl xtopology nonstop_tsc cpuid aperfmperf pni pclmulqdq
dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm pcid dca
sse4_1 sse4_2 x2apic popcnt tsc_deadline_timer aes xsave avx f16c
rdrand lahf_lm tpr_shadow vnmi flexpriority ept vpid fsgsbase smep
erms xsaveopt dtherm arat pln pts
bugs        :
bogomips    : 4799.69
clflush size    : 64
cache_alignment    : 64
address sizes    : 46 bits physical, 48 bits virtual
power management:

processor    : 1
vendor_id    : GenuineIntel
cpu family    : 6
model        : 62
model name    : Intel(R) Xeon(R) CPU E5-2407 v2 @ 2.40GHz
stepping    : 4
microcode    : 0x428
cpu MHz        : 1240.283
cache size    : 10240 KB
physical id    : 0
siblings    : 4
core id        : 1
cpu cores    : 4
apicid        : 2
initial apicid    : 2
fpu        : yes
fpu_exception    : yes
cpuid level    : 13
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe
syscall nx pdpe1gb rdtscp lm constant_tsc arch_perfmon pebs bts
rep_good nopl xtopology nonstop_tsc cpuid aperfmperf pni pclmulqdq
dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm pcid dca
sse4_1 sse4_2 x2apic popcnt tsc_deadline_timer aes xsave avx f16c
rdrand lahf_lm tpr_shadow vnmi flexpriority ept vpid fsgsbase smep
erms xsaveopt dtherm arat pln pts
bugs        :
bogomips    : 4800.75
clflush size    : 64
cache_alignment    : 64
address sizes    : 46 bits physical, 48 bits virtual
power management:

processor    : 2
vendor_id    : GenuineIntel
cpu family    : 6
model        : 62
model name    : Intel(R) Xeon(R) CPU E5-2407 v2 @ 2.40GHz
stepping    : 4
microcode    : 0x428
cpu MHz        : 1200.000
cache size    : 10240 KB
physical id    : 0
siblings    : 4
core id        : 2
cpu cores    : 4
apicid        : 4
initial apicid    : 4
fpu        : yes
fpu_exception    : yes
cpuid level    : 13
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe
syscall nx pdpe1gb rdtscp lm constant_tsc arch_perfmon pebs bts
rep_good nopl xtopology nonstop_tsc cpuid aperfmperf pni pclmulqdq
dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm pcid dca
sse4_1 sse4_2 x2apic popcnt tsc_deadline_timer aes xsave avx f16c
rdrand lahf_lm tpr_shadow vnmi flexpriority ept vpid fsgsbase smep
erms xsaveopt dtherm arat pln pts
bugs        :
bogomips    : 4800.71
clflush size    : 64
cache_alignment    : 64
address sizes    : 46 bits physical, 48 bits virtual
power management:

processor    : 3
vendor_id    : GenuineIntel
cpu family    : 6
model        : 62
model name    : Intel(R) Xeon(R) CPU E5-2407 v2 @ 2.40GHz
stepping    : 4
microcode    : 0x428
cpu MHz        : 1200.000
cache size    : 10240 KB
physical id    : 0
siblings    : 4
core id        : 3
cpu cores    : 4
apicid        : 6
initial apicid    : 6
fpu        : yes
fpu_exception    : yes
cpuid level    : 13
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe
syscall nx pdpe1gb rdtscp lm constant_tsc arch_perfmon pebs bts
rep_good nopl xtopology nonstop_tsc cpuid aperfmperf pni pclmulqdq
dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm pcid dca
sse4_1 sse4_2 x2apic popcnt tsc_deadline_timer aes xsave avx f16c
rdrand lahf_lm tpr_shadow vnmi flexpriority ept vpid fsgsbase smep
erms xsaveopt dtherm arat pln pts
bugs        :
bogomips    : 4800.71
clflush size    : 64
cache_alignment    : 64
address sizes    : 46 bits physical, 48 bits virtual
power management:

[7.3.] Module information (from /proc/modules):
nfsv3 40960 1 - Live 0x0000000000000000
ip_vs_rr 16384 4 - Live 0x0000000000000000
ip_vs_wlc 16384 6 - Live 0x0000000000000000
ip_vs 151552 16 ip_vs_rr,ip_vs_wlc, Live 0x0000000000000000
nf_conntrack 126976 1 ip_vs, Live 0x0000000000000000
libcrc32c 16384 2 ip_vs,nf_conntrack, Live 0x0000000000000000
autofs4 40960 354 - Live 0x0000000000000000
rpcsec_gss_krb5 36864 3 - Live 0x0000000000000000
nfsd 339968 2 - Live 0x0000000000000000
auth_rpcgss 61440 3 rpcsec_gss_krb5,nfsd, Live 0x0000000000000000
nfs_acl 16384 2 nfsv3,nfsd, Live 0x0000000000000000
nfs 249856 2 nfsv3, Live 0x0000000000000000
lockd 90112 3 nfsv3,nfsd,nfs, Live 0x0000000000000000
grace 16384 2 nfsd,lockd, Live 0x0000000000000000
sunrpc 335872 22
nfsv3,rpcsec_gss_krb5,nfsd,auth_rpcgss,nfs_acl,nfs,lockd, Live
0x0000000000000000
fscache 61440 1 nfs, Live 0x0000000000000000
intel_rapl 20480 0 - Live 0x0000000000000000
sb_edac 24576 0 - Live 0x0000000000000000
edac_core 53248 1 sb_edac, Live 0x0000000000000000
x86_pkg_temp_thermal 16384 0 - Live 0x0000000000000000
intel_powerclamp 16384 0 - Live 0x0000000000000000
coretemp 16384 0 - Live 0x0000000000000000
kvm_intel 200704 0 - Live 0x0000000000000000
kvm 593920 1 kvm_intel, Live 0x0000000000000000
ipmi_ssif 24576 0 - Live 0x0000000000000000
irqbypass 16384 1 kvm, Live 0x0000000000000000
crct10dif_pclmul 16384 0 - Live 0x0000000000000000
crc32_pclmul 16384 0 - Live 0x0000000000000000
ghash_clmulni_intel 16384 0 - Live 0x0000000000000000
pcbc 16384 0 - Live 0x0000000000000000
aesni_intel 163840 8 - Live 0x0000000000000000
aes_x86_64 20480 1 aesni_intel, Live 0x0000000000000000
crypto_simd 16384 1 aesni_intel, Live 0x0000000000000000
glue_helper 16384 1 aesni_intel, Live 0x0000000000000000
dcdbas 16384 0 - Live 0x0000000000000000
cryptd 24576 3 ghash_clmulni_intel,aesni_intel,crypto_simd, Live
0x0000000000000000
mei_me 40960 0 - Live 0x0000000000000000
intel_cstate 20480 0 - Live 0x0000000000000000
mei 102400 1 mei_me, Live 0x0000000000000000
intel_rapl_perf 16384 0 - Live 0x0000000000000000
joydev 20480 0 - Live 0x0000000000000000
input_leds 16384 0 - Live 0x0000000000000000
mac_hid 16384 0 - Live 0x0000000000000000
ipmi_si 57344 0 - Live 0x0000000000000000
acpi_pad 180224 0 - Live 0x0000000000000000
lpc_ich 24576 0 - Live 0x0000000000000000
ipmi_msghandler 45056 2 ipmi_ssif,ipmi_si, Live 0x0000000000000000
wmi 16384 0 - Live 0x0000000000000000
acpi_power_meter 20480 0 - Live 0x0000000000000000
shpchp 36864 0 - Live 0x0000000000000000
lp 20480 0 - Live 0x0000000000000000
parport 49152 1 lp, Live 0x0000000000000000
hid_generic 16384 0 - Live 0x0000000000000000
usbhid 49152 0 - Live 0x0000000000000000
hid 114688 2 hid_generic,usbhid, Live 0x0000000000000000
ahci 36864 0 - Live 0x0000000000000000
tg3 163840 0 - Live 0x0000000000000000
libahci 32768 1 ahci, Live 0x0000000000000000
ptp 20480 1 tg3, Live 0x0000000000000000
pps_core 20480 1 ptp, Live 0x0000000000000000
be2net 131072 0 - Live 0x0000000000000000
megaraid_sas 143360 2 - Live 0x0000000000000000

[7.4.] Loaded driver and hardware information (/proc/ioports, /proc/iomem)
0000-0000 : PCI Bus 0000:00
  0000-0000 : dma1
  0000-0000 : pic1
  0000-0000 : timer0
  0000-0000 : timer1
  0000-0000 : keyboard
  0000-0000 : keyboard
  0000-0000 : rtc0
  0000-0000 : dma page reg
  0000-0000 : pic2
  0000-0000 : APEI ERST
  0000-0000 : dma2
  0000-0000 : PNP0C04:00
    0000-0000 : fpu
  0000-0000 : serial
  0000-0000 : pnp 00:04
0000-0000 : PCI Bus 0000:00
  0000-0000 : vesafb
0000-0000 : PCI Bus 0000:00
  0000-0000 : serial
  0000-0000 : pnp 00:04
    0000-0000 : ACPI PM1a_EVT_BLK
    0000-0000 : ACPI PM1a_CNT_BLK
    0000-0000 : ACPI PM_TMR
    0000-0000 : ACPI GPE0_BLK
    0000-0000 : iTCO_wdt.0.auto
    0000-0000 : ACPI PM2_CNT_BLK
    0000-0000 : iTCO_wdt.0.auto
  0000-0000 : pnp 00:04
  0000-0000 : pnp 00:04
  0000-0000 : pnp 00:04
  0000-0000 : pnp 00:04
  0000-0000 : pnp 00:04
  0000-0000 : pnp 00:05
    0000-0000 : ipmi_si
  0000-0000 : pnp 00:04
  0000-0000 : pnp 00:05
    0000-0000 : ipmi_si
  0000-0000 : pnp 00:04
  0000-0000 : pnp 00:04
0000-0000 : PCI conf1
0000-0000 : PCI Bus 0000:00
0000-0000 : PCI Bus 0000:00
  0000-0000 : 0000:00:1f.2
    0000-0000 : ahci
  0000-0000 : 0000:00:1f.2
    0000-0000 : ahci
  0000-0000 : 0000:00:1f.2
    0000-0000 : ahci
  0000-0000 : 0000:00:1f.2
    0000-0000 : ahci
  0000-0000 : 0000:00:1f.2
    0000-0000 : ahci
  0000-0000 : PCI Bus 0000:01
    0000-0000 : 0000:01:00.0

00000000-00000000 : reserved
00000000-00000000 : System RAM
00000000-00000000 : RAM buffer
00000000-00000000 : PCI Bus 0000:00
00000000-00000000 : Video ROM
00000000-00000000 : Adapter ROM
00000000-00000000 : Adapter ROM
00000000-00000000 : Adapter ROM
00000000-00000000 : Adapter ROM
00000000-00000000 : System ROM
00000000-00000000 : System RAM
00000000-00000000 : reserved
  00000000-00000000 : APEI ERST
  00000000-00000000 : APEI ERST
  00000000-00000000 : APEI ERST
  00000000-00000000 : APEI ERST
00000000-00000000 : ACPI Tables
00000000-00000000 : reserved
00000000-00000000 : PCI Bus 0000:00
  00000000-00000000 : PCI Bus 0000:03
    00000000-00000000 : PCI Bus 0000:04
      00000000-00000000 : PCI Bus 0000:05
        00000000-00000000 : PCI Bus 0000:06
          00000000-00000000 : 0000:06:00.0
          00000000-00000000 : vesafb
  00000000-00000000 : PCI Bus 0000:08
    00000000-00000000 : 0000:08:00.0
      00000000-00000000 : be2net
    00000000-00000000 : 0000:08:00.0
      00000000-00000000 : be2net
    00000000-00000000 : 0000:08:00.1
      00000000-00000000 : be2net
    00000000-00000000 : 0000:08:00.1
      00000000-00000000 : be2net
    00000000-00000000 : 0000:08:00.0
      00000000-00000000 : be2net
    00000000-00000000 : 0000:08:00.1
      00000000-00000000 : be2net
  00000000-00000000 : PCI Bus 0000:02
    00000000-00000000 : 0000:02:00.0
      00000000-00000000 : tg3
    00000000-00000000 : 0000:02:00.0
      00000000-00000000 : tg3
    00000000-00000000 : 0000:02:00.0
      00000000-00000000 : tg3
    00000000-00000000 : 0000:02:00.1
      00000000-00000000 : tg3
    00000000-00000000 : 0000:02:00.1
      00000000-00000000 : tg3
    00000000-00000000 : 0000:02:00.1
      00000000-00000000 : tg3
  00000000-00000000 : PCI Bus 0000:01
    00000000-00000000 : 0000:01:00.0
    00000000-00000000 : 0000:01:00.0
    00000000-00000000 : 0000:01:00.0
      00000000-00000000 : megasas: LSI
  00000000-00000000 : PCI Bus 0000:08
    00000000-00000000 : 0000:08:00.0
    00000000-00000000 : 0000:08:00.1
  00000000-00000000 : PCI Bus 0000:02
    00000000-00000000 : 0000:02:00.0
    00000000-00000000 : 0000:02:00.1
  00000000-00000000 : PCI Bus 0000:03
    00000000-00000000 : PCI Bus 0000:04
      00000000-00000000 : PCI Bus 0000:05
        00000000-00000000 : PCI Bus 0000:06
          00000000-00000000 : 0000:06:00.0
          00000000-00000000 : 0000:06:00.0
      00000000-00000000 : PCI Bus 0000:07
  00000000-00000000 : 0000:00:16.0
  00000000-00000000 : 0000:00:16.1
  00000000-00000000 : 0000:00:1a.0
    00000000-00000000 : ehci_hcd
  00000000-00000000 : 0000:00:1d.0
    00000000-00000000 : ehci_hcd
  00000000-00000000 : 0000:00:1f.2
    00000000-00000000 : ahci
  00000000-00000000 : dmar0
  00000000-00000000 : PCI MMCONFIG 0000 [bus 00-ff]
    00000000-00000000 : reserved
      00000000-00000000 : pnp 00:06
      00000000-00000000 : pnp 00:07
00000000-00000000 : reserved
  00000000-00000000 : IOAPIC 0
  00000000-00000000 : IOAPIC 1
  00000000-00000000 : HPET 0
    00000000-00000000 : PNP0103:00
  00000000-00000000 : PCI Bus 0000:00
  00000000-00000000 : iTCO_wdt.0.auto
  00000000-00000000 : Local APIC
00000000-00000000 : System RAM
  00000000-00000000 : Kernel code
  00000000-00000000 : Kernel data
  00000000-00000000 : Kernel bss

[7.5.] PCI information ('lspci -vvv' as root)
00:00.0 Host bridge: Intel Corporation Xeon E7 v2/Xeon E5 v2/Core i7
DMI2 (rev 04)
    Subsystem: Dell Device 04f7
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Interrupt: pin A routed to IRQ 0
    Capabilities: <access denied>

00:01.0 PCI bridge: Intel Corporation Xeon E7 v2/Xeon E5 v2/Core i7
PCI Express Root Port 1a (rev 04) (prog-if 00 [Normal decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B- DisINTx+
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
    I/O behind bridge: 0000f000-0000ffff
    Memory behind bridge: dc000000-dcffffff
    Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
    Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- <SERR- <PERR-
    BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
    Capabilities: <access denied>
    Kernel driver in use: pcieport

00:03.0 PCI bridge: Intel Corporation Xeon E7 v2/Xeon E5 v2/Core i7
PCI Express Root Port 3a (rev 04) (prog-if 00 [Normal decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B- DisINTx+
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Bus: primary=00, secondary=08, subordinate=08, sec-latency=0
    I/O behind bridge: 0000f000-00000fff
    Memory behind bridge: dd000000-dd7fffff
    Prefetchable memory behind bridge: 00000000d9000000-00000000d90fffff
    Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ <SERR- <PERR-
    BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
    Capabilities: <access denied>
    Kernel driver in use: pcieport

00:05.0 System peripheral: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 VTd/Memory Map/Misc (rev 04)
    Subsystem: Dell Device 04f7
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Capabilities: <access denied>

00:05.2 System peripheral: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 IIO RAS (rev 04)
    Subsystem: Dell Device 04f7
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Capabilities: <access denied>

00:11.0 PCI bridge: Intel Corporation C600/X79 series chipset PCI
Express Virtual Root Port (rev 05) (prog-if 00 [Normal decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx+
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Bus: primary=00, secondary=09, subordinate=09, sec-latency=0
    I/O behind bridge: 0000f000-00000fff
    Memory behind bridge: fff00000-000fffff
    Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
    Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ <SERR- <PERR-
    BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
    Capabilities: <access denied>
    Kernel driver in use: pcieport

00:16.0 Communication controller: Intel Corporation C600/X79 series
chipset MEI Controller #1 (rev 05)
    Subsystem: Dell Device 04f7
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx+
    Latency: 0
    Region 0: Memory at df8fb000 (64-bit, non-prefetchable) [size=16]
    Capabilities: <access denied>

00:16.1 Communication controller: Intel Corporation C600/X79 series
chipset MEI Controller #2 (rev 05)
    Subsystem: Dell Device 04f7
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Region 0: Memory at df8fc000 (64-bit, non-prefetchable) [size=16]
    Capabilities: <access denied>

00:1a.0 USB controller: Intel Corporation C600/X79 series chipset USB2
Enhanced Host Controller #2 (rev 05) (prog-if 20 [EHCI])
    Subsystem: Dell Device 04f7
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Interrupt: pin A routed to IRQ 23
    Region 0: Memory at df8fd000 (32-bit, non-prefetchable) [size=1K]
    Capabilities: <access denied>
    Kernel driver in use: ehci-pci

00:1c.0 PCI bridge: Intel Corporation C600/X79 series chipset PCI
Express Root Port 1 (rev b5) (prog-if 00 [Normal decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B- DisINTx+
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Bus: primary=00, secondary=0a, subordinate=0a, sec-latency=0
    I/O behind bridge: 0000f000-00000fff
    Memory behind bridge: fff00000-000fffff
    Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
    Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ <SERR- <PERR-
    BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
    Capabilities: <access denied>
    Kernel driver in use: pcieport

00:1c.4 PCI bridge: Intel Corporation C600/X79 series chipset PCI
Express Root Port 5 (rev b5) (prog-if 00 [Normal decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B- DisINTx+
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
    I/O behind bridge: 0000f000-00000fff
    Memory behind bridge: dd800000-ddffffff
    Prefetchable memory behind bridge: 00000000d9100000-00000000d91fffff
    Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ <SERR- <PERR-
    BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
    Capabilities: <access denied>
    Kernel driver in use: pcieport

00:1c.7 PCI bridge: Intel Corporation C600/X79 series chipset PCI
Express Root Port 8 (rev b5) (prog-if 00 [Normal decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B- DisINTx+
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Bus: primary=00, secondary=03, subordinate=07, sec-latency=0
    I/O behind bridge: 0000f000-00000fff
    Memory behind bridge: de000000-df7fffff
    Prefetchable memory behind bridge: 00000000d8000000-00000000d8ffffff
    Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ <SERR- <PERR-
    BridgeCtl: Parity+ SERR+ NoISA- VGA+ MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
    Capabilities: <access denied>
    Kernel driver in use: pcieport

00:1d.0 USB controller: Intel Corporation C600/X79 series chipset USB2
Enhanced Host Controller #1 (rev 05) (prog-if 20 [EHCI])
    Subsystem: Dell Device 04f7
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Interrupt: pin A routed to IRQ 22
    Region 0: Memory at df8fe000 (32-bit, non-prefetchable) [size=1K]
    Capabilities: <access denied>
    Kernel driver in use: ehci-pci

00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev a5)
(prog-if 01 [Subtractive decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Bus: primary=00, secondary=0b, subordinate=0b, sec-latency=32
    I/O behind bridge: 0000f000-00000fff
    Memory behind bridge: fff00000-000fffff
    Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
    Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort+ <SERR- <PERR-
    BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
    Capabilities: <access denied>

00:1f.0 ISA bridge: Intel Corporation C600/X79 series chipset LPC
Controller (rev 05)
    Subsystem: Dell Device 04f7
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Capabilities: <access denied>
    Kernel driver in use: lpc_ich

00:1f.2 SATA controller: Intel Corporation C600/X79 series chipset
6-Port SATA AHCI Controller (rev 05) (prog-if 01 [AHCI 1.0])
    Subsystem: Dell Device 04f7
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR- FastB2B- DisINTx+
    Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Interrupt: pin A routed to IRQ 34
    Region 0: I/O ports at ece8 [size=8]
    Region 1: I/O ports at ecf8 [size=4]
    Region 2: I/O ports at ecf0 [size=8]
    Region 3: I/O ports at ecfc [size=4]
    Region 4: I/O ports at ecc0 [size=32]
    Region 5: Memory at df8ff000 (32-bit, non-prefetchable) [size=2K]
    Capabilities: <access denied>
    Kernel driver in use: ahci

01:00.0 RAID bus controller: LSI Logic / Symbios Logic MegaRAID SAS
2008 [Falcon] (rev 03)
    Subsystem: Dell PERC H310 Mini Monolithics
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx+
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Interrupt: pin A routed to IRQ 31
    Region 0: I/O ports at fc00 [size=256]
    Region 1: Memory at dcffc000 (64-bit, non-prefetchable) [size=16K]
    Region 3: Memory at dcf80000 (64-bit, non-prefetchable) [size=256K]
    Expansion ROM at dc000000 [disabled] [size=128K]
    Capabilities: <access denied>
    Kernel driver in use: megaraid_sas

02:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5720
Gigabit Ethernet PCIe
    Subsystem: Dell Device 04f7
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx+
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Interrupt: pin A routed to IRQ 16
    Region 0: Memory at d91a0000 (64-bit, prefetchable) [size=64K]
    Region 2: Memory at d91b0000 (64-bit, prefetchable) [size=64K]
    Region 4: Memory at d91c0000 (64-bit, prefetchable) [size=64K]
    Expansion ROM at dd800000 [disabled] [size=256K]
    Capabilities: <access denied>
    Kernel driver in use: tg3

02:00.1 Ethernet controller: Broadcom Corporation NetXtreme BCM5720
Gigabit Ethernet PCIe
    Subsystem: Dell Device 04f7
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx+
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Interrupt: pin B routed to IRQ 17
    Region 0: Memory at d91d0000 (64-bit, prefetchable) [size=64K]
    Region 2: Memory at d91e0000 (64-bit, prefetchable) [size=64K]
    Region 4: Memory at d91f0000 (64-bit, prefetchable) [size=64K]
    Expansion ROM at dd840000 [disabled] [size=256K]
    Capabilities: <access denied>
    Kernel driver in use: tg3

03:00.0 PCI bridge: Renesas Technology Corp. SH7757 PCIe Switch [PS]
(prog-if 00 [Normal decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    BIST result: 00
    Bus: primary=03, secondary=04, subordinate=07, sec-latency=0
    I/O behind bridge: 0000f000-00000fff
    Memory behind bridge: de000000-df7fffff
    Prefetchable memory behind bridge: 00000000d8000000-00000000d8ffffff
    Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- <SERR- <PERR-
    BridgeCtl: Parity+ SERR+ NoISA- VGA+ MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
    Capabilities: <access denied>
    Kernel driver in use: pcieport

04:00.0 PCI bridge: Renesas Technology Corp. SH7757 PCIe Switch [PS]
(prog-if 00 [Normal decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    BIST result: 00
    Bus: primary=04, secondary=05, subordinate=06, sec-latency=0
    I/O behind bridge: 0000f000-00000fff
    Memory behind bridge: de000000-deffffff
    Prefetchable memory behind bridge: 00000000d8000000-00000000d8ffffff
    Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- <SERR- <PERR-
    BridgeCtl: Parity+ SERR+ NoISA- VGA+ MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
    Capabilities: <access denied>
    Kernel driver in use: pcieport

04:01.0 PCI bridge: Renesas Technology Corp. SH7757 PCIe Switch [PS]
(prog-if 00 [Normal decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    BIST result: 00
    Bus: primary=04, secondary=07, subordinate=07, sec-latency=0
    I/O behind bridge: 0000f000-00000fff
    Memory behind bridge: df700000-df7fffff
    Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
    Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- <SERR- <PERR-
    BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
    Capabilities: <access denied>
    Kernel driver in use: pcieport

05:00.0 PCI bridge: Renesas Technology Corp. SH7757 PCIe-PCI Bridge
[PPB] (prog-if 00 [Normal decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    BIST result: 00
    Bus: primary=05, secondary=06, subordinate=06, sec-latency=0
    I/O behind bridge: 0000f000-00000fff
    Memory behind bridge: de000000-deffffff
    Prefetchable memory behind bridge: 00000000d8000000-00000000d8ffffff
    Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ <SERR- <PERR-
    BridgeCtl: Parity+ SERR+ NoISA- VGA+ MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
    Capabilities: <access denied>

06:00.0 VGA compatible controller: Matrox Electronics Systems Ltd.
G200eR2 (prog-if 00 [VGA controller])
    Subsystem: Dell Device 04f7
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 64 (4000ns min, 8000ns max), Cache Line Size: 64 bytes
    Interrupt: pin A routed to IRQ 11
    Region 0: Memory at d8000000 (32-bit, prefetchable) [size=16M]
    Region 1: Memory at deffc000 (32-bit, non-prefetchable) [size=16K]
    Region 2: Memory at de000000 (32-bit, non-prefetchable) [size=8M]
    [virtual] Expansion ROM at 000c0000 [disabled] [size=128K]
    Capabilities: <access denied>

08:00.0 Ethernet controller: Emulex Corporation OneConnect NIC
(Skyhawk) (rev 10)
    Subsystem: Emulex Corporation Device e820
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx+
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Interrupt: pin A routed to IRQ 32
    Region 0: Memory at d90f8000 (64-bit, prefetchable) [size=16K]
    Region 2: Memory at d9060000 (64-bit, prefetchable) [size=128K]
    Region 4: Memory at d9080000 (64-bit, prefetchable) [size=128K]
    Expansion ROM at dd000000 [disabled] [size=512K]
    Capabilities: <access denied>
    Kernel driver in use: be2net

08:00.1 Ethernet controller: Emulex Corporation OneConnect NIC
(Skyhawk) (rev 10)
    Subsystem: Emulex Corporation Device e820
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx+
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Interrupt: pin B routed to IRQ 39
    Region 0: Memory at d90fc000 (64-bit, prefetchable) [size=16K]
    Region 2: Memory at d90a0000 (64-bit, prefetchable) [size=128K]
    Region 4: Memory at d90c0000 (64-bit, prefetchable) [size=128K]
    Expansion ROM at dd080000 [disabled] [size=512K]
    Capabilities: <access denied>
    Kernel driver in use: be2net

3f:08.0 System peripheral: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 QPI Link 0 (rev 04)
    Subsystem: Intel Corporation Device 0000
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-

3f:09.0 System peripheral: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 QPI Link 1 (rev 04)
    Subsystem: Intel Corporation Device 0000
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-

3f:0a.0 System peripheral: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 Power Control Unit 0 (rev 04)
    Subsystem: Intel Corporation Device 0000
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-

3f:0a.1 System peripheral: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 Power Control Unit 1 (rev 04)
    Subsystem: Intel Corporation Device 0000
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-

3f:0a.2 System peripheral: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 Power Control Unit 2 (rev 04)
    Subsystem: Intel Corporation Device 0000
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-

3f:0a.3 System peripheral: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 Power Control Unit 3 (rev 04)
    Subsystem: Intel Corporation Device 0000
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-

3f:0b.0 System peripheral: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 UBOX Registers (rev 04)
    Subsystem: Intel Corporation Device 0000
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-

3f:0b.3 System peripheral: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 UBOX Registers (rev 04)
    Subsystem: Intel Corporation Device 0000
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-

3f:0c.0 System peripheral: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 Unicast Registers (rev 04)
    Subsystem: Intel Corporation Device 0000
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-

3f:0c.1 System peripheral: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 Unicast Registers (rev 04)
    Subsystem: Intel Corporation Device 0000
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-

3f:0d.0 System peripheral: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 Unicast Registers (rev 04)
    Subsystem: Intel Corporation Device 0000
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-

3f:0d.1 System peripheral: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 Unicast Registers (rev 04)
    Subsystem: Intel Corporation Device 0000
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-

3f:0e.0 System peripheral: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 Home Agent 0 (rev 04)
    Subsystem: Dell Device 04f7
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-

3f:0e.1 Performance counters: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 Home Agent 0 (rev 04)
    Subsystem: Dell Device 04f7
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Kernel driver in use: ivbep_uncore

3f:0f.0 System peripheral: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 Integrated Memory Controller 0 Target Address/Thermal
Registers (rev 04)
    Subsystem: Intel Corporation Device 0000
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Capabilities: <access denied>

3f:0f.1 System peripheral: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 Integrated Memory Controller 0 RAS Registers (rev 04)
    Subsystem: Intel Corporation Device 0000
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Capabilities: <access denied>

3f:0f.2 System peripheral: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 Integrated Memory Controller 0 Channel Target Address
Decoder Registers (rev 04)
    Subsystem: Intel Corporation Device 0000
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Capabilities: <access denied>

3f:0f.3 System peripheral: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 Integrated Memory Controller 0 Channel Target Address
Decoder Registers (rev 04)
    Subsystem: Intel Corporation Device 0000
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Capabilities: <access denied>

3f:0f.4 System peripheral: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 Integrated Memory Controller 0 Channel Target Address
Decoder Registers (rev 04)
    Subsystem: Intel Corporation Device 0000
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Capabilities: <access denied>

3f:0f.5 System peripheral: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 Integrated Memory Controller 0 Channel Target Address
Decoder Registers (rev 04)
    Subsystem: Intel Corporation Device 0000
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Capabilities: <access denied>

3f:10.0 System peripheral: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 Integrated Memory Controller 1 Channel 0-3 Thermal Control
0 (rev 04)
    Subsystem: Intel Corporation Device 0000
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Capabilities: <access denied>
    Kernel driver in use: ivbep_uncore

3f:10.1 System peripheral: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 Integrated Memory Controller 1 Channel 0-3 Thermal Control
1 (rev 04)
    Subsystem: Intel Corporation Device 0000
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Capabilities: <access denied>
    Kernel driver in use: ivbep_uncore

3f:10.2 System peripheral: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 Integrated Memory Controller 1 Channel 0-3 ERROR Registers
0 (rev 04)
    Subsystem: Intel Corporation Device 0000
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Capabilities: <access denied>

3f:10.3 System peripheral: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 Integrated Memory Controller 1 Channel 0-3 ERROR Registers
1 (rev 04)
    Subsystem: Intel Corporation Device 0000
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Capabilities: <access denied>

3f:10.4 System peripheral: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 Integrated Memory Controller 1 Channel 0-3 Thermal Control
2 (rev 04)
    Subsystem: Intel Corporation Device 0000
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Capabilities: <access denied>
    Kernel driver in use: ivbep_uncore

3f:10.5 System peripheral: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 Integrated Memory Controller 1 Channel 0-3 Thermal Control
3 (rev 04)
    Subsystem: Intel Corporation Device 0000
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Capabilities: <access denied>
    Kernel driver in use: ivbep_uncore

3f:10.7 System peripheral: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 Integrated Memory Controller 1 Channel 0-3 ERROR Registers
3 (rev 04)
    Subsystem: Intel Corporation Device 0000
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Capabilities: <access denied>

3f:13.0 System peripheral: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 R2PCIe (rev 04)
    Subsystem: Intel Corporation Device 0000
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-

3f:13.1 Performance counters: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 R2PCIe (rev 04)
    Subsystem: Dell Device 04f7
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Kernel driver in use: ivbep_uncore

3f:13.4 System peripheral: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 QPI Ring Registers (rev 04)
    Subsystem: Dell Device 04f7
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-

3f:13.5 Performance counters: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 QPI Ring Performance Ring Monitoring (rev 04)
    Subsystem: Dell Device 04f7
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Kernel driver in use: ivbep_uncore

3f:16.0 System peripheral: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 System Address Decoder (rev 04)
    Subsystem: Intel Corporation Device 0000
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-

3f:16.1 System peripheral: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 Broadcast Registers (rev 04)
    Subsystem: Intel Corporation Device 0000
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-

3f:16.2 System peripheral: Intel Corporation Xeon E7 v2/Xeon E5
v2/Core i7 Broadcast Registers (rev 04)
    Subsystem: Intel Corporation Device 0000
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-

[7.6.] SCSI information (from /proc/scsi/scsi)
Attached devices:
Host: scsi0 Channel: 02 Id: 00 Lun: 00
  Vendor: DELL     Model: PERC H310        Rev: 2.12
  Type:   Direct-Access                    ANSI  SCSI revision: 05

[7.7.] Other information that might be relevant to the problem
       (please look in /proc and include all information that you
       think to be relevant):
[X.] Other notes, patches, fixes, workarounds:
The main place this is noticed is that LVS monitor scripts that check
back-end servers sporadically fail.

I expect that somewhere, something (e.g. functionality for IPVS MASQ
responses) is applying IPVS connection
information to incoming traffic, matching a DROUTE rule, and treating
it as NAT traffic.

Many thanks,
-- 
Nick Moriarty
Linux Systems Administrator and Developer

IT Services
Computer Science Building
University of York
York
YO10 5GH
+44 (0)1904 32 3484

e-mail disclaimer: http://www.york.ac.uk/docs/disclaimer/email.htm
