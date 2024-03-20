git diff --name-only main > patched_files.txt
java -jar "Chasm Launcher.jar" /z "patched_files.txt" "" "true"