From: Julian Anastasov <ja@ssi.bg>
Subject: Re: kernel oops - do_ip_vs_get_ctl
Date: Fri, 20 Apr 2012 12:03:34 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1204201156590.1986@ja.ssi.bg>
References: <4F90EE1F.9010904@redhat.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <4F90EE1F.9010904@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ryan O'Hara <rohara@redhat.com>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Fri, 20 Apr 2012, Ryan O'Hara wrote:

> 
> I frequently get a kernel oops in do_ip_vs_get_ctl when starting keepalived on
> a 3.3.0 kernel. I'm attaching the trace from /var/log/messages. Has anyone
> encountered this problem and if so is there a patch available? Much
> appreciated.

	Is it happening while ip_vs module is loading?
nf_register_sockopt is one of the first thing that is
initialized, may be the GET operation accesses something
from net->ipvs that is not initialized yet. As I can not
see properly the exact place from the oops, I'll try to
analyze do_ip_vs_get_ctl for such problem. May be other
folks will be faster in tracking the right command and
position in the source code.

	May be we have to split ip_vs_control_init to
two parts so that sockopts are the last thing to register
on init.

Regards

--
Julian Anastasov <ja@ssi.bg>
