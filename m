From: Alex Gartrell <agartrell@fb.com>
Subject: IPVS Health Checking Best Practices
Date: Thu, 18 Sep 2014 14:26:58 -0700
Message-ID: <541B4E22.6080802@fb.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=message-id : date : from :
 mime-version : to : cc : subject : content-type :
 content-transfer-encoding; s=facebook;
 bh=1ixWox0JfirmUyeIfNISLtXMtEuMjsD9anGAfL4ugig=;
 b=iOt7lGeEn/dxQ3dYIDDAiJroFy8waLF9ROUXnOws8UU0AN3UAozzzwQ6K1BZIayxfCPH
 R9Iq97dTvoocqM/RMblSUb3YLUcAMtculR0Pc4uk/3VLqObK+Ps64NMpzYplL2TitNtU
 uC1FU37s+t66Fa16c+XODbk0ZtLeR6l+/Mk= 
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: lvs-devel@vger.kernel.org
Cc: dsp@fb.com, kernel-team <Kernel-team@fb.com>, ps@fb.com

Hello All,

Today, we run IPVS on a number of hosts.  Each of these hosts has a 
python process responsible for ensuring the health of pool members and 
then updating their weights as necessary.

We do these health checks via IPVS for two reasons:
1) Different VIPs have different listeners on our real servers, so we 
can't just use the regular host address
2) We want to ensure that decapsulation is happening appropriately.

The way we do this today is a giant hack.  We have a scheduler that 
we've not (yet) open sourced that does consistent hashing, and someone 
just wired in a couple additional sysctls that will allow you to do the 
following:

If a request is from $MAGIC_IP and the source port is >= $MAGIC_PORT, 
then send it to pool->members[($SRC_PORT - $MAGIC_PORT) % $N].

I'd like to solve this problem more generally.

The other solution I've heard of is using fwmarks, but that kind of 
sucks from a configuration perspective (because you have to add in all 
of the persistent vips and everything).

Here are some other ideas:

1) Map the socket itself to a particular pool with a netlink invocation 
or something

2) Provide a way to bind specific src addr, port tuples to specific 
destination (though this is a bummer because you have to reserve port space)

But I'm completely open to ideas and I think we're willing to do the 
work to make this happen.


Thanks,

-- 
Alex Gartrell <agartrell@fb.com>
