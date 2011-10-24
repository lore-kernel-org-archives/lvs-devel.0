From: Graeme Fowler <graeme@graemef.net>
Subject: Re: lvs-users mailing list and archive dead?
Date: Mon, 24 Oct 2011 09:58:51 +0100
Message-ID: <1319446731.12559.2.camel@localhost>
References: <4EA44C9F.4030104@wpkg.org>
	 <e6ed933e-c1dc-4931-b97e-89dec46d8617@email.android.com>
	 <4EA4709A.1050501@wpkg.org> <1319445137.12559.0.camel@localhost>
	 <4EA525B4.1030601@wpkg.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <4EA525B4.1030601@wpkg.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Tomasz Chmielewski <mangoo@wpkg.org>
Cc: lvs-devel@vger.kernel.org

On Mon, 2011-10-24 at 10:45 +0200, Tomasz Chmielewski wrote:
> On 24.10.2011 10:32, Graeme Fowler wrote:
> > Can you please tell me which IP netblock these queries are originating
> > from? I smell a previously unallocated (to an RIR) block which is in my
> > bogons list.
> 
> I.e. 178.63.195.*, 178.63.11.*, 46.4.130.*, 46.4.96.124, 46.4.115.*, 
> 176.9.54.*.

Yep, that was it - I had a terribly outdated bogons filter in my
named.conf which had been pulled in via my poor revision control system
(that is, I copied an old version in from a rather old named.conf when
rebuilding servers a few months ago).

Sorry - and thanks for the heads up!

Graeme

