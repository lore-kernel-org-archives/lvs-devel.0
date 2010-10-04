From: Simon Horman <horms@verge.net.au>
Subject: Re: Forwarding method in backup server
Date: Mon, 4 Oct 2010 18:44:18 +0900
Message-ID: <20101004094417.GC18749@verge.net.au>
References: <alpine.LFD.2.00.1009282343130.2049@ja.ssi.bg>
 <20101002083026.GD2248@verge.net.au>
 <1286174099.5670.171.camel@seasc0214>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1286174099.5670.171.camel@seasc0214>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: Julian Anastasov <ja@ssi.bg>, Wensong Zhang <wensong@linux-vs.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>

On Mon, Oct 04, 2010 at 08:34:59AM +0200, Hans Schillstrom wrote:
> Hi 
> 
> On Sat, 2010-10-02 at 10:30 +0200, Simon Horman wrote:
> > On Wed, Sep 29, 2010 at 01:01:37AM +0300, Julian Anastasov wrote:
> > 
> > Hi Julian, Hi all,
> > 
> > > 
> > > 	Hello,
> > > 
> > > 	From the recent discussion about loaded backup server
> > > it looks like we do not properly assign forwarding method
> > > to connections in backup server. If backup is used in master
> > > as real server, eg. DR, then backup should use LOCALNODE
> > > for its IP. May be ip_vs_find_dest should allow real server
> > > with port 0 to be used as default server? And if real server
> > > is found its forwarding method should be used for the
> > > connection? So, backup should have the same IP and Port but
> > > it can choose to use different forwarding method? For example,
> > > master uses DR but backup TUN for the same real server.
> > > 
> > > 	Because now when server is added its method can
> > > be converted to LOCALNODE but when such connections
> > > are created in backup server we should use DR or NAT
> > > or whatever the method is configured there. The same is
> > > when backup is added as DR server in master but the
> > > connections should be LOCALNODE when created in backup.
> > > 
> > > 	If we still allow DR/NAT/TUN connections in backup
> > > to work without real server then all such xmitters should
> > > check RTCF_LOCAL and assume LOCALNODE if needed. This is
> > > needed for the case when we do not know the fwmark used
> > > by connection and we can not find the virtual service.
> > > 
> > > 	Then __ip_vs_update_dest should not replace the
> > > configured forwarding method with IP_VS_CONN_F_LOCALNODE
> > > to allow backup to see this method in fwmark connections.
> > > If needed, we can remember that it is local in some
> > > new dest flag, eg. IP_VS_DEST_F_LOCAL. But better to
> > > show it as it was configured?
> > > 
> > > 	So, how to fix these problems? May be:
> > > 
> > > - ip_vs_find_dest to find svc and dest in more complex way
> > > 
> > > - if backup has dest it should assign its forwarding method
> > > to the connection (ip_vs_bind_dest)
> > > 
> > > - allow some transmitters to deliver traffic locally to support
> > > fwmark setups, eg. when no dest is assigned to connection
> > 
> > This seems rather tricky to say the least.
> > I prefer the 2nd version of struct ip_vs_sync_conn option...
> > 
> > > 	There is also an option to create 2nd version
> > > of struct ip_vs_sync_conn. For example, size in
> > > struct ip_vs_sync_mesg can be moved after new field
> > > version which will be in place of size. Old backups will
> > > think the small version number as some short size and will
> > > ignore the message. New backup servers can support both
> > > formats. The new format can add new fields for fwmark,
> > > IPv6 addresses, 1 byte af (AF_INET/AF_INET6), 1 byte len
> > > for easy skipping of messages if af or protocol are not
> > > supported.
> 
> >From my narrow view of the LVS:
> If you use Network name spaces there is no need of LOCAL NODE since the
> entire LVS could be placed in it's own netns....
> (I know people will use what they always have been using.)

I'm not quite sure what you are getting at there.

LOCAL NODE is basically an optimisation in the transmit path for
the case where the real-server is the local host. But I think
that most of the problem with it relates to it being determined
at the time that a real-server is added.

I'm unclear about how name spaces can help here,
but I'm certainly very happy to learn.

> > It funny that you should mention that. I need to extend the synchronisation
> > protocol to allow the synchronisation of persistence engine data. And I
> > came up with more or less the same scheme for extending the protocol
> > without breaking old implementations - set the current size field to 0 (or
> > any other value that doesn't match the packet length), add a new size field
> > and a version field.
> 
> Why not change port ?

I considered that too. But I think changing the protocol is easy enough.
And in any case new kernels will need to understand both the new and
old ways of doing things.

> > Lets spend a bit of time thinking out a v2 of the protocol that solves the
> > outstanding problems that we have.
> > 
> > * No version field
> > * Only 16 bits of flags
> > * No space for IPv6 addresses
> > * No space fwmarks
> > (* No space for persistence engine data)
> > 
> 
> I have stared to implement IPv6 backup using IPv6 multicast
> My Idea was to keep the IPv4 and IPv6 separated, i.e. send IPv4 over its
> own socket and IPv6 over another just to keep IPv4 untouched.
> If there is a need for changes I vote for - "keep them together".
> 
> I think a version 2 would be nice, where IPv6 is a part.
> 
> Needed new fields
> * Version must be there
> * next field  (offset to next filed, IPv4, fwmark, IPv6)
> * flags/type field
> 
> 
> Divide the messages into required no of fields ex.
> IPv4
> fwmark 
> IPv6

Perhaps we just need an addrlen field somewhere.
Or if we wanted to save space, an addr type field.

If you have some firm ideas perhaps you could send
them here, perhaps in the form of a C structure or a diagram?

> > Individually those problems don't seem to warrant a new protocol.
> > But when combined it seems worthwhile to me.
> > 
> > > 	Simon, may be now ip_vs_nat_xmit should see
> > > RTCF_LOCAL flag and we should check all NAT handlers
> > > to support the LOCALNODE fallback where the port can
> > > be changed too.
> > 
> > I'm not quite sure what you are describing there.
> > 
> > Is the idea that if the forwarding mechanism is NAT
> > then packets will always go via ip_vs_nat_xmit, even if
> > the IP is local (at config time). And that ip_vs_nat_xmit()
> > will use local xmit if RTCF_LOCAL is set?
> 
> IPv6 also have a number of other issues not related to the backup
> protocol like  Usage of IPv6 or IPv4 multicast address etc. 

Could you elaborate?

