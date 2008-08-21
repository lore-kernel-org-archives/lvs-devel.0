From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch] ipvsadm: use strtoul to convert ip addresses from hex
Date: Thu, 21 Aug 2008 10:48:07 +1000
Message-ID: <20080821004805.GF19235@verge.net.au>
References: <20080820054415.GA31393@verge.net.au> <f4845fc0808200330lc1cad87ya94eb73da9b4c175@mail.gmail.com> <48AC5870.9050000@google.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <48AC5870.9050000@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vince Busam <vbusam@google.com>
Cc: Julius Volz <juliusv@google.com>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, wensong@linux-vs.org

On Wed, Aug 20, 2008 at 10:46:24AM -0700, Vince Busam wrote:
> Julius Volz wrote:
>> On Wed, Aug 20, 2008 at 7:44 AM, Simon Horman <horms@verge.net.au> wrote:
>>> The ip addresses that come out of /proc/net/ip_vs_conn as integers
>>> are in hex not decimal.
>>
>> Thanks for this fix! I'm sure Vince will release a new version with
>> this once there is sunlight in his timezone :)
>
> A new version, which also fixes a bug in sorting IPv6 addresses, is up  
> at http://sixpak.org/vince/google/ipvsadm/

Thanks. That does fix the 0.0.0.0 problem that I was seeing.


