From: Simon Horman <horms@verge.net.au>
Subject: Re: Forwarding method in backup server
Date: Sat, 2 Oct 2010 17:30:26 +0900
Message-ID: <20101002083026.GD2248@verge.net.au>
References: <alpine.LFD.2.00.1009282343130.2049@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1009282343130.2049@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Wensong Zhang <wensong@linux-vs.org>, lvs-devel@vger.kernel.org

On Wed, Sep 29, 2010 at 01:01:37AM +0300, Julian Anastasov wrote:

Hi Julian, Hi all,

> 
> 	Hello,
> 
> 	From the recent discussion about loaded backup server
> it looks like we do not properly assign forwarding method
> to connections in backup server. If backup is used in master
> as real server, eg. DR, then backup should use LOCALNODE
> for its IP. May be ip_vs_find_dest should allow real server
> with port 0 to be used as default server? And if real server
> is found its forwarding method should be used for the
> connection? So, backup should have the same IP and Port but
> it can choose to use different forwarding method? For example,
> master uses DR but backup TUN for the same real server.
> 
> 	Because now when server is added its method can
> be converted to LOCALNODE but when such connections
> are created in backup server we should use DR or NAT
> or whatever the method is configured there. The same is
> when backup is added as DR server in master but the
> connections should be LOCALNODE when created in backup.
> 
> 	If we still allow DR/NAT/TUN connections in backup
> to work without real server then all such xmitters should
> check RTCF_LOCAL and assume LOCALNODE if needed. This is
> needed for the case when we do not know the fwmark used
> by connection and we can not find the virtual service.
> 
> 	Then __ip_vs_update_dest should not replace the
> configured forwarding method with IP_VS_CONN_F_LOCALNODE
> to allow backup to see this method in fwmark connections.
> If needed, we can remember that it is local in some
> new dest flag, eg. IP_VS_DEST_F_LOCAL. But better to
> show it as it was configured?
> 
> 	So, how to fix these problems? May be:
> 
> - ip_vs_find_dest to find svc and dest in more complex way
> 
> - if backup has dest it should assign its forwarding method
> to the connection (ip_vs_bind_dest)
> 
> - allow some transmitters to deliver traffic locally to support
> fwmark setups, eg. when no dest is assigned to connection

This seems rather tricky to say the least.
I prefer the 2nd version of struct ip_vs_sync_conn option...

> 	There is also an option to create 2nd version
> of struct ip_vs_sync_conn. For example, size in
> struct ip_vs_sync_mesg can be moved after new field
> version which will be in place of size. Old backups will
> think the small version number as some short size and will
> ignore the message. New backup servers can support both
> formats. The new format can add new fields for fwmark,
> IPv6 addresses, 1 byte af (AF_INET/AF_INET6), 1 byte len
> for easy skipping of messages if af or protocol are not
> supported.

It funny that you should mention that. I need to extend the synchronisation
protocol to allow the synchronisation of persistence engine data. And I
came up with more or less the same scheme for extending the protocol
without breaking old implementations - set the current size field to 0 (or
any other value that doesn't match the packet length), add a new size field
and a version field.

Lets spend a bit of time thinking out a v2 of the protocol that solves the
outstanding problems that we have.

* No version field
* Only 16 bits of flags
* No space for IPv6 addresses
* No space fwmarks
(* No space for persistence engine data)

Individually those problems don't seem to warrant a new protocol.
But when combined it seems worthwhile to me.

> 	Simon, may be now ip_vs_nat_xmit should see
> RTCF_LOCAL flag and we should check all NAT handlers
> to support the LOCALNODE fallback where the port can
> be changed too.

I'm not quite sure what you are describing there.

Is the idea that if the forwarding mechanism is NAT
then packets will always go via ip_vs_nat_xmit, even if
the IP is local (at config time). And that ip_vs_nat_xmit()
will use local xmit if RTCF_LOCAL is set?
