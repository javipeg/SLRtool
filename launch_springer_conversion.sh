

for a in ./springer/*.csv
do
	ruby SPLExtractor.rb $a $a.bib
done

