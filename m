From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [ipvsadm PATCH 0/2] trivial compile warning fixes for ipvsadm
Date: Sun, 7 Dec 2014 20:30:38 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1412072028010.1885@ja.home.ssi.bg>
References: <20141204093757.20470.92421.stgit@localhost>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20141204093757.20470.92421.stgit@localhost>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: lvs-devel@vger.kernel.org, Daniel Borkmann <dborkman@redhat.com>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Ryan O'Hara <rohara@redhat.com>


	Hello,

On Thu, 4 Dec 2014, Jesper Dangaard Brouer wrote:

> Some trivial compile warning fixes from Daniel Borkmann to the ipvsadm tool.
> 
> I'll apply these to the git repo[1] if nobody objects.
> 
> [1] git://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git
> 
> ---
> 
> Daniel Borkmann (2):
>       ipvsadm: fix compile warning in print_largenum
>       ipvsadm: fix compile warning in modprobe_ipvs

	Both patches look ok to me too,

Acked-by: Julian Anastasov <ja@ssi.bg>

	We should not see ECHILD when SIGCHLD=SIG_DFL, right?
Only for SIG_IGN.

Regards

--
Julian Anastasov <ja@ssi.bg>
