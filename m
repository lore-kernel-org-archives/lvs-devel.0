From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: Re: [ath9k-devel] [PATCH net-next 00/21] treewide: Use
 consistent api style for address testing
Date: Fri, 19 Oct 2012 11:55:17 -0400
Message-ID: <20121019115517.7b8514a8@mj>
References: <cover.1350618006.git.joe@perches.com>
	<1350630254.2293.183.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1350630254.2293.183.camel@edumazet-glaptop>
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org, linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devel-s9riP+hp16TNLxjTenLetw@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, wimax-BPSAo7wm5JOHVYUYWc+uSQ@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lvs-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, cbe-oss-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, user-mode-linux-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org, netfilter-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, user-mode-linux-user-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, l

On Fri, 19 Oct 2012 09:04:14 +0200
Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> Yes they are some names discrepancies, thats a big deal.
> 
> And we have alloc_skb() / kfree_skb() / skb_clone() 
> 
> Why not skb_alloc() / skb_free() / skb_clone() ?
> 
> Some people actually know current code by name of functions, they dont
> want to change their mind and having to grep include files and git log
> to learn the new names of an old function, especially when traveling
> and using a laptop.

I agree.

Also, it makes sense to introduce a more consistent name for a function
when it's improved in some way and the callers need to be adjusted or
re-checked.

That way, the old name can be phased out as the code is made compatible
with the new function.

-- 
Regards,
Pavel Roskin
