From: Simon Horman <horms@verge.net.au>
Subject: Re: ovf scheduler
Date: Tue, 14 Jul 2015 10:36:25 +0900
Message-ID: <20150714013625.GE29200@verge.net.au>
References: <CAA0i4Bp0n-PooNaUq=F7MgD2Ou8=hdA6w+B0te5tcWP4ODxTfw@mail.gmail.com>
 <alpine.LFD.2.11.1507132328500.1708@ja.home.ssi.bg>
 <CAA0i4Bph-Gw00+-kUovvvfSgEta6XEH2-hGtSnusuPNdro2nCA@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAA0i4Bph-Gw00+-kUovvvfSgEta6XEH2-hGtSnusuPNdro2nCA@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "rhadoo.io88" <rhadoo.io88@gmail.com>
Cc: Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org

Hi,

On Tue, Jul 14, 2015 at 01:47:16AM +0300, rhadoo.io88 wrote:
> Unfortunately i was not aware of the FO scheduler, i looked it up just
> now...indeed you could get similar behavior with FO scheduler and
> proper thresholds.
> The only trouble with that is that i can't set the thresholds from
> within ldirectord , so i won't be able to keep all the config in one
> place,  and that upper threshold seems to take into account all
> connections ( active and inactive) , that making the upper limit a bit
> vague.

Perhaps ldirectord could be enhanced in this regard?

> i think this approach has the advantage of keeping all the config in
> one place, having the weight set at the actual number of active
> connections the node can handle whilst still allowing to have
> thresholds on the total connections.
> 
> On Mon, Jul 13, 2015 at 11:35 PM, Julian Anastasov <ja@ssi.bg> wrote:
> >
> >         Hello,
> >
> > On Mon, 13 Jul 2015, rhadoo.io88 wrote:
> >
> >> Hi,
> >> My name is Raducu Deaconu, i am a romanian syadmin/solution manager
> >> and i have been working with lvs for some years now, great software!
> >> I mainly use ldirectord on top of lvs and every now and then i do run
> >> into customer tasks that would need new features.
> >> One such feature is the need of a failover scheduler that would allow
> >> a certain number of active connections to be served by a server and
> >> only in case that is overloaded send some jobs to another/other
> >> servers.
> >> That would be needed say in the case you have let's say a galera
> >> cluster and you want to make sure all writes go to one node, and only
> >> one node,or in the case where you have some caching implemented in an
> >> application and you want the virtual service to always go to that
> >> server, unless there is a problem, case when another server can handle
> >> the job, although without the caching.
> >> These features are not possible now in ldirectord/lvs and i think they
> >> would bring some benefits to many use cases like my own.
> >
> >         Can the same be achieved by setting --u-threshold
> > and using the FO scheduler? ip_vs_bind_dest() sets the
> > IP_VS_DEST_F_OVERLOAD flag if number of connections
> > exceed upper threshold and then the FO scheduler can select
> > another real server with lower weight.
> >
> > Regards
> >
> > --
> > Julian Anastasov <ja@ssi.bg>
> --
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
