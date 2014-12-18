From: Julian Anastasov <ja@ssi.bg>
Subject: seqadj ext fix in ipvs for 3.12 stable
Date: Thu, 18 Dec 2014 22:56:26 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1412182244420.2055@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, Smart Weblications GmbH - Florian Wiessner <f.wiessner@smart-weblications.de>


	Hello,

	Pablo, please consider commit b25adce16064
("ipvs: correct usage/allocation of seqadj ext in ipvs") for
inclusion in 3.12 stable. Florian Wiessner tested it
on 3.12.33 to fix the crash in nf_ct_seqadj_set.

3.10 and below do not need it. It is part of 3.13
but seqadj code that caused the problem is in 3.12.

Reference: http://marc.info/?t=141761860700001&r=1&w=2

Regards

--
Julian Anastasov <ja@ssi.bg>
