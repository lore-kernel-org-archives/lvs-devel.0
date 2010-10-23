From: Simon Horman <horms@verge.net.au>
Subject: [patch 0/9] [rfc] synchronisation of persistence engines
Date: Sun, 24 Oct 2010 00:26:26 +0900
Message-ID: <20101023152626.811097720@joe.akashicho.tokyo.vergenet.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>

Hi,

This is an extension of the synchronisation protocol
to support the synchronisation of persistence engine data.

Although it is called v2, it is only WIP and does not meet
many of the stated goals of v2 - notably no IPv6, fwmark
or timeout synchronisation.

It is not intended to compete with other work in this area,
rather to add to the discussion.

