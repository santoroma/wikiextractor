#launch the extractor
#dump 17 febbraio 2020
system2("sh","../extract.sh ../data/itwiki-latest-pages-articles.xml.bz2 5 ../Template_File ../Extraction")
system2("find","../Extraction -name '*bz2' -exec bzip2 -c {} \; > ../data/Dump_Text.xml")



system2("find","../test -name '*bz2' -exec bzip2 -dc {} \; > ../test/Dump_Text.xml")
