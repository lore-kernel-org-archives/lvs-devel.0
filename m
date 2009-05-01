From: Caleb Anthony <caleb.anthony@gmail.com>
Subject: Ldirectord Feature Request
Date: Fri, 1 May 2009 14:18:06 -0600
Message-ID: <33afbbe70905011318j35d226a6h31e0dfaeb1b77b45@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:mime-version:received:date:message-id:subject
         :from:to:content-type:content-transfer-encoding;
        bh=t6yq4rpdmxwT6UOLzhHcj/M12akJ/FLCLNFS0gIgQ8M=;
        b=cALeuiswijCjwrrJnnqNnZbI0Ym5n4zEbnrd1d0yF/+UgwmEy33Xo7Uux7Y7IIV2XE
         PyqUfNe4sFkgum50ZmnibBw2C5nJrEKww5gNf/vDANPAJOYCOWwa6fsAjqdsPBj88Zus
         s/MyG0UaqjivBJdTtmsiPtaM38NVol9Em6gp4=
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org

Hello,

In my organization we use ldirectord to monitor and maintain the ipvs
table. It works great, except that we run a bit of a strange setup
that involves nested ipvs (ipvs forwarding to another ipvs), and a
combination of direct routing and IP tunneling. I'm actually in the
process of writing up a small of a testimonial about our
configuration, which I don't think is very common, or maybe ever been
used at all. But, in our endeavors we've come across two limitations
with ldirectord in our environment.

First, we use the source hash scheduling algorithm to maintain
affinity with real servers. And according to the documentation that I
have seen, the weight setting really means "number of connections" to
the source hash scheduler. This is a problem for us with the fallback
setting, because ldirectord doesn't allow you to set the weight of a
fallback server. Instead, it just defaults to 1. So, in the event of
an emergency, ipvs is only going to allow 1 connection at a time to
our fallback server. Being able to specify the weight of a fallback
server would be a great addition for us.

Our second suggestion would be to have the ability to specify multiple
fallback servers, just like you can with real servers. It's hard for
me to explain why we can't live with just one fallback server without
a huge explanation about our setup, but basically we have more than
one fallback server that serves real content, and if a failure
occurred, we have to hope that that one server we have configured is
not only running, but able to handle the sudden load. Also, I'm not
entirely sure if fallback servers are health monitored. I ask because,
if we could specify multiple fallback servers, we would like them to
be monitored just like a real server and added or removed from the
ipvs table as necessary.

Any thoughts - pro or con about these requests?

Thanks.
