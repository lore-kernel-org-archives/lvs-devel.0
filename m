From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH v2] netfilter: Clean up tests if NULL returned on
 failure
Date: Wed, 29 Mar 2017 11:33:54 +0200 (CEST)
Message-ID: <alpine.LSU.2.20.1703291133190.27467@n3.vanv.qr>
References: <20170328131340.GA19688@singhal-Inspiron-5558> <alpine.LSU.2.20.1703281552040.21255@n3.vanv.qr> <CALrZqyPeR6X1RrqOsGfLbbZ2rPQgOf=50Rs+ot0kxkkA464V5w@mail.gmail.com> <alpine.LSU.2.20.1703290854390.26906@n3.vanv.qr>
 <CALrZqyN2Vh0J219tY_zj5u-4bUVmD+T=q6yMH9WZN2Y3O7yzpA@mail.gmail.com> <CALrZqyOMPfvt1OyH_LrNwj-a316gt=ZU2O0h+s+_NWH49dj_sw@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <CALrZqyOMPfvt1OyH_LrNwj-a316gt=ZU2O0h+s+_NWH49dj_sw@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: SIMRAN SINGHAL <singhalsimran0@gmail.com>
Cc: wensong@linux-vs.org, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, outreachy-kernel <outreachy-kernel@googlegroups.com>


On Wednesday 2017-03-29 11:15, SIMRAN SINGHAL wrote:
>>>>>>       dest = kzalloc(sizeof(struct ip_vs_dest), GFP_KERNEL);
>>>>>>-      if (dest == NULL)
>>>>>>+      if (!dest)
>>>>>>               return -ENOMEM;
>
>But, according to me we should prefer !var over ( var ==NULL ) according to the
>coding style

Where does it say that?
