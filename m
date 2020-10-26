From: =?UTF-8?Q?Cezar_S=C3=A1_Espinola?= <cezarsa@gmail.com>
Subject: Possibility of adding a new netlink command to dump everything
Date: Mon, 26 Oct 2020 12:27:37 -0300
Message-ID: <CA++F93g_WfKbVHLMUFYgQbR63o2-s8Ky_W9Z85qsFM77OaweEQ@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=eubxZeME9MVo04i3g72Z1OM8ee4gR4GC+PAdwG/Au5k=;
        b=QYZuoscyQaujv+iztaxwUNJDww7d+xKaIUPvG8YIUGJuHFlUKlav9SYWWo9H0iDRca
         hw5dhEYPpoViHKJ5n2A4tnghdBn/5IqC9V+hopc2b3CY8W26mGFIRAAUu/a/MqL1717K
         YNtaQoIIE29O4x8ofoC0876OkpMGyDzpyoGYpQ8X+k4uJlMPBVs60kjNDTvgVs2YlEo+
         hZl3F4Rc9YAJoJXiC1JSL2+W3ABuVAYYu4T4TS7e8F2G4Agwq+3vlfOTMrlcG+wz5es0
         udP3lkXwTWPmiZE+jHysjq5qJ4D6a2kapWwkIk+4twgk+ICtWlSHGP/+hfgOujHQ1kio
         kL5g==
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org

Hi all. This is my first message here and also my first attempt at kernel
development so I'm a bit nervous and afraid I'm doing something wrong.

The last few days I've been toying with a patch to IPVS to allow me to use
netlink to dump all services and all its destinations in a single call.

The motivation for this came after profiling a kubernetes node machine with a
few thousand IPVS services each with an average of two destinations. The
component responsible for ensuring that the IPVS rules are correct always needs
a fresh dump of all services with all destinations and currently this is
accomplished by issuing a IPVS_CMD_GET_SERVICE generic netlink dump command
followed by multiple IPVS_CMD_GET_DEST dump commands.

The patch in question adds a new netlink command IPVS_CMD_GET_SERVICE_DEST
which dumps all services where each service is followed by a dump of its
destinations. It's working now on my machine and some preliminary experiments
show me that there's a significant performance improvement in switching to a
single call to dump everything. However, I have some questions that I'd like to
talk about before trying to submit it.

1. First of all is such a patch adding a new command something desirable and
could it possibly be merged or should I just drop it?

2. I can see that besides the generic netlink interface there's also another
interface based on getsockopt options, should the patch also add a new socket
option or is it okay for this new functionality to be exclusive to generic
netlink?

3. Should this go forward, any advice on my next steps? Should I simply send the
patch here?

Thank you for your time!
