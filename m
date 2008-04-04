From: Simon Horman <horms@verge.net.au>
Subject: Re: Adapting LVS in order to allow Call-Id based persistence
Date: Fri, 4 Apr 2008 17:07:23 +0900
Message-ID: <20080404080723.GA30670@verge.net.au>
References: <c2f80c020804020703u6ebd4ed6oc430668daae94b30@mail.gmail.com> <Pine.LNX.4.64.0804020713370.25100@wm7d.net> <20080403052243.GA1683@verge.net.au> <c2f80c020804030056k1ba58dc6ocb7a2e1acfe4c013@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <c2f80c020804030056k1ba58dc6ocb7a2e1acfe4c013@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: pierrick grasland <pierrick.grasland@gmail.com>
Cc: Joseph Mack NA3T <jmack@wm7d.net>, lvs-devel@vger.kernel.org

On Thu, Apr 03, 2008 at 09:56:30AM +0200, pierrick grasland wrote:
> Hi,
> 
> What I have in mind is the same kind of architecture (I think it's because I
> have read the HOWTO's chapter on SIP before).
> So, even if it's for an older kernel, it will be interesting to see it.

I will speak with my client about posing the patches - though it may
take a while as big companies sometimes move quite slowly.

> Also, I have some questions about general organization of ipvs/ipvsadm. If I
> understand this correctly, it's ipvs which receive inbound connection and
> schedule them following the different services created with ipvsadm.

ipvsadm runs in user-space and is used to configure ipvs.
ipvs lives inside the kernel and does all the real work.

> But how do you work with persistence ? (actually, with -p options).
> 
> Each call during the interval go to the same server, and then, do you reset
> the timer for each new call) or no ?

Ok, this is something that I have tired to explain several times without
success. I'll have another go.

When a packet comes in the hash of known connections is checked. If an
entry there is found then it is used and the information in this entry
tells ipvs which real-server to forward the connection to. The entry has
a timeout which is updated each time a packet for it is forwarded.

If an entry is not found, then a new one is created and a real-server
is assigned using the scheduling algorithm (as configured by ipvsadm).

For persistent services, a template is also kept which models persistance.
Before going to the scheduler for a new connection the template
is looked up. If it is found then its real-server is used for the
connection. If not, the scheduler is used to create both a new entry
for the new connection and a new template.

These templates also have a timeout (as configured by ipvsadm),
which is reset each time a packet is forwarded for any connections
whose entry used the template in question.

For persistent connections you can think of the template as a parent
of all the connections from the same host (masked with the netmask
configured by ipvsadm).

For non-persistent connections, there is no parent-child
relationship as there are no templates.

-- 
Horms

