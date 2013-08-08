From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: ipvsadm git head not compiling on RHEL6
Date: Thu, 8 Aug 2013 10:19:24 +0200
Message-ID: <20130808101924.7b363a4e@redhat.com>
References: <1375937999-11660-1-git-send-email-horms@verge.net.au>
	<52034D12.4070100@redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <52034D12.4070100@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Daniel Borkmann <dborkman@redhat.com>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>


I noticed that I get an compile error, when compiling ipvsadm
git HEAD 1ea1f41f4 on RHEL6.4.

Compile Error:

gcc -Wall -Wunused -Wstrict-prototypes -g -o ipvsadm ipvsadm.o config_stream.o dynamic_array.o libipvs/libipvs.a -lpopt -lnl
libipvs/libipvs.a(libipvs.o): In function `ipvs_nl_send_message':
/home/jbrouer/git/ipvsadm/libipvs/libipvs.c:76: undefined reference to `nl_socket_alloc'
/home/jbrouer/git/ipvsadm/libipvs/libipvs.c:91: undefined reference to `nl_socket_free'
/home/jbrouer/git/ipvsadm/libipvs/libipvs.c:107: undefined reference to `nl_socket_free'
/home/jbrouer/git/ipvsadm/libipvs/libipvs.c:112: undefined reference to `nl_socket_free'
collect2: ld returned 1 exit status
make: *** [ipvsadm] Error 1

I'll investigate, but hints would be appreciated ;-)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
