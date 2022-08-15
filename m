From: Simon Horman <horms@kernel.org>
Subject: Re: How many physical machines do I need for running the Linux
 Virtual Server?
Date: Mon, 15 Aug 2022 18:22:03 +0100
Message-ID: <YvqAu4kafE2bElT6@vergenet.net>
References: <CACsrZYY6aWpVOdZ5SOhDPdU+_=P0LX4=q4xCht+E-+PHRwEhGw@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACsrZYY6aWpVOdZ5SOhDPdU+_=P0LX4=q4xCht+E-+PHRwEhGw@mail.gmail.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Turritopsis Dohrnii Teo En Ming <tdtemccna@gmail.com>
Cc: lvs-devel@vger.kernel.org, ceo@teo-en-ming-corp.com

On Wed, Aug 10, 2022 at 05:43:09PM +0800, Turritopsis Dohrnii Teo En Ming wrote:
> Subject: How many physical machines do I need for running the Linux
> Virtual Server?
> 
> Good day from Singapore,
> 
> How many physical machines do I need for running the Linux Virtual Server?

Hi,

typically you would want one or two load balances, running IPVS.
And two or more real servers running your application, f.e. a web server.

It is, however possible, to make a minimal configuration with
only one of each. Or to use VMs to run the entire system
on one physical server.
