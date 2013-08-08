From: Simon Horman <horms@verge.net.au>
Subject: Re: ipvsadm git head not compiling on RHEL6
Date: Thu, 8 Aug 2013 18:00:57 +0900
Message-ID: <20130808090057.GB22983@verge.net.au>
References: <1375937999-11660-1-git-send-email-horms@verge.net.au>
 <52034D12.4070100@redhat.com>
 <20130808101924.7b363a4e@redhat.com>
 <52035659.8080503@redhat.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52035659.8080503@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Daniel Borkmann <dborkman@redhat.com>
Cc: Jesper Dangaard Brouer <jbrouer@redhat.com>, lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Thu, Aug 08, 2013 at 10:27:05AM +0200, Daniel Borkmann wrote:
> On 08/08/2013 10:19 AM, Jesper Dangaard Brouer wrote:
> >
> >I noticed that I get an compile error, when compiling ipvsadm
> >git HEAD 1ea1f41f4 on RHEL6.4.
> >
> >Compile Error:
> >
> >gcc -Wall -Wunused -Wstrict-prototypes -g -o ipvsadm ipvsadm.o config_stream.o dynamic_array.o libipvs/libipvs.a -lpopt -lnl
> >libipvs/libipvs.a(libipvs.o): In function `ipvs_nl_send_message':
> >/home/jbrouer/git/ipvsadm/libipvs/libipvs.c:76: undefined reference to `nl_socket_alloc'
> >/home/jbrouer/git/ipvsadm/libipvs/libipvs.c:91: undefined reference to `nl_socket_free'
> >/home/jbrouer/git/ipvsadm/libipvs/libipvs.c:107: undefined reference to `nl_socket_free'
> >/home/jbrouer/git/ipvsadm/libipvs/libipvs.c:112: undefined reference to `nl_socket_free'
> >collect2: ld returned 1 exit status
> >make: *** [ipvsadm] Error 1
> >
> >I'll investigate, but hints would be appreciated ;-)
> 
> Did you try using libnl3? (Migrating to libnl3 would be better anyway as
> distributions try to get rid of supporting libnl.)
> 
> I think sometime in libnl*, nl_handle_{alloc,free} was changed to
> nl_socket_{alloc,free}.
> 
> Maybe try changing include locations and libs that are linked against
> to libnl3.

I'm pretty sure that I saw the same problem and that using libnl3 was
the solution.
