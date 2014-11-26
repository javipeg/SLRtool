

for a in ./dblp/*.xml
do
	ruby DBLPExtractor.rb $a $a.bib
done

