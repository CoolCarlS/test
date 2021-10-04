 #!/usr/bin/perl
use File::Copy;
    #use strict;
    #use warnings;

    $dir = 'C:\Documents and Settings\cn136.ECRMC\My Documents\el-centro\mmodel\txt_files';
    #$dir = 'C:\\Documents and Settings\\cn136.ECRMC\\My Documents\\el-centro\mmodel\\txt_files\\';
    #$dir = 'C:\MModalSignedDocs';

    # $dir = 'C:\Perl\Bin';

    opendir(DIR, $dir) or die $!;
      $cnt=0;
      while ($file = readdir(DIR)) {
   


        # Use a regular expression to ignore files beginning with a period
        
        if($file =~ m/txt/) {
           
            @mylist1;
            push(@mylist1,$file);
       $cnt++;

       } else {
}

 }

    closedir(DIR);


#---------------------------------------------------------------------
  # for ($a=0;$a<=3;$a++) { # loop through files
    for ($a=0;$a<=$cnt-1;$a++) {
 


 
#--- clear header for next file run ------------
$pname = "";
$drname_one = "";
$dob ="";
$dr_flag=0;

$inFile = $mylist1[$a];
printf "$inFile\n";


#--inFile path---------------
$inFileRead = "C:\\Documents and Settings\\cn136.ECRMC\\My Documents\\el-centro\mmodel\\txt_files\\";
$inFileRead .= $inFile;


#-----Set up extension for logs----------------------------------------------------------------------------
use Time::localtime; 
$year = localtime->year(); 
$month = localtime->mon(); 
$day=localtime->mday(); 
$hour=localtime->hour(); 
$min=localtime->min(); 
$sec=localtime->sec();
$month++; # Increment the month by 1
$year = $year + 1900; # Add 1900 to the year; 
$cnow = sprintf ("%04d%02d%02d%02d%02d",$year,$month,$day,$hour,$min);  

$outlog = "Processed: " . $inFile. " @ " . $cnow . "\n";
$log = "C:\\Documents and Settings\\cn136.ECRMC\\My Documents\\el-centro\mmodel\\txt_files\\";
$log .= "log.data";
 open(HIST, ">> $log") ; #|| die "cannot write $file in ",__FILE__," line ",__LINE__, "\n";
    print HIST $outlog;
    close(HIST);

#--outfile path---------------
$outFile = "C:\\Documents and Settings\\cn136.ECRMC\\My Documents\\el-centro\mmodel\\txt_files\\";
$outFile .= $inFile . ".hl7";

$seq = "";
$i=0;
my @tokenz = split('_',$mylist1[$a]); # one line
$mr_save = $tokenz[0];
$acct_num = $tokenz[1];
$drcode = $tokenz[2];
$worktype = $tokenz[3];
$datework = $tokenz[4];

($dateconsult, $junk1,$junk2) = split(/\./, $datework);

$count=0;

#$printf "$inFile\n";

open(INFILE, $inFileRead);
open(OUTFILE, ">$outFile");


while($line = <INFILE>){

$line =~ s/[\x0C]//g;
 
$count=$count+1;
    chomp $line;
     @tokens = split(' ',$line); # one line
#printf "$line\n";
#printf "$worktype\n";
 

#----------Dig out header info of non 88 or 8------------------------------------------------
 if ($worktype ne  "88" &&  $worktype ne  "8"  ){

if ($line =~ "Patient Name:")
{       
    if($tokens[3] =~ m/(,)/)   { 
          # special case
        $pname = sprintf($tokens[2] ." ". $tokens[3] ."^". $tokens[4] );
        $pname =~ s/,//;

    } else {
        # regular name
      $pname = sprintf($tokens[2] ."^". $tokens[3] );
        $pname =~ s/,//;
      #  printf "$pname\n";
     }
}
if ($line =~ "Physician:")
{
	
        $drname_one = sprintf($tokens[3] ."^". $tokens[1] ."^". $tokens[2] );
        $drname_one =~ s/\.//;
        $drname_one =~ s/,//;
       # printf "$drname_one\n";
}
if ($line =~ "DOB:")
{

if ( $tokens[3] == "DOB:") {
        $dob = sprintf($tokens[4] );
        ($mo, $da, $yr) = split(/\//, $dob);
        $dob = $yr . $mo . $da;
       # printf "$dob\n";
} else {
	$dob = sprintf($tokens[3] );
        ($mo, $da, $yr) = split(/\//, $dob);
        $dob = $yr . $mo . $da;
       # printf "$dob\n";

}
} # dob

} # ne 88 --------------

#---end if not 88 or 8---------------------------------

 else {
 
#--if 88 or 8 worktype ----------------------------

 if ($line =~ "RE:")
     {       

     if ($tokens[0] eq "RE:") {

     if($tokens[2] =~ m/(,)/)   { 
          # special case
        $pname = sprintf($tokens[1] ." ". $tokens[2] ."^". $tokens[3] );
        $pname =~ s/,//;

    } else {
        $pname = sprintf($tokens[1] ."^". $tokens[2] );
        $pname =~ s/,//;
        printf "$pname\n";
       }

}
if ($tokens[1] eq "RE:") {
        $pname = sprintf($tokens[2] ."^". $tokens[2] );
        $pname =~ s/,//;
        printf "$pname\n";
       }



      }


#--get DOB-----------------------------


     if ($line =~ "DOB:")
     {       
       
       if ($tokens[0] eq "DOB:") {
          $dob = sprintf($tokens[1] );
         ($mo, $da, $yr) = split(/\//, $dob);
         $dob = $yr . $mo . $da;
          #printf "$dob\n"; 
        }
     if ($tokens[1] eq "DOB:") {
          $dob = sprintf($tokens[2] );
         ($mo, $da, $yr) = split(/\//, $dob);
         $dob = $yr . $mo . $da;
         # printf "$dob\n";
        }
 if ($tokens[2] eq "DOB:") {
          $dob = sprintf($tokens[3] );
         ($mo, $da, $yr) = split(/\//, $dob);
         $dob = $yr . $mo . $da;
         # printf "$dob\n";
        }

      }
}
    
  




#----Text section to OBX--------------------------------------------------------------  

if($count>6) {
$i++;
 # print "OBX|" . $i . "|TX|" .$worktype . "||||||F" . $line ."\n";
  $seq .= sprintf("OBX|" . $i . "|TX|". $worktype . "||" . $line . "||||||F|\n" );
  #$seq =~ s/ //;



#--get Dr from text line----------------
if ($line =~ ", MD" && $dr_flag == 0) {       
   if ($line =~ ":") { 
      #no nothing
    } else {     
     $drname_one = $line;
     $drname_one = sprintf($tokens[1] ."^". $tokens[0]  );
     $drname_one =~ s/\.//;
     $drname_one =~ s/,//;
     $drname_one =~ s/MD//;
     $dr_flag=1;
     #printf "$tokens[1] . $tokens[0]\n";
   }
   

}









}   

$line =~ s/\r$//;
    
#  printf "$count\n";

    
} # end line loop



$head = "";
 $head .= sprintf("MSH|^~\&|TST|TST|||20120724170709||MDM^T08|18143295|P|2.3\n" );
 $head .= sprintf("EVN|T08|20120724170709\n" );
 $head .= sprintf("PID||" . $mr_save . "|".$mr_save . "||" . $pname  ."||". $dob . "|U||||||||||" . $acct_num.  "|\n" );
 $head .= sprintf("PV1||||||||||||||||||||||||||||||||||||||||||||". $dateconsult . "|\n" );
 $head .= sprintf("TXA||". $worktype . "|||57553218|20120723181258|20120724105500||" . $drcode . "^" . $drname_one . 

"^MD||TST|18143295|||||F|\n" );

if ($seq ne "") {
 print OUTFILE "$head$seq\n";
} 




close(OUTFILE);
close(INFILE);

#--delete source txt file --------------------------------

$del_files = "C:\\Documents and Settings\\cn136.ECRMC\\My Documents\\el-centro\mmodel\\txt_files\\" . $inFile;
printf "$del_files\n"; 
unlink("$del_files");


} # end for

