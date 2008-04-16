From: Jason Stubbs <j.stubbs@linkthink.co.jp>
Subject: Re: [PATCH 2/6] move ipvs to PRE/POSTROUTING
Date: Wed, 16 Apr 2008 10:35:12 +0900
Message-ID: <200804161035.12575.j.stubbs@linkthink.co.jp>
References: <200804151540.04006.j.stubbs@linkthink.co.jp> <200804151541.17117.j.stubbs@linkthink.co.jp>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <200804151541.17117.j.stubbs@linkthink.co.jp>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-2022-jp"
To: LVS Devel <lvs-devel@vger.kernel.org>

Having to reply to myself sucks.. :(

On Tuesday 15 April 2008 15:41:17 Jason Stubbs wrote:
> I am also not certain of how traffic control will handle this. This
> patch may be causing traffic to be accounted for twice depending on when
> tcp_output is actually run.

I got confused between TCP congestion control and qdiscs here. Congestion 
control is before netfilter and thus unaffected. Qdiscs run directly on 
interfaces after netfilter has completed and so is also unaffected.

-- 
Jason Stubbs <j.stubbs@linkthink.co.jp>
LINKTHINK INC.
東京都渋谷区桜ヶ丘町22-14 N.E.S S棟 3F
TEL 03-5728-4772  FAX 03-5728-4773
