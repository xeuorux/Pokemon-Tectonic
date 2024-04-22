git diff --name-only main > patched_files.txt
java -jar "Tectonic Builder.jar" /z "patched_files.txt" "" "true"