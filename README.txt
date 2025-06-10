
Eksempel på opsætning af en gem executable. Den er skabt ved først at køre

  mkgem -x sensible

(-x laver en executable gem)

Derefter skal alle eksterne ikke-standard libraries, du bruger, erklæres i
sensible.gemspec filen. I dette tilfælde bruger vi shellopts, så du skal tilføje flg. til sensible.gemspec:

  spec.add_dependency "shellopts"

(du _kunne_ tilføje et versionsnummer, men det er jeg tit for doven til)

Når du har rettet i sensible.gemspec, skal du opdatere din installation med

  bundle

Den sørger for at alle pakker er på plads. Derefter kan du køre dit script med 

  bundle exec exe/sensible andre-options-men-dem-har-vi-ikke-endnu


I dette katalog, har jeg lavet starten på exe/sensible og lib/sensible.rb. Du kan f.eks køre

  bundle exec exe/sensible --help

for at se, hvad der er til rådighed

Her er et eksempel på en kommando:

  bundle exec exe/sensible task gryf


  
