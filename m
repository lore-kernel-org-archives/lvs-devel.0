From: Simon Horman <horms@verge.net.au>
Subject: Ipvsadm pre v1.27 on Debian 7.1 (wheezy update 1)
Date: Thu, 5 Sep 2013 09:43:02 +0900
Message-ID: <20130905004302.GP25209@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: Jesper Dangaard Brouer <jbrouer@redhat.com>, Wensong Zhang <wensong@linux-vs.org>

Hi,

in preparation for releasing ipvsadm v1.27 I have
tested building the code on Debian 7.1 (wheezy update 1).
The result was success.

Details
-------

Revision tested:
3141694cb0d873adc8ef9b09ff71d510957ef640
("ipvsadm: support for scheduler flags")

Test:
# apt-get build-dep ipvsadm
# apt-get install pkg-config
$ make clean
$ make
make -C libipvs
make[1]: Entering directory `/home/horms/projects/ipvsadm/git/ipvsadm/libipvs'
gcc -Wall -Wunused -Wstrict-prototypes -g -fPIC -DLIBIPVS_USE_NL    -DHAVE_NET_IP_VS_H -DFALLBACK_LIBNL1 -c -o libipvs.o libipvs.c
gcc -Wall -Wunused -Wstrict-prototypes -g -fPIC -DLIBIPVS_USE_NL    -DHAVE_NET_IP_VS_H -DFALLBACK_LIBNL1 -c -o ip_vs_nl_policy.o ip_vs_nl_policy.c
ar rv libipvs.a libipvs.o ip_vs_nl_policy.o
ar: creating libipvs.a
a - libipvs.o
a - ip_vs_nl_policy.o
gcc -shared -Wl,-soname,libipvs.so -o libipvs.so libipvs.o ip_vs_nl_policy.o
make[1]: Leaving directory `/home/horms/projects/ipvsadm/git/ipvsadm/libipvs'
gcc -Wall -Wunused -Wstrict-prototypes -g  -DVERSION=\"1.26\" -DSCHEDULERS=\""rr|wrr|lc|wlc|lblc|lblcr|dh|sh|sed|nq"\" -DPE_LIST=\""sip"\"  -DHAVE_NET_IP_VS_H -c -o ipvsadm.o ipvsadm.c
ipvsadm.c: In function 'modprobe_ipvs':
ipvsadm.c:1243:6: warning: variable 'rc' set but not used [-Wunused-but-set-variable]
ipvsadm.c: In function 'print_largenum':
ipvsadm.c:1436:3: warning: field width specifier '*' expects argument of type 'int', but argument 2 has type 'size_t' [-Wformat]
gcc -Wall -Wunused -Wstrict-prototypes -g  -DVERSION=\"1.26\" -DSCHEDULERS=\""rr|wrr|lc|wlc|lblc|lblcr|dh|sh|sed|nq"\" -DPE_LIST=\""sip"\"  -DHAVE_NET_IP_VS_H -c -o config_stream.o config_stream.c
gcc -Wall -Wunused -Wstrict-prototypes -g  -DVERSION=\"1.26\" -DSCHEDULERS=\""rr|wrr|lc|wlc|lblc|lblcr|dh|sh|sed|nq"\" -DPE_LIST=\""sip"\"  -DHAVE_NET_IP_VS_H -c -o dynamic_array.o dynamic_array.c
gcc -Wall -Wunused -Wstrict-prototypes -g -o ipvsadm ipvsadm.o config_stream.o dynamic_array.o libipvs/libipvs.a -lpopt -lnl  
$ echo $?
0


