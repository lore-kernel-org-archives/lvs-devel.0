From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: Remove leading spaces in Kconfig
Date: Tue, 18 May 2021 18:20:27 +0200
Message-ID: <20210518162027.GB24332@salvia>
References: <20210517095850.82083-1-juergh@canonical.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20210517095850.82083-1-juergh@canonical.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Juerg Haefliger <juerg.haefliger@canonical.com>
Cc: kadlec@netfilter.org, fw@strlen.de, horms@verge.net.au, ja@ssi.bg, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, juergh@canonical.com

On Mon, May 17, 2021 at 11:58:50AM +0200, Juerg Haefliger wrote:
> Remove leading spaces before tabs in Kconfig file(s) by running the
> following command:
> 
>   $ find net/netfilter -name 'Kconfig*' | xargs sed -r -i 's/^[ ]+\t/\t/'

Applied, thanks.
