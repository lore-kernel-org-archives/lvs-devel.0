From: Geoff Harrison <geoff@thehive.com>
Subject: patch for sql to support SELECT
Date: Wed, 16 Jan 2008 11:38:28 -0500
Message-ID: <88FE1CB2-3144-464C-8D97-BC4798E9CA2A@thehive.com>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: multipart/mixed; boundary=Apple-Mail-7-1003492404
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: LVS Devel <lvs-devel@vger.kernel.org>


--Apple-Mail-7-1003492404
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=US-ASCII;
	delsp=yes;
	format=flowed

I've been patching this by hand, it doesn't really work with select  
properly as it is out of the box, patch is in-line (mailed separately  
to horms as well)


try #3 - I'm mailing this from Mail.app, which is apparently retarded  
and vger is rejecting all the mail from it :)


Geoff Harrison
Chief Architect
The Hive
(617) 301-6200


--Apple-Mail-7-1003492404
Content-Transfer-Encoding: 7bit
Content-Type: application/octet-stream;
	x-unix-mode=0644;
	name=ldirector.patch
Content-Disposition: attachment;
	filename=ldirector.patch

--- ldirectord.in	2008-01-07 10:51:07.000000000 -0500
+++ ldirectord.in.new	2008-01-16 10:45:39.000000000 -0500
@@ -2803,44 +2803,24 @@
 		goto err_finish;
 	}
 
-	# After calling "execute" $sth->{NUM_OF_FIELDS} will be greater
-	# than zero for SELECT statements, and 0 for all other statements.
-	#
-	# For non-SELECT statements a non-undef value returned by
-	# "execcute" inticates the number of rows returned.  "0E0" (Some
-	# garbage to make 0 true) or > 1.  But testing for this isn't
-	# particularly interesting as its quite valid for operations to
-	# affect 0 rows. So for non-SELECT statements, if "execute"
-	# doesn't return undef, consider the test a success.
-	unless ($sth->{NUM_OF_FIELDS}) {
-		goto out;
+	# On error "execute" will return undef.
+	# Assuming you're using 'SELECT' you will get the number of rows returned from the db when running execute:
+	# the 'rows' method is only used when doing something that is NOT a select.  I cannot imagine that
+	# you would ever want to insert or update from a regular polling on this system, so we will assume you
+	# are using SELECT here.  Ideally you will do something like this:
+	# 'select * from director_slave where enabled=1'
+	# This way you can have, say, a MEMORY table in MySQL where you insert a value into a row (enabled) that says
+	# whether or not you want to actually use this in the pool from ldirector / ipvs, and disable them without
+	# actually turning off your sql server.
+	unless ($rows = $sth->execute) {
+		check_sql_log_errstr("Error executing statement:", $dbh->errstr, $dbh->err);
+		goto err_finish;
 	}
 
-	# For SELECT staements "execute" will always return a true
-	# value unless an error occurs. A "fetch" operation is performed
-	# to obtain the row returned by the SELECT statement. Again 0
-	# rows is valid.
-	#
-	# I suspect that for at leaast some DB engines "execute" will
-	# always succeed unless there is some bizzare internal error.
-	# So it seems that in order to have a reasonable test "fetch"
-	# needs to be called.
-	#
-	# I also wonder if having a table missing
-	# will result in an error or just 0 rows returned. If the
-	# latter is true then I guess we need to consider 0 rows an
-	# error state. But I'll have the code consider 0 rows a success
-	# for now leave this to be changed if testing proves it neccessary.
-
-	# As it is important that the SELECT succeeded, rather than
-	# how may rows it returns, just call "fetchrow_arrayref" once.
-	#
-	# I guess that in a pathalogical case the query may fail
-	# at a particular row. But I'm not going to worry about that for
-	# now.
-	$row = $sth->fetchrow_arrayref;
-	unless ($row && !$sth->err) {
-		check_sql_log_errstr("Error fetching row:", $dbh->errstr);
+	# Actually look to see if there was data returned in this statement, else disable node
+	if($rows > 0) {
+		goto out;
+	} else {
 		goto err_finish;
 	}
 

--Apple-Mail-7-1003492404--
