From: Brian Carpio <bcarpio@broadhop.com>
Subject: Re: UDP / DHCP / LDIRECTORD
Date: Thu, 24 Feb 2011 14:46:48 -0800
Message-ID: <131ECB70A13234449BBD551EC5022B686E3D87B9DF@VA3DIAXVS061.RED001.local>
References: <20100412020447.GB10826@verge.net.au>
	<20100413025551.GA25064@verge.net.au>
	<0CABC52FBCB6564DA3F567CC933D1FF36854D03287@VA3DIAXVS061.RED001.local>
Reply-To: General Linux-HA mailing list <linux-ha@lists.linux-ha.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linux-ha-bounces@lists.linux-ha.org>
In-Reply-To: <0CABC52FBCB6564DA3F567CC933D1FF36854D03287@VA3DIAXVS061.RED001.local>
Content-Language: en-US
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <http://lists.linux-ha.org/mailman/listinfo/linux-ha>,
	<mailto:linux-ha-request@lists.linux-ha.org?subject=unsubscribe>
List-Archive: <http://lists.linux-ha.org/pipermail/linux-ha>
List-Post: <mailto:linux-ha@lists.linux-ha.org>
List-Help: <mailto:linux-ha-request@lists.linux-ha.org?subject=help>
List-Subscribe: <http://lists.linux-ha.org/mailman/listinfo/linux-ha>,
	<mailto:linux-ha-request@lists.linux-ha.org?subject=subscribe>
Sender: linux-ha-bounces@lists.linux-ha.org
Errors-To: linux-ha-bounces@lists.linux-ha.org
To: 'Simon Horman' <horms@verge.net.au>
Cc: 'lvs-devel' <lvs-devel@vger.kernel.org>, 'Julian Anastasov' <ja@ssi.bg>, "'linux-ha@lists.linux-ha.org'" <linux-ha@lists.linux-ha.org>

All,

So this patch has been working for us flawlessly for the last 5 months or so. 

Our infrastructure is 100% virtualized, the other day our loadbalacner01 had a memory leak and crashed, since we use ldirectord with heartbeat loadbalacner02 took over, however ever since then it seems like the single packet UDP scheduling has stopped working. Even if I fail back over the loadbalacner01 VM, I still see all the DHCP traffic going to only one backend server. 

If I run ipvsadm -L -n I can see that ipvsadm thinks both of the backend servers are up since the weight is set to 1 for each server, if I reboot the second backend server the one which is not receiving any traffic then run ipvsadm -L -n I can see its weight go to 0 and in the ldirectord log I can see that its marked dead. 

I have exported one of the loadblancers and one of the backend servers (using VMware) and imported them into another ESXi server, once I boot up the loadbalacner it works perfectly... I'm very stumped why this would happen, is there any additional logging you can think of that I might want to enable to see where the exact problem is?

Here are my configs:

 
/etc/ha.d/ldirectord.conf

checktimeout=10
checkinterval=2
autoreload=yes
logfile="/var/log/ldirectord.log"
quiescent=yes
virtual=10.10.10.10:67
        real=backend_server01:67 masq
        real=backend_server02:67 masq
        protocol=udp
        checktype=ping
        scheduler=rr
virtual=10.10.10.10:68
        real=back_endserver01:68 masq
        real=backend_server02:68 masq
        protocol=udp
        checktype=ping
        scheduler=rr


I had to rewrite the ldirectord start script and added the following lines in the start and restart sections:

        ipvsadm -E -u 10.10.10.10:67 -o -s rr
        ipvsadm -E -u 10.10.10.10:68 -o -s rr


Here is the output of ipvsadm -L -n when both backend servers are up (working environment):


IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
UDP  10.10.10.10:67 rr ops
  -> backend_server01:67            Masq    1      0          16731     
  -> backend_server02:67            Masq    1      0          17447     
UDP  192.168.181.67:68 rr ops
  -> backend_server01:68            Masq    1      0          0         
  -> backend_server02:68            Masq    1      0          0         

Here is the output of ipvsadm -L -n when both backend servers are up (non-working environment):

[root@lb01 log]# ipvsadm -L -n
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
UDP  10.10.10.10:67 rr ops
  -> backend_server01:67                 Masq    1      0          1         
  -> backend_server02:67                 Masq    1      0          0         
UDP  10.10.10.10:68 rr ops
  -> backend_server01:68                 Masq    1      0          0         
  -> backend_server02:68                 Masq    1      0          0         


The only difference I see is that in my "Working" environment my InActConn number increases as I send load through it, in my "Non-Working" environment the InActConn stays at 1 the entire time.. Another difference is that in the "Working" environment I am using a DHCP load testing tool one of my developers wrote, whereas in the "NON-Working" environment we are actually getting DHCP traffic from another network device... 





Brian Carpio 
Senior Systems Engineer

Office: +1.303.962.7242
Mobile: +1.720.319.8617
Email: bcarpio@broadhop.com


-----Original Message-----
From: Brian Carpio 
Sent: Thursday, April 15, 2010 1:57 PM
To: Simon Horman
Cc: linux-ha@lists.linux-ha.org; lvs-devel; Julian Anastasov
Subject: RE: [Linux-HA] UDP / DHCP / LDIRECTORD

Simon,

Thanks again for all of your hard work, I have sent over a million UDP DHCP packets at the new kernel/ipvsadm with the patches applied and currently the only issue (which you know about already) is that ldirectord doesn't know about the -o option which causes a slight issue with heartbeat (but I just put in a cheap fix in my ldirectord start script to edit the services created by ldirectord).. 

So not only have I sent over 1,000,000 packets to this setup but I have also sent them as fast as 10 packets every 3 milliseconds, I plan to do a long term week long test but I don't foresee any issues.. 

Let me know if there is any other testing you would like us to do.. or if you would like me to send out the kernel-2.6.18-128 with the patch and the ipvsadm-1.24-10 rpm with the patch.. 

Thanks again Simon you are the man!!

Brian Carpio



-----Original Message-----
From: Simon Horman [mailto:horms@verge.net.au] 
Sent: Monday, April 12, 2010 8:56 PM
To: Brian Carpio
Cc: linux-ha@lists.linux-ha.org; lvs-devel; Julian Anastasov
Subject: Re: [Linux-HA] UDP / DHCP / LDIRECTORD

Hi Brian,

here are some patches to test.
I have only lightly tested them to the extent that they compile and appear to configure a valid service.

You can enable one packet scheduling (OPS) by passing the -o option to ipvsadm when creating a virtual service.

	e.g.

	# ipvsadm -A -u 172.17.60.211:80 -o
	# ipvsadm -L -n
	IP Virtual Server version 1.2.1 (size=4096)
	Prot LocalAddress:Port Scheduler Flags
	  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
	UDP  172.17.60.211:80 wlc ops

There are three patches:

ops-kernel-2.6.18-128.el5.patch: Patch against CentOS-5.3's 2.6.18-128 kernel.
ops-ipvsadm-1.24-10: Patch against CentOS-5.3's ipvsadm 1.24-10.
ops-ipvsadm-1.24: Patch against upstream ipvsadm 1.24

I have not up-ported the code to the 2.6.33 kernel and ipvsadm 1.25 yet.


No virus found in this incoming message.
Checked by AVG - www.avg.com
Version: 9.0.801 / Virus Database: 271.1.1/2808 - Release Date: 04/13/10 00:32:00
_______________________________________________
Linux-HA mailing list
Linux-HA@lists.linux-ha.org
http://lists.linux-ha.org/mailman/listinfo/linux-ha
See also: http://linux-ha.org/ReportingProblems
