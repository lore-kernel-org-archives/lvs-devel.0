From: Robin Bowes <robin-lists@robinbowes.com>
Subject: Is net-snmp-lvs-module maintained?
Date: Wed, 30 Sep 2009 19:31:35 +0100
Message-ID: <ha0867$44i$2@ger.gmane.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org
Cc: lvs-users@LinuxVirtualServer.org, net-snmp-users@lists.sourceforge.net, lvs-users@LinuxVirtualServer.org

Hi,

I'm using the net-snmp-lvs-module which I've successfully built into an
x86_64 RPM and installed on CentOS 5.3 with net-snmp 5.4.2.1.

However, I'm seeing a couple of bugs, and I wondered if this module is
maintained, and where/who best to report them to?

Here are the problems I'm seeing:

1. When started up, I see this error in /var/log/messages:

Sep 30 14:04:32 a003 snmpd[25050]: IPVS initialization for
Sep 30 14:04:32 a003 snmpd[25050]: netsnmp_assert !"registration !=
duplicate" failed agent_registry.c:536 netsnmp_subtree_load()
Sep 30 14:04:32 a003 snmpd[25050]: NET-SNMP version 5.4.2.1

Looking in lvs.c, I see these lines in init_lvs:

netsnmp_register_read_only_instance(netsnmp_create_handler_registration("lvsNumServices",
get_lvs_var, lvsNumServices_oid, OID_LENGTH(lvsNumServices_oid),
HANDLER_CAN_RONLY));

netsnmp_register_read_only_instance(netsnmp_create_handler_registration("lvsNumServices",
get_lvs_var, lvsHashTableSize_oid, OID_LENGTH(lvsHashTableSize_oid),
HANDLER_CAN_RONLY));

netsnmp_register_read_only_instance(netsnmp_create_handler_registration("lvsNumServices",
get_lvs_var, lvsHashTableSize_oid, OID_LENGTH(lvsHashTableSize_oid),
HANDLER_CAN_RONLY));

It seems to me that at least one of those is wrong/a duplicate.

I don't know if this is the cause of the error message


2. None of the Connection rate counters seem to be working, but the
bytes/packet counters are OK:

LVS-MIB::lvsServiceRateCps.1 = Gauge32: 0 <-- not working
LVS-MIB::lvsServiceRateInPPS.1 = Gauge32: 9672
LVS-MIB::lvsServiceRateOutPPS.1 = Gauge32: 0
LVS-MIB::lvsServiceRateInBPS.1 = Gauge32: 969111
LVS-MIB::lvsServiceRateOutBPS.1 = Gauge32: 0

LVS-MIB::lvsRealRateCps.1.1 = Gauge32: 0 <-- not working
LVS-MIB::lvsRealRateCps.1.2 = Gauge32: 0 <-- not working
LVS-MIB::lvsRealRateCps.1.3 = Gauge32: 0 <-- not working
LVS-MIB::lvsRealRateInPPS.1.1 = Gauge32: 3224
LVS-MIB::lvsRealRateInPPS.1.2 = Gauge32: 3224
LVS-MIB::lvsRealRateInPPS.1.3 = Gauge32: 3224
LVS-MIB::lvsRealRateOutPPS.1.1 = Gauge32: 0
LVS-MIB::lvsRealRateOutPPS.1.2 = Gauge32: 0
LVS-MIB::lvsRealRateOutPPS.1.3 = Gauge32: 0
LVS-MIB::lvsRealRateInBPS.1.1 = Gauge32: 323083
LVS-MIB::lvsRealRateInBPS.1.2 = Gauge32: 323025
LVS-MIB::lvsRealRateInBPS.1.3 = Gauge32: 323003
LVS-MIB::lvsRealRateOutBPS.1.1 = Gauge32: 0
LVS-MIB::lvsRealRateOutBPS.1.2 = Gauge32: 0
LVS-MIB::lvsRealRateOutBPS.1.3 = Gauge32: 0

(I'm using DR so I expect the "Out" counters to be 0.)

Is anyone listening who might be in a position to look at these issues?

Thanks,

R.

