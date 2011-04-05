From: Simon Horman <horms@verge.net.au>
Subject: [Announce] New IPVS GIT trees
Date: Tue, 5 Apr 2011 09:24:17 +0900
Message-ID: <20110405002416.GE16175@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
Cc: Hans Schillstrom <hans@schillstrom.com>, Julian Anastasov <ja@ssi.bg>, Wensong Zhang <wensong@linux-vs.org>, Patrick McHardy <kaber@trash.net>, David Miller <davem@davemloft.net>

Hi,

I would like to announce that I have created two new trees
to help me maintain the flow of changes to IPVS.

1) ipvs-2.6

   This the master branch of tree is based of the master
   branch of Patrick's nf-2.6 tree. Patches to rc kernels
   should be made against the master branch. That is, bug fixes.

   I intend to add some other branches for backports and the like.
   Temporary branches, such as for-patrick, will come and
   go as the need arises.

   git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-2.6.git

2) ipvs-next-2.6

   This the master branch of tree is based of the master
   branch of Patrick's nf-next-2.6 tree. Patches for the next/current
   merge window should be made against the master branch.
   This is where the development of new features should be done.

   My intention is to close this tree to new features during the merge window.

   I may add topic branches as the need arises.
   Temporary branches, such as for-patrick, will come and
   go as the need arises.

   git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next-2.6.git

My lvs-test-2.6 tree is now deprecated.  Please avoid using it if possible.
I intend to delete it in the not to distant future.
