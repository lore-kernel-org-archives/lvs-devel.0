From: =?utf-8?Q?Stefan_Bauer?= <stefan.bauer@cubewerk.de>
Subject: How does the mode fullnat work in detail and is implemented?
Date: Sat, 2 Feb 2013 10:12:41 +0100
Message-ID: <zarafa.510cd889.2056.2ff512266db7af11@zarafa.cubewerk.int>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: =?utf-8?Q?lvs-devel=40vger=2Ekernel=2Eorg?= <lvs-devel@vger.kernel.org>

Dear developers,

how does the mode fullnat work and how is it implemented?

I see there are patches at http://kb.linuxvirtualserver.org/images/a/a5/Lvs-fullnat-synproxy.tar.gz for the kernel.

How is this mode triggered in userland? I see there are patches for ipvsadm as well. Additionally to this, do i have to set a SNAT-rule with iptables?

It would be nice to get some informations on this - there arent many informations out there about the deeper details.

Thank you in advance.

Stefan Bauer
