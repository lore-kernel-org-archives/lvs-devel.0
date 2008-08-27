From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 0/2] IPVS: Merge AH and ESP support into one file
Date: Wed, 27 Aug 2008 15:30:35 +1000
Message-ID: <20080827053032.GB7815@verge.net.au>
References: <1219406773-19357-1-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1219406773-19357-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, vbusam@google.com, sven.wegener@stealer.net, brian.haley@hp.com

On Fri, Aug 22, 2008 at 02:06:11PM +0200, Julius Volz wrote:
> These patches remove the duplication between ip_vs_proto_ah.c and
> ip_vs_proto_esp.c by merging the same functionality into one file,
> ip_vs_proto_ah_esp.c.
> 
> The original files are almost 100% identical, except for names,
> constants, etc., which either referenced AH or ESP. This was brought
> up by Brian Haley when I duplicated even more in those files in the
> IPVS IPv6 patches. Maybe there's some interest in keeping the files
> apart though, so feel free to ignore this then.

Hi Julius,

these changes look good to me. I have pushed them into lvs-2.6.
The master branch is based on net-2.6. The lvs-next-2.6 branch
is based on net-next.2.6.
