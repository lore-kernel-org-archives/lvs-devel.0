From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [4.4.y,netfilter/ipvs] please, apply 3c5ab3f395d6
Date: Mon, 24 Jul 2017 11:59:40 +0200
Message-ID: <20170724095940.GA3853@salvia>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: stable@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org

Hi Greg,

Please, apply this commit:

commit 3c5ab3f395d66a9e4e937fcfdf6ebc63894f028b
Author: Julian Anastasov <ja@ssi.bg>
Date:   Sat Apr 29 20:33:09 2017 +0300

    ipvs: SNAT packet replies only for NATed connections

to stable 4.4.y.

Julian made a backport for you, in case cherry-pick doesn't work, that
is available at Netfilter's patchwork:

        http://patchwork.ozlabs.org/patch/789260/

Thanks!
