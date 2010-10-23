From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch 0/9] [rfc] synchronisation of persistence engines
Date: Sun, 24 Oct 2010 00:42:29 +0900
Message-ID: <20101023154228.GA21814@verge.net.au>
References: <20101023152626.811097720@joe.akashicho.tokyo.vergenet.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101023152626.811097720@joe.akashicho.tokyo.vergenet.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>

On Sun, Oct 24, 2010 at 12:26:26AM +0900, Simon Horman wrote:
> Hi,
> 
> This is an extension of the synchronisation protocol
> to support the synchronisation of persistence engine data.
> 
> Although it is called v2, it is only WIP and does not meet
> many of the stated goals of v2 - notably no IPv6, fwmark
> or timeout synchronisation.
> 
> It is not intended to compete with other work in this area,
> rather to add to the discussion.

The series is available in the pe-sync-0.1 branch of
git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git

