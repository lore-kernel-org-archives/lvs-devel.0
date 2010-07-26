From: Simon Horman <horms@verge.net.au>
Subject: [patch 3/5] ipvsadm: Initialise descrip and argDescrip elements of struct poptOption
Date: Mon, 26 Jul 2010 17:04:51 +0900
Message-ID: <20100726080645.990677532@vergenet.net>
References: <20100726080448.476781076@vergenet.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=poptOption-desc.patch
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Nick Chalk <nick@loadbalancer.org>

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: trunk/ipvsadm.c
===================================================================
--- trunk.orig/ipvsadm.c	2010-07-26 17:00:07.000000000 +0900
+++ trunk/ipvsadm.c	2010-07-26 17:00:38.000000000 +0900
@@ -343,52 +343,62 @@ parse_options(int argc, char **argv, str
 	poptContext context;
 	char *optarg=NULL;
 	struct poptOption options_table[] = {
-		{"add-service", 'A', POPT_ARG_NONE, NULL, 'A'},
-		{"edit-service", 'E', POPT_ARG_NONE, NULL, 'E'},
-		{"delete-service", 'D', POPT_ARG_NONE, NULL, 'D'},
-		{"clear", 'C', POPT_ARG_NONE, NULL, 'C'},
-		{"list", 'L', POPT_ARG_NONE, NULL, 'L'},
-		{"list", 'l', POPT_ARG_NONE, NULL, 'l'},
-		{"zero", 'Z', POPT_ARG_NONE, NULL, 'Z'},
-		{"add-server", 'a', POPT_ARG_NONE, NULL, 'a'},
-		{"edit-server", 'e', POPT_ARG_NONE, NULL, 'e'},
-		{"delete-server", 'd', POPT_ARG_NONE, NULL, 'd'},
-		{"set", '\0', POPT_ARG_NONE, NULL, '4'},
-		{"help", 'h', POPT_ARG_NONE, NULL, 'h'},
-		{"version", 'v', POPT_ARG_NONE, NULL, 'v'},
-		{"restore", 'R', POPT_ARG_NONE, NULL, 'R'},
-		{"save", 'S', POPT_ARG_NONE, NULL, 'S'},
-		{"start-daemon", '\0', POPT_ARG_STRING, &optarg, '1'},
-		{"stop-daemon", '\0', POPT_ARG_STRING, &optarg, '2'},
-		{"tcp-service", 't', POPT_ARG_STRING, &optarg, 't'},
-		{"udp-service", 'u', POPT_ARG_STRING, &optarg, 'u'},
-		{"fwmark-service", 'f', POPT_ARG_STRING, &optarg, 'f'},
-		{"scheduler", 's', POPT_ARG_STRING, &optarg, 's'},
-		{"persistent", 'p', POPT_ARG_STRING|POPT_ARGFLAG_OPTIONAL,
-		 &optarg, 'p'},
-		{"netmask", 'M', POPT_ARG_STRING, &optarg, 'M'},
-		{"real-server", 'r', POPT_ARG_STRING, &optarg, 'r'},
-		{"masquerading", 'm', POPT_ARG_NONE, NULL, 'm'},
-		{"ipip", 'i', POPT_ARG_NONE, NULL, 'i'},
-		{"gatewaying", 'g', POPT_ARG_NONE, NULL, 'g'},
-		{"weight", 'w', POPT_ARG_STRING, &optarg, 'w'},
-		{"u-threshold", 'x', POPT_ARG_STRING, &optarg, 'x'},
-		{"l-threshold", 'y', POPT_ARG_STRING, &optarg, 'y'},
-		{"numeric", 'n', POPT_ARG_NONE, NULL, 'n'},
-		{"connection", 'c', POPT_ARG_NONE, NULL, 'c'},
-		{"mcast-interface", '\0', POPT_ARG_STRING, &optarg, '3'},
-		{"syncid", '\0', POPT_ARG_STRING, &optarg, 'I'},
-		{"timeout", '\0', POPT_ARG_NONE, NULL, '5'},
-		{"daemon", '\0', POPT_ARG_NONE, NULL, '6'},
-		{"stats", '\0', POPT_ARG_NONE, NULL, '7'},
-		{"rate", '\0', POPT_ARG_NONE, NULL, '8'},
-		{"thresholds", '\0', POPT_ARG_NONE, NULL, '9'},
-		{"persistent-conn", '\0', POPT_ARG_NONE, NULL, 'P'},
-		{"nosort", '\0', POPT_ARG_NONE, NULL, '0'},
-		{"sort", '\0', POPT_ARG_NONE, NULL, 'o'},
-		{"exact", 'X', POPT_ARG_NONE, NULL, 'X'},
-		{"ipv6", '6', POPT_ARG_NONE, NULL, '%'},
-		{NULL, 0, 0, NULL, 0}
+		{ "add-service", 'A', POPT_ARG_NONE, NULL, 'A', NULL, NULL },
+		{ "edit-service", 'E', POPT_ARG_NONE, NULL, 'E', NULL, NULL },
+		{ "delete-service", 'D', POPT_ARG_NONE, NULL, 'D', NULL, NULL },
+		{ "clear", 'C', POPT_ARG_NONE, NULL, 'C', NULL, NULL },
+		{ "list", 'L', POPT_ARG_NONE, NULL, 'L', NULL, NULL },
+		{ "list", 'l', POPT_ARG_NONE, NULL, 'l', NULL, NULL },
+		{ "zero", 'Z', POPT_ARG_NONE, NULL, 'Z', NULL, NULL },
+		{ "add-server", 'a', POPT_ARG_NONE, NULL, 'a', NULL, NULL },
+		{ "edit-server", 'e', POPT_ARG_NONE, NULL, 'e', NULL, NULL },
+		{ "delete-server", 'd', POPT_ARG_NONE, NULL, 'd', NULL, NULL },
+		{ "set", '\0', POPT_ARG_NONE, NULL, '4', NULL, NULL },
+		{ "help", 'h', POPT_ARG_NONE, NULL, 'h', NULL, NULL },
+		{ "version", 'v', POPT_ARG_NONE, NULL, 'v', NULL, NULL },
+		{ "restore", 'R', POPT_ARG_NONE, NULL, 'R', NULL, NULL },
+		{ "save", 'S', POPT_ARG_NONE, NULL, 'S', NULL, NULL },
+		{ "start-daemon", '\0', POPT_ARG_STRING, &optarg, '1',
+		  NULL, NULL },
+		{ "stop-daemon", '\0', POPT_ARG_STRING, &optarg, '2',
+		  NULL, NULL },
+		{ "tcp-service", 't', POPT_ARG_STRING, &optarg, 't',
+		  NULL, NULL },
+		{ "udp-service", 'u', POPT_ARG_STRING, &optarg, 'u',
+		  NULL, NULL },
+		{ "fwmark-service", 'f', POPT_ARG_STRING, &optarg, 'f',
+		  NULL, NULL },
+		{ "scheduler", 's', POPT_ARG_STRING, &optarg, 's', NULL, NULL },
+		{ "persistent", 'p', POPT_ARG_STRING|POPT_ARGFLAG_OPTIONAL,
+		 &optarg, 'p', NULL, NULL },
+		{ "netmask", 'M', POPT_ARG_STRING, &optarg, 'M', NULL, NULL },
+		{ "real-server", 'r', POPT_ARG_STRING, &optarg, 'r',
+		  NULL, NULL },
+		{ "masquerading", 'm', POPT_ARG_NONE, NULL, 'm', NULL, NULL },
+		{ "ipip", 'i', POPT_ARG_NONE, NULL, 'i', NULL, NULL },
+		{ "gatewaying", 'g', POPT_ARG_NONE, NULL, 'g', NULL, NULL },
+		{ "weight", 'w', POPT_ARG_STRING, &optarg, 'w', NULL, NULL },
+		{ "u-threshold", 'x', POPT_ARG_STRING, &optarg, 'x',
+		  NULL, NULL },
+		{ "l-threshold", 'y', POPT_ARG_STRING, &optarg, 'y',
+		  NULL, NULL },
+		{ "numeric", 'n', POPT_ARG_NONE, NULL, 'n', NULL, NULL },
+		{ "connection", 'c', POPT_ARG_NONE, NULL, 'c', NULL, NULL },
+		{ "mcast-interface", '\0', POPT_ARG_STRING, &optarg, '3',
+		  NULL, NULL },
+		{ "syncid", '\0', POPT_ARG_STRING, &optarg, 'I', NULL, NULL },
+		{ "timeout", '\0', POPT_ARG_NONE, NULL, '5', NULL, NULL },
+		{ "daemon", '\0', POPT_ARG_NONE, NULL, '6', NULL, NULL },
+		{ "stats", '\0', POPT_ARG_NONE, NULL, '7', NULL, NULL },
+		{ "rate", '\0', POPT_ARG_NONE, NULL, '8', NULL, NULL },
+		{ "thresholds", '\0', POPT_ARG_NONE, NULL, '9', NULL, NULL },
+		{ "persistent-conn", '\0', POPT_ARG_NONE, NULL, 'P',
+		  NULL, NULL },
+		{ "nosort", '\0', POPT_ARG_NONE, NULL, '0', NULL, NULL },
+		{ "sort", '\0', POPT_ARG_NONE, NULL, 'o', NULL, NULL },
+		{ "exact", 'X', POPT_ARG_NONE, NULL, 'X', NULL, NULL },
+		{ "ipv6", '6', POPT_ARG_NONE, NULL, '%', NULL, NULL },
+		{ NULL, 0, 0, NULL, 0, NULL, NULL }
 	};
 
 	context = poptGetContext("ipvsadm", argc, (const char **)argv,

