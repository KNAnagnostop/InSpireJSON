#!/usr/bin/perl
# -------------------------------------------------------------------
# A Perl script to create a publication list, using the iNSPIRE API metadta. See https://github.com/inspirehep/rest-api-doc
# -------------------------------------------------------------------
# Install JSON: cpan -i JSON JSON::Parse       Documentation: https://metacpan.org/pod/JSON , https://metacpan.org/dist/JSON-Parse/view/lib/JSON/Parse.pod
# -------------------------------------------------------------------
use JSON;use JSON::Parse 'read_json';use Data::Dumper;use utf8::all;
# -------------------------------------------------------------------
# Personal data:
$myfname   = "Konstantinos";
$mylname   = "Anagnostopoulos";
$myBAI     = "K.N.Anagnostopoulos.1";    # InSpire BAI
# -------------------------------------------------------------------
# Preferences:
$fulllatex        = 1;                   # 0: Write only a series of \item to be included in another file   1: Write a full LaTeX file, see functions writeLaTeX()
$includeabstract  = 1;                   # 0: a list of publication with no abstract                        1: a list of publications and abstracts
$includecitations = 1;                   # 0: does nor print citation count                                 1: prints citation cound            
# -------------------------------------------------------------------
# Filenames:
$ftex      = "publist-${mylname}.tex";
$fjson     = "InSpire-${mylname}.json";  # Publication list metadata in JSON format
$fibib     = "InSpire-${mylname}.bib";   # Publication list BibTeX entries to use elsewhere
$fperl     = "InSpire-${mylname}.pdat";  # Publication list metadata dump of perl hash (up to a certain level, see also ${fperl}.all for the full dump)
$flog      = "InSpire-${mylname}.log";   # Log file, with extracted information
# -------------------------------------------------------------------
#
#
$urlpub    = "https://inspirehep.net/api/literature?sort=mostrecent&size=200&q=a%20${myBAI}";
$latex     = "";                         # A string containing data in LaTeX form to be printed in file


if( ! -e $fjson){
 system("wget \"$urlpub\" -o /tmp/publist.log -O $fjson") && die "You must download the JSON data using the link (copy/paste it to your browser):\n$urlpub";
}

$t = read_json ($fjson) || die "red_json: Failed to read data";   # $t is the reference to the Perl hash with the JSON data

open  LOG,">", $flog;
print LOG "-------------------------------------------------------------------------\n";
$npubs   = ${$t}{hits}{total};
print LOG "Number of publications: $npubs\n";
 for( my $n=0; $n < $npubs; $n++){
  $npub     = $n+1;
  $id       = ${$t}{hits}{hits}[$n]{id};
  $clink    = ${$t}{hits}{hits}[$n]{links}{citations};
  $blink    = ${$t}{hits}{hits}[$n]{links}{bibtex};

  $bibid    = ${$t}{hits}{hits}[$n]{metadata}{texkeys}  [0];
  $doi      = ${$t}{hits}{hits}[$n]{metadata}{dois}     [0]{value};                           if( ! $doi  ){$doi   = "NoDOI";}
  $title    = ${$t}{hits}{hits}[$n]{metadata}{titles}   [0]{title};
  $abstract = ${$t}{hits}{hits}[$n]{metadata}{abstracts}[0]{value};
  $cites    = ${$t}{hits}{hits}[$n]{metadata}{citation_count};
  $ccites   = ${$t}{hits}{hits}[$n]{metadata}{citation_count_without_self_citations};
  $nauth    = ${$t}{hits}{hits}[$n]{metadata}{author_count};
  $npages   = ${$t}{hits}{hits}[$n]{metadata}{number_of_pages};
  $arxiv    = ${$t}{hits}{hits}[$n]{metadata}{arxiv_eprints}   [0]{value};                    if( ! $arxiv){$arxiv = "NoArXiv";}
  $journal  = ${$t}{hits}{hits}[$n]{metadata}{publication_info}[0]{journal_title};
  $jvol     = ${$t}{hits}{hits}[$n]{metadata}{publication_info}[0]{journal_volume};
  $jyear    = ${$t}{hits}{hits}[$n]{metadata}{publication_info}[0]{year};
  $jpage    = ${$t}{hits}{hits}[$n]{metadata}{publication_info}[0]{artid}; # same as: page_start (if it exists), prefer artid
  $authorsb = ""; for( my $nn = 0; $nn < $nauth-1; $nn++){$authorsb .= ${$t}{hits}{hits}[$n]{metadata}{authors}[$nn     ]{full_name}." and ";}; # BibTeX style
                                                          $authorsb .= ${$t}{hits}{hits}[$n]{metadata}{authors}[$nauth-1]{full_name};
  $authors  = ""; for( my $nn = 0; $nn < $nauth-1; $nn++){$authors  .= ${$t}{hits}{hits}[$n]{metadata}{authors}[$nn     ]{first_name}." ".${$t}{hits}{hits}[$n]{metadata}{authors}[$nn     ]{last_name}.", ";} 
                                                          $authors  .= ${$t}{hits}{hits}[$n]{metadata}{authors}[$nauth-1]{first_name}." ".${$t}{hits}{hits}[$n]{metadata}{authors}[$nauth-1]{last_name};
  @myrecids = (); for( my $nn = 0; $nn < $nauth  ; $nn++){@myrecids = (@myrecids,${$t}{hits}{hits}[$n]{metadata}{authors}[$nn]{recid})};
 #For authors, see also:    first_name, last_name, full_name, recid 

  print LOG "-------------------------------------------------------------------------\n";
  print LOG "NewRecord        : $npub : $arxiv :  $id : $bibid : DOI: $doi : Citations: $cites ($ccites) : Pages: $npages\n";
  if($journal){
  print LOG "Published in     : $journal $jvol ($jyear) $jpage\n";
  }
  print LOG "Title            : $title\n";
  print LOG "Authors          : $nauth : $authors\n"; 
  print LOG "Authors (BibTex) : $nauth : $authorsb\n"; 
  print LOG "Authors recids   : $nauth : @myrecids\n"; 
  print LOG "Cited            : $cites : $ccites\n";
  print LOG "Citations Link   : $clink\n";
  print LOG "BibTeX    link   : $blink\n";
  print LOG "Abstract         : $abstract\n";

  #Write LaTeX string:
  $urldoi    = "https://www.doi.org/$doi";
  $urlarxiv  = "https://arxiv.org/abs/$arxiv";
  $pubstring = "";
  if($journal){
   if($doi   ne  "NoDOI"  ){$pubstring .= ", \\href{$urldoi}{$journal {\\bf $jvol} ($jyear) $jpage}";}
   else                    {$pubstring .=                 ", $journal {\\bf $jvol} ($jyear) $jpage" ;}
   if($arxiv ne  "NoArXiv"){$pubstring .= " \\href{$urlarxiv}{[arXiv:$arxiv]}"                      ;}
  }else{ # only preprint number
   if($arxiv ne  "NoArXiv"){$pubstring .= ", \\href{$urlarxiv}{arXiv:$arxiv}"                       ;}
  }
  ($latexdoi = $doi) =~ s/\_/\\\_/g;
  if( $doi   ne  "NoDOI"  ){$pubstring .=  ", \\href{$urldoi}{[doi:$latexdoi]}"                     ;}

  $latex .= "%-------------------------------------------------------------------------\n";
  $latex .= "% NewRecord: ${npub}. $arxiv $bibid SlacID: $id DOI: $doi Citations:  $cites ( $ccites ) Pages: $npages\n";
  $latex .= "\\item $authors, {\\it ``$title''}${pubstring}.\n";
  if($includecitations && $cites > 0){
  ($latexclink = $clink) =~ s{api\/}{};
  $latex .= "\\\\\\href{$latexclink}{Cited by $cites ($ccites)} articles\n";
  }
# Abstracts are not well formed: they contain math notation that is not around \ensuremath{} backets
# Use $abstract instead of $latexabstract if you wish to manually correct the LaTeX errors that arise because of that.
  if($includeabstract ){ 
  ($latexabstract = $abstract) =~ s/[\_\^\$\\]//g; 
  $latex .= "\n$latexabstract\n";
  }
# $latex .= "\n";

 } # for( my $n=0; $n < $npubs; $n++)

close LOG;

dumpData  (); # You can inspect the data structure of the has referenced by $t in the files $fperl and ${fperl}.all
writeLaTeX(); # Write info in LaTeX form


#----------------------------------------------------------
sub dumpData {

 $dumpfile =  ${fperl}.".all";
 if( ! -e $dumpfile){
  open  DD, ">", $dumpfile;
  print DD  Dumper($t);
  close DD;
 }
 #Make a shallower dump (you can change $Data::Dumper::Maxdepth to any depth you like)
 #local $Data::Dumper::Purity = 1;
 $Data::Dumper::Indent   = 3; 
 $Data::Dumper::Deepcopy = 1;       # avoid cross-refs
 $Data::Dumper::Maxdepth = 8;       # no deeper than 8 refs down

 $dumpfile =  ${fperl};
 if( ! -e $dumpfile){
  open DD, ">",  $dumpfile;
  print DD  Dumper($t);
  close DD;
 }
    
}
#----------------------------------------------------------
# Write LaTeX code to file. 
# If $fulllatex = 0: Write only a series of \item to be included in another filem and if = 1 write a full LaTeX file.
# $latex is the string with all the \item
sub writeLaTeX{

 open  TEX, ">", $ftex;

 if($fulllatex){ # because of single quotes, characters are literals, and variables are not expandin
  print TEX << 'EOF'
\documentclass[a4paper,10pt]{article} 
\usepackage{amssymb} \usepackage{amsfonts}\usepackage{amsmath}
\usepackage{fontspec}\usepackage{xunicode}\usepackage{xltxtra}
\usepackage{hyperref}
\usepackage [a4paper, total={6.5in, 10in}]{geometry}  % Increase width of text https://www.sharelatex.com/learn/Page_size_and_margins
\setmainfont[Mapping=tex-text]{GFS Didot}
EOF
;
  print TEX << "EOF"
\\hypersetup{pdftitle={Publications of $myfname $mylname}, colorlinks=true,linkcolor=blue,filecolor=magenta,citecolor = blue,anchorcolor = blue, urlcolor=blue, bookmarks=true}
\\begin{document}
\\begin{center}
{\\Large\\bf $myfname $mylname}\\\\
{\\large\\bf List of Publications}
\\end  {center}
\\begin{enumerate}
EOF
;
 }
 print TEX $latex;

 if($fulllatex){
  print TEX << 'EOF'
\end{enumerate}
\end{document}
EOF
 }
 close TEX;

}
#----------------------------------------------------------

# !  #####################################################################
# !  ---------------------------------------------------------------------
# !  Copyright by Konstantinos N. Anagnostopoulos (2023)
# !  Physics Dept., National Technical University,
# !  konstant@mail.ntua.gr, www.physics.ntua.gr/konstant
# !  
# !  This program is free software: you can redistribute it and/or modify
# !  it under the terms of the GNU General Public License as published by
# !  the Free Software Foundation, version 3 of the License.
# !  
# !  This program is distributed in the hope that it will be useful, but
# !  WITHOUT ANY WARRANTY; without even the implied warranty of
# !  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# !  General Public License for more details.
# !  
# !  You should have received a copy of the GNU General Public Liense along
# !  with this program.  If not, see <http://www.gnu.org/licenses/>.
# !  ---------------------------------------------------------------------
# !  #####################################################################
